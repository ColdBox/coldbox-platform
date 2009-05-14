<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 		: Luis Majano
Date     		: April 20, 2009
Description		: 
	The Official ColdBox Mocking Factory
----------------------------------------------------------------------->
<cfcomponent name="MockFactory" output="false" hint="A unit testing mocking factory for ColdFusion 7 and above">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="MockFactory" hint="Constructor">
		<cfargument name="generationPath" type="string" required="false" default="" hint="The mocking generation relative path.  If not defined, then the factory will use its internal tmp path. Just make sure that this folder is accessible from an include."/>
		<cfscript>
			var tempDir =  "/coldbox/testing/tmp";
			
			/* Setup the generation Path */
			if( len(trim(arguments.generationPath)) neq 0 ){
				/* Default to java tmp path */
				instance.generationPath = arguments.generationPath;
			}
			else{
				instance.generationPath = tempDir;
			}
			
			/* version */
			instance.version = "1.0";
			
			/* Return Instance */
			return this;
		</cfscript>
	</cffunction>
	
	
<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<!--- Get/Set generation path --->
	<cffunction name="getgenerationPath" access="public" returntype="string" output="false" hint="Get the current generation path">
		<cfreturn instance.generationPath>
	</cffunction>
	<cffunction name="setgenerationPath" access="public" returntype="void" output="false" hint="Override the generation path">
		<cfargument name="generationPath" type="string" required="true">
		<cfset instance.generationPath = arguments.generationPath>
	</cffunction>
	
	<!--- Get/Set version --->
	<cffunction name="getversion" access="public" returntype="string" output="false" hint="Get the current mock factory version">
		<cfreturn instance.version>
	</cffunction>
	
	<!--- createMock --->
	<cffunction name="createMock" output="false" access="public" returntype="any" hint="Create a mock object or prepares an object to act as a mock">
		<!--- ************************************************************* --->
		<cfargument name="className"		type="string" 	required="false" hint="The class name of the object to mock. The mock factory will instantiate it for you"/>
		<cfargument name="object" 			type="any" 		required="false" hint="The object to mock, already instantiated"/>
		<cfargument name="clearMethods" 	type="boolean"  required="false" default="false" hint="If true, all methods in the target mock object will be removed. You can then mock only the methods that you want to mock"/>
		<!--- ************************************************************* --->
		<cfscript>
			var obj = 0;
			
			/* class to mock */
			if ( structKeyExists(arguments, "className") ){
				try{
					obj = createObject("component",arguments.className);
				}
				catch(Any e){	
					throw(type="mock.invalidCFC",message="The specified CFC #arguments.className# could not be created. Verify the CFC name and path being specified.");
				}
			}
			else if ( structKeyExists(arguments, "object") ){
				/* Object to Mock */
				obj = arguments.object;
			}
			else{
				throw(type="mock.invalidArguments",message="You need a className or an object argument.");
			}		
			
			/* Clear up Mock object? */
			if( arguments.clearMethods ){
				structClear(obj);
			}
			/* Mock Method Results Holder */
			obj._mockMethodResults = structnew();
			obj._mockMethodCallCounters = structnew();
			/* Mock Generation Path */
			obj._mockGenerationPath = getgenerationPath();
			/* Original Metadata */
			obj._mockOriginalMD = getMetadata(obj);
			/* Incoming Method Name */
			obj._mockCurrentMethodName = "";
			/* Utility Method Injections */
			obj.mockMethod = variables.mockMethod;
			obj.mockProperty = variables.mockProperty;
			obj.mockMethodCallCount = variables.mockMethodCallCount;
			obj.mockResults = variables.mockResults;
			
			/* Return mock obj */
			return obj;			
		</cfscript>
	</cffunction>	

	<!--- mockProperty --->
	<cffunction name="mockProperty" output="false" access="public" returntype="void" hint="Mock a property in the object.">
		<!--- ************************************************************* --->
		<cfargument name="propertyName" 	type="string" 	required="true" hint="The name of the property to mock"/>
		<cfargument name="propertyScope" 	type="string" 	required="false" default="variables" hint="The scope where the property lives in"/>
		<cfargument name="mockObject" 		type="any" 		required="true" hint="The object or data to inject"/>
		<!--- ************************************************************* --->
		<cfscript>
			"#arguments.propertyScope#.#arguments.propertyName#" = arguments.mockObject;
			return this;
		</cfscript>	
	</cffunction>	
	
	<!--- Tell how many times a method has been called. --->
	<cffunction name="mockMethodCallCount" output="false" returntype="numeric" hint="I return the number of times the specified mock method has been called.  If the mock method has not been defined the results is a -1">
		<cfargument name="methodName" type="string" hint="Name of the method" />
		<cfscript>
			if( structKeyExists(this._mockMethodCallCounters, arguments.methodName) ){
				return this._mockMethodCallCounters[arguments.methodName];
			}
			else{
				return -1;
			}
		</cfscript>
	</cffunction>
	
	<!--- mockResults --->
	<cffunction name="mockResults" output="false" access="public" returntype="void" hint="Use this method to mock more than 1 result as passed in arguments.  Can only be called when chained to a mockMethod() call.  Results will be recycled on a multiple of their lengths according to how many times they are called.">
		<cfif len(this._mockCurrentMethodName)>
			<!--- Save incoming arguments as results --->
			<cfset this._mockMethodResults[this._mockCurrentMethodName] = arguments>
			<!--- Cleanup the incoming call --->
			<cfset this._mockCurrentMethodName = "">
		<cfelse>
			<cfthrow type="MockFactory.IllegalStateException"
					 message="No current method name set"
					 detail="This method was probably called without chaining it to a mockMethod() call. Ex: obj.mockMethod().mockResults()">
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<!--- mockMethod --->
	<cffunction name="mockMethod" output="false" access="public" returntype="any" hint="Mock a Method, very simply, no fancy stuff">
		<!--- ************************************************************* --->
		<cfargument name="method" 	type="string" 	required="true" hint="The method you want to mock"/>
		<cfargument name="returns" 	type="any" 		required="false" hint="The results it must return, if not passed it returns void"/>
		<cfargument name="preserveReturnType" type="boolean" required="true" default="true" hint="If false, the mock will make the returntype of the method equal to ANY"/>
		<cfargument name="throwException" type="boolean" required="false" default="false" hint="If you want the method call to throw an exception"/>
		<cfargument name="throwType" 	  type="string" required="false" default="" hint="The type of the exception to throw"/>
		<cfargument name="throwDetail" 	  type="string" required="false" default="" hint="The detail of the exception to throw"/>
		<cfargument name="throwMessage"	  type="string" required="false" default="" hint="The message of the exception to throw"/>
		<!--- ************************************************************* --->
		<cfscript>
			var udfOut = CreateObject("java","java.lang.StringBuffer").init('');
			var genPath = ExpandPath(this._mockGenerationPath);
			var tmpFile = createUUID() & ".cfm";
			var lb = "#chr(13)##chr(10)#";
			var fncMD = structnew();
			
			/* Check if the method is existent in public scope */
			if ( structKeyExists(this,arguments.method) ){
				fncMD = getMetadata(this[arguments.method]);
			}
			/* Else check in private scope */
			else if( structKeyExists(variables,arguments.method) ){
				fncMD = getMetadata(variables[arguments.method]);				
			}
			
			/* Prepare Metadata Existence, works on virtual methods */
			if ( not structKeyExists(fncMD,"returntype") ){
				fncMD["returntype"] = "any";
			}
			if ( not structKeyExists(fncMD,"access") ){
				fncMD["access"] = "public";
			}
			if( not structKeyExists(fncMD,"output") ){
				fncMD["output"] = false;
			}
			
			/* Remove Method From Object */
			structDelete(this,arguments.method);
			structDelete(variables,arguments.method);
			
			/* Create Mock Call Counter */
			this._mockMethodCallCounters["#arguments.method#"] = 0;
			
			/* PReserve Return Type? */
			if( NOT arguments.preserveReturnType ){
				fncMD["returntype"] = "any";
			}
			
			/* Create Method On Appropriate Scope */
			if ( fncMD["access"] eq "public" ){
				udfOut.append('<cfset this["#arguments.method#"] = #arguments.method#>#lb#');
			}
			udfOut.append('<cfset variables["#arguments.method#"] = #arguments.method#>');
			/* Start Method */
			udfOut.append('<cffunction name="#arguments.method#" access="#fncMD.access#" output="#fncMD.output#" returntype="#fncMD.returntype#">#lb#');
			/* Method Call Counters */
			udfOut.append('<cfset var resultsCounter = 0>#lb#');	
			udfOut.append('<cfset var internalCounter = 0>#lb#');	
			udfOut.append('<cfset var resultsLen = arrayLen(this._mockMethodResults["#arguments.method#"])>#lb#');	
			/* Increase Counter */
			udfOut.append('<cfset this._mockMethodCallCounters["#arguments.method#"] = this._mockMethodCallCounters["#arguments.method#"] + 1>#lb#');
			/* Set Local Reference */
			udfOut.append('<cfset internalCounter = this._mockMethodCallCounters["#arguments.method#"]>#lb#');
			/* Exceptions? To Throw */
			if( arguments.throwException ){
				udfOut.append('<cfthrow type="#arguments.throwType#" message="#arguments.throwMessage#" detail="#arguments.throwDetail#" />#lb#');
			}			
			/* Returns Something? */
			if ( fncMD["returntype"] neq "void" ){
				/* Results Recyling Code, basically, the results recylce depending on the multiple of results and coutner calls */
				udfOut.append('<cfif internalCounter gt resultsLen>#lb#');
				udfOut.append('<cfset resultsCounter = internalCounter - ( resultsLen*fix( (internalCounter-1)/resultsLen ) )>#lb#');
				udfOut.append('<cfreturn this._mockMethodResults["#arguments.method#"][resultsCounter]>#lb#');
				udfOut.append('<cfelse>#lb#');
				udfOut.append('<cfreturn this._mockMethodResults["#arguments.method#"][internalCounter]>#lb#');
				udfOut.append('</cfif>#lb#');				
			}
			udfOut.append('</cffunction>');
		</cfscript>
		
		<!--- Write UDF --->
		<cffile action="write" file="#genPath##tmpFile#" output="#udfOut.toString()#">
		
		<cftry>
			<!--- Include it --->
			<cfinclude template="#this._mockGenerationPath##tmpFile#">
			<cfcatch type="Any">
				<!--- Remove it --->
				<cffile action="delete" file="#genPath##tmpFile#">
				<cfrethrow />
			</cfcatch>
		</cftry>
		
		<!--- Remove it --->
		<cffile action="delete" file="#genPath##tmpFile#">

		<!--- Save Returns --->
		<cfif structKeyExists(arguments,"returns")>
			<cfset this._mockMethodResults[arguments.method] = ArrayNew(1)>
			<cfset this._mockMethodResults[arguments.method][1] = arguments.returns>
		<cfelse>
			<cfset this._mockMethodResults[arguments.method] = ArrayNew(1)>
		</cfif>
		
		<!--- Incoming Method Name --->
		<cfset this._mockCurrentMethodName = arguments.method>
		
		<cfreturn this>
	</cffunction>	

<!------------------------------------------- PRIVATE ------------------------------------------>

	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.util.Util")/>
	</cffunction>

</cfcomponent>