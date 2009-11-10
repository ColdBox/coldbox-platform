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
<cfcomponent output="false" hint="A unit testing mocking/stubing factory for ColdFusion 7 and above and any CFML Engine">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="MockBox" hint="Create an instance of MockBox">
		<cfargument name="generationPath" type="string" required="false" default="" hint="The mocking generation relative path.  If not defined, then the factory will use its internal tmp path. Just make sure that this folder is accessible from an include."/>
		<cfscript>
			var tempDir =  "/coldbox/system/testing/stubs";
			
			// Setup the generation Path
			if( len(trim(arguments.generationPath)) neq 0 ){
				// Default to coldbox tmp path
				instance.generationPath = arguments.generationPath;
			}
			else{
				instance.generationPath = tempDir;
			}
			
			// Cleanup of paths.
			if( right(instance.generationPath,1) neq "/" ){
				instance.generationPath = instance.generationPath & "/";
			}
			
			instance.version = "1.0 RC 1";
			instance.mockGenerator = createObject("component","coldbox.system.testing.mockutils.MockGenerator").init(this);
			
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<!--- Get Generator --->
	<cffunction name="getMockGenerator" access="public" returntype="coldbox.system.testing.mockutils.MockGenerator" output="false">
		<cfreturn instance.mockGenerator>
	</cffunction>
	
	<!--- Get/Set generation path --->
	<cffunction name="getGenerationPath" access="public" returntype="string" output="false" hint="Get the current generation path">
		<cfreturn instance.generationPath>
	</cffunction>
	<cffunction name="setGenerationPath" access="public" returntype="void" output="false" hint="Override the generation path">
		<cfargument name="generationPath" type="string" required="true">
		<cfset instance.generationPath = arguments.generationPath>
	</cffunction>
	
	<!--- Get/Set version --->
	<cffunction name="getVersion" access="public" returntype="string" output="false" hint="Get the current mock factory version">
		<cfreturn instance.version>
	</cffunction>
	
	<!--- createEmptyMock --->
	<cffunction name="createEmptyMock" output="false" access="public" returntype="any" hint="Creates an empty mock object. By empty we mean we remove all methods so you can mock them.">
		<!--- ************************************************************* --->
		<cfargument name="className"		type="string" 	required="false" hint="The class name of the object to mock. The mock factory will instantiate it for you"/>
		<cfargument name="object" 			type="any" 		required="false" hint="The object to mock, already instantiated"/>
		<cfargument name="callLogging" 		type="boolean"  required="false" default="true" hint="Add method call logging for all mocked methods. Defaults to true"/>
		<!--- ************************************************************* --->
		<cfset arguments.clearMethods = true>
		<cfreturn createMock(argumentCollection=arguments)>
	</cffunction>
	
	<!--- createMock --->
	<cffunction name="createMock" output="false" access="public" returntype="any" hint="Create a mock object or prepares an object to act as a mock for spying.">
		<!--- ************************************************************* --->
		<cfargument name="className"		type="string" 	required="false" hint="The class name of the object to mock. The mock factory will instantiate it for you"/>
		<cfargument name="object" 			type="any" 		required="false" hint="The object to mock, already instantiated"/>
		<cfargument name="clearMethods" 	type="boolean"  required="false" default="false" hint="If true, all methods in the target mock object will be removed. You can then mock only the methods that you want to mock. Defaults to false"/>
		<cfargument name="callLogging" 		type="boolean"  required="false" default="true" hint="Add method call logging for all mocked methods. Defaults to true"/>
		<!--- ************************************************************* --->
		<cfscript>
			var obj = 0;
			
			// class to mock
			if ( structKeyExists(arguments, "className") ){
				obj = createObject("component",arguments.className);
			}
			else if ( structKeyExists(arguments, "object") ){
				// Object to Mock
				obj = arguments.object;
			}
			else{
				getUtil().throwit(type="mock.invalidArguments",message="Invalid mocking arguments: className or object not found");
			}		
			
			// Clear up Mock object?
			if( arguments.clearMethods ){
				structClear(obj);
			}
			// Decorate Mock
			decorateMock(obj);
			
			// Call Logging Global Flag
			if( arguments.callLogging ){ obj._mockCallLoggingActive = true; }
			
			// Return Mock
			return obj;			
		</cfscript>
	</cffunction>	
	
	<!--- prepareMock --->
	<cffunction name="prepareMock" output="false" access="public" returntype="any" hint="Prepares an object to act as a mock for spying.">
		<!--- ************************************************************* --->
		<cfargument name="object" 		type="any" 		required="false" hint="The already instantiated object to prepare for mocking"/>
		<cfargument name="callLogging" 	type="boolean" 	required="false" default="false" hint="Add method call logging for all mocked methods"/>
		<!--- ************************************************************* --->
		<cfscript>
			return createMock(object=arguments.object);
		</cfscript>
	</cffunction>	
	
	<!--- createStub --->
	<cffunction name="createStub" output="false" access="public" returntype="any" hint="Create an empty stub object that you can use for mocking.">
		<cfargument name="callLogging" 	type="boolean" required="false" default="false" hint="Add method call logging for all mocked methods"/>
		<cfscript>
			return createMock(className="coldbox.system.testing.mockutils.Stub",callLogging=arguments.callLogging);
		</cfscript>
	</cffunction>	

<!------------------------------------------- DECORATION INJECTED METHODS ON MOCK OBJECTS ------------------------------------------>

	<!--- mockProperty --->
	<cffunction name="mockProperty" output="false" access="public" returntype="any" hint="Mock a property inside of an object in any scope. Methods Alias = $property()">
		<!--- ************************************************************* --->
		<cfargument name="propertyName" 	type="string" 	required="true" hint="The name of the property to mock"/>
		<cfargument name="propertyScope" 	type="string" 	required="false" default="variables" hint="The scope where the property lives in. By default we will use the variables scope."/>
		<cfargument name="mock" 			type="any" 		required="true" hint="The object or data to inject"/>
		<!--- ************************************************************* --->
		<cfscript>
			"#arguments.propertyScope#.#arguments.propertyName#" = arguments.mock;
			return this;
		</cfscript>	
	</cffunction>	
	
	<!--- Tell how many times a method has been called. --->
	<cffunction name="mockMethodCallCount" output="false" returntype="numeric" hint="I return the number of times the specified mock method has been called.  If the mock method has not been defined the results is a -1. Method Alias = $count()">
		<cfargument name="methodName" type="string" hint="Name of the method to get calls from" />
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
	<cffunction name="mockResults" output="false" access="public" returntype="any" hint="Use this method to mock more than 1 result as passed in arguments.  Can only be called when chained to a mockMethod(),$() or $().mockArgs() call.  Results will be recycled on a multiple of their lengths according to how many times they are called, simulating a state-machine algorithm. Method Alias: $results()">
		<!--- Check if current method set? --->
		<cfif len(this._mockCurrentMethod)>
			<cfscript>
				// Check if arguments hash is set
				if( len(this._mockCurrentArgsHash) ){
					this._mockArgResults[this._mockCurrentArgsHash] = arguments;
				}
				else{
					// Save incoming results array
					this._mockResults[this._mockCurrentMethod] = arguments;
				}
				// Cleanup
				this._mockCurrentMethod = "";
				this._mockCurrentArgsHash = "";
			</cfscript>
		<cfelse>
			<cfthrow type="MockFactory.IllegalStateException"
					 message="No current method name set"
					 detail="This method was probably called without chaining it to a mockMethod() call. Ex: obj.$().mockResults(), or obj.$('method').mockArgs().mockResults()">
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<!--- mockArgs --->
	<cffunction name="mockArgs" output="false" access="public" returntype="any" hint="Use this method to mock specific arguments when calling a mocked method.  Can only be called when chained to a mockMethod() call.  If a method is called with arguments and no match, it defaults to the base results defined. Method Alias: $args()">
		<cfif len(this._mockCurrentMethod)>
			<!--- Save incoming arguments as results --->
			<cfset this._mockCurrentArgsHash = this._mockCurrentMethod & "|" & hash(arguments.toString())>
		<cfelse>
			<cfthrow type="MockBox.IllegalStateException"
					 message="No current method name set"
					 detail="This method was probably called without chaining it to a mockMethod() call. Ex: obj.mockMethod().mockArgs()">
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<!--- mockMethod --->
	<cffunction name="mockMethod" output="false" access="public" returntype="any" hint="Mock a Method, very simply, no fancy stuff. Method Alias: $()">
		<!--- ************************************************************* --->
		<cfargument name="method" 	type="string" 	required="true" hint="The method you want to mock or spy on"/>
		<cfargument name="returns" 	type="any" 		required="false" hint="The results it must return, if not passed it returns void or you will have to do the mockResults() chain"/>
		<cfargument name="preserveReturnType" type="boolean" required="true" default="true" hint="If false, the mock will make the returntype of the method equal to ANY"/>
		<cfargument name="throwException" type="boolean" required="false" default="false" hint="If you want the method call to throw an exception"/>
		<cfargument name="throwType" 	  type="string"  required="false" default="" hint="The type of the exception to throw"/>
		<cfargument name="throwDetail" 	  type="string"  required="false" default="" hint="The detail of the exception to throw"/>
		<cfargument name="throwMessage"	  type="string"  required="false" default="" hint="The message of the exception to throw"/>
		<cfargument name="callLogging" 	  type="boolean" required="false" default="false" hint="Will add the machinery to also log the incoming arguments to each subsequent calls to this method"/>
		<!--- ************************************************************* --->
		<cfscript>
			var fncMD = structnew();
			var genFile = "";
			var oMockGenerator = this.MockBox.getmockGenerator();
			
			// Check if the method is existent in public scope
			if ( structKeyExists(this,arguments.method) ){
				fncMD = getMetadata(this[arguments.method]);
			}
			// Else check in private scope
			else if( structKeyExists(variables,arguments.method) ){
				fncMD = getMetadata(variables[arguments.method]);				
			}
			
			// Prepare Metadata Existence, works on virtual methods also
			if ( not structKeyExists(fncMD,"returntype") ){
				fncMD["returntype"] = "any";
			}
			if ( not structKeyExists(fncMD,"access") ){
				fncMD["access"] = "public";
			}
			if( not structKeyExists(fncMD,"output") ){
				fncMD["output"] = false;
			}
			// Preserve Return Type?
			if( NOT arguments.preserveReturnType ){
				fncMD["returntype"] = "any";
			}
			
			// Remove Method From Object
			structDelete(this,arguments.method);
			structDelete(variables,arguments.method);
			
			// Generate Mock Method
			arguments.metadata = fncMD;
			arguments.targetObject = this;
			oMockGenerator.generate(argumentCollection=arguments);
			
			// Results Setup For No Argument Definitions or base results
			if( structKeyExists(arguments, "returns") ){
				this._mockResults[arguments.method] = ArrayNew(1);
				this._mockResults[arguments.method][1] = arguments.returns;
			}
			else{
				this._mockResults[arguments.method] = ArrayNew(1);
			}
			// Create Mock Call Counters
			this._mockMethodCallCounters["#arguments.method#"] = 0;
			
			// Save method name for concatenation
			this._mockCurrentMethod = arguments.method;
			this._mockCurrentArgsHash = "";
			
			// Create Call Loggers, just in case
			this._mockCallLoggers[arguments.method] = arrayNew(1);
			
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- mockCallLog --->
	<cffunction name="mockCallLog" output="false" access="private" returntype="struct" hint="Retrieve the method call logger structure. Method Alias: $callLog()">
		<cfreturn this._mockCallLoggers>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- Mock Debugging Calls --->
	<cffunction name="mockDebug" access="private" returntype="struct" hint="Debugging method for MockBox">
	<cfscript>
		var rtn = structnew();
		rtn.mockResults = this._mockResults;
		rtn.mockArgResults = this._mockArgResults;
		rtn.mockMethodCallCounters = this._mockMethodCallCounters;
		rtn.mockCallLoggingActive = this._mockCallLoggingActive;
		rtn.mockCallLoggers = this._mockCallLoggers;
		rtn.mockGenerationPath = this._mockGenerationPath;
		rtn.mockOriginalMD = this._mockOriginalMD;
		return rtn;		
	</cfscript>
	</cffunction>
	
	<!--- Decorate Mock --->
	<cffunction name="decorateMock" access="private" returntype="void" hint="Decorate a mock object" output="false" >
		<cfargument name="target"  type="any" required="true" hint="The target object">
		<cfscript>
			var obj = target;
			
			// Mock Method Results Holder
			obj._mockResults = structnew();
			obj._mockArgResults = structnew();
			obj._mockMethodCallCounters = structnew();
			obj._mockCallLoggingActive = false;
			
			// Mock Method Call Logger
			obj._mockCallLoggers = structnew();
			
			// Mock Generation Path
			obj._mockGenerationPath = getGenerationPath();
			
			// Original Metadata
			obj._mockOriginalMD = getMetadata(obj);
			
			// Chanining Properties
			obj._mockCurrentMethod = "";
			obj._mockCurrentArgsHash = "";
			
			// Mock Method
			obj.$ 					= variables.mockMethod;
			obj.mockMethod			= variables.mockMethod;
			// Mock Property
			obj.$property	 		= variables.mockProperty;
			obj.mockProperty 		= variables.mockProperty;
			// MOck Method Call COunts
			obj.$count 				= variables.mockMethodCallCount;
			obj.mockMethodCallCount = variables.mockMethodCallCount;
			// Mock Results
			obj.mockResults 		= variables.mockResults;
			obj.$results			= obj.mockResults;
			// Mock Arguments
			obj.mockArgs			= variables.mockArgs;
			obj.$args				= obj.mockArgs;
			// CallLog
			obj.mockCallLog			= variables.mockCallLog;
			obj.$callLog			= obj.mockCallLog;
			// Debug
			obj.$debug				= variables.mockDebug;
			// Mock Box
			obj.mockBox 			= this;			
		</cfscript>
	</cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

</cfcomponent>