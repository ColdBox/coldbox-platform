<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The WireBox injector is the pivotal class in WireBox that performs
	dependency injection.  It can be used standalone or it can be used in conjunction
	of a ColdBox application context.  It can also be configured with a mapping configuration
	file called a binder, that can provide object/mappings and configuration data.
	
	Easy Startup:
	injector = new coldbox.system.ioc.Injector();
	
	Binder Startup
	injector = new coldbox.system.ioc.Injector(new MyBinder());
	
	Binder Path Startup
	injector = new coldbox.system.ioc.Injector("config.MyBinder");

----------------------------------------------------------------------->
<cfcomponent hint="A WireBox Injector: Builds the graphs of objects that make up your application." output="false" serializable="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
		
	<!--- init --->
	<cffunction name="init" access="public" returntype="Builder" hint="Constructor. If called without a configuration binder, then WireBox will instantiate the default configuration binder found in: coldbox.system.ioc.config.DefaultBinder" output="false" >
		<cfargument name="injector" type="any" required="true" hint="The linked WireBox injector" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfscript>
			instance = {
				injector = arguments.injector,
				log		 = arguments.injector.getLogBox().getlogger(this)
			};
			return this;
		</cfscript>
	</cffunction>
	
	<!--- buildCFC --->
    <cffunction name="buildCFC" output="false" access="private" returntype="any" hint="Build a cfc class via mappings">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfscript>
			var thisMap = arguments.mapping;
			var oModel 	= createObject("component", thisMap.getPath() );
			
			// Constructor initialization?
			if( thisMap.isAutoInit() ){
				// init this puppy
				invokeMethod(oModel,thisMap.getConstructor(),buildConstructorArguments(thisMap));
			}
			
			return oModel;
		</cfscript>
    </cffunction>
	
	<!--- buildJavaClass --->
    <cffunction name="buildJavaClass" output="false" access="private" returntype="any" hint="Build a Java class via mappings">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfscript>
			var x 			= 1;
			var DIArgs 		= arguments.mapping.getDIConstructorArguments();
			var DIArgsLen 	= arrayLen(DIArgs);
			var args		= [];

			// Loop Over Arguments
			for(x = 1; x <= DIArgsLen; x++){
				// do we have javacasting?
				if( structKeyExists(DIArgs[x],"javaCast") ){
					ArrayAppend(args, "javaCast(DIArgs[#x#].javaCast, DIArgs[#x#].value)");
				}	
				else{
					ArrayAppend(args, "DIArgs[#x#].value");
				}
			}

			return evaluate('createObject("java",arguments.mapping.getPath()).init(#arrayToList(args)#)');
		</cfscript>
    </cffunction>
	
	<!--- buildConstructorArguments --->
    <cffunction name="buildConstructorArguments" output="false" access="private" returntype="any" hint="Build constructor arguments for a mapping and return the structure representation">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfscript>
			var x 			= 1;
			var thisMap 	= arguments.mapping;
			var DIArgs 		= arguments.mapping.getDIConstructorArguments();
			var DIArgsLen 	= arrayLen(DIArgs);
			var args		= structnew();

			// Loop Over Arguments
			for(x=1;x lte DIArgsLen; x=x+1){
				
				// Is value set in mapping? If so, add it and continue
				if( structKeyExists(DIArgs[x],"value") ){
					args[ DIArgs[x].name ] = DIArgs[x].value;
					continue;
				}
				
				// Is it by DSL construction? If so, add it and continue, if not found it returns null, which is ok
				if( structKeyExists(DIArgs[x],"dsl") ){
					args[ DIArgs[x].name ] = buildDSLDependency( DIArgs[x].dsl );
				}
				
				// If we get here then it is by ref id, so let's verify it exists and optional
				if( len(containsInstance( DIArgs[x].ref )) ){
					args[ DIArgs[x].name ] = instance.injector.getInstance( DIArgs[x].ref );
				}
				else if( DIArgs[x].required ){
					// not found but required, then throw exception
					getUtil().throwIt(message="Constructor argument reference not located: #DIArgs[x].name#",
									  detail="Injecting: #thisMap.getMemento().toString()#. The constructor argument details are: #DIArgs[x].toString()#.",
									  type="Injector.ConstructorArgumentNotFoundException");
					instance.log.error("Constructor argument reference not located: #DIArgs[x].name# for mapping: #arguments.mapping.getMemento().toString()#", DIArgs[x]);
				}
				// else just log it via debug
				else if( instance.log.canDebug() ){
					instance.log.debug("Constructor argument reference not located: #DIArgs[x].name# for mapping: #arguments.mapping.getMemento().toString()#", DIArgs[x]);
				}
				
			}

			return args;
		</cfscript>
    </cffunction>
	
	<!--- buildWebservice --->
    <cffunction name="buildWebservice" output="false" access="private" returntype="any" hint="Build a webservice object">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfscript>
    		var oModel = createObject("webservice", arguments.mapping.getPath() );
			
			return oModel;
		</cfscript>
    </cffunction>
	
	<!--- buildFeed --->
    <cffunction name="buildFeed" output="false" access="private" returntype="any" hint="Build an rss feed the WireBox way">
    	<cfargument name="source" type="any" required="true" hint="The feed source to read"/>
    	<cfset var results = {}>
		
    	<cffeed action="read" source="#arguments.source#" query="results.items" properties="results.metadata">
    	
		<cfreturn results>
    </cffunction>

<!------------------------------------------- private ------------------------------------------>
	
	<cffunction name="invokeMethod" hint="Invokes a method and returns its result. If no results, then it returns null" access="private" returntype="any" output="false">
		<cfargument name="component"	required="true" hint="The component to invoke against">
		<cfargument name="methodName"   required="true" hint="The name of the method to invoke">
		<cfargument name="args" 		required="false" default="#structNew()#" hint="Argument Collection to pass in to execution">
	
		<cfset var refLocal = StructNew()>
	
		<cfinvoke component="#arguments.component#"
				  method="#arguments.methodName#"
				  argumentcollection="#arguments.args#"
				  returnvariable="refLocal.results">
		
		<cfif structKeyExists(refLocal, "results")>
			<cfreturn refLocal.results>
		</cfif>
	</cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a core util object" colddoc:generic="coldbox.system.core.util.Util">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
	
	
</cfcomponent>