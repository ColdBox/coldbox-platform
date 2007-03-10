<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	October 10, 2006
Description :
	This is supposed to be an interface, when scorpio comes out, it will.
	For now it is an abstract class for installer implemnetations.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="Implementation" hint="A ColdBox installer implementation CFC.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="any">
		<!--- ************************************************************* --->
		<cfargument name="setupStruct"  			type="struct" 	 required="yes" hint="The setup structure">
		<cfargument name="implementationSettings" 	type="struct" 	 required="yes" hint="The implementation settings.">
		<cfscript>
		//Zip file Component
		variables.objZip = CreateObject("component","Zip");
		//Setup Structure
		variables.setupStruct = arguments.setupStruct;
		//Implementation Structure
		variables.implementationSettings = arguments.implementationSettings;
		//Error Properties
		variables.errorMessage = "";
		variables.abortInstall = false;
		//Return
		return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="start" hint="Start the installation implementation" access="public" output="false" returntype="Any">
		<cfthrow detail="Abstract method. You should implement this.">
		<cfabort>
	</cffunction>
	
	<cffunction name="geterrorMessage" access="public" output="false" returntype="string" hint="Get errorMessage">
		<cfreturn variables.errorMessage/>
	</cffunction>
	
	<cffunction name="seterrorMessage" access="public" output="false" returntype="void" hint="Set errorMessage">
		<cfargument name="errorMessage" type="string" required="true"/>
		<cfset variables.errorMessage = arguments.errorMessage/>
	</cffunction>
	
	<cffunction name="getabortInstall" access="public" output="false" returntype="boolean" hint="Get abortInstall">
		<cfreturn variables.abortInstall/>
	</cffunction>
	
	<cffunction name="setabortInstall" access="public" output="false" returntype="void" hint="Set abortInstall">
		<cfargument name="abortInstall" type="boolean" required="true"/>
		<cfset variables.abortInstall = arguments.abortInstall/>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	
	<cffunction name="getFileSize" access="private" returntype="string" output="false" hint="Get the filesize of a file.">
		<!--- ************************************************************* --->
		<cfargument name="filename"   type="string" required="yes">
		<cfargument name="sizeFormat" type="string" required="no" default="bytes"
					hint="Available formats: [bytes][kbytes][mbytes][gbytes]">
		<!--- ************************************************************* --->
		<cfscript>
		var objFile =  createObject("java","java.io.File");
		objFile.init(JavaCast("string", filename));
		if ( arguments.sizeFormat eq "bytes" )
			return objFile.length();
		if ( arguments.sizeFormat eq "kbytes" )
			return (objFile.length()/1024);
		if ( arguments.sizeFormat eq "mbytes" )
			return (objFile.length()/(1048576));
		if ( arguments.sizeFormat eq "gbytes" )
			return (objFile.length()/1073741824);
		</cfscript>
	</cffunction>
	

</cfcomponent>