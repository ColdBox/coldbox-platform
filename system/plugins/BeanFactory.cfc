<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author: Luis Majano
Description: I am a plugin that taps into WireBox or the ColdBox Compat BeanFactory

----------------------------------------------------------------------->
<cfcomponent hint="I am a plugin that taps into WireBox or the ColdBox Compat BeanFactory"
			 extends="coldbox.system.Plugin"
			 output="false"
			 singleton>

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="BeanFactory" output="false" hint="constructor">
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<cfscript>
			super.init(arguments.controller);

			//Plugin properties
			setpluginName("BeanFactory - WireBox Facade");
			setpluginVersion("1.0");
			setpluginDescription("I am a plugin that taps into WireBox or the ColdBox Compat BeanFactory");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");

			// Bean Populator
			instance.beanPopulator 	= createObject("component","coldbox.system.core.dynamic.BeanPopulator").init();
			// Compat Mode or Not?
			if( controller.getSetting("WireBox").enabled ){
				instance.wireBox 	= controller.getWireBox();
				instance.compatMode = false;
			}
			else{
				instance.beanFactory 	= getPlugin("BeanFactoryCompat");
				instance.compatMode		= true;
				instance.beanFactory.configure();
			}
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- configure --->
	<cffunction name="configure" access="public" returntype="BeanFactory" hint="Configure the bean factory for operation from the configuration file." output="false" >
		<cfscript>
			instance.beanFactory.configure();
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get Model Mappings --->
	<cffunction name="getModelMappings" access="public" returntype="struct" hint="Get the model mappings structure" output="false" >
		<cfreturn instance.beanFactory.getModelMappings()>
	</cffunction>

	<!--- Add Model Mapping --->
	<cffunction name="addModelMapping" access="public" returntype="void" hint="Add a new model mapping. Ex: addModelMapping('myBean','security.test.FormBean'). The alias can be a single item or a comma delimmitted list" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="alias" required="false" type="any" hint="The model alias to use, this can also be a list of aliases. Ex: SecurityService,Security">
		<cfargument name="path"  required="true"  type="any" hint="The model path (From the model conventions downward). Do not add full path, this is a convenience">
		<!--- ************************************************************* --->
		<cfscript>
			instance.beanFactory.addModelMapping(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Just create and call init, simple --->
	<cffunction name="create" hint="Create a named bean, simple as that. If the bean has an init() method, it will be called." access="public" output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="bean" required="true"  type="any" hint="The type of bean to create and return. Uses full cfc path mapping.Ex: coldbox.beans.ExceptionBean">
		<!--- ************************************************************* --->
		<cfscript>
			var beanInstance = "";
			try{
				/* Try to create bean */
				beanInstance = createObject("component","#arguments.bean#");

				/* check if an init */
				if( structKeyExists(beanInstance,"init") ){
					beanInstance = beanInstance.init();
				}

				/* Return object */
				return beanInstance;
			}
			Catch(Any e){
				$throw("Error creating bean: #arguments.bean#","#e.Detail#<br>#e.message#","ColdBox.plugins.BeanFactory.BeanCreationException");
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
					announceInterception("afterModelCreation",announceData);
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

	<!--- Populate a model object from the request Collection --->
	<cffunction name="populateModel" access="public" output="false" returntype="Any" hint="Populate a named or instantiated model (java/cfc) from the request collection items">
		<!--- ************************************************************* --->
		<cfargument name="model" 			required="true"  type="any" 	hint="The name of the model to get and populate or the acutal model object. If you already have an instance of a model, then use the populateBean() method">
		<cfargument name="scope" 			required="false" type="string"  default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<!--- ************************************************************* --->
		<cfscript>
			arguments.memento = controller.getRequestService().getContext().getCollection();

			// Do we have a model or name
			if( isSimpleValue(arguments.model) ){
				arguments.target = getModel(model);
			}
			else{
				arguments.target = arguments.model;
			}

			// Inflate from Request Collection
			return instance.beanPopulator.populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate a bean from the request Collection --->
	<cffunction name="populateBean" access="public" output="false" returntype="Any" hint="Populate a named or instantiated bean (java/cfc) from the request collection items">
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true" 	type="any" 	hint="This can be an instantiated bean object or a bean instantitation path as a string.  This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<!--- ************************************************************* --->
		<cfscript>
			arguments.memento = controller.getRequestService().getContext().getCollection();

			if( isSimpleValue(arguments.target) ){
				arguments.target = create(arguments.target);
			}

			return instance.beanPopulator.populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromJSON" access="public" returntype="any" hint="Populate a named or instantiated bean from a json string" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true" 	type="any" 		hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="JSONString"   	required="true" 	type="string" 	hint="The JSON string to populate the object with. It has to be valid JSON and also a structure with name-key value pairs. ">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<!--- ************************************************************* --->
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = create(arguments.target);
			}

			return instance.beanPopulator.populateFromJSON(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate from XML--->
	<cffunction name="populateFromXML" access="public" returntype="any" hint="Populate a named or instantiated bean from an XML packet" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true" 	type="any" 		hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="xml"   			required="true" 	type="any" 	hint="The XML string or packet">
		<cfargument name="root"   			required="false" 	type="string" 	default=""  hint="The XML root element to start from">
		<cfargument name="scope" 			required="false" 	type="string"  default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" 	type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" 	type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false"	type="string"  default="" hint="A list of keys to exclude in the population">
		<!--- ************************************************************* --->
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = create(arguments.target);
			}

			return instance.beanPopulator.populateFromXML(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate from Query --->
	<cffunction name="populateFromQuery" access="public" returntype="any" hint="Populate a named or instantiated bean from query" output="false">
		<!--- ************************************************************* --->
		<cfargument name="target"  			required="true"  type="any" 	 hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="qry"       		required="true"  type="query"   hint="The query to popluate the bean object with">
		<cfargument name="RowNumber" 		required="false" type="Numeric" hint="The query row number to use for population" default="1">
		<cfargument name="scope" 			required="false" type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<!--- ************************************************************* --->
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = create(arguments.target);
			}

			return instance.beanPopulator.populateFromQuery(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate an object using a query, but, only specific columns in the query. --->
	<cffunction name="populateFromQueryWithPrefix" output="false" returnType="any" hint="Populates an Object using only specific columns from a query. Useful for performing a query with joins that needs to populate multiple objects.">
		<cfargument name="target"  			required="true"  	type="any" 	 	hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="qry"       		required="true"  	type="query"   	hint="The query to popluate the bean object with">
		<cfargument name="RowNumber" 		required="false" 	type="Numeric" 	hint="The query row number to use for population" default="1">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" 	type="boolean" 	default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" 	type="string"  	default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" 	type="string"  	default="" hint="A list of keys to exclude in the population">
		<cfargument name="prefix"  			required="true" 	type="string"  	hint="The prefix used to filter, Example: 'user_' would apply to the following columns: 'user_id' and 'user_name' but not 'address_id'.">
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = create(arguments.target);
			}

			//populate bean and return
			return instance.beanPopulator.populateFromQueryWithPrefix(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromStruct" access="public" returntype="any" hint="Populate a named or instantiated bean from a structure" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  type="any" 	hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="memento"  		required="true"  type="struct" 	hint="The structure to populate the object with.">
		<cfargument name="scope" 			required="false" type="string"  hint="Use scope injection instead of setters population."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<!--- ************************************************************* --->
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = create(arguments.target);
			}

			return instance.beanPopulator.populateFromStruct(argumentCollection=arguments);
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

</cfcomponent>