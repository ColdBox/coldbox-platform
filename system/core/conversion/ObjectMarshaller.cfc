<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	Ability to serialize/deserialize data.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="Ability to serialize/deserialize objects.">

	<cffunction name="init" output="false" access="public" returntype="ObjectMarshaller" hint="Constructor">
    	<cfscript>
			var engine = "";
			var version = "";
			var CFMLEngine = createObject("component","coldbox.system.core.cf.CFMLEngine").init();
			
			engine  = CFMLEngine.getEngine();
			version = CFMLEngine.getVersion();
			
			// Algorithm detection
			instance.algorithm = "generic";
			if( engine eq CFMLEngine.RAILO ){ instance.algorithm = "railo"; }
			if( engine eq CFMLEngine.ADOBE and version GTE 9 ){ instance.algorithm = "objectSave"; }
			
			return this;
    	</cfscript>
    </cffunction>
	
	<cffunction name="serializeObject" output="false" access="public" returntype="any" hint="Serialize an object and optionally save it into a file.">
		<cfargument name="target"   type="any" 		required="true" 	hint="The complex object, such as a query or CFC, that will be serialized."/>
	   	<cfargument name="filePath" type="string" 	required="false" 	hint="The path of the file in which to save the serialized data."/>
		<cfscript>
			var binaryData = "";
			
			// Which algorithm to use?
			switch(instance.algorithm){
				case "generic" : {
					binaryData = serializeGeneric(arguments.target);
					break;
				}
				case "railo" : {
					binaryData = serializeRailo(arguments.target);
					break;
				}
				case "objectSave" : {
					binaryData = serializeWithObjectSave(arguments.target);
					break;
				}
			}
			
			// Save to File?
			if( structKeyExists(arguments,"filePath") ){
				saveToFile(arguments.filePath,binaryData);
			}
			
			return binaryData;
		</cfscript>
	</cffunction>
	
	<!--- deserializeObject --->
	<cffunction name="deserializeObject" output="false" access="public" returntype="any" hint="Deserialize an object using a binary object or a filepath">
		<cfargument name="binaryObject" type="any" 		required="false" hint="The binary object to inflate"/>
		<cfargument name="filepath" 	type="string" 	required="false" hint="The location of the file that has the binary object to inflate"/>
		<cfscript>
			var obj = "";
			
			// Read From File?
			if( structKeyExists(arguments,"filePath") ){
				arguments.binaryObject = readFile(arguments.filePath);
			}
			
			// Which algorithm to use?
			switch(instance.algorithm){
				case "generic" : {
					obj = deserializeGeneric(arguments.binaryObject);
					break;
				}
				case "railo" : {
					obj = deserializeRailo(arguments.binaryObject);
					break;
				}
				case "objectSave" : {
					obj = deserializeWithObjectLoad(arguments.binaryObject);
					break;
				}
			}
			
			return obj;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>
    
	<!--- serializeRailo --->
	<cffunction name="serializeRailo" output="false" access="public" returntype="any" hint="Serialize the railo way">
		<cfargument name="target"   type="any" 		required="true" 	hint="The complex object, such as a query or CFC, that will be serialized."/>
	   	<cfreturn serialize(arguments.target)>
	</cffunction>
	
	<!--- deserializeRailo --->
	<cffunction name="deserializeRailo" output="false" access="public" returntype="any" hint="Deserialize the railo way">
		<cfargument name="binaryObject" type="any" 		required="false" hint="The binary object to inflate"/>
		<cfreturn evaluate(arguments.binaryObject)>
	</cffunction>
	
	<!--- serializeWithObjectLoad --->
	<cffunction name="serializeWithObjectSave" output="false" access="public" returntype="any" hint="Serialize using new object save method">
		<cfargument name="target"   type="any" 		required="true" 	hint="The complex object, such as a query or CFC, that will be serialized."/>
	   	<cfreturn toBase64(objectSave(arguments.target))>
	</cffunction>
	
	<!--- deserializeWithObjectLoad --->
	<cffunction name="deserializeWithObjectLoad" output="false" access="public" returntype="any" hint="deserialize using the new object load method">
		<cfargument name="binaryObject" type="any" 		required="false" hint="The binary object to inflate"/>
		<cfscript>
			// check if string
			if( not isBinary(arguments.binaryObject) ){ arguments.binaryObject = toBinary(arguments.binaryObject); }
			
			return objectLoad(arguments.binaryObject);
		</cfscript>
	</cffunction>
	
	<!--- serializeGeneric --->
	<cffunction name="serializeGeneric" output="false" access="public" returntype="any" hint="Serialize generic way">
		<cfargument name="target"   type="any" 		required="true" 	hint="The complex object, such as a query or CFC, that will be serialized."/>
	   	<cfscript>
			var ByteArrayOutput = CreateObject("java", "java.io.ByteArrayOutputStream").init();
            var ObjectOutput    = CreateObject("java", "java.io.ObjectOutputStream").init(ByteArrayOutput);
           
            // Serialize the incoming object.
            ObjectOutput.writeObject(arguments.target);
            ObjectOutput.close();

            return toBase64(ByteArrayOutput.toByteArray());
		</cfscript>
	</cffunction>
	
	<!--- deserializeGeneric --->
	<cffunction name="deserializeGeneric" output="false" access="public" returntype="any" hint="deserialize generic way">
		<cfargument name="binaryObject" type="any" 		required="false" hint="The binary object to inflate"/>
		<cfscript>
			var ByteArrayInput = CreateObject("java", "java.io.ByteArrayInputStream").init(toBinary(arguments.binaryObject));
    		var ObjectInput    = CreateObject("java", "java.io.ObjectInputStream").init(ByteArrayInput);
	        var obj = "";
	           
           	obj = ObjectInput.readObject();
            objectInput.close();
            
            return obj;
		</cfscript>
	</cffunction>	

	<!--- Save To File --->
	<cffunction name="saveToFile" access="private" hint="Facade to save a file's content" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="fileToSave"	 	type="any"  	required="yes" 	 hint="The absolute path to the file.">
		<cfargument name="fileContents" 	type="any"  	required="yes"   hint="The file contents">
		<cfargument name="charSet"			type="string"   required="false" default="utf-8" hint="CF File CharSet Encoding to use.">
		<!--- ************************************************************* --->
		<cffile action="write" file="#arguments.fileToSave#" output="#arguments.fileContents#" charset="#arguments.charset#">
	</cffunction>
	
	<!--- Read File --->
	<cffunction name="readFile" access="private" hint="Facade to Read a file's content" returntype="Any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="fileToRead"	 		type="String"  required="yes" 	 hint="The absolute path to the file.">
		<!--- ************************************************************* --->
		<cfset var fileContents = "">
		<cffile action="read" file="#arguments.fileToRead#" variable="fileContents">
		<cfreturn fileContents>
	</cffunction>

</cfcomponent>