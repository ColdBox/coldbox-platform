<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 		: Luis Majano
Date     		: April 20, 2009
Description		: 
	A mock generator
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The guy in charge of creating mocks">

	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="MockGenerator" hint="Constructor">
		<cfargument name="mockBox" type="coldbox.system.testing.MockBox" required="true"/>
		<cfscript>
			instance.mockBox = arguments.mockBox;
			return this;
		</cfscript>
	</cffunction>
	
	<!--- generate --->
	<cffunction name="generate" output="false" access="public" returntype="string" hint="Generate a mock method and return the generated path">
		<!--- ************************************************************* --->
		<cfargument name="method" 			type="string" 	required="true" hint="The method you want to mock or spy on"/>
		<cfargument name="returns" 			type="any" 		required="false" hint="The results it must return, if not passed it returns void or you will have to do the mockResults() chain"/>
		<cfargument name="preserveReturnType" type="boolean" required="true" default="true" hint="If false, the mock will make the returntype of the method equal to ANY"/>
		<cfargument name="throwException" type="boolean" 	required="false" default="false" hint="If you want the method call to throw an exception"/>
		<cfargument name="throwType" 	  type="string" 	required="false" default="" hint="The type of the exception to throw"/>
		<cfargument name="throwDetail" 	  type="string" 	required="false" default="" hint="The detail of the exception to throw"/>
		<cfargument name="throwMessage"	  type="string" 	required="false" default="" hint="The message of the exception to throw"/>
		<cfargument name="metadata" 	  type="any" 		required="true" default="" hint="The function metadata"/>
		<cfargument name="targetObject"	  type="any" 		required="true" hint="The target object to mix in"/>
		<cfargument name="callLogging" 	  type="boolean" 	required="false" default="false" hint="Will add the machinery to also log the incoming arguments to each subsequent calls to this method"/>
		<!--- ************************************************************* --->
		<cfscript>
			var udfOut = CreateObject("java","java.lang.StringBuffer").init('');
			var genPath = ExpandPath(getMockBox().getGenerationPath());
			var tmpFile = createUUID() & ".cfm";
			var lb = "#chr(13)##chr(10)#";
			var fncMD = arguments.metadata;
			
			// Create Method Signature
			udfOut.append('
			<cfset this["#arguments.method#"] = #arguments.method#>
			<cfset variables["#arguments.method#"] = #arguments.method#>
			<cffunction name="#arguments.method#" access="#fncMD.access#" output="#fncMD.output#" returntype="#fncMD.returntype#">
			<cfset var results = this._mockResults>
			<cfset var resultsKey = "#arguments.method#">
			<cfset var resultsCounter = 0>
			<cfset var internalCounter = 0>
			<cfset var resultsLen = 0>
			<cfset var argsHashKey = resultsKey & "|" & this.mockBox.normalizeArguments(arguments)>
			
			<!--- If Method & argument Hash Results, switch the results struct --->
			<cfif structKeyExists(this._mockArgResults,argsHashKey)>
				<cfset results = this._mockArgResults>
				<cfset resultsKey = argsHashKey>
			</cfif>
			
			<!--- Get the statemachine counter --->
			<cfset resultsLen = arrayLen(results[resultsKey])>
			
			<!--- Log the Method Call --->
			<cfset this._mockMethodCallCounters[listFirst(resultsKey,"|")] = this._mockMethodCallCounters[listFirst(resultsKey,"|")] + 1>
			
			<!--- Get the CallCounter Reference --->
			<cfset internalCounter = this._mockMethodCallCounters[listFirst(resultsKey,"|")]>
			');
			
			// Call Logging argument or Global Flag
			if( arguments.callLogging OR arguments.targetObject._mockCallLoggingActive  ){
				udfOut.append('<cfset arrayAppend(this._mockCallLoggers["#arguments.method#"], arguments)>#lb#');
			}
			
			// Exceptions? To Throw
			if( arguments.throwException ){
				udfOut.append('<cfthrow type="#arguments.throwType#" message="#arguments.throwMessage#" detail="#arguments.throwDetail#" />#lb#');
			}			
			// Returns Something according to metadata?
			if ( fncMD["returntype"] neq "void" ){
				/* Results Recyling Code, basically, state machine code */
				udfOut.append('
				<cfif resultsLen neq 0>
					<cfif internalCounter gt resultsLen>
						<cfset resultsCounter = internalCounter - ( resultsLen*fix( (internalCounter-1)/resultsLen ) )>
						<cfreturn results[resultsKey][resultsCounter]>
					<cfelse>
						<cfreturn results[resultsKey][internalCounter]>
					</cfif>
				</cfif>
				');			
			}
			udfOut.append('</cffunction>');
			
			// Write it out
			writeStub(genPath & tmpFile, udfOUt.toString());
		
			// Mix In Stub
			try{
				arguments.targetObject.$include = variables.$include;
				arguments.targetObject.$include(getMockBox().getGenerationPath() & tmpFile);
				structDelete(arguments.targetObject,"$include");
				// Remove Stub	
				removeStub(genPath & tmpFile);				
			}
			catch(Any e){
				// Remove Stub
				removeStub(genPath & tmpFile);
			}			
		</cfscript>
	</cffunction>
	
	<!--- writeStub --->
	<cffunction name="writeStub" output="false" access="public" returntype="void" hint="Write a method generator stub">
		<cfargument name="genPath" 	type="string" required="true"/>
		<cfargument name="code" 	type="string" required="true"/>
		
		<cffile action="write" file="#arguments.genPath#" output="#arguments.code#">
		
	</cffunction>

	<!--- removeStub --->
	<cffunction name="removeStub" output="false" access="public" returntype="boolean" hint="Remove a method generator stub">
		<cfargument name="genPath" type="string" required="true"/>
		
		<cfif fileExists(arguments.genPath)>
			<cffile action="delete" file="#arguments.genPath#">
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- $include --->
	<cffunction name="$include" output="false" access="private" returntype="void" hint="Mix in a template">
		<cfargument name="templatePath" type="string" required="true"/>
		<cfinclude template="#arguments.templatePath#">
	</cffunction>
	
	<!--- Get Mock Box --->
	<cffunction name="getmockBox" access="private" returntype="coldbox.system.testing.MockBox" output="false">
		<cfreturn instance.mockBox>
	</cffunction>

</cfcomponent>