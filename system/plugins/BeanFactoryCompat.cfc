<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author: Luis Majano
Date:   July 28, 2006
Description: This is the framework's simple bean factory.

----------------------------------------------------------------------->
<cfcomponent hint="I am the ColdBox BeanFactory plugin that takes care of autowiring and dependency injection"
			 extends="coldbox.system.Plugin"
			 output="false"
			 singleton="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="BeanFactoryCompat" output="false" hint="constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<!--- ************************************************************* --->
		<cfscript>
			super.init(arguments.controller);

			//Plugin properties
			setpluginName("Bean Factory - WireBox lite");
			setpluginVersion("4.0");
			setpluginDescription("I am an awesome conventions,IoC and DI bean factory plugin.");
			setpluginAuthor("Luis Majano, Sana Ullah");
			setpluginAuthorURL("http://www.coldbox.org");

			// Model Settings
			instance.ModelsPath 			= getSetting("ModelsPath");
			instance.ModelsInvocationPath 	= getSetting("ModelsInvocationPath");
			instance.ModelsObjectCaching 	= getSetting("ModelsObjectCaching");
			instance.ModelsExternalLocation = getSetting("ModelsExternalLocation");
			instance.ModelsDefinitionFile 	= getSetting("ModelsDefinitionFile");
			instance.ModelsStopRecursion	= getSetting("ModelsStopRecursion");
			instance.ModelsSetterInjection	= getSetting("ModelsSetterInjection");
			instance.ModelsDICompleteUDF	= getSetting("ModelsDICompleteUDF");
			instance.cacheCompatMode		= getSetting("cacheSettings").compatMode;

			// Model Mappings Map
			instance.modelMappings 	= structnew();
			instance.NOT_FOUND 		= "_NOT_FOUND_";
			instance.refLocationMap = structnew();
			instance.cachePrefix	= "model-";

			// Default DSL marker
			instance.dslMarker = "inject";
			if( settingExists("BeanFactory_dslMarker") ){
				instance.dslMarker = getSetting("BeanFactory_dslMarker");
			}

			// Default DSL Type, mostly used in setters or constructor arguments.
			instance.dslDefaultType = "model";
			if( len(trim(getSetting("IOCFramework"))) ){
				instance.dslDefaultType = "ioc";
			}

			// Default DSL Type override
			if( settingExists("BeanFactory_dslDefaultType") ){
				instance.dslDefaultType = getSetting("BeanFactory_dslDefaultType");
			}

			// Setup the Autowire DI Dictionary
			setDICacheDictionary(CreateObject("component","coldbox.system.core.collections.BaseDictionary").init('DIMetadata'));
			instance.autowireCache = structnew();
			// Bean Populator
			instance.beanPopulator 	= createObject("component","coldbox.system.core.dynamic.BeanPopulator").init();
			// Mixer util
			instance.mixerUtil     	= CreateObject("component","coldbox.system.core.dynamic.MixerUtil").init();
			// Cache Reference
			instance.cache			= getColdBoxOCM();
			// Configure the plugin
			configure();

			return this;
		</cfscript>
	</cffunction>
	
	<!--- getAutowireCache --->
    <cffunction name="getAutowireCache" output="false" access="public" returntype="any" hint="Get a structure of all the metadata available for all autowired model objects">
    	<cfreturn instance.autowireCache>
    </cffunction>

	<!--- configure --->
	<cffunction name="configure" access="public" returntype="BeanFactoryCompat" hint="Configure the bean factory for operation from the configuration file." output="false" >
		<cfscript>
			var configFilePath = "/";
			var appLocPrefix = "/";
			var refLocal = structnew();

			//App location prefix
			if( len(getSetting('AppMapping')) ){
				appLocPrefix = appLocPrefix & getSetting('AppMapping') & "/";
			}

			// Setup the config Path for relative location first.
			configFilePath = appLocPrefix & reReplace(instance.ModelsDefinitionFile,"^/","");
			if( NOT fileExists(expandPath(configFilePath)) ){

				//Check absolute location as not found inside our app
				configFilePath = instance.ModelsDefinitionFile;
				if( NOT fileExists(expandPath(configFilePath)) ){
					if( log.canInfo() ){
						log.info("No bean factory model mappings configuration file found, continuing operation.");
					}
					return this;
				}
			}

			// We are ready to roll. Import configuration as we have found it somewhere
			try{
				$include(configFilePath);
			}
			catch(Any e){
				$throw("Error including configuration file #configFilePath#. Error: #e.message#",
					   e.detail & e.tagContext.toString(),
					   "BeanFactory.ModelsDefinitionFileIncludeException");
			}

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Add Model Mapping --->
	<cffunction name="addModelMapping" access="public" returntype="void" hint="Add a new model mapping. Ex: addModelMapping('myBean','security.test.FormBean'). The alias can be a single item or a comma delimmitted list" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="alias" required="false" type="any" hint="The model alias to use, this can also be a list of aliases. Ex: SecurityService,Security">
		<cfargument name="path"  required="true"  type="any" hint="The model path (From the model conventions downward). Do not add full path, this is a convenience">
		<!--- ************************************************************* --->
		<cfscript>
			var x = 1;

			// Default Alias is from the path if alias not sent.
			if(NOT structKeyExists(arguments,"alias") ){
				arguments.alias = listlast(arguments.path,".");
			}

			// Loop and add aliases
			for(x=1;x lte listlen(arguments.alias); x=x+1){
				instance.modelMappings[listgetAt(arguments.alias,x)] = arguments.path;
			}
		</cfscript>
	</cffunction>

	<!--- Get Model --->
	<cffunction name="getModel" access="public" returntype="any" hint="Create or retrieve model objects by convention" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 				required="false" type="any" default="" hint="The name of the model to retrieve">
		<cfargument name="useSetterInjection" 	required="false" type="any" hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence. Boolean" colddoc:generic="Boolean">
		<cfargument name="onDICompleteUDF" 		required="false" type="any"	hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete">
		<cfargument name="stopRecursion"		required="false" type="any"  hint="A comma-delimmited list of stoprecursion classpaths.">
		<cfargument name="dsl"					required="false" type="any"  hint="The dsl string to use to retrieve the domain object"/>
		<cfargument name="executeInit"			required="false" type="any" default="true" hint="Whether to execute the init() constructor or not.  Defaults to execute, Boolean" colddoc:generic="Boolean"/>
		<!--- ************************************************************* --->
		<cfscript>
			var oModel 			 = 0;
			var modelClassPath   = 0;
			var md 				 = 0;
			var announceData 	 = structnew();
			var isModelFinalized = false;
			var definition		 = structnew();
			var alias			 = arguments.name;
			var cacheKey		 = "";
			var refLocal		 = structnew();
			var cacheCompatMode	 = instance.cacheCompatMode;

			// Are we using dsl or name localization?
			if( structKeyExists(arguments,"dsl") ){
				definition.type = arguments.dsl;
				return getDSLDependency(definition);
			}

			// Resolve name in Aliases
			arguments.name = resolveModelAlias(arguments.name);

			// Class Path
			modelClassPath = locateModel(arguments.name);

			// Trip error if not found
			if( NOT len(modelClassPath) ){
				$throw(message="Model #arguments.name# could not be located.",
					   detail="The model object could not be located in the following locations: #instance.ModelsPath# OR #instance.ModelsExternalLocation#",
					   type="BeanFactory.modelNotFoundException");
			}

			// Construct CacheKey
			cacheKey = buildCacheKey(alias,modelClassPath);
			// Get model
			refLocal.oModel = instance.cache.get( cacheKey );
			// Test it, existance is enough for cacheBox
			if( structKeyExists(refLocal,"oModel") AND NOT cacheCompatMode){
				return refLocal.oModel;				
			}
			// Test it via compat mode (deprecated by 3.1)
			if( cacheCompatMode AND 
				(
					( NOT isSimpleValue(refLocal.oModel) ) 
					 OR 
					( refLocal.oModel neq instance.cache.NOT_FOUND )
				)
				){
				return refLocal.oModel;
			}
			
			// Argument Overrides, else grab from existing settings
			if( not structKeyExists(arguments,"useSetterInjection") ){
				arguments.useSetterInjection = instance.ModelsSetterInjection;
			}
			if( not structKeyExists(arguments,"onDICompleteUDF") ){
				arguments.onDICompleteUDF = instance.ModelsDICompleteUDF;
			}
			if( not structKeyExists(arguments,"stopRecursion") ){
				arguments.stopRecursion = instance.ModelsStopRecursion;
			}
		</cfscript>

		<!--- Create It if it exists, race conditions --->
		<cfif NOT isModelFinalized>
			<cflock name="beanfactory.createmodel.#arguments.name#" type="exclusive" timeout="20" throwontimeout="true">
				<cfscript>
				if( NOT isModelFinalized ){
					// Create the model object
					oModel = createObject("component", modelClassPath);
					//If we are to execute the init() constructor, then do it.
					if ( arguments.executeInit ) {
						// Verify Constructor: Init() and execute
						if( structKeyExists(oModel,"init") ){
							try{
								oModel.init(argumentCollection=getConstructorArguments(oModel));
							}
							catch(Any e){
								$throw(message="Error constructing model: #arguments.name#",
									   detail=e.message & e.detail & e.stacktrace,
									   type="BeanFactory.BeanCreationException");
							}
						}
					}
					// Persistence Checks
					if( instance.ModelsObjectCaching ){
						// Caching Metadata exists?
						if( NOT structKeyExists(instance.autowireCache, modelClassPath) ){
							instance.autowireCache[modelClassPath] = getMetadata(oModel);
						}
						md = instance.autowireCache[modelClassPath];
						// persistence checks
						if( not structKeyExists(md,"cache") or not isBoolean(md.cache) ){
							md.cache = false;
						}
						// Singleton Support
						if( structKeyExists(md,"singleton") ){
							md.cache = true;
							md.cacheTimeout = 0;
						}
						// Are we Caching?
						if( md.cache ){
							// Prepare Timeouts and info.
							if( not structKeyExists(md,"cachetimeout") or not isNumeric(md.cacheTimeout) ){
								md.cacheTimeout = "";
							}
							if( not structKeyExists(md,"cacheLastAccessTimeout") or not isNumeric(md.cacheLastAccessTimeout) ){
								md.cacheLastAccessTimeout = "";
							}
							// Cache This Puppy.
							instance.cache.set(cacheKey,oModel,md.cacheTimeout,md.CacheLastAccessTimeout);
						}
					}//end if caching enabled via settings.

					// Autowire Dependencies
					autowire(target=oModel,
							 useSetterInjection=arguments.useSetterInjection,
							 annotationCheck=false,
							 onDICompleteUDF=arguments.onDICompleteUDF,
							 stopRecursion=arguments.stopRecursion,
							 targetID=modelClassPath);

					// Announce Model Creation
					announceData.oModel = oModel;
					announceData.modelName = arguments.name;
					announceData.modelClassPath = modelClassPath;
					announceInterception("afterInstanceCreation",announceData);
					// Model Creation Finalized
					isModelFinalized = true;
				}
				</cfscript>
			</cflock>
		<cfelse>
			<cfthrow message="Model #arguments.name# could not be located."
					 type="BeanFactory.modelNotFoundException"
					 detail="The model object #arguments.name# cannot be located in the following locations: #instance.ModelsPath# OR #instance.ModelsExternalLocation#">
		</cfif>

		<cfreturn oModel>
	</cffunction>

	<!--- Resolve Model Alias --->
	<cffunction name="resolveModelAlias" access="public" returntype="string" hint="Resolve the real name of any incoming argument model name or alias" output="false" >
		<cfargument name="name" required="true"  type="any" hint="The model alias or name to resolve">
		<cfscript>
			// Resolve name in Aliases
			if( structKeyExists(instance.modelMappings,arguments.name) ){
				return instance.modelMappings[arguments.name];
			}

			return arguments.name;
		</cfscript>
	</cffunction>

	<!--- getExternalLocations --->
	<cffunction name="getExternalLocations" output="false" access="public" returntype="string" hint="Get all the registered external locations">
		<cfreturn instance.ModelsExternalLocation>
	</cffunction>

	<!--- removeExternalLocations --->
	<cffunction name="removeExternalLocations" output="false" access="public" returntype="void" hint="Try to remove all the external locations passed in">
		<cfargument name="locations" type="string" required="true" hint="Locations to remove from the lookup.  Comma delimited allowed."/>
		<cfscript>
			var currentList = getExternalLocations();
			var x 				= 1;
			var idxFound 	= "";

			// Validate locations
			if( len(trim(arguments.locations)) eq 0){ return; }

			// Loop and Add
			for(;x lte listlen(arguments.locations); x=x+1 ){
				//Check if found in list
				idxFound = listFindNoCase(currentList, listgetAt(arguments.locations,x) );
				if( idxFound ){
					// Remove it
					currentList = listDeleteAt(currentList,idxFound);
				}
			}

			// Save it
			instance.ModelsExternalLocation = currentList;
		</cfscript>
	</cffunction>

	<!--- appendExternalLocation --->
	<cffunction name="appendExternalLocations" output="false" access="public" returntype="void" hint="Try to append a new model external location">
		<cfargument name="locations" type="string" required="true" hint="Locations to add to the lookup, will be added in passed order.  Comma delimited allowed."/>
		<cfscript>
			var currentList = getExternalLocations();
			var x = 1;

			// Validate locations
			if( len(trim(arguments.locations)) eq 0){ return; }

			// Loop and Add
			for(;x lte listlen(arguments.locations); x=x+1 ){
				if ( not listfindnocase(currentList, listgetAt(arguments.locations,x)) ){
					currentList = listAppend(currentList,listgetAt(arguments.locations,x));
				}
			}

			// Save it
			instance.ModelsExternalLocation = currentList;
		</cfscript>
	</cffunction>

	<!--- Locate a Model Object --->
	<cffunction name="locateModel" access="public" returntype="string" hint="Get the location instantiation path for a model object. If the model location is not found, this method returns an empty string." output="false" >
		<cfargument name="name" 		type="any"  required="true" hint="The model to locate">
		<cfargument name="resolveAlias" type="any"  required="false" default="false" hint="Resolve model aliases">
		<cfscript>
			var checkPath 			= 0;
			var checkExternalPath 	= 0;
			var extPaths 			= instance.ModelsExternalLocation;
			var thisExtPath 		= "";
			var x					= 1;

			// Resolve Alias?
			if( arguments.resolveAlias ){
				arguments.name = resolveModelAlias(arguments.name);
			}

			// Check refLocationMap for location discovery
			if( structKeyExists(instance.refLocationMap, arguments.name) ){
				return instance.refLocationMap[ arguments.name ];
			}

			// Conventions Check First
			checkPath = instance.ModelsPath & "/" & replace(arguments.name,".","/","all") & ".cfc";

			// Check Conventions First
			if( fileExists(checkPath) ){
				instance.refLocationMap[ arguments.name ] = instance.ModelsInvocationPath & "." & arguments.name;
				return instance.refLocationMap[ arguments.name ];
			}

			// Check External Locations in declared Order
			for(x=1; x lte listLen(extPaths);x=x+1){

				// Compose Object Location
				thisExtPath = listGetAt(extPaths,x);
				checkExternalPath = "/" & replace(thisExtPath,".","/","all")  & "/" & replace(arguments.name,".","/","all") & ".cfc";

				// Check if located
				if( fileExists(expandPath(checkExternalPath)) ){
					instance.refLocationMap[ arguments.name ] = thisExtPath & "." & arguments.name;
					return instance.refLocationMap[ arguments.name ];
				}
			}

			// Try full namespace
			checkPath = "/" & replace(arguments.name,".","/","all") & ".cfc";
			if( fileExists( expandPath(checkPath) ) ){
				instance.refLocationMap[ arguments.name ] = arguments.name;
				return instance.refLocationMap[ arguments.name ];
			}

			return "";
		</cfscript>
	</cffunction>

	<!--- Check if the model exists in a path --->
	<cffunction name="containsModel" access="public" returntype="boolean" hint="Checks if the factory has a model object definition found" output="false" >
		<cfargument name="name" 		type="string"  required="true" hint="The name of the model to check">
		<cfargument name="resolveAlias" type="boolean" required="false" default="false" hint="Resolve model aliases">
		<cfscript>
			// Resolve Alias?
			if( arguments.resolveAlias ){ arguments.name = resolveModelAlias(arguments.name); }

			// Try to Locate with already resolved alias
			if( len(locateModel(arguments.name)) ){
				return true;
			}

			return false;
		</cfscript>
	</cffunction>

	<!--- Autowire --->
	<cffunction name="autowire" access="public" returntype="void" output="false" hint="Autowire an object using the ColdBox DSL">
		<!--- ************************************************************* --->
		<cfargument name="target" 				required="true" 	type="any" 	hint="The object to autowire">
		<cfargument name="useSetterInjection" 	required="false" 	type="any" 	default="true"	hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence. Boolean Value" colddoc:generic="Boolean">
		<cfargument name="annotationCheck" 		required="false" 	type="any"  default="false" hint="This value determines if we check if the target contains an autowire annotation in the cfcomponent tag: autowire=true|false, it will only autowire if that metadata attribute is set to true. The default is false, which will autowire automatically. Boolean Value" colddoc:generic="Boolean">
		<cfargument name="onDICompleteUDF" 		required="false" 	type="any"	default="onDIComplete" hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete" colddoc:generic="string">
		<cfargument name="stopRecursion" 		required="false" 	type="any"  default="" hint="The stop recursion class. Ex: transfer.com.TransferDecorator. By default all ColdBox base classes are included." colddoc:generic="string">
		<cfargument name="targetID"				required="false"	type="any"	default="" hint="A unique resource target identifier used for wiring the sent in target. If not sent, then this will become getMetadata(target).name and use resources." colddoc:generic="string">
		<!--- ************************************************************* --->
		<cfscript>
			// Targets
			var targetObject 	= arguments.target;
			var targetCacheKey 	= arguments.targetID;
			var metaData 		= "";
			
			// Dependencies
			var thisDependency = instance.NOT_FOUND;

			// Metadata entry structures
			var mdEntry 			= "";
			var targetDIEntry 		= "";
			var dependenciesLength 	= 0;
			var x 					= 1;
			var tmpBean 			= "";	
			
			// do we have a targetCache Key?
			if( NOT len(targetCacheKey) ){
				// Not sent, so get metadata, cache it and build cache id
				metadata 		= getMetadata(targetObject);
				targetCacheKey 	= metadata.name;
				instance.autowireCache[targetCacheKey] = metadata;
			}	
			// is md cached for target?
			else if( NOT structKeyExists(instance.autowireCache, targetCacheKey) ){
				metadata = getMetadata(targetObject);
				instance.autowireCache[targetCacheKey] = metadata;
			}
			else{
				// Get metadata for autowire target
				metadata = instance.autowireCache[targetCacheKey];
			}
		</cfscript>

		<!--- Do we have the incoming target object's data in the cache? or caching disabled for objects --->
		<cfif NOT instance.DICacheDictionary.keyExists(targetCacheKey) OR NOT instance.modelsObjectCaching>
			<cflock type="exclusive" name="plugins.autowire.#targetCacheKey#" timeout="30" throwontimeout="true">
				<cfscript>
					if ( not instance.DICacheDictionary.keyExists(targetCacheKey) ){
						// Get Empty Default MD Entry, default autowire = false
						mdEntry = getNewMDEntry();

						// Annotation Checks
						if( arguments.annotationCheck eq false){
							mdEntry.autowire = true;
						}
						else if ( structKeyExists(metaData,"autowire") and isBoolean(metaData["autowire"]) ){
							mdEntry.autowire = metaData.autowire;
						}

						// Lookup Dependencies if using autowire and not a ColdBox core object
						if ( mdEntry.autowire and findNoCase("coldbox.system",metaData.name) EQ 0 ){
							// Recurse for dependencies here, in order to build them
							mdEntry.dependencies = parseMetadata(metaData,mdEntry.dependencies,arguments.useSetterInjection,arguments.stopRecursion);
						}

						// Set Entry in dictionary
						instance.DICacheDictionary.setKey(targetCacheKey,mdEntry);
					}
				</cfscript>
			</cflock>
		</cfif>

		<cfscript>
		// We are now assured that the DI cache has data.
		targetDIEntry = instance.DICacheDictionary.getKey(targetCacheKey);

		// Do we Inject Dependencies, are we AutoWiring
		if ( targetDIEntry.autowire ){

			// Bean Factory Awareness
			if( structKeyExists(targetObject,"setBeanFactory") ){
				targetObject.setBeanFactory( this );
			}

			// ColdBox Context Awareness
			if( structKeyExists(targetObject,"setColdBox") ){
				targetObject.setColdBox( controller );
			}

			// Dependencies Length
			dependenciesLength = arrayLen(targetDIEntry.dependencies);
			if( dependenciesLength gt 0 ){
				// Let's inject our mixins
				instance.mixerUtil.start(targetObject);

				// Loop over dependencies and inject
				for(x=1; x lte dependenciesLength; x=x+1){
					// Get Dependency
					thisDependency = getDSLDependency(definition=targetDIEntry.dependencies[x]);

					// Was dependency Found?
					if( isSimpleValue(thisDependency) and thisDependency eq instance.NOT_FOUND ){
						if( log.canDebug() ){
							log.debug("Dependency: #targetDIEntry.dependencies[x].toString()# Not Found when wiring #getMetadata(arguments.target).name#");
						}
						continue;
					}

					// Inject dependency
					injectBean(targetBean=targetObject,
							   beanName=targetDIEntry.dependencies[x].name,
							   beanObject=thisDependency,
							   scope=targetDIEntry.dependencies[x].scope);

					if( log.canDebug() ){
						log.debug("Dependency: #targetDIEntry.dependencies[x].toString()# --> injected into #getMetadata(targetObject).name#.");
					}
				}//end for loop of dependencies.

				// Process After ID Complete
				processAfterCompleteDI(targetObject,onDICompleteUDF);

			}// if dependencies found.
		}//if autowiring
	</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- buildCacheKey --->
    <cffunction name="buildCacheKey" output="false" access="private" returntype="any" hint="Get a cache key constructed for model objects">
    	<cfargument name="alias" 	type="any"/>
		<cfargument name="location" type="any"/>
		<cfscript>
			return instance.cachePrefix & arguments.alias & "-" & arguments.location;
		</cfscript>
    </cffunction>

	<!--- getConstructorArguments --->
	<cffunction name="getConstructorArguments" output="false" access="private" returntype="struct" hint="The constructor argument collection for a model object">
		<!--- ************************************************************* --->
		<cfargument name="model" required="true" 	type="any"		default="" hint="The model object"/>
		<!--- ************************************************************* --->
		<cfscript>
			var md = getMetadata(model.init);
			var params = md.parameters;
			var paramLen = ArrayLen(md.parameters);
			var x =1;
			var args = structnew();
			var definition = structnew();
			var thisDependency = instance.NOT_FOUND;

			// Loop Over Arguments
			for(x=1;x lte paramLen; x=x+1){
				// Check Marker and IOC Framework
				if( structKeyExists(params[x],instance.dslMarker) ){
					definition.type = params[x][instance.dslMarker];
				}
				else{
					definition.type = instance.dslDefaultType;
				}
				// Other Defaults
				definition.name = params[x].name;
				definition.scope="";

				// Get Dependency
				thisDependency = getDSLDependency(definition=definition);
				if( isSimpleValue(thisDependency) and thisDependency eq instance.NOT_FOUND ){
					if( log.canDebug() ){
						log.debug("Constructor Dependency: #definition.toString()# not found when wiring model: #getMetaData(arguments.model).name#, skipping");
					}
				}
				else{
					args[definition.name] = thisDependency;
				}
			}

			return args;
		</cfscript>
	</cffunction>

	<!--- getDSLDependency --->
	<cffunction name="getDSLDependency" output="false" access="private" returntype="any" hint="get a dsl dependency">
		<!--- ************************************************************* --->
		<cfargument name="definition" required="true" 	type="any" hint="The dependency definition structure">
		<!--- ************************************************************* --->
		<cfscript>
			var dependency = instance.NOT_FOUND;
			var DSLNamespace = listFirst(arguments.Definition.type,":");

			// Determine Type of Injection according to Type
			switch(DSLNamespace){
				case "ioc" 				: { dependency = getIOCDependency(arguments.definition); break; }
				case "ocm" 				: { dependency = getOCMDependency(arguments.definition); break; }
				case "coldbox" 			: { dependency = getColdboxDSL(arguments.definition); break; }
				case "model" 			: { dependency = getModelDSL(definition=arguments.definition); break; }
				case "webservice" 		: { dependency = getWebserviceDSL(arguments.definition); break; }
				case "logbox"			: { dependency = getLogBoxDSL(definition=arguments.definition); break;}
				case "javaloader"		: { dependency = getJavaLoaderDSL(definition=arguments.definition); break;}
				case "entityService"	: { dependency = getEntityServiceDSL(definition=arguments.definition); break;}
				case "cacheBox"			: { dependency = getCacheBoxDSL(definition=arguments.definition); break;}
			}

			return dependency;
		</cfscript>
	</cffunction>

	<!--- getEntityServiceDSL --->
	<cffunction name="getEntityServiceDSL" access="private" returntype="any" hint="Get a virtual entity service object" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<!--- ************************************************************* --->
		<cfscript>
			var thisDependency  = arguments.Definition;
			var entityName  	= getToken(thisDependency.type,2,":");

			// Do we have an entity name? If we do create virtual entity service
			if( len(entityName) ){
				return createObject("component","coldbox.system.orm.hibernate.VirtualEntityService").init(entityName);
			}

			// else Return Base ORM Service
			return createObject("component","coldbox.system.orm.hibernate.BaseORMService").init();
		</cfscript>
	</cffunction>

	<!--- getWebserviceDSL --->
	<cffunction name="getWebserviceDSL" access="private" returntype="any" hint="Get webservice dependencies" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="Definition" 	required="true" type="any" hint="The dependency definition structure">
		<!--- ************************************************************* --->
		<cfscript>
			var oWebservices = getPlugin("Webservices");
			var thisDependency = arguments.Definition;
			var webserviceName = listLast(thisDependency.type,":");

			// Get Dependency
			return oWebservices.getWSobj(webserviceName);
		</cfscript>
	</cffunction>

	<!--- getJavaLoaderDSL --->
	<cffunction name="getJavaLoaderDSL" access="private" returntype="any" hint="Get JavaLoader Dependency" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<!--- ************************************************************* --->
		<cfscript>
			var thisDependency  = arguments.Definition;
			var className  = listLast(thisDependency.type,":");

			// Get Dependency
			return getPlugin("JavaLoader").create(className);
		</cfscript>
	</cffunction>

	<!--- getModelDSL --->
	<cffunction name="getModelDSL" access="private" returntype="any" hint="Get dependencies using the model dependency DSL" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="definition" 			required="true" 	type="any" hint="The dependency definition structure">
		<!--- ************************************************************* --->
		<cfscript>
			var thisDependency = arguments.Definition;
			var thisType = thisDependency.type;
			var thisTypeLen = listLen(thisType,":");
			var thisLocationType = "";
			var thisLocationKey = "";
			var locatedDependency = instance.NOT_FOUND;
			var args = structnew();

			// DSL stages
			switch(thisTypeLen){
				//model default
				case 1: { args.name = arguments.Definition.name; break; }
				//model:{name} stage
				case 2: {
					thisLocationType = getToken(thisType,2,":");
					args.name = thisLocationType;
					break;
				}
				//model:{name}:{method} stage
				case 3: {
					thisLocationType = getToken(thisType,2,":");
					thisLocationKey = getToken(thisType,3,":");
					args.name = thisLocationType;
					break;
				}
			}

			// Check if model Exists
			if( containsModel(name=args.name,resolveAlias=true) ){
				// Get Model
				locatedDependency = getModel(argumentCollection=args);
				// Factories: TODO: Need Encap here and change evaluation to allso allow arguments.
				if( thisTypeLen eq 3 ){
					locatedDependency = evaluate("locatedDependency.#thisLocationKey#()");
				}
			}
			else if( log.canDebug() ){
				log.debug("getModelDSL() cannot find model object #args.name# using definition #arguments.definition.toString()#");
			}

			return locatedDependency;
		</cfscript>
	</cffunction>

	<!--- getColdboxDSL --->
	<cffunction name="getColdboxDSL" access="private" returntype="any" hint="Get dependencies using the coldbox dependency DSL" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<!--- ************************************************************* --->
		<cfscript>
			var thisDependency = arguments.Definition;
			var thisType = thisDependency.type;
			var thisTypeLen = listLen(thisType,":");
			var thisLocationType = "";
			var thisLocationKey = "";
			var locatedDependency = instance.NOT_FOUND;

			// DSL stages
			switch(thisTypeLen){
				// coldbox only
				case 1: { locatedDependency = getController(); break;}
				// coldbox:{key} stage 2
				case 2: {
					thisLocationKey = getToken(thisType,2,":");
					switch( thisLocationKey ){
						case "fwconfigbean" 		: { locatedDependency = getSettingsBean(true); break; }
						case "configbean" 			: { locatedDependency = getSettingsBean(); break; }
						case "mailsettingsbean"		: { locatedDependency = getMailSettings(); break; }
						case "loaderService"		: { locatedDependency = getController().getLoaderService(); break; }
						case "requestService"		: { locatedDependency = getController().getrequestService(); break; }
						case "debuggerService"		: { locatedDependency = getController().getDebuggerService(); break; }
						case "pluginService"		: { locatedDependency = getController().getPluginService(); break; }
						case "handlerService"		: { locatedDependency = getController().gethandlerService(); break; }
						case "interceptorService"	: { locatedDependency = getController().getinterceptorService(); break; }
						case "cacheManager"			: { locatedDependency = instance.cache; break; }
						case "moduleService"		: { locatedDependency = getController().getModuleService(); break; }
					}//end of services
					break;
				}
				//coldobx:{key}:{target} Usually for named factories
				case 3: {
					thisLocationType = getToken(thisType,2,":");
					thisLocationKey  = getToken(thisType,3,":");
					switch(thisLocationType){
						case "setting" 				: { locatedDependency = getSetting(thisLocationKey); break; }
						case "fwSetting" 			: { locatedDependency = getSetting(thisLocationKey,true); break; }
						case "plugin" 				: { locatedDependency = getPlugin(thisLocationKey); break; }
						case "myplugin" 			: {
							if( find("@",thisLocationKey) ){
								locatedDependency = getMyPlugin(plugin=listFirst(thisLocationKey,"@"),module=listLast(thisLocationKey,"@"));
							}
							else{
								locatedDependency = getMyPlugin(thisLocationKey);
							}
							break;
						}
						case "datasource" 			: { locatedDependency = getDatasource(thisLocationKey); break; }
						case "interceptor" 			: { locatedDependency = getInterceptor(thisLocationKey,true); break; }
					}//end of services
					break;
				}
			}

			return locatedDependency;
		</cfscript>
	</cffunction>


	<!--- getLogBoxDSL --->
	<cffunction name="getLogBoxDSL" access="private" returntype="any" hint="Get dependencies using the logbox dependency DSL" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<!--- ************************************************************* --->
		<cfscript>
			var thisDependency = arguments.Definition;
			var thisType = thisDependency.type;
			var thisTypeLen = listLen(thisType,":");
			var thisLocationType = "";
			var thisLocationKey = "";
			var thisLogBox = getController().getLogBox();
			var locatedDependency = instance.NOT_FOUND;

			// DSL stages
			switch(thisTypeLen){
				// LogBox
				case 1 : { locatedDependency = thisLogBox; break;}
				// Root Logger
				case 2 : {
					thisLocationKey = getToken(thisType,2,":");
					switch( thisLocationKey ){
						case "root" : { locatedDependency = thisLogBox.getRootLogger(); break; }
					}
					break;
				}
				// Named Loggers
				case 3 : {
					thisLocationType = getToken(thisType,2,":");
					thisLocationKey = getToken(thisType,3,":");
					// DSL Level 2 Stage Types
					switch(thisLocationType){
						// Get a named Logger
						case "logger" : { locatedDependency = thisLogBox.getLogger(thisLocationKey); break; }
					}
					break;
				} // end level 3 main DSL
			}

			return locatedDependency;
		</cfscript>
	</cffunction>

	<!--- getCacheBoxDSL --->
	<cffunction name="getCacheBoxDSL" access="private" returntype="any" hint="Get dependencies using the cacheBox dependency DSL" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<!--- ************************************************************* --->
		<cfscript>
			var thisDependency 		= arguments.Definition;
			var thisType 			= thisDependency.type;
			var thisTypeLen 		= listLen(thisType,":");
			var cacheName 			= "";
			var cacheElement 		= "";
			var thisCacheBox 		= getController().getCacheBox();
			var locatedDependency 	= instance.NOT_FOUND;

			// DSL stages
			switch(thisTypeLen){
				// CacheBox
				case 1 : { locatedDependency = thisCacheBox; break;}
				// CacheBox:CacheName
				case 2 : {
					cacheName 			= getToken(thisType,2,":");

					// Verify that cache exists
					if( thisCacheBox.cacheExists( cacheName ) ){
						locatedDependency = thisCacheBox.getCache( cacheName );
					}
					else if( log.canDebug() ){
						log.debug("getOCMDependency() cannot find named cache #cacheName# using definition: #arguments.definition.toString()#. Existing cache names are #thisCacheBox.getCacheNames().toString#");
					}

					break;
				}
				// CacheBox:CacheName:Element
				case 3 : {
					cacheName 			= getToken(thisType,2,":");
					cacheElement 		= getToken(thisType,3,":");

					// Verify that dependency exists in the Cache container
					if( thisCacheBox.getCache( cacheName ).lookup( cacheElement ) ){
						locatedDependency = thisCacheBox.getCache( cacheName ).get( cacheElement );
					}
					else if( log.canDebug() ){
						log.debug("getOCMDependency() cannot find cache Key: #cacheElement# in the #cacheName# cache using definition: #arguments.definition.toString()#");
					}

					break;
				} // end level 3 main DSL
			}

			return locatedDependency;
		</cfscript>
	</cffunction>

	<!--- getIOCDependency --->
	<cffunction name="getIOCDependency" access="private" returntype="any" hint="Get an IOC dependency" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<!--- ************************************************************* --->
		<cfscript>
			var oIOC = getPlugin("IOC");
			var thisDependency = arguments.Definition;
			var thisType = thisDependency.type;
			var thisTypeLen = listLen(thisType,":");
			var thisLocationKey = "";
			var locatedDependency = instance.NOT_FOUND;

			//dump(arguments.definition);abort();

			// DSL stages
			switch(thisTypeLen){
				// ioc name
				case 1: { thisLocationKey = thisDependency.name; break;}
				// ioc:beanName
				case 2: { thisLocationKey = getToken(thisType,2,":"); break;}

			}

			// Check for Bean
			if( oIOC.containsBean(thisLocationKey) ){
				locatedDependency = oIOC.getBean(thisLocationKey);
			}
			else if( log.canDebug() ){
				log.debug("getIOCDependency() cannot find IOC Bean: #thisLocationKey# using definition: #arguments.definition.toString()#");
			}

			return locatedDependency;
		</cfscript>
	</cffunction>

	<!--- getOCMDependency --->
	<cffunction name="getOCMDependency" access="private" returntype="any" hint="Get OCM dependencies" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="definition" 	required="true" type="any" hint="The dependency definition structure">
		<!--- ************************************************************* --->
		<cfscript>
			var thisDependency = arguments.Definition;
			var thisType = thisDependency.type;
			var thisTypeLen = listLen(thisType,":");
			var thisLocationKey = "";
			var locatedDependency = instance.NOT_FOUND;

			// DSL stages
			switch(thisTypeLen){
				// ocm only
				case 1: { thisLocationKey = thisDependency.name; break;}
				// ocm:objectKey
				case 2: { thisLocationKey = getToken(thisType,2,":"); break;}
			}

			// Verify that dependency exists in the Cache container
			if( instance.cache.lookup(thisLocationKey) ){
				locatedDependency = instance.cache.get(thisLocationKey);
			}
			else if( log.canDebug() ){
				log.debug("getOCMDependency() cannot find cache Key: #thisLocationKey# using definition: #arguments.definition.toString()#");
			}

			return locatedDependency;
		</cfscript>
	</cffunction>

	<!--- Get an object's dependencies via metadata --->
	<cffunction name="parseMetadata" returntype="array" access="private" output="false" hint="I get a components dependencies via searching for 'setters'">
		<!--- ************************************************************* --->
		<cfargument name="metadata" 			required="true"  type="any" 	hint="The recursive metadata">
		<cfargument name="dependencies" 		required="true"  type="any" 	hint="The dependencies array" colddoc:generic="array">
		<cfargument name="useSetterInjection" 	required="false" type="any" 	default="true"	hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence. Boolean" colddoc:generic="Boolean">
		<cfargument name="stopRecursion" 		required="false" type="any" 	default="" hint="The stop recursion class(es)">
		<!--- ************************************************************* --->
		<cfscript>
			var x = 1;
			var md = arguments.metadata;
			var entry = structnew();
			var foundDependencies = "";

			//TODO: The foundDependencies check should be made on the recursive array not the single list.

			// Look for Object's attributes, and override if found.
			if( structKeyExists(md,"autowire_stoprecursion") ){
				arguments.stopRecursion = md["autowire_stoprecursion"];
			}
			if( structKeyExists(md,"autowire_setterinjection") and isBoolean(md["autowire_setterinjection"]) ){
				arguments.useSetterInjection = md["autowire_setterinjection"];
			}

			// Look For properties for annotation injections
			if( structKeyExists(md,"properties") and ArrayLen(md.properties) gt 0){

				// Loop over each property and identify injectable properties
				for(x=1; x lte ArrayLen(md.properties); x=x+1 ){

					// Check Inject annotation, if it exists, add it and process it
					if( structKeyExists(md.properties[x],"inject") ){

						// New MD Entry
						entry 		= structnew();
						entry.name 	= md.properties[x].name;
						entry.scope = "variables";
						entry.type 	= instance.dslDefaultType;

						// Scope override if it exists
						if( structKeyExists(md.properties[x],"scope") ){
							entry.scope = md.properties[x].scope;
						}

						// Setup the DSL Type if it has a value
						if( len(md.properties[x].inject) ){
							entry.type 	= md.properties[x].inject;
						}

						// Add to found list
						listAppend(foundDependencies,entry.name);
						ArrayAppend( arguments.dependencies, entry );
					}

				}//end for loop
			}//end if properties found.

			// Setter injection if enabled?
			if( arguments.useSetterInjection and structKeyExists(md, "functions") ){
				for(x=1; x lte ArrayLen(md.functions); x=x+1 ){

					// Verify we have a setter marked with the DSL injector annotation
					if( left(md.functions[x].name,3) eq "set" AND structKeyExists(md.functions[x],instance.dslMarker)){

						// New MD Entry
						entry 		= structnew();
						entry.name 	= right(md.functions[x].name, Len(md.functions[x].name)-3);
						entry.scope = "";
						entry.type 	= instance.dslDefaultType;

						// Check DSL marker if it has a value else use default
						if( len(md.functions[x].instance.dslMarker) ){
							entry.type = md.functions[x][instance.dslMarker];
						}

						// Add if not already in properties
						if( NOT listFindNoCase(foundDependencies,entry.name) ){
							// Found Setter, append property Name
							listAppend(foundDependencies,entry.name);
							ArrayAppend(arguments.dependencies, entry);
						}

					}//end if setter found with annotation

				}//end loop of functions
			}//end if functions found

			// Start Registering inheritances
			if ( structKeyExists(md, "extends")
				 AND
				 stopClassRecursion(classname=md.extends.name,stopRecursion=arguments.stopRecursion) EQ FALSE){

				// Recursive lookup
				arguments.dependencies = parseMetadata(md.extends,arguments.dependencies,arguments.useSetterInjection,arguments.stopRecursion);

			}

			return arguments.dependencies;
		</cfscript>
	</cffunction>

	<!--- Stop Recursion --->
	<cffunction name="stopClassRecursion" access="private" returntype="any" hint="Should we stop recursion or not due to class name found: Boolean" output="false" colddoc:generic="Boolean">
		<!--- ************************************************************* --->
		<cfargument name="classname" 		required="true" type="any" hint="The class name to check">
		<cfargument name="stopRecursion" 	required="true" type="any" hint="The comma delimmitted list of stop recurssion classes">
		<!--- ************************************************************* --->
		<cfscript>
			var coldboxReservedClasses = "coldbox.system.Plugin,coldbox.system.EventHandler,coldbox.system.Interceptor";
			var x = 1;

			// Append Coldbox Classes
			arguments.stopRecursion = listAppend(arguments.stopRecursion,coldboxReservedClasses);

			// Try to find a match
			for(x=1;x lte listLen(arguments.stopRecursion); x=x+1){
				if( CompareNoCase(listGetAt(arguments.stopRecursion,x),arguments.classname) eq 0){
					return true;
				}
			}

			return false;
		</cfscript>
	</cffunction>

	<!--- Inject Bean --->
	<cffunction name="injectBean" access="private" returntype="void" output="false" hint="Inject a bean with dependencies via setters or property injections">
		<!--- ************************************************************* --->
		<cfargument name="targetBean"  	 type="any" required="true" hint="The bean that will be injected with dependencies" />
		<cfargument name="beanName"  	 type="any" required="true" hint="The name of the property to inject"/>
		<cfargument name="beanObject" 	 type="any" required="true" hint="The bean object to inject." />
		<cfargument name="scope" 		 type="any" required="true" hint="The scope to inject a property into.">
		<!--- ************************************************************* --->
		<cfscript>
			var argCollection = structnew();
			argCollection[arguments.beanName] = arguments.beanObject;
		</cfscript>
		<!--- Property or Setter --->
		<cfif len(arguments.scope) eq 0>
			<!--- Call our mixin invoker --->
			<cfinvoke component="#arguments.targetBean#" method="invokerMixin">
				<cfinvokeargument name="method"  		value="set#arguments.beanName#">
				<cfinvokeargument name="argCollection"  value="#argCollection#">
			</cfinvoke>
		<cfelse>
			<!--- Call our property injector mixin --->
			<cfinvoke component="#arguments.targetBean#" method="injectPropertyMixin">
				<cfinvokeargument name="propertyName"  	value="#arguments.beanName#">
				<cfinvokeargument name="propertyValue"  value="#arguments.beanObject#">
				<cfinvokeargument name="scope"			value="#arguments.scope#">
			</cfinvoke>
		</cfif>
	</cffunction>

	<!--- Process After DI Complete --->
	<cffunction name="processAfterCompleteDI" hint="see if we have a method to call after DI, and if so, call it" access="private" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="targetObject" 	required="true"  	type="any"	hint="the target object to call on">
		<cfargument name="onDICompleteUDF" 	required="false" 	type="any"	default="onDIComplete" hint="After Dependencies are injected, this method will look for this UDF and call it if it exists.">
		<!--- ************************************************************* --->
		<!--- Check if method exists --->
		<cfif StructKeyExists(arguments.targetObject, arguments.onDICompleteUDF )>
			<!--- Call our mixin invoker --->
			<cfinvoke component="#arguments.targetObject#" method="invokerMixin">
				<cfinvokeargument name="method"  		value="#arguments.onDICompleteUDF#">
			</cfinvoke>
		</cfif>
	</cffunction>

	<!--- Get a new MD cache entry structure --->
	<cffunction name="getNewMDEntry" access="private" returntype="any" hint="Get a new metadata entry structure" output="false" >
		<cfscript>
			var mdEntry = structNew();

			mdEntry.autowire = false;
			mdEntry.dependencies = Arraynew(1);

			return mdEntry;
		</cfscript>
	</cffunction>

	<!--- Get Set DI CACHE Dictionary --->
	<cffunction name="getDICacheDictionary" access="private" output="false" returntype="any" hint="Get DICacheDictionary" colddoc:generic="coldbox.system.core.collections.BaseDictionary">
		<cfreturn instance.DICacheDictionary/>
	</cffunction>
	<cffunction name="setDICacheDictionary" access="private" output="false" returntype="void" hint="Set DICacheDictionary">
		<cfargument name="DICacheDictionary" type="any" required="true" colddoc:generic="coldbox.system.core.collections.BaseDictionary"/>
		<cfset instance.DICacheDictionary = arguments.DICacheDictionary/>
	</cffunction>

</cfcomponent>