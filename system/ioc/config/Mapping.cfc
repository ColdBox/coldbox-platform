<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
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
				autoWire = "",
				// Auto init or not
				autoInit = true,
				// Lazy load the mapping or not
				eagerInit = "",
				// The storage or visibility scope of the mapping
				scope = "",
				// A construction dsl
				dsl = "",
				// Caching parameters
				cache = {provider="", key="", timeout="", lastAccessTimeout=""},
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
				providerMethods = [],
				// AOP aspect
				aspect = false,
				// AutoAspectBinding
				autoAspectBinding = true,
				// Virtual Inhertiance
				virtualInheritance = "",
				// Extra Attributes
				extraAttributes = {},
				// Mixins
				mixins = [],
				// Thread safety on wiring
				threadSafe = "",
				// A closure that can influence the creation of the instance
				influenceClosure = ""
			};

			// DI definition structure
			DIDefinition = { name="", value="", dsl="", scope="variables", javaCast="", ref="", required=false, argName="", type="any" };

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
		<cfargument name="excludes" required="false" hint="List of instance's memento keys to not process" default="" />
    	<cfscript>
			var x = 1;
			var key = "";


			// if excludes is passed as an array, convert to list
			if(isArray(arguments.excludes)){
				arguments.excludes = arrayToList(arguments.excludes);
			}

			// append incoming memento data
			for(key in arguments.memento){

				// if current key is in excludes list, skip and continue to next loop
				if(listFindNoCase(arguments.excludes, key)){
					continue;
				}

				switch(key){

					//process cache properties
					case "cache" :
					{
						setCacheProperties(argumentCollection=arguments.memento.cache );
						break;
					}

					//process constructor args
					case "DIConstructorArgs" :
					{
						for(x=1; x lte arrayLen(arguments.memento.DIConstructorArgs); x++){
							addDIConstructorArgument(argumentCollection=arguments.memento.DIConstructorArgs[x] );
						}
						break;
					}

					//process properties
					case "DIProperties" :
					{
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
					case "DIMethodArgs" :
					{
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

	<!--- Virtual Inheritance --->
	<cffunction name="getVirtualInheritance" access="public" returntype="any" output="false" hint="Get the virtual inheritance mapping">
    	<cfreturn instance.virtualInheritance>
    </cffunction>
    <cffunction name="setVirtualInheritance" access="public" returntype="any" output="false" hint="Set the virtual inheritance mapping">
    	<cfargument name="mapping" required="true">
    	<cfset instance.virtualInheritance = arguments.mapping>
    	<cfreturn this>
    </cffunction>
    <cffunction name="isVirtualInheritance" access="public" returntype="boolean" output="false" hint="Checks if the mapping needs virtual inheritace or not">
    	<cfreturn len( instance.virtualInheritance ) GT 0>
    </cffunction>

	<!--- Name --->
	<cffunction name="getName" access="public" returntype="any" output="false" hint="Get the mapping name">
    	<cfreturn instance.name>
    </cffunction>
    <cffunction name="setName" access="public" returntype="any" output="false" hint="Name the mapping">
    	<cfargument name="name" required="true">
    	<cfset instance.name = arguments.name>
    	<cfreturn this>
    </cffunction>

    <!--- Thread Safety for wiring --->
    <cffunction name="getThreadSafe" access="public" returntype="any" output="false" hint="Get the thread safety for wiring bit" coldstruct:generic="boolean">
    	<cfreturn instance.threadSafe>
    </cffunction>
    <cffunction name="setThreadSafe" access="public" returntype="any" output="false" hint="Set the thread safety for wiring bit">
    	<cfargument name="threadSafe" type="boolean" required="true">
    	<cfset instance.threadSafe = arguments.threadSafe>
		<cfreturn this>
    </cffunction>

    <!--- Closure for influencing instance creation --->
    <cffunction name="getInfluenceClosure" access="public" returntype="any" output="false" hint="Get the influence closure. Empty string if not exists">
    	<cfreturn instance.influenceClosure>
    </cffunction>
    <cffunction name="setInfluenceClosure" access="public" returntype="any" output="false" hint="Set the influence closure.">
    	<cfargument name="influenceClosure" type="any" required="true">
    	<cfset instance.influenceClosure = arguments.influenceClosure>
		<cfreturn this>
    </cffunction>

    <!--- Mixins --->
	<cffunction name="getMixins" access="public" returntype="any" output="false" hint="Get the mixins array list">
    	<cfreturn instance.mixins>
    </cffunction>
    <cffunction name="setMixins" access="public" returntype="any" output="false" hint="Set the mixins array list">
    	<cfargument name="mixins" required="true">
    	<cfset instance.mixins = arguments.mixins>
    	<cfreturn this>
    </cffunction>

    <!--- ExtraAttributes --->
	<cffunction name="getExtraAttributes" access="public" returntype="any" output="false" hint="Get the mapping's extra attributes">
    	<cfreturn instance.extraAttributes>
    </cffunction>
    <cffunction name="setExtraAttributes" access="public" returntype="any" output="false" hint="Set the mapping's extra attributes">
    	<cfargument name="data" required="true">
    	<cfset instance.extraAttributes = arguments.data>
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

    <!--- isAspect --->
    <cffunction name="isAspect" output="false" access="public" returntype="any" hint="Flag describing if this mapping is an AOP aspect or not" colddoc:generic="Boolean">
    	<cfreturn instance.aspect>
    </cffunction>
    <cffunction name="setAspect" access="public" returntype="any" output="false" hint="Set aspect property">
    	<cfargument name="aspect" required="true" colddoc:generic="Boolean">
    	<cfset instance.aspect = arguments.aspect>
    	<cfreturn this>
    </cffunction>

    <!--- isAspectAutoBinding --->
    <cffunction name="isAspectAutoBinding" output="false" access="public" returntype="any" hint="Is this mapping an auto aspect binding" colddoc:generic="Boolean">
    	<cfreturn instance.autoAspectBinding>
    </cffunction>
    <!--- setAspectAutoBinding --->
    <cffunction name="setAspectAutoBinding" output="false" access="public" returntype="any" hint="Set the aspect auto binding bit">
    	<cfargument name="autoBinding" required="true" colddoc:generic="Boolean">
    	<cfset instance.autoAspectBinding = arguments.autoBinding>
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
		<cfargument name="type"		required="false" default="any" hint="The type of the argument."/>
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
    	<cfargument name="type"		required="false" default="any" hint="The type of the argument."/>
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
    	<cfargument name="required" required="false" default="true" hint="If the property is required or not, by default we assume required DI properties."/>
		<cfargument name="type"		required="false" default="any" hint="The type of the property."/>
		<cfscript>
    		var def = getDIDefinition();
			var x	= 1;
			// check if already registered, if it is, just return
			for( x=1; x lte arrayLen( instance.DIProperties ); x++ ){
				if( instance.DIProperties[ x ].name eq arguments.name ){ return this;}
			}
			structAppend( def, arguments, true );
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
    	<cfargument name="argName" 	required="false" hint="The name of the argument to use, if not passed, we default it to the setter name"/>
    	<cfscript>
    		var def = getDIDefinition();
			var x	= 1;

			// check if already registered, if it is, just return
			for(x=1; x lte arrayLen(instance.DISetters); x++){
				if( instance.DISetters[x].name eq arguments.name ){ return this;}
			}
			// Remove scope for setter injection
			def.scope = "";
			// Verify argument name, if not default it to setter name
			if( NOT structKeyExists(arguments,"argName") OR len(arguments.argName) EQ 0 ){
				arguments.argName = arguments.name;
			}
			// save incoming params
			structAppend(def, arguments, true);
			// save new DI setter injection
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
		<cfset var mappings		= arguments.binder.getMappings()>
		<cfset var iData	 	= "">
		<cfset var eventManager	= arguments.injector.getEventManager()>
		<cfset var cacheProperties = {}>
		<cfif isSimpleValue( instance.path ) >
			<cfset var lockToken  = instance.path>
		<cfelse>
			<cfset var lockToken = createUUID()>
		</cfif>

		<!--- Lock for discovery based on path location, only done once per instance of mapping. --->
		<cflock name="Mapping.#arguments.injector.getInjectorID()#.MetadataProcessing.#lockToken#" type="exclusive" timeout="20" throwOnTimeout="true">
		<cfscript>
	    	if( NOT instance.discovered ){
				// announce inspection
				iData = {mapping=this,binder=arguments.binder,injector=arguments.binder.getInjector()};
				eventManager.processState("beforeInstanceInspection",iData);

				// Processing only done for CFC's,rest just mark and return
				if( instance.type neq arguments.binder.TYPES.CFC ){
					if( NOT len(instance.scope) ){ instance.scope = "noscope"; }
					if( NOT len(instance.autowire) ){ instance.autowire = true; }
					if( NOT len(instance.eagerInit) ){ instance.eagerInit = false; }
					if( NOT len(instance.threadSafe) ){ instance.threadSafe = false; }
					// finished processing mark as discovered
					instance.discovered = true;
					// announce it
					eventManager.processState("afterInstanceInspection",iData);
					return;
				}

				// Get the instance's metadata first, so we can start processing.
				if( structKeyExists(arguments,"metadata") ){
					md = arguments.metadata;
				}
				else{
					md = arguments.injector.getUtil().getInheritedMetaData(instance.path, arguments.binder.getStopRecursions());
				}

				// Store Metadata
				instance.metadata = md;

				// Process persistence if not set already by configuration as it takes precedence
				if( NOT len(instance.scope) ){
					// Singleton Processing
					if( structKeyExists(md,"singleton") ){ instance.scope = arguments.binder.SCOPES.SINGLETON; }
					// Registered Scope Processing
					if( structKeyExists(md,"scope") ){ instance.scope = md.scope; }
					// CacheBox scope processing if cachebox annotation found, or cache annotation found
					if( structKeyExists(md,"cacheBox") OR ( structKeyExists(md,"cache") AND isBoolean(md.cache) AND md.cache ) ){
						instance.scope = arguments.binder.SCOPES.CACHEBOX;
					}

					// check if scope found? If so, then set it to no scope.
					if( NOT len(instance.scope) ){ instance.scope = "noscope"; }

				} // end of persistence checks

				// Cachebox Persistence Processing
				if( instance.scope EQ arguments.binder.SCOPES.CACHEBOX ){
					// Check if we already have a key, maybe added via configuration
					if( NOT len( instance.cache.key ) ){
						instance.cache.key = "wirebox-#instance.name#";
					}
					// Check the default provider now to see if set by configuration
					if( NOT len( instance.cache.provider) ){
						// default it first
						instance.cache.provider = "default";
						// Now check the annotations for the provider
						if( structKeyExists(md,"cacheBox") AND len(md.cacheBox) ){
							instance.cache.provider = md.cacheBox;
						}
					}
					// Check if timeouts set by configuration or discovery
					if( NOT len( instance.cache.timeout ) ){
						// Discovery by annocations
						if( structKeyExists(md,"cachetimeout") AND isNumeric(md.cacheTimeout) ){
							instance.cache.timeout = md.cacheTimeout;
						}
					}
					// Check if lastAccessTimeout set by configuration or discovery
					if( NOT len( instance.cache.lastAccessTimeout ) ){
						// Discovery by annocations
						if( structKeyExists(md,"cacheLastAccessTimeout") AND isNumeric(md.cacheLastAccessTimeout) ){
							instance.cache.lastAccessTimeout = md.cacheLastAccessTimeout;
						}
					}
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
				if( NOT len(instance.eagerInit) ){
					if( structKeyExists(md,"eagerInit") ){
						instance.eagerInit = true;
					}
					else{
						// defaults to lazy loading
						instance.eagerInit = false;
					}
				}

				// threadSafe wiring annotation
				if( NOT len(instance.threadSafe) ){
					if( structKeyExists(md,"threadSafe") AND NOT len(md.threadSafe)){
						instance.threadSafe = true;
					}
					else if( structKeyExists(md,"threadSafe") AND len(md.threadSafe) AND isBoolean(md.threadSafe) ){
						instance.threadSafe = md.threadSafe;
					}
					else{
						// defaults to non thread safe wiring
						instance.threadSafe = false;
					}
				}

				// mixins annotation only if not overriden
				if( NOT arrayLen(instance.mixins) ){
					if( structKeyExists(md,"mixins") ){
						instance.mixins = listToArray( md.mixins );
					}
				}

				// check if the autowire NOT set, so we can discover it.
				if( NOT len(instance.autowire) ){
					// Check if autowire annotation found or autowire already set
					if( structKeyExists(md,"autowire") and isBoolean(md.autowire) ){
						instance.autoWire = md.autowire;
					}
					else{
						// default to true
						instance.autoWire = true;
					}
				}

				// look for parent metadata on the instance referring to an abstract parent (by alias) to copy
				// dependencies and definitions from
				if( structKeyExists(md, "parent") and len(trim(md.parent))){
					arguments.binder.parent(alias:md.parent);
				}

				// Only process if autowiring
				if( instance.autoWire ){
					// Process Methods, Constructors and Properties only if non autowire annotation check found on component.
					processDIMetadata( arguments.binder, md );
				}

				// AOP AutoBinding only if both @classMatcher and @methodMatcher exist
				if( isAspectAutoBinding() AND structKeyExists(md,"classMatcher") AND structKeyExists(md,"methodMatcher") ){
					processAOPBinding( arguments.binder, md);
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

	<!--- processAOPBinding --->
    <cffunction name="processAOPBinding" output="false" access="private" returntype="any" hint="Process the AOP self binding aspects">
    	<cfargument name="binder" 		required="true" hint="The binder requesting the processing"/>
		<cfargument name="metadata" 	required="true" hint="The metadata to process"/>
		<cfscript>
			var classes 		= listFirst(arguments.metadata.classMatcher,":");
			var methods 		= listFirst(arguments.metadata.methodMatcher,":");
			var classMatcher 	= "";
			var methodMatcher 	= "";

			// determine class matching
			switch(classes){
				case "any" : { classMatcher = arguments.binder.match().any(); break; }
				case "annotatedWith" : {
					// annotation value?
					if( listLen(arguments.metadata.classMatcher,":") eq 3 ){
						classMatcher = arguments.binder.match().annotatedWith( getToken(arguments.metadata.classMatcher,2,":"), getToken(arguments.metadata.classMatcher,3,":") );
					}
					// No annotation value
					else{
						classMatcher = arguments.binder.match().annotatedWith( getToken(arguments.metadata.classMatcher,2,":") );
					}
					break;
				}
				case "mappings" : { classMatcher = arguments.binder.match().mappings( getToken(arguments.metadata.classMatcher,2,":") ); break; }
				case "instanceOf" : { classMatcher = arguments.binder.match().instanceOf( getToken(arguments.metadata.classMatcher,2,":") ); break; }
				case "regex" : { classMatcher = arguments.binder.match().regex( getToken(arguments.metadata.classMatcher,2,":") ); break; }
				default: {
					// throw, no matching matchers
					throw(message="Invalid Class Matcher: #classes#",
						  type="Mapping.InvalidAOPClassMatcher",
						  detail="Valid matchers are 'any,annotatedWith:annotation,annotatedWith:annotation:value,mappings:XXX,instanceOf:XXX,regex:XXX'");
				}
			}

			// determine method matching
			switch(methods){
				case "any" : { methodMatcher = arguments.binder.match().any(); break; }
				case "annotatedWith" : {
					// annotation value?
					if( listLen(arguments.metadata.classMatcher,":") eq 3 ){
						methodMatcher = arguments.binder.match().annotatedWith( getToken(arguments.metadata.methodMatcher,2,":"), getToken(arguments.metadata.methodMatcher,3,":") );
					}
					// No annotation value
					else{
						methodMatcher = arguments.binder.match().annotatedWith( getToken(arguments.metadata.methodMatcher,2,":") );
					}
					break;
				}
				case "methods" : { methodMatcher = arguments.binder.match().methods( getToken(arguments.metadata.methodMatcher,2,":") ); break; }
				case "instanceOf" : { methodMatcher = arguments.binder.match().instanceOf( getToken(arguments.metadata.methodMatcher,2,":") ); break; }
				case "regex" : { methodMatcher = arguments.binder.match().regex( getToken(arguments.metadata.methodMatcher,2,":") ); break; }
				default: {
					// throw, no matching matchers
					throw(message="Invalid Method Matcher: #classes#",
						  type="Mapping.InvalidAOPMethodMatcher",
						  detail="Valid matchers are 'any,annotatedWith:annotation,annotatedWith:annotation:value,methods:XXX,instanceOf:XXX,regex:XXX'");
				}
			}

			// Bind the Aspect to this Mapping
			arguments.binder.bindAspect(classMatcher,methodMatcher,getName());
    	</cfscript>
    </cffunction>

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
						// prepare default params, we do this so we do not alter the md as it is cached by cf
						params = {
							scope="variables", inject="model", name=md.properties[x].name, required=true, type="any"
						};
						// default property type
						if( structKeyExists( md.properties[ x ], "type" ) ){
							params.type = md.properties[ x ].type;
						}
						// default injection scope, if not found in object
						if( structKeyExists(md.properties[x],"scope") ){
							params.scope = md.properties[x].scope;
						}
						// Get injection if it exists
						if( len(md.properties[x].inject) ){
							params.inject = md.properties[x].inject;
						}
						// Get required
						if( structKeyExists( md.properties[ x ], "required" ) and isBoolean( md.properties[ x ].required ) ){
							params.required = md.properties[ x ].required;
						}
						// Add to property to mappings
						addDIProperty( name=params.name, dsl=params.inject, scope=params.scope, required=params.required, type=params.type );
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

							// prepare params as we do not alter md as cf caches it
							params = {
								required = false, inject="model", name=md.functions[x].parameters[y].name, type="any"
							};
							// check type annotation
							if( structKeyExists( md.functions[ x ].parameters[ y ], "type" ) ){
								params.type = md.functions[ x ].parameters[ y ].type;
							}
							// Check required annotation
							if( structKeyExists(md.functions[x].parameters[y], "required") ){
								params.required = md.functions[x].parameters[y].required;
							}
							// Check injection annotation, if not found then no injection
							if( structKeyExists(md.functions[x].parameters[y],"inject") ){

								// Check if inject has value, else default it to 'model' or 'id' namespace
								if( len(md.functions[x].parameters[y].inject) ){
									params.inject = md.functions[x].parameters[y].inject;
								}

								// ADD Constructor argument
								addDIConstructorArgument(name=params.name,
														 dsl=params.inject,
														 required=params.required,
														 type=params.type);
							}

						}
						// add constructor to found list, so it is processed only once in recursions
						arguments.dependencies[md.functions[x].name] = "constructor";
					}

					// Setter discovery, MUST be inject annotation marked to be processed.
					if( left(md.functions[x].name,3) eq "set" AND structKeyExists(md.functions[x],"inject")){

						// setup setter params in order to avoid touching the md struct as cf caches it
						params = {inject="model",name=right(md.functions[x].name, Len(md.functions[x].name)-3)};

						// Check DSL marker if it has a value else use default of Model
						if( len(md.functions[x].inject) ){
							params.inject = md.functions[x].inject;
						}
						// Add to setter to mappings and recursion lookup
						addDISetter(name=params.name,dsl=params.inject);
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

		</cfscript>
	</cffunction>

	<!--- getDIDefinition --->
    <cffunction name="getDIDefinition" output="false" access="private" returntype="any" hint="Get a new DI definition structure" colddoc:generic="structure">
    	<cfreturn duplicate(variables.DIDefinition)>
    </cffunction>

</cfcomponent>