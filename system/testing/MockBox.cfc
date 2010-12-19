<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 		: Luis Majano
Date     		: April 20, 2009
Description		: 
	The Official ColdBox Mocking Factory
----------------------------------------------------------------------->
<cfcomponent output="false" hint="A unit testing mocking/stubing factory for ColdFusion 7 and above and any CFML Engine">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="MockBox" hint="Create an instance of MockBox">
		<cfargument name="generationPath" type="string" required="false" default="" hint="The mocking generation relative path.  If not defined, then the factory will use its internal tmp path. Just make sure that this folder is accessible from an include."/>
		<cfscript>
			var tempDir =  "/coldbox/system/testing/stubs";
			
			instance = structnew();
			
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
			
			instance.version 		= "1.3";
			instance.mockGenerator 	= createObject("component","coldbox.system.testing.mockutils.MockGenerator").init(this);
			
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<!--- Get Generator --->
	<cffunction name="getMockGenerator" access="public" returntype="coldbox.system.testing.mockutils.MockGenerator" output="false" hint="Get the Mock Generator Utility">
		<cfreturn instance.mockGenerator>
	</cffunction>
	
	<!--- Get/Set generation path --->
	<cffunction name="getGenerationPath" access="public" returntype="string" output="false" hint="Get the current generation path">
		<cfreturn instance.generationPath>
	</cffunction>
	<cffunction name="setGenerationPath" access="public" returntype="void" output="false" hint="Override the mocks generation path">
		<cfargument name="generationPath" type="string" required="true">
		<cfset instance.generationPath = arguments.generationPath>
	</cffunction>
	
	<!--- Get MockBox Version --->
	<cffunction name="getVersion" access="public" returntype="string" output="false" hint="Get the MockBox version">
		<cfreturn instance.version>
	</cffunction>

<!------------------------------------------- MOCK CREATION METHODS ------------------------------------------>
	
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
	<cffunction name="prepareMock" output="false" access="public" returntype="any" hint="Prepares an already instantiated object to act as a mock for spying and much more.">
		<!--- ************************************************************* --->
		<cfargument name="object" 		type="any" 		required="false" hint="The already instantiated object to prepare for mocking"/>
		<cfargument name="callLogging" 	type="boolean" 	required="false" default="true" hint="Add method call logging for all mocked methods"/>
		<!--- ************************************************************* --->
		<cfscript>
			return createMock(object=arguments.object);
		</cfscript>
	</cffunction>	
	
	<!--- createStub --->
	<cffunction name="createStub" output="false" access="public" returntype="any" hint="Create an empty stub object that you can use for mocking.">
		<cfargument name="callLogging" 	type="boolean" required="false" default="true" hint="Add method call logging for all mocked methods"/>
		<cfscript>
			return createMock(className="coldbox.system.testing.mockutils.Stub",callLogging=arguments.callLogging);
		</cfscript>
	</cffunction>	

<!------------------------------------------- DECORATION INJECTED METHODS ON MOCK OBJECTS ------------------------------------------>

	<!--- $property --->
	<cffunction name="$property" output="false" access="public" returntype="any" hint="Mock a property inside of an object in any scope. Injected as = $property()">
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
	
	<!--- $count --->
	<cffunction name="$count" output="false" returntype="numeric" hint="I return the number of times the specified mock object's methods have been called or a specific method has been called.  If the mock method has not been defined the results is a -1">
		<cfargument name="methodName" type="string" default="" required="false" hint="Name of the method to get the total made calls from. If not passed, then we count all methods in this mock object" />
		<cfscript>
			var key   		= "";
			var totalCount 	= 0;
			
			// If method name used? Count only this method signatures
			if( len(arguments.methodName) ){
				if( structKeyExists(this._mockMethodCallCounters, arguments.methodName) ){
					return this._mockMethodCallCounters[arguments.methodName];
				}
				return -1;
			}
			
			// All Calls
			for( key in this._mockMethodCallCounters ){
				totalCount = totalCount + this._mockMethodCallCounters[key];
			}
			return totalCount;
		</cfscript>
	</cffunction>
	
	<!--- $times --->
	<cffunction name="$times" output="false" returntype="boolean" hint="Assert how many calls have been made to the mock or a specific mock method: Injected as $verifyCallCount() and $times()">
		<cfargument name="count" 		type="numeric" required="true"  hint="The number of calls to assert"/>
		<cfargument name="methodName" 	type="string"  required="false" default="" hint="Name of the method to verify the calls from, if not passed it asserts all mocked method calls" />
		<cfscript>
			return (this.$count(argumentCollection=arguments) eq arguments.count );
		</cfscript>
	</cffunction>
	
	<!--- $never--->
	<cffunction name="$never" output="false" returntype="boolean" hint="Assert that no interactions have been made to the mock or a specific mock method: Alias to $times(0). Injected as $never()">
		<cfargument name="methodName" 	type="string"  required="false" default="" hint="Name of the method to verify the calls from" />
		<cfscript>
			if( this.$count(arguments.methodName) EQ 0 ){ return true; }
			return false;
		</cfscript>
	</cffunction>
	
	<!--- $atLeast --->
	<cffunction name="$atLeast" output="false" returntype="boolean" hint="Assert that at least a certain number of calls have been made on the mock or a specific mock method. Injected as $atLeast()">
		<cfargument name="minNumberOfInvocations" type="numeric" required="true"  hint="The min number of calls to assert"/>
		<cfargument name="methodName" 			  type="string"  required="false" default="" hint="Name of the method to verify the calls from, if blank, from the entire mock" />
		<cfscript>
			return (this.$count(argumentCollection=arguments) GTE arguments.minNumberOfInvocations);
		</cfscript>
	</cffunction>
	
	<!--- $once --->
	<cffunction name="$once" output="false" returntype="boolean" hint="Assert that only 1 call has been made on the mock or a specific mock method. Injected as $once()">
		<cfargument name="methodName" type="string"  required="false" default="" hint="Name of the method to verify the calls from, if blank, from the entire mock" />
		<cfscript>
			return (this.$count(argumentCollection=arguments) EQ 1);
		</cfscript>
	</cffunction>
	
	<!--- $atMost --->
	<cffunction name="$atMost" output="false" returntype="boolean" hint="Assert that at most a certain number of calls have been made on the mock or a specific mock method. Injected as $atMost()">
		<cfargument name="maxNumberOfInvocations" type="numeric" required="true"  hint="The max number of calls to assert"/>
		<cfargument name="methodName" 			  type="string"  required="false" default="" hint="Name of the method to verify the calls from, if blank, from the entire mock" />
		<cfscript>
			return (this.$count(argumentCollection=arguments) LTE arguments.maxNumberOfInvocations);
		</cfscript>
	</cffunction>
		
	<!--- $results --->
	<cffunction name="$results" output="false" access="public" returntype="any" hint="Use this method to mock more than 1 result as passed in arguments.  Can only be called when chained to a $() or $().$args() call.  Results will be recycled on a multiple of their lengths according to how many times they are called, simulating a state-machine algorithm. Injected as: $results()">
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
				
				return this;
			</cfscript>
		</cfif>
		
		<cfthrow type="MockFactory.IllegalStateException"
			     message="No current method name set"
			     detail="This method was probably called without chaining it to a mockMethod() call. Ex: obj.$().mockResults(), or obj.$('method').mockArgs().mockResults()">
	</cffunction>
	
	<!--- $args --->
	<cffunction name="$args" output="false" access="public" returntype="any" hint="Use this method to mock specific arguments when calling a mocked method.  Can only be called when chained to a $() call.  If a method is called with arguments and no match, it defaults to the base results defined. Injected as: $args()">
		<cfscript>
			var argOrderedTree = "";
			
			// check if method is set on concat
			if( len(this._mockCurrentMethod) ){
				
				// argument Hash Signature
				this._mockCurrentArgsHash = this._mockCurrentMethod & "|" & this.mockBox.normalizeArguments(arguments);
				
				// concat this
				return this;
			}
		</cfscript>
		
		<cfthrow type="MockBox.IllegalStateException"
				 message="No current method name set"
				 detail="This method was probably called without chaining it to a mockMethod() call. Ex: obj.mockMethod().mockArgs()">

	</cffunction>
	
	<!--- $ --->
	<cffunction name="$" output="false" access="public" returntype="any" hint="Mock a Method, simple but magical Injected as: $()">
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
	
	<!--- $callLog --->
	<cffunction name="$callLog" output="false" access="public" returntype="struct" hint="Retrieve the method call logger structures. Injected as: $callLog()">
		<cfreturn this._mockCallLoggers>
	</cffunction>
	
	<!--- $debug --->
	<cffunction name="$debug" access="public" returntype="struct" hint="Debugging method for MockBox enabled mocks/stubs, useful to find out things about your mocks. Injected as $debug()" output="false">
	<cfscript>
		var rtn 					= structnew();
		rtn.mockResults 			= this._mockResults;
		rtn.mockArgResults 			= this._mockArgResults;
		rtn.mockMethodCallCounters 	= this._mockMethodCallCounters;
		rtn.mockCallLoggingActive 	= this._mockCallLoggingActive;
		rtn.mockCallLoggers 		= this._mockCallLoggers;
		rtn.mockGenerationPath 		= this._mockGenerationPath;
		rtn.mockOriginalMD 			= this._mockOriginalMD;
		return rtn;		
	</cfscript>
	</cffunction>
	
	<!--- $reset --->
    <cffunction name="$reset" output="false" access="public" returntype="any" hint="Reset all mock counters and logs on the targeted mock. Injected as $reset">
    	<cfscript>
    		this._mockMethodCallCounters = structnew();
			this._mockCallLoggers 		 = structnew();
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- UTILITY METHODS ------------------------------------------>

	<!--- querySim --->
	<cffunction name="querySim" access="public" returntype="query" output="false" hint="First line are the query columns separated by commas. Then do a consecuent rows separated by line breaks separated by | to denote columns." >
		<cfargument name="queryData"  type="string" required="true" hint="The data to create queries">
		<cfscript>
		/**
		* Accepts a specifically formatted chunk of text, and returns it as a query object.
		* v2 rewrite by Jamie Jackson
		*
		* @param queryData      Specifically format chunk of text to convert to a query. (Required)
		* @return Returns a query object.
		* @author Bert Dawson (bert@redbanner.com)
		* @version 2, December 18, 2007
		* 
		*/
		var fieldsDelimiter="|";
	    var colnamesDelimiter=",";
	    var listOfColumns="";
	    var tmpQuery="";
	    var numLines="";
	    var cellValue="";
	    var cellValues="";
	    var colName="";
	    var lineDelimiter=chr(10) & chr(13);
	    var lineNum=0;
	    var colPosition=0;
	
	    // the first line is the column list, eg "column1,column2,column3"
	    listOfColumns = Trim(ListGetAt(queryData, 1, lineDelimiter));
	    
	    // create a temporary Query
	    tmpQuery = QueryNew(listOfColumns);
	
	    // the number of lines in the queryData
	    numLines = ListLen(queryData, lineDelimiter);
	    
	    // loop though the queryData starting at the second line
	    for(lineNum=2; lineNum LTE numLines; lineNum = lineNum + 1) {
	     cellValues = ListGetAt(queryData, lineNum, lineDelimiter);
	
	        if (ListLen(cellValues, fieldsDelimiter) IS ListLen(listOfColumns,",")) {
	            QueryAddRow(tmpQuery);
	            for (colPosition=1; colPosition LTE ListLen(listOfColumns); colPosition = colPosition + 1){
	                cellValue = Trim(ListGetAt(cellValues, colPosition, fieldsDelimiter));
	                colName = Trim(ListGetAt(listOfColumns,colPosition));
	                QuerySetCell(tmpQuery, colName, cellValue);
	            }
	        }
	    }
	    
	    return( tmpQuery );
		</cfscript>
	</cffunction>
	
	<!--- normalizeArguments --->
    <cffunction name="normalizeArguments" output="false" access="public" returntype="string" hint="Normalize argument values on method calls">
    	<cfargument name="args" type="any" required="true" hint="The arguments structure to normalize"/>
    	<cfscript>
    		var argOrderedTree = createObject("java","java.util.TreeMap").init(arguments.args).values().toString();
			
			return hash( argOrderedTree );
		</cfscript>
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- Decorate Mock --->
	<cffunction name="decorateMock" access="private" returntype="void" hint="Decorate a mock object" output="false" >
		<cfargument name="target"  type="any" required="true" hint="The target object">
		<cfscript>
			var obj = target;
			
			// Mock Method Results Holder
			obj._mockResults = structnew();
			obj._mockArgResults = structnew();
			// Call Counters
			obj._mockMethodCallCounters = structnew();
			// Call Logging
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
			obj.$ 					= variables.$;
			// Mock Property
			obj.$property	 		= variables.$property;
			// Mock Results
			obj.$results			= variables.$results;
			// Mock Arguments
			obj.$args				= variables.$args;
			// CallLog
			obj.$callLog			= variables.$callLog;
			// Verify Call Counts
			obj.$count 				= variables.$count;
			obj.$times				= variables.$times;
			obj.$never				= variables.$never;
			obj.$verifyCallCount	= variables.$times;			
			obj.$atLeast			= variables.$atLeast;
			obj.$once				= variables.$once;
			obj.$atMost				= variables.$atMost;
			// Debug
			obj.$debug				= variables.$debug;
			obj.$reset				= variables.$reset;
			// Mock Box
			obj.mockBox 			= this;			
		</cfscript>
	</cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

</cfcomponent>