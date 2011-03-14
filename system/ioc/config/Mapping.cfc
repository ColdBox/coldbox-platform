<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I model a WireBox object mapping in all of its glory and splendour
	

----------------------------------------------------------------------->
<cfcomponent hint="I model a WireBox object mapping in all of its glory and splendour" output="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
		
	<!--- init --->
	<cffunction name="init" access="public" returntype="Mapping" hint="Constructor" output="false" >
		<cfargument name="name" required="true" hint="The mapping name"/>
		<cfscript>
			
			// Configure Instance
			instance = {
				// Setup the mapping name
				name = arguments.name,
				// Setup the alias list for this mapping.
				alias = [],
				// Mapping Type
				type =  "",
				// Mapping Value (If Any)
				value = "",
				// Mapped instantiation path or mapping
				path = "",
				// A factory method to execute on the mapping if this is a factory mapping
				method = "",
				// Mapped constructor
				constructor = "init",
				// Discovery and wiring flag
				autoWire = true,
				// Auto init or not
				autoInit = true,
				// Lazy load the mapping or not
				eagerInit = false,
				// The storage or visibility scope of the mapping
				scope = "",
				// A construction dsl
				dsl = "",
				// Caching parameters
				cache = {provider="default", key="", timeout="", lastAccessTimeout=""},
				// Explicit Constructor arguments
				DIConstructorArgs = [],
				// Explicit Properties
				DIProperties = [],
				// Explicit Setters
				DISetters = [],
				// Explicit method arguments
				DIMethodArgs = [],
				// Post Processors
				onDIComplete = [],
				// Flag used to distinguish between discovered and non-discovered mappings
				discovered = false,
				// original object's metadata
				metadata = {},
				// discovered provider methods
				providerMethods = []
			};
			
			// DI definition structure
			DIDefinition = {name="",value="",dsl="",scope="variables",javaCast="",ref="",required=false};
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- getMemento --->
    <cffunction name="getMemento" output="false" access="public" returntype="any" hint="Get the instance memento structure" colddoc:generic="struct">
    	<cfreturn instance>
    </cffunction>
	
	<!--- processMemento --->
    <cffunction name="processMemento" output="false" access="public" returntype="any" hint="Process a mapping memento">
    	<cfargument name="memento" required="true" hint="The data memento to process" colddoc:generic="struct"/>
    	<cfscript>
    		var x = 1;
			var key = "";
			
			// append incoming memento data
    		for(key in arguments.memento){
				
				switch(key){
					//process cache properties
					case "cache" : {
						setCacheProperties(argumentCollection=arguments.memento.cache ); break;
					}
					//process constructor args
					case "DIConstructorArgs" : {
						for(x=1; x lte arrayLen(arguments.memento.DIConstructorArgs); x++){
							addDIConstructorArgument(argumentCollection=arguments.memento.DIConstructorArgs[x] );
						}
						break; 
					}	
					//process properties
					case "DIProperties" : {
						for(x=1; x lte arrayLen(arguments.memento.DIProperties); x++){
							addDIProperty(argumentCollection=arguments.memento.DIProperties[x] );
						} 
						break; 
					}	
					//process DISetters
					case "DISetters" : {
						for(x=1; x lte arrayLen(arguments.memento.DISetters); x++){
							addDISetter(argumentCollection=arguments.memento.DISetters[x] );
						} 
						break; 
					}	
					//process DIMethodArgs
					case "DIMethodArgs" : {
						for(x=1; x lte arrayLen(arguments.memento.DIMethodArgs); x++){
							addDIMethodArgument(argumentCollection=arguments.memento.DIMethodArgs[x] );
						} 
						break; 
					}	
					
					default:{
						instance[key] = arguments.memento[key];
					}
				}// end switch
				
			}
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- Name --->
	<cffunction name="getName" access="public" returntype="any" output="false" hint="Get the mapping name">
    	<cfreturn instance.name>
    </cffunction>
    <cffunction name="setName" access="public" returntype="any" output="false" hint="Name the mapping">
    	<cfargument name="name" type="string" required="true">
    	<cfset instance.name = arguments.name>
    	<cfreturn this>
    </cffunction>
	
	<!--- Aliases --->
	<cffunction name="getAlias" access="public" returntype="any" output="false" hint="Get the mapping aliases array" colddoc:generic="Array">
    	<cfreturn instance.alias>
    </cffunction>
    <cffunction name="setAlias" access="public" returntype="any" output="false" hint="Set the mapping aliases">
    	<cfargument name="alias" required="true" colddoc:generic="Array">
    	<cfset instance.alias = arguments.alias>
    	<cfreturn this>
    </cffunction>
	
	<!--- Path --->
	<cffunction name="getPath" access="public" returntype="any" output="false" hint="Get the path to this mapping">
    	<cfreturn instance.path>
    </cffunction>
    <cffunction name="setPath" access="public" returntype="any" output="false" hint="Set the path to this mapping">
    	<cfargument name="path" required="true">
    	<cfset instance.path = arguments.path>
    	<cfreturn this>
    </cffunction>
    
	<!--- method --->
	<cffunction name="getMethod" access="public" returntype="any" output="false" hint="Get the method that this mapping needs to execute from a mapping factory">
    	<cfreturn instance.method>
    </cffunction>
    <cffunction name="setMethod" access="public" returntype="any" output="false" hint="Set the method used for getting this mapping from a factory">
    	<cfargument name="method" required="true">
    	<cfset instance.method = arguments.method>
    	<cfreturn this>
    </cffunction>
	
	<!--- Type --->
	<cffunction name="getType" access="public" returntype="any" output="false" hint="Get the mapping type">
    	<cfreturn instance.type>
    </cffunction>
    <cffunction name="setType" access="public" returntype="any" output="false" hint="Set the mapping type">
    	<cfargument name="type" required="true">
    	<cfset instance.type = arguments.type>
    	<cfreturn this>
    </cffunction>
	
	<!--- Value --->
	<cffunction name="getValue" access="public" returntype="any" output="false" hint="Get the mapping value (if any)">
    	<cfreturn instance.value>
    </cffunction>
    <cffunction name="setValue" access="public" returntype="any" output="false" hint="Set the mapping value">
    	<cfargument name="value" required="true">
    	<cfset instance.value = arguments.value>
    	<cfreturn this>
    </cffunction>
	
	<!--- Constructor --->
	<cffunction name="getConstructor" access="public" returntype="any" output="false" hint="Get the name of the constructor method">
    	<cfreturn instance.constructor>
    </cffunction>
    <cffunction name="setConstructor" access="public" returntype="any" output="false" hint="Override the name of the constructor method">
    	<cfargument name="constructor" required="true">
    	<cfset instance.constructor = arguments.constructor>
    	<cfreturn this>
    </cffunction>
    
	<!--- isAutowire --->
    <cffunction name="isAutowire" output="false" access="public" returntype="any" hint="Flag describing if you are using autowire or not as Boolean" colddoc:generic="Boolean">
    	<cfreturn instance.autowire>
    </cffunction>
    <cffunction name="setAutowire" access="public" returntype="any" output="false" hint="Set autowire property">
    	<cfargument name="autowire" required="true" colddoc:generic="Boolean">
    	<cfset instance.autowire = arguments.autowire>
    	<cfreturn this>
    </cffunction>
	
	<!--- isAutoInit --->
    <cffunction name="isAutoInit" output="false" access="public" returntype="any" hint="Using auto init of mapping target or not as boolean" colddoc:generic="Boolean">
    	<cfreturn instance.autoInit>
    </cffunction>
    <cffunction name="setAutoInit" access="public" returntype="any" output="false" hint="Set autoInit property">
    	<cfargument name="autoInit" required="true">
    	<cfset instance.autoInit = arguments.autoInit>
    	<cfreturn this>
    </cffunction>
	
	<!--- scope --->
	<cffunction name="getScope" access="public" returntype="any" output="false" hint="Get the visibility scope">
    	<cfreturn instance.scope>
    </cffunction>
    <cffunction name="setScope" access="public" returntype="any" output="false" hint="Set the visibility scope">
    	<cfargument name="scope" type="any" required="true">
    	<cfset instance.scope = arguments.scope>
    	<cfreturn this>
    </cffunction>
    
	<!--- DSL --->
	<cffunction name="isDSL" output="false" access="public" returntype="any" hint="Does this mapping have a DSL construction element or not as Boolean" colddoc:generic="boolean">
		<cfreturn (len(instance.dsl) GT 0)>    	
    </cffunction>
    <cffunction name="getDSL" access="public" returntype="any" output="false" hint="Get the construction DSL">
    	<cfreturn instance.dsl>
    </cffunction>
    <cffunction name="setDSL" access="public" returntype="any" output="false" hint="Set the construction DSL">
    	<cfargument name="dsl" required="true">
    	<cfset instance.dsl = arguments.dsl>
    	<cfreturn this>
    </cffunction>
	
	<!--- cacheProperties --->
    <cffunction name="setCacheProperties" output="false" access="public" returntype="any" hint="Set the cache properties for this mapping (Needs cachebox integration)">
    	<cfargument name="key" 					required="true" hint="Cache key to use"/>
    	<cfargument name="timeout" 				required="false" default="" hint="Object Timeout"/>
		<cfargument name="lastAccessTimeout" 	required="false" default="" hint="Object Last Access Timeout"/>
		<cfargument name="provider" 			required="false" default="default" hint="The Cache Provider to use"/>
		<cfscript>
			structAppend( instance.cache, arguments, true);
			return this;
		</cfscript>
    </cffunction>
    <cffunction name="getCacheProperties" output="false" access="public" returntype="any" hint="Get this mappings cache properties structure" colddoc:generic="struct">
    	<cfreturn instance.cache>
    </cffunction>
	
	<!--- getDIConstructorArguments --->
    <cffunction name="getDIConstructorArguments" output="false" access="public" returntype="any" hint="Get all the constructor argument definitions array" colddoc:generic="array">
    	<cfreturn instance.DIConstructorArgs>
    </cffunction>
	
	<!--- addConstructorArgument --->
    <cffunction name="addDIConstructorArgument" output="false" access="public" returntype="any" hint="Add a new constructor argument to this mapping">
    	<cfargument name="name" 	required="false" hint="The name of the constructor argument (Not used for: JAVA,WEBSERVICE)"/>
		<cfargument name="ref" 		required="false" hint="The reference mapping id this constructor argument maps to"/>
		<cfargument name="dsl" 		required="false" hint="The construction dsl this argument references. If used, the name value must be used."/>
		<cfargument name="value" 	required="false" hint="The explicit value of the constructor argument, if passed."/>
    	<cfargument name="javaCast" required="false" hint="The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments"/>
    	<cfargument name="required" required="false" default="true" hint="If the argument is required or not, by default we assume required DI arguments."/>
		<cfscript>
    		var def = getDIDefinition();
			var x   = 1;
			// check if already registered, if it is, just return
			for(x=1; x lte arrayLen(instance.DIConstructorArgs); x++){
				if( structKeyExists(instance.DIConstructorArgs[x],"name") AND
					instance.DIConstructorArgs[x].name eq arguments.name ){ return this;}
			}
			// Register new constructor argument.
			structAppend(def, arguments, true);
			arrayAppend( instance.DIConstructorArgs, def );
			
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- addDIMethodArgument --->
    <cffunction name="addDIMethodArgument" output="false" access="public" returntype="any" hint="Add a new method argument to this mapping">
    	<cfargument name="name" 	required="false" hint="The name of the method argument (Not used for: JAVA,WEBSERVICE)"/>
		<cfargument name="ref" 		required="false" hint="The reference mapping id this method argument maps to"/>
		<cfargument name="dsl" 		required="false" hint="The construction dsl this argument references. If used, the name value must be used."/>
		<cfargument name="value" 	required="false" hint="The explicit value of the method argument, if passed."/>
    	<cfargument name="javaCast" required="false" hint="The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments"/>
    	<cfargument name="required" required="false" default="true" hint="If the argument is required or not, by default we assume required DI arguments."/>
		<cfscript>
    		var def = getDIDefinition();
			var x	= 1;
			// check if already registered, if it is, just return
			for(x=1; x lte arrayLen(instance.DIMethodArgs); x++){
				if( structKeyExists(instance.DIMethodArgs[x],"name") AND
					instance.DIMethodArgs[x].name eq arguments.name ){ return this;}
			}
			structAppend(def, arguments, true);
			arrayAppend( instance.DIMethodArgs, def );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- getDIMethodArguments --->
    <cffunction name="getDIMethodArguments" output="false" access="public" returntype="any" hint="Get all the method argument definitions array" colddoc:generic="array">
    	<cfreturn instance.DIMethodArgs>
    </cffunction>

	<!--- getProperties --->
    <cffunction name="getDIProperties" output="false" access="public" returntype="any" hint="Get all the DI property definitions array" colddoc:generic="Array">
    	<cfreturn instance.DIProperties>
    </cffunction>
	
	<!--- addDIProperty --->
    <cffunction name="addDIProperty" output="false" access="public" returntype="any" hint="Add a new cfproperty definition">
    	<cfargument name="name" 	required="true"  hint="The name of the cfproperty to inject"/>
		<cfargument name="ref" 		required="false" hint="The reference mapping id this property maps to"/>
		<cfargument name="dsl" 		required="false" hint="The construction dsl this property references. If used, the name value must be used."/>
		<cfargument name="value" 	required="false" hint="The value of the property, if passed."/>
    	<cfargument name="javaCast" required="false" hint="The type of javaCast() to use on the value of the property. Only used if using dsl or ref arguments"/>
    	<cfargument name="scope" 	required="false" default="variables" hint="The scope in the CFC to inject the property to. By default it will inject it to the variables scope"/>
    	<cfscript>
    		var def = getDIDefinition();
			var x	= 1;
			// check if already registered, if it is, just return
			for(x=1; x lte arrayLen(instance.DIProperties); x++){
				if( instance.DIProperties[x].name eq arguments.name ){ return this;}
			}
			structAppend(def, arguments, true);
			arrayAppend( instance.DIProperties, def );
			return this;
    	</cfscript>
    </cffunction>

    <!--- getDISetters --->
    <cffunction name="getDISetters" output="false" access="public" returntype="any" hint="Get all the DI setter definitions array" colddoc:generic="array">
    	<cfreturn instance.DISetters>
    </cffunction>
	
	<!--- addDISetter --->
    <cffunction name="addDISetter" output="false" access="public" returntype="any" hint="Add a new DI setter definition">
    	<cfargument name="name" 	required="true"  hint="The name of the setter method."/>
		<cfargument name="ref" 		required="false" hint="The reference mapping id this setter argument maps to"/>
		<cfargument name="dsl" 		required="false" hint="The construction dsl this argument references. If used, the name value must be used."/>
		<cfargument name="value" 	required="false" hint="The value of the setter argument, if passed."/>
    	<cfargument name="javaCast" required="false" hint="The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments"/>
    	<cfscript>
    		var def = getDIDefinition();
			var x	= 1;
			// check if already registered, if it is, just return
			for(x=1; x lte arrayLen(instance.DISetters); x++){
				if( instance.DISetters[x].name eq arguments.name ){ return this;}
			}
			structAppend(def, arguments, true);
			arrayAppend( instance.DISetters, def );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- onDIComplete --->
    <cffunction name="getOnDIComplete" output="false" access="public" returntype="any" hint="Get all the DI complete methods array" colddoc:generic="array">
    	<cfreturn instance.onDIComplete>
    </cffunction>
    <cffunction name="setOnDIComplete" output="false" access="public" returntype="any" hint="Set the DI Complete method array">
  		<cfargument name="DIComplete" required="true" hint="The method array to set"/>
    	<cfset instance.onDIComplete = arguments.DIComplete>
    	<cfreturn this>
    </cffunction>

	<!--- isDiscovered --->
    <cffunction name="isDiscovered" output="false" access="public" returntype="any" hint="Checks if this mapping has already been processed or not" colddoc:generic="Boolean">
    	<cfreturn instance.discovered>
    </cffunction>
	
	<!--- setDiscovered --->
    <cffunction name="setDiscovered" output="false" access="public" returntype="any" hint="Flag this mapping as discovered">
    	<cfset instance.discovered = true>
    	<cfreturn this>
    </cffunction>
	
	<!--- getObjectMetadata --->
    <cffunction name="getObjectMetadata" output="false" access="public" returntype="any" hint="Get the internal mapping metadata of the object">
    	<cfreturn instance.metadata>
    </cffunction>
	
	<!--- setObjectMetadata --->
    <cffunction name="setObjectMetadata" output="false" access="public" returntype="any" hint="Set the mappings CFC target metadata">
    	<cfargument name="metadata" required="true" hint="Target CFC metadata"/>
		<cfset instance.metadata = arguments.metadata>
		<cfreturn this>
    </cffunction>

	<!--- isEagerInit --->
    <cffunction name="isEagerInit" output="false" access="public" returntype="any" hint="Is this mapping eager initialized or not as Boolean" colddoc:generic="Boolean">
    	<cfreturn instance.eagerInit>
    </cffunction>
	
	<!--- setEagerInit --->
    <cffunction name="setEagerInit" output="false" access="public" returntype="any" hint="Set the eager init flag">
    	<cfargument name="eagerInit" required="true" hint="Set the eager init flag"/>
    	<cfset instance.eagerInit = arguments.eagerInit>
    	<cfreturn this>
	</cffunction>
	
	<!--- getProviderMethods --->
    <cffunction name="getProviderMethods" output="false" access="public" returntype="any" hint="Get the discovered provider methods array" colddoc:generic="Array">
    	<cfreturn instance.providerMethods>
    </cffunction>
	
	<!--- addProviderMethod --->
    <cffunction name="addProviderMethod" output="false" access="public" returntype="any" hint="Add a new provider method to this mapping">
    	<cfargument name="method" 	required="true" hint="The provided method to override as a provider"/>
		<cfargument name="mapping" 	required="true" hint="The mapping to provide via the selected method"/>
		<cfset arrayAppend( instance.providerMethods, arguments)>
		<cfreturn this>
    </cffunction>

<!------------------------------------------- PROCESSING METHDOS ------------------------------------------>

	<!--- process --->
    <cffunction name="process" output="false" access="public" returntype="any" hint="Process a mapping for metadata discovery and more">
    	<cfargument name="binder" 	required="true"  hint="The binder requesting the processing"/>
		<cfargument name="injector" required="true"  hint="The calling injector processing the mappping"/>
		<cfargument name="metadata" required="false" hint="The metadata of an a-la-carte processing, use instead of retrieveing again"/>
    	<!--- Link the metadata --->
		<cfset var md 			= instance.metadata>
		<cfset var x 			= 1>
		<cfset var thisAliases 	= "">
		<cfset var mappings		= "">
		<cfset var iData	 	= "">
		<cfset var eventManager	= arguments.injector.getEventManager()>
		
		<!--- Lock for discovery based on path location, only done once per instance of mapping. --->
		<cflock name="Mapping.MetadataProcessing.#instance.path#" type="exclusive" timeout="20" throwOnTimeout="true">
		<cfscript>	
	    	if( NOT instance.discovered ){
				
				// announce inspection
				iData = {mapping=this,binder=arguments.binder,injector=arguments.binder.getInjector()};
				eventManager.processState("beforeInstanceInspection",iData);
				
				// Processing only done for CFC's,rest just mark and return
				if( instance.type neq arguments.binder.TYPES.CFC ){
					instance.discovered = true;
					return;
				}
	    		
				// Get the instance's metadata first, so we can start processing.
				if( structKeyExists(arguments,"metadata") ){
					md = arguments.metadata;
				}
				else{
					md = getComponentMetadata( instance.path );
				}
				
				// Singleton Processing
				if( structKeyExists(md,"singleton") ){ instance.scope = arguments.binder.SCOPES.SINGLETON; }
				// Registered Scope Processing
				if( structKeyExists(md,"scope") ){ instance.scope = md.scope; }
				// CacheBox scope processing if cachebox annotation found, or cache annotation found
				if( structKeyExists(md,"cacheBox") OR structKeyExists(md,"cache") ){ 
					instance.scope = arguments.binder.SCOPES.CACHEBOX;
				}
				
				// Cachebox Persistence Processing
				if( instance.scope eq "cachebox" ){
					// Prepare to default provider if no cachebox annotation found or it is empty
					if(NOT structKeyExists(md,"cacheBox") OR len(md.cacheBox) EQ 0){
						md.cacheBox = "default";
					}				
					// Prepare Timeouts
					if( NOT structKeyExists(md,"cachetimeout") or not isNumeric(md.cacheTimeout) ){
						md.cacheTimeout = "";
					}
					if( NOT structKeyExists(md,"cacheLastAccessTimeout") or not isNumeric(md.cacheLastAccessTimeout) ){
						md.cacheLastAccessTimeout = "";
					}
					// setup cachebox properties
					setCacheProperties(key="wirebox-#instance.name#",
									   timeout=md.cacheTimeout,
									   lastAccessTimeout=md.cacheLastAccessTimeout,
									   provider=md.cachebox);
				}
				
				// Alias annotations if found, then append them as aliases.
				if( structKeyExists(md, "alias") ){
					thisAliases = listToArray(md.alias);
					instance.alias.addAll( thisAliases );
					// register alias references on binder
					for(x=1; x lte arrayLen(thisAliases); x++){
						mappings[ thisAliases[x] ] = this;
					}
				}
				
				// eagerInit annotation
				if( structKeyExists(md,"eagerInit") ){
					instance.eagerInit = true;
				}
								
				// Check if autowire annotation found or autowire already set
				if( structKeyExists(md,"autowire") and isBoolean(md.autowire) ){
					instance.autoWire = md.autowire;
				}
				
				// Only process if autowiring
				if( instance.autoWire){
					// Process Methods, Constructors and Properties only if non autowire annotation check found on component.
					processDIMetadata( arguments.binder, md );
				}
				
				// finished processing mark as discovered
				instance.discovered = true;
				
				// announce it
				eventManager.processState("afterInstanceInspection",iData);
			}
		</cfscript>
		</cflock>
    </cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	
	
	<!--- processDIMetadata --->
	<cffunction name="processDIMetadata" returntype="void" access="private" output="false" hint="Process methods/properties for dependency injection">
		<cfargument name="binder" 		required="true" hint="The binder requesting the processing"/>
		<cfargument name="metadata" 	required="true" hint="The metadata to process"/>
		<cfargument name="dependencies" required="false" default="#structnew()#" hint="The dependencies structure">
		<cfscript>
			var x 		= 1;
			var y 		= 1;
			var md 		= arguments.metadata;
			var fncLen	= 0;
			var params	= "";
			
			// Look For properties for annotation injections
			if( structKeyExists(md,"properties") and ArrayLen(md.properties) GT 0){
				// Loop over each property and identify injectable properties
				for(x=1; x lte ArrayLen(md.properties); x=x+1 ){
					// Check if property not discovered or if inject annotation is found
					if( structKeyExists(md.properties[x],"inject") ){
						// default injection scope, if not found in object
						if( NOT structKeyExists(md.properties[x],"scope") ){
							md.properties[x].scope = "variables";
						}
						// Setup the default injection DSL (model) if it is empty
						if( len(md.properties[x].inject) EQ 0){
							md.properties[x].inject = "model";
						}
						// Add to property to mappings
						addDIProperty(name=md.properties[x].name,dsl=md.properties[x].inject,scope=md.properties[x].scope);
					}

				}				
			}//end DI properties
			
			// Method DI discovery
			if( structKeyExists(md, "functions") ){
				fncLen = arrayLen(md.functions);
				for(x=1; x lte fncLen; x++ ){
					
					// Verify Processing or do we continue to next iteration for processing
					// This is to avoid overriding by parent trees in inheritance chains
					if( structKeyExists(arguments.dependencies, md.functions[x].name) ){
						continue;
					}
					
					// Constructor Processing if found
					if( md.functions[x].name eq instance.constructor ){
						// Loop Over Arguments to process them for dependencies
						for(y=1;y lte arrayLen(md.functions[x].parameters); y++){
							// Check required annotation
							if( NOT structKeyExists(md.functions[x].parameters[y], "required") ){
								md.functions[x].parameters[y].required = false;
							}
							// Check injection annotation, if not found, default it
							if( NOT structKeyExists(md.functions[x].parameters[y],"inject") OR len(md.functions[x].parameters[y].inject) EQ 0 ){
								md.functions[x].parameters[y].inject = "model";
							}
							// ADD Constructor argument.
							addDIConstructorArgument(name=md.functions[x].parameters[y].name,
													 dsl=md.functions[x].parameters[y].inject,
													 required=md.functions[x].parameters[y].required);
						}
						// add constructor to found list, so it is processed only once in recursions
						arguments.dependencies[md.functions[x].name] = "constructor";
					}
					
					// Setter discovery, MUST be inject annotation marked to be processed.
					if( left(md.functions[x].name,3) eq "set" AND structKeyExists(md.functions[x],"inject")){
						// Check DSL marker if it has a value else use default of Model
						if( NOT len(md.functions[x].inject) ){
							md.functions[x].inject = "model";
						}
						// Add to setter to mappings and recursion lookup
						addDISetter(name=right(md.functions[x].name, Len(md.functions[x].name)-3),dsl=md.functions[x].inject);
						arguments.dependencies[md.functions[x].name] = "setter";
					}
					
					// Provider Methods Discovery
					if( structKeyExists( md.functions[x], "provider") AND len(md.functions[x].provider)){
						addProviderMethod(md.functions[x].name, md.functions[x].provider);
						arguments.dependencies[md.functions[x].name] = "provider";
					}
					
					// onDIComplete Method Discovery
					if( structKeyExists( md.functions[x], "onDIComplete") ){
						arrayAppend(instance.onDIComplete, md.functions[x].name );
						arguments.dependencies[md.functions[x].name] = "onDIComplete";
					}

				}//end loop of functions
			}//end if functions found
			
			// Start Registering inheritances, if the exists
			if ( structKeyExists(md, "extends")
				 AND
				 stopClassRecursion(md.extends.name,arguments.binder) EQ FALSE){
				// Recursive lookup
				processDIMetadata(arguments.binder, md.extends, arguments.dependencies);
			}
		</cfscript>
	</cffunction>
	
	<!--- stopClassRecursion --->
	<cffunction name="stopClassRecursion" access="private" returntype="any" hint="Should we stop recursion or not due to class name found: Boolean" output="false" colddoc:generic="Boolean">
		<cfargument name="classname" 	required="true" hint="The class name to check">
		<cfargument name="binder" 		required="true" hint="The binder requesting the processing"/>
		<cfscript>
			var x 				= 1;
			var stopRecursions 	= arguments.binder.getStopRecursions();
			var stopLen			= arrayLen(stopRecursions);
			
			// Try to find a match
			for(x=1;x lte stopLen; x=x+1){
				if( CompareNoCase( stopRecursions[x], arguments.classname) eq 0){
					return true;
				}
			}

			return false;
		</cfscript>
	</cffunction>
	
	<!--- getDIDefinition --->
    <cffunction name="getDIDefinition" output="false" access="private" returntype="any" hint="Get a new DI definition structure" colddoc:generic="structure">
    	<cfreturn duplicate(variables.DIDefinition)>
    </cffunction>

</cfcomponent>