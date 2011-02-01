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
				injector 	= arguments.injector,
				log		 	= arguments.injector.getLogBox().getlogger(this),
				utility		= arguments.injector.getUtil()
			};
			return this;
		</cfscript>
	</cffunction>
	
	<!--- buildCFC --->
    <cffunction name="buildCFC" output="false" access="public" returntype="any" hint="Build a cfc class via mappings">
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
    <cffunction name="buildJavaClass" output="false" access="public" returntype="any" hint="Build a Java class via mappings">
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
    <cffunction name="buildConstructorArguments" output="false" access="public" returntype="any" hint="Build constructor arguments for a mapping and return the structure representation">
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
					continue;
				}
				
				// If we get here then it is by ref id, so let's verify it exists and optional
				if( len(instance.injector.containsInstance( DIArgs[x].ref )) ){
					args[ DIArgs[x].name ] = instance.injector.getInstance( DIArgs[x].ref );
					continue;
				}
				
				// Not found, so check if it is required
				if( DIArgs[x].required ){
					// Log the error
					instance.log.error("Constructor argument reference not located: #DIArgs[x].name# for mapping: #arguments.mapping.getMemento().toString()#", DIArgs[x]);
					// not found but required, then throw exception
					instance.utility.throwIt(message="Constructor argument reference not located: #DIArgs[x].name#",
									  		 detail="Injecting: #thisMap.getMemento().toString()#. The constructor argument details are: #DIArgs[x].toString()#.",
									  		 type="Injector.ConstructorArgumentNotFoundException");
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
    <cffunction name="buildWebservice" output="false" access="public" returntype="any" hint="Build a webservice object">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfscript>
    		var argStruct 	= {};
			var DIArgs 		= arguments.mapping.getDIConstructorArguments();
			var DIArgsLen   = arraylen(DIArgs);
    		
			// Loop Over Arguments for wsdl args
			for(x=1;x lte DIArgsLen; x=x+1){
				argStruct[ DIArgs[x].name ] = DIArgs[x].value;
			}
			
			return createObject("webservice", arguments.mapping.getPath(), argStruct );
		</cfscript>
    </cffunction>
	
	<!--- buildFeed --->
    <cffunction name="buildFeed" output="false" access="public" returntype="any" hint="Build an rss feed the WireBox way">
    	<cfargument name="mapping" 	required="true" hint="The mapping to construct" colddoc:generic="coldbox.system.ioc.config.Mapping">
    	<cfset var results = {}>
		
    	<cffeed action="read" source="#arguments.mapping.getPath()#" query="results.items" properties="results.metadata">
    	
		<cfreturn results>
    </cffunction>
	
	<!--- invokeMethod --->
	<cffunction name="invokeMethod" hint="Invokes a method and returns its result. If no results, then it returns null" access="public" returntype="any" output="false">
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
	
<!------------------------------------------- Internal DSL Builders ------------------------------------------>

	<!--- buildSimpleDSL --->
	<cffunction name="buildSimpleDSL" output="false" access="public" returntype="any" hint="Build a DSL Dependency using a simple dsl string">
		<cfargument name="dsl" required="true" 	hint="The dsl string to build">
		<cfscript>
			var definition = {
				name = "",
				dsl = arguments.dsl
			};
			return buildDSLDependency( definition );
		</cfscript>
	</cffunction>

	<!--- buildDSLDependency --->
	<cffunction name="buildDSLDependency" output="false" access="public" returntype="any" hint="Build a DSL Dependency, if not found, returns null">
		<cfargument name="definition" required="true" hint="The dependency definition structure: name,dsl as keys">
		<cfscript>
			var refLocal 		= {};
			var DSLNamespace 	= listFirst(arguments.definition.dsl,":");

			// Determine Type of Injection according to Internal Types first
			switch(DSLNamespace){
				// ioc dependency usually only when coldbox context is connected
				case "ioc" 				 : { refLocal.dependency = getIOCDependency(arguments.definition); break; }
				// ocm is used only on coldbox context
				case "ocm" 				 : { refLocal.dependency = getOCMDependency(arguments.definition); break; }
				// coldbox webservice is used only on coldbox context
				case "webservice" 		 : { refLocal.dependency = getWebserviceDSL(arguments.definition); break; }
				// javaloader only used on coldbox context
				case "javaloader"		 : { refLocal.dependency = getJavaLoaderDSL(arguments.definition); break;}
				// entity service only used on coldbox context
				case "entityService"	 : { refLocal.dependency = getEntityServiceDSL(arguments.definition); break;}
				// coldbox is used only on coldbox context
				case "coldbox" 			 : { refLocal.dependency = getColdboxDSL(arguments.definition); break; }
				// basic wirebox injection DSL
				case "model" : case "id" : { refLocal.dependency = getModelDSL(arguments.definition); break; }
				// logbox injection DSL
				case "logbox"			 : { refLocal.dependency = getLogBoxDSL(arguments.definition); break;}
				// cachebox injection DSL
				case "cacheBox"			 : { refLocal.dependency = getCacheBoxDSL(arguments.definition); break;}
				default : {
					// No internal DSL's found, then check custom DSL's
					// TODO: custom DSL's
				}
			}
				
			// return only if found, else returns null
			if( structKeyExists(refLocal,"dependency") ){ return dependency; }
			
			// Some warning data
			if( instance.log.canWarn() ){
				instance.log.warn("The DSL dependency definition: #arguments.definition# did not produce any result.");
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- private ------------------------------------------>
		
</cfcomponent>