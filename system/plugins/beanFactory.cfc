<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author: Luis Majano
Date:   July 28, 2006
Description: This is the framework's simple bean factory.

----------------------------------------------------------------------->
<cfcomponent name="beanFactory"
			 hint="I am a simple bean factory and you can use me if you want."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="beanFactory" output="false" hint="constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.controller">
		<!--- ************************************************************* --->
		<cfscript>
			var modelMappingsFile = "/";
			
			/* Super Init */
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("Bean Factory");
			setpluginVersion("2.0");
			setpluginDescription("I am a simple bean factory");
			
			/* Setup the Autowire DI Dictionary */
			setDICacheDictionary(CreateObject("component","coldbox.system.util.BaseDictionary").init('DIMetadata'));
			
			/* Model Mappings */
			instance.modelMappings = structnew();
			
			/* Run Model Mappings */
			if( fileExists(getSetting("ApplicationPath") & "config/modelMappings.cfm") ){
				try{
					/* If AppMapping is not Blank check */
					if( getSetting('AppMapping') neq "" ){
						modelMappingsFile = modelMappingsFile & getSetting('AppMapping');
					}
					modelMappingsFile = modelMappingsFile & "/config/modelMappings.cfm";
					/* Include it */
					include(modelMappingsFile);
				}
				catch(Any e){
					throw("Error including model mappings file: #e.message#",e.detail,"plugin.beanFactory.ModelMappingsIncludeException");
				}
			}
			
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get Model Mappings --->
	<cffunction name="getModelMappings" access="public" returntype="struct" hint="Get the model mappings structure" output="false" >
		<cfreturn instance.modelMappings>
	</cffunction>
	
	<!--- Add Model Mapping --->
	<cffunction name="addModelMapping" access="public" returntype="void" hint="Add a new model mapping. Ex: addModelMapping('myBean','security.test.FormBean')" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="alias" required="true" type="string" hint="The model alias">
		<cfargument name="model" required="true" type="string" hint="The model class path (From the model conventions downward)">
		<!--- ************************************************************* --->
		<cfset var mappings = getModelMappings()>
		<cfset mappings[arguments.alias] = arguments.model>
	</cffunction>

	<!--- Just create and call init, simple --->
	<cffunction name="create" hint="Create a named bean, simple as that. If the bean has an init() method, it will be called." access="public" output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="bean" 		required="true"  type="string" hint="The type of bean to create and return. Uses full cfc path mapping.Ex: coldbox.beans.exceptionBean">
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
				throw("Error creating bean: #arguments.bean#","#e.Detail#<br>#e.message#","ColdBox.plugins.beanFactory.BeanCreationException");
			}
		</cfscript>
	</cffunction>
	
	<!--- Get Model --->
	<cffunction name="getModel" access="public" returntype="any" hint="Create or retrieve model objects by convention" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 				required="true"  type="string" hint="The name of the model to retrieve">
		<cfargument name="useSetterInjection" 	required="false" type="boolean" default="false"	hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence.">
		<cfargument name="onDICompleteUDF" 		required="false" type="string"	default="onDIComplete" hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete">
		<cfargument name="debugMode" 			required="false" type="boolean" default="false" hint="Debugging Mode or not">
		<!--- ************************************************************* --->
		<cfscript>
			var oModel = 0;
			var ModelsPath = getSetting("ModelsPath");
			var ModelsInvocationPath = getSetting("ModelsInvocationPath");
			var checkPath = 0;
			var modelClassPath = 0;
			var md = 0;
			var modelMappings = getModelMappings();
			
			/* Resolve name in Alias Checks */
			if( structKeyExists(modelMappings,arguments.name) ){
				arguments.name = modelMappings[arguments.name];
			}
			/* Setup Paths */
			checkPath = ModelsPath & "/" & replace(arguments.name,".","/","all") & ".cfc";
			modelClassPath = ModelsInvocationPath & "." & arguments.name;
		</cfscript>
		
		<!--- Verify if model exists in cache --->
		<cfif ( getColdboxOCM().lookup(arguments.name) )>
			<cfset oModel = getColdBoxOCM().get(arguments.name)>
		<!--- Else Create It if it exists --->
		<cfelseif ( fileExists(checkPath) )>
			<cflock name="beanfactory.createmodel.#arguments.name#" type="exclusive" timeout="20" throwontimeout="true">
				<cfscript>
				if( fileExists(checkPath) ){
					/* Create the model object */
					oModel = createObject("component", modelClassPath);
					/* Verify Init() and execute */
					if( structKeyExists(oModel,"init") ){
						oModel.init();
					}
					/* Caching Metadata */
					md = getMetadata(oModel);
					if( not structKeyExists(md,"cache") or not isBoolean(md.cache) ){
						md.cache = false;
					}
					/* Are we Caching? */
					if( md.cache ){
						/* Prepare Timeouts and info. */
						if( not structKeyExists(md,"cachetimeout") or not isNumeric(md.cacheTimeout) ){
							md.cacheTimeout = "";
						}
						if( not structKeyExists(md,"cacheLastAccessTimeout") or not isNumeric(md.cacheLastAccessTimeout) ){
							md.cacheLastAccessTimeout = "";
						}
						/* Cache This Puppy. */
						getColdBoxOCM().set(arguments.name,oModel,md.cacheTimeout,md.CacheLastAccessTimeout);
					}
					
					/* Autowire Dependencies */
					autowire(target=oModel,
							 useSetterInjection=arguments.useSetterInjection,
							 annotationCheck=false,
							 onDICompleteUDF=arguments.onDICompleteUDF,
							 debugMode=arguments.debugmode);
				}
				</cfscript>
			</cflock>
		<cfelse>
			<cfset throw("Model Not Found","The model path is not valid: #checkPath#","plugin.beanFactory.modelNotFoundException")>
		</cfif>
		
		<cfreturn oModel>
	</cffunction>
	
	<!--- Populate a model object from the request Collection --->
	<cffunction name="populateModel" access="public" output="false" returntype="Any" hint="Populate a named or instantiated model (java/cfc) from the request collection items">
		<!--- ************************************************************* --->
		<cfargument name="model" 			required="true"  type="any" 	hint="The name of the model to get and populate or the acutal model object. If you already have an instance of a model, then use the populateBean() method">
		<cfargument name="scope" 			required="false" type="string"  default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<!--- ************************************************************* --->
		<cfscript>
			var rc = controller.getRequestService().getContext().getCollection();
			var oModel = 0;
			
			/* Do we have a model or name */
			if( isSimpleValue(arguments.model) ){
				oModel = getModel(model);
			}
			else{
				oModel = arguments.model;
			}
			
			/* Inflate from Request Collection */
			return populateFromStruct(oModel,rc,arguments.scope,arguments.trustedSetter);			
		</cfscript>
	</cffunction>

	<!--- Populate a bean from the request Collection --->
	<cffunction name="populateBean" access="public" output="false" returntype="Any" hint="Populate a named or instantiated bean (java/cfc) from the request collection items">
		<!--- ************************************************************* --->
		<cfargument name="formBean" 		required="true" 	type="any" 	hint="This can be an instantiated bean object or a bean instantitation path as a string.  This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<!--- ************************************************************* --->
		<cfscript>
			var rc = controller.getRequestService().getContext().getCollection();
			
			/* Inflate from Request Collection */
			return populateFromStruct(arguments.formBean,rc,arguments.scope,arguments.trustedSetter);			
		</cfscript>
	</cffunction>
	
	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromJSON" access="public" returntype="any" hint="Populate a named or instantiated bean from a json string" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="formBean" 		required="true" 	type="any" 		hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="JSONString"   	required="true" 	type="string" 	hint="The JSON string to populate the object with. It has to be valid JSON and also a structure with name-key value pairs. ">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<!--- ************************************************************* --->
		<cfscript>
			var inflatedStruct = "";
			
			/* Inflate JSON */
			inflatedStruct = getPlugin("json").decode(arguments.JSONString);
			
			/* populate and return */
			return populateFromStruct(arguments.formBean,inflatedStruct,arguments.scope,arguments.trustedSetter);
		</cfscript>
	</cffunction>
	
	<!--- Populate from Query --->
	<cffunction name="populateFromQuery" access="public" returntype="Any" hint="Populate a named or instantiated bean from query" output="false">
		<!--- ************************************************************* --->
		<cfargument name="formBean"  		required="true"  type="any" 	 hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="qry"       		required="true"  type="query"   hint="The query to popluate the bean object with">
		<cfargument name="RowNumber" 		required="false" type="Numeric" hint="The query row number to use for population" default="1">
		<cfargument name="scope" 			required="false" type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<!--- ************************************************************* --->
		<cfscript>
			//by default to take values from first row of the query
			var row = arguments.RowNumber;
			//columns array
			var cols = listToArray(arguments.qry.columnList);
			//new struct to hold query colum name and value
			var stReturn = structnew();
			var i   = 1;
			
			//build the struct from the query row
			for(i = 1; i lte arraylen(cols); i = i + 1){
				stReturn[cols[i]] = arguments.qry[cols[i]][row];
			}		
			
			//populate bean and return
			return populateFromStruct(arguments.formBean,stReturn,scope);
		</cfscript>
	</cffunction>

	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromStruct" access="public" returntype="any" hint="Populate a named or instantiated bean from a structure" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="formBean" 		required="true"  type="any" 	hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="memento"  		required="true"  type="struct" 	hint="The structure to populate the object with.">
		<cfargument name="scope" 			required="false" type="string"  hint="Use scope injection instead of setters population."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<!--- ************************************************************* --->
		<cfscript>
			var beanInstance = "";
			var key = "";
			
			try{
				/* Create or just use form bean */
				if( isSimpleValue(arguments.formBean) ){
					beanInstance = create(arguments.formBean);
				}
				else{
					beanInstance = arguments.formBean;
				}
				
				/* Determine Method of popuation */
				if( structKeyExists(arguments,"scope") and len(trim(arguments.scope)) neq 0 ){
					/* Mix the Bean */
					getPlugin("methodInjector").start(beanInstance);
					/* Populate Bean */
					for(key in arguments.memento){
						beanInstance.populatePropertyMixin(propertyName=key,propertyValue=arguments.memento[key],scope=arguments.scope);
					}
					/* Un-Mix It */
					getPlugin("methodInjector").stop(beanInstance);
				}
				//Setter Population
				else{
					/* Populate Bean */
					for(key in arguments.memento){
						/* Check if setter exists */
						if( structKeyExists(beanInstance,"set" & key) or arguments.trustedSetter ){
							evaluate("beanInstance.set#key#(arguments.memento[key])");
						}
					}
				}
				
				/* Return if created */
				return beanInstance;
			}
			catch(Any e){
				throw(type="ColdBox.plugins.beanFactory.PopulateBeanException",message="Error populating bean.",detail="#e.Detail#<br>#e.message#");
			}
		</cfscript>
	</cffunction>

	<!--- Autowire --->
	<cffunction name="autowire" access="public" returntype="void" output="false" hint="Autowire an object using the IoC plugin.">
		<!--- ************************************************************* --->
		<cfargument name="target" 				required="true" 	type="any" 		hint="The object to autowire">
		<cfargument name="useSetterInjection" 	required="false" 	type="boolean" 	default="true"	hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence.">
		<cfargument name="annotationCheck" 		required="false" 	type="boolean"  default="false" hint="This value determines if we check if the target contains an autowire annotation in the cfcomponent tag: autowire=true|false, it will only autowire if that metadata attribute is set to true. The default is false, which will autowire automatically.">
		<cfargument name="onDICompleteUDF" 		required="false" 	type="string"	default="onDIComplete" hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete">
		<cfargument name="debugMode" 			required="false" 	type="boolean"  default="false" hint="Whether to log debug messages. Default is false">
		<cfargument name="stopRecursion" 		required="false" 	type="string"   default="" hint="The stop recursion class. Ex: transfer.com.TransferDecorator. By default all ColdBox base classes are included.">
		<!--- ************************************************************* --->
		<cfscript>
			/* Targets */
			var targetObject = arguments.target;
			var MetaData = getMetaData(targetObject);
			var targetCacheKey = MetaData.name;
			
			/* Dependencies */
			var thisDependency = "";
			var thisScope = "";
			
			/* Metadata entry structures */
			var mdEntry = "";
			var targetDIEntry = "";
			var dependenciesLength = 0;
			var x = 1;
			var tmpBean = "";
			
			/* Helpers */
			var oIOC = '';
			var oOCM = '';
			var oMethodInjector = '';
		</cfscript>
		
		<!--- Do we have the incoming target object's data in the cache? --->
		<cfif ( not getDICacheDictionary().keyExists(targetCacheKey) )>
			<cflock type="exclusive" name="plugins.autowire.#targetCacheKey#" timeout="30" throwontimeout="true">
				<cfscript>
					/* Double Lock for thread concurrency */
					if ( not getDICacheDictionary().keyExists(targetCacheKey) ){
						/* Get Empty Default MD Entry */
						mdEntry = getNewMDEntry();
												
						/* Annotation Check*/
						if( not arguments.annotationCheck ){
							MetaData.autowire = true;
						}
						else if ( not structKeyExists(MetaData,"autowire") or not isBoolean(MetaData["autowire"]) ){
							MetaData.autowire = false;
							mdEntry.autowire = false;
						}
						
						/* Lookup Dependencies if using autowire */
						if ( MetaData["autowire"] ){
							/* Set md entry to true for autowiring */
							mdEntry.autowire = true;
							/* Recurse for dependencies here, in order to build them. */
							mdEntry.dependencies = parseMetadata(MetaData,mdEntry.dependencies,arguments.useSetterInjection,arguments.stopRecursion);
						}
						
						/* Set Entry in dictionary */
						getDICacheDictionary().setKey(targetCacheKey,mdEntry);
					}
				</cfscript>
			</cflock>
		</cfif>
			
		<cfscript>
		/* We are now assured that the DI cache has data. */
		targetDIEntry = getDICacheDictionary().getKey(targetCacheKey);
		
		/* Do we Inject Dependencies, are we AutoWiring */
		if ( targetDIEntry.autowire ){
			/* Dependencies Length */
			dependenciesLength = arrayLen(targetDIEntry.dependencies);
			/* References */
			oMethodInjector = getPlugin("methodInjector");
			/* Let's inject our mixins */
			oMethodInjector.start(targetObject);
			/* Loop over dependencies and inject. */
			for(x=1; x lte dependenciesLength; x=x+1){
				/* Get Dependency */
				thisDependency = targetDIEntry.dependencies[x];
				
				/* Determine Type of Injection according to Type */
				if( thisDependency.type eq "ioc" ){
					injectIOC(thisDependency,targetObject,arguments.debugMode);
				}
				else if (thisDependency.type eq "ocm"){
					injectOCM(thisDependency,targetObject,arguments.debugMode);
				}
				else if ( listFirst(thisDependency.type,":") eq "coldbox" ){
					/* Try to inject coldbox dependencies */
					injectColdboxDSL(thisDependency,targetObject,arguments.debugMode);
				}
				else if ( listFirst(thisDependency.type,":") eq "model" ){
					/* Try to inject coldbox dependencies */
					injectModelDSL(thisDependency,targetObject,arguments.debugMode);
				}								
				
			}//end for loop of dependencies.
			/* Process After ID Complete */
			processAfterCompleteDI(targetObject,onDICompleteUDF);
			/* Let's cleanup our mixins */
			getPlugin("methodInjector").stop(targetObject);
			
		}//if autowiring			
	</cfscript>
	</cffunction>
	
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- injectModelDSL --->
	<cffunction name="injectModelDSL" access="private" returntype="void" hint="Inject dependencies using the model dependency DSL" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="Definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfargument name="targetObject" required="true" type="any" hint="The target object">
		<cfargument name="debugMode" 	required="true" type="boolean" hint="The debug mode">
		<!--- ************************************************************* --->
		<cfscript>
			var thisDependency = arguments.Definition;
			var thisType = thisDependency.type;
			var thisTypeLen = listLen(thisType,":");
			var thisLocationType = "";
			var thisLocationKey = "";
			var locatedDependency = "_NOT_FOUND_";
			
			/* 2 stage dependency dsl */
			if(thisTypeLen eq 2){
				thisLocationType = getToken(thisType,2,":");
				/* Get model object*/
				locatedDependency = getModel(thisLocationType);
			}
			/* 3 stage dependency dsl */
			else if(thisTypeLen eq 3){
				thisLocationType = getToken(thisType,2,":");
				thisLocationKey = getToken(thisType,3,":");
				/* Call model method to get dependency */
				locatedDependency = evaluate("getModel(thisLocationType).#thisLocationKey#()");
			}//end 3 stage DSL
			
			/* Verify injetion */
			if( isSimpleValue(locatedDependency) AND locatedDependency EQ "_NOT_FOUND_" ){
				/* Only log if debugmode, else no injection */
				if( arguments.debugMode ){
					getPlugin("logger").logEntry("warning","Dependency: #thisDependency.toString()# --> not found in factory");
				}
			}
			else{
				/* Inject Dependency */
				injectBean(targetBean=arguments.targetObject,
						   beanName=thisDependency.name,
						   beanObject=locatedDependency,
						   scope=thisDependency.scope);
				/* Debug Mode Check */
				if( arguments.debugMode ){
					getPlugin("logger").logEntry("information","Dependency: #thisDependency.toString()# --> injected into #getMetadata(arguments.targetObject).name#.");
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- injectColdboxDSL --->
	<cffunction name="injectColdboxDSL" access="private" returntype="void" hint="Inject dependencies using the coldbox dependency DSL" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="Definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfargument name="targetObject" required="true" type="any" hint="The target object">
		<cfargument name="debugMode" 	required="true" type="boolean" hint="The debug mode">
		<!--- ************************************************************* --->
		<cfscript>
			var thisDependency = arguments.Definition;
			var thisType = thisDependency.type;
			var thisTypeLen = listLen(thisType,":");
			var thisLocationType = "";
			var thisLocationKey = "";
			var locatedDependency = "_NOT_FOUND_";
			
			/* 1 stage dependency */
			if( thisTypeLen eq 1 ){
				/* Coldbox Reference is the only one available on 1 stage DSL */
				locatedDependency = getController();
			}
			/* 2 stage dependencies. Model:Test or Coldbox:etc */
			else if(thisTypeLen eq 2){
				thisLocationKey = getToken(thisType,2,":");
				if( thisLocationKey eq "configbean" ){
					locatedDependency = getSettingsBean();
				}	
				else if( thisLocationKey eq "mailsettingsbean" ){
					locatedDependency = getMailSettings();
				}
			}
			/* 3 stage dependencies */
			else if(thisTypeLen eq 3){
				thisLocationType = getToken(thisType,2,":");
				thisLocationKey = getToken(thisType,3,":");
				/* Fork on types */
				if( thisLocationType eq "setting" ){
					locatedDependency = getSetting(thisLocationKey);
				}
				else if( thisLocationType eq "plugin" ){
					locatedDependency = getPlugin(thisLocationKey);
				}
				else if( thisLocationType eq "myplugin" ){
					locatedDependency = getMyPlugin(thisLocationKey);
				}
				else if( thisLocationType eq "datasource" ){
					locatedDependency = getDatasource(thisLocationKey);
				}
			}//end 3 stage DSL
			
			/* Verify injetion */
			if( isSimpleValue(locatedDependency) AND locatedDependency EQ "_NOT_FOUND_" ){
				/* Only log if debugmode, else no injection */
				if( arguments.debugMode ){
					getPlugin("logger").logEntry("warning","Dependency: #thisDependency.toString()# --> not found in factory");
				}
			}
			else{
				/* Inject Dependency */
				injectBean(targetBean=arguments.targetObject,
						   beanName=thisDependency.name,
						   beanObject=locatedDependency,
						   scope=thisDependency.scope);
				/* Debug Mode Check */
				if( arguments.debugMode ){
					getPlugin("logger").logEntry("information","Dependency: #thisDependency.toString()# --> injected into #getMetadata(arguments.targetObject).name#.");
				}
			}
		</cfscript>
	</cffunction>

	<!--- injectIOC --->
	<cffunction name="injectIOC" access="private" returntype="void" hint="Inject a bean with IOC dependencies" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="Definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfargument name="targetObject" required="true" type="any" hint="The target object">
		<cfargument name="debugMode" 	required="true" type="boolean" hint="The debug mode">
		<!--- ************************************************************* --->
		<cfscript>
			var oIOC = getPlugin("ioc");
			var thisDependency = arguments.Definition;
			/* Verify that bean exists in the IOC container. */
			if( oIOC.getIOCFactory().containsBean(thisDependency.name) ){
				/* Inject dependency */
				injectBean(targetBean=arguments.targetObject,
						   beanName=thisDependency.name,
						   beanObject=oIOC.getBean(thisDependency.name),
						   scope=thisDependency.scope);
				
				/* Debug Mode Check */
				if( arguments.debugMode ){
					getPlugin("logger").logEntry("information","Dependency: #thisDependency.toString()# --> injected into #getMetadata(arguments.targetObject).name#.");
				}
			}
			else if( arguments.debugMode ){
				getPlugin("logger").logEntry("warning","Dependency: #thisDependency.toString()# --> not found in factory");
			}
		</cfscript>
	</cffunction>
	
	<!--- injectOCM --->
	<cffunction name="injectOCM" access="private" returntype="void" hint="Inject a bean with OCM dependencies" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="Definition" 	required="true" type="any" hint="The dependency definition structure">
		<cfargument name="targetObject" required="true" type="any" hint="The target object">
		<cfargument name="debugMode" 	required="true" type="boolean" hint="The debug mode">
		<!--- ************************************************************* --->
		<cfscript>
			var oOCM = getColdboxOCM();
			var thisDependency = arguments.Definition;
			/* Verify that bean exists in the Cache container. */
			if( oOCM.lookup(thisDependency.name) ){
				
				/* Inject dependency */
				injectBean(targetBean=arguments.targetObject,
						   beanName=thisDependency.name,
						   beanObject=oOCM.get(thisDependency.name),
						   scope=thisDependency.scope);
				
				/* Debug Mode Check */
				if( arguments.debugMode ){
					getPlugin("logger").logEntry("information","Dependency: #thisDependency.toString()# --> injected into #getMetadata(arguments.targetObject).name#.");
				}
			}
			else if( arguments.debugMode ){
				getPlugin("logger").logEntry("warning","Dependency: #thisDependency.toString()# --> not found in factory");
			}
		</cfscript>
	</cffunction>
	
	<!--- Get an object's dependencies via metadata --->
	<cffunction name="parseMetadata" returntype="array" access="private" output="false" hint="I get a components dependencies via searching for 'setters'">
		<!--- ************************************************************* --->
		<cfargument name="metadata" 			required="true"  type="any" 	hint="The recursive metadata">
		<cfargument name="dependencies" 		required="true"  type="array" 	hint="The dependencies">
		<cfargument name="useSetterInjection" 	required="false" type="boolean" default="true"	hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence.">
		<cfargument name="stopRecursion" 		required="false" type="string" 	default="" hint="The stop recursion class">
		<!--- ************************************************************* --->
		<cfscript>
			var x = 1;
			var md = arguments.metadata;
			var entry = structnew();
			var cbox_reserved_functions = "setSetting,setDebugMode,setNextEvent,setNextRoute,setController,settingExists,setPluginName,setPluginVersion,setPluginDescription,setProperty,setproperties";
			var foundDependencies = "";
			var DSLNamespaces = "coldbox,ioc,ocm";
			
			/* Look for Object's attributes, and override if found. */
			if( structKeyExists(md,"autowire_stoprecursion") ){
				arguments.stopRecursion = md["autowire_stoprecursion"];
			}
			if( structKeyExists(md,"autowire_setterinjection") and isBoolean(md["autowire_setterinjection"]) ){
				arguments.useSetterInjection = md["autowire_setterinjection"];
			}
			
			/* Look For cfProperties */
			if( structKeyExists(md,"properties") and ArrayLen(md.properties) gt 0){
				for(x=1; x lte ArrayLen(md.properties); x=x+1 ){
					/* Check types are valid for autowiring. */
					if( structKeyExists(md.properties[x],"type") AND 
						( listFindNoCase(DSLNamespaces,md.properties[x].type) OR
						  findnocase("model",md.properties[x].type) OR
						  findnocase("coldbox",md.properties[x].type) )  	
					){
						/* New MD Entry */
						entry = structnew();
						/* Scope Check */
						if( not structKeyExists(md.properties[x],"scope") ){
							md.properties[x].scope = "variables";
						}		
						/* Setup Entry */
						entry.name 	= md.properties[x].name;
						entry.scope = md.properties[x].scope;
						entry.type 	= md.properties[x].type;
						
						/* Add to found list */
						listAppend(foundDependencies,entry.name);
						
						/* Add Property Dependency */
						ArrayAppend( arguments.dependencies, entry );
					}
					
				}//end for loop		
			}//end if properties found.
			
			/* Look for cfFunctions and if setter injection is enabled. */		
			if( arguments.useSetterInjection and structKeyExists(md, "functions") ){
				for(x=1; x lte ArrayLen(md.functions); x=x+1 ){
					/* Verify we have a setter */
					if( left(md.functions[x].name,3) eq "set" AND NOT 
					    listFindNoCase(cbox_reserved_functions,md.functions[x].name) ){
						
						/* New MD Entry */
						entry = structnew();
						entry.name = Right(md.functions[x].name, Len(md.functions[x].name)-3);
						entry.scope = "";
						entry.type = "ioc";
						
						/* Add if not already in properties */
						if( not listFindNoCase(foundDependencies,entry.name) ){
							/* Found Setter, append property Name */
							listAppend(foundDependencies,entry.name);
							ArrayAppend(arguments.dependencies, entry);
						}
					
					}//end if setter found.
				}//end loop of functions
			}//end if functions found
			
			/* Start Registering inheritances */
			if ( structKeyExists(md, "extends") AND 
				 ( md.extends.name NEQ "coldbox.system.plugin" AND
				   md.extends.name NEQ "coldbox.system.eventhandler" AND
				   md.extends.name NEQ "coldbox.system.interceptor" AND
				   (
				   	(len(arguments.stopRecursion) and md.extends.name NEQ arguments.stopRecursion ) 
				   	 OR
				   	( len(arguments.stopRecursion) eq 0 )
				   ) 
				  )
			){
				/* Recursive lookup */
				arguments.dependencies = parseMetadata(md.extends,dependencies,arguments.useSetterInjection,arguments.stopRecursion);
			}
			
			/* return the dependencies found */
			return arguments.dependencies;
		</cfscript>	
	</cffunction>
	
	<!--- Inject Bean --->
	<cffunction name="injectBean" access="private" returntype="void" output="false" hint="Inject a bean with dependencies via setters or property injections">
		<!--- ************************************************************* --->
		<cfargument name="targetBean"  	 type="any" 	required="true" hint="The bean that will be injected with dependencies" />
		<cfargument name="beanName"  	 type="string" 	required="true" hint="The name of the property to inject"/>
		<cfargument name="beanObject" 	 type="any" 	required="true" hint="The bean object to inject." />
		<cfargument name="scope" 		 type="string"  required="true" hint="The scope to inject a property into.">
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
		<cfargument name="targetObject" 	required="Yes"  	type="any"	hint="the target object to call on">
		<cfargument name="onDICompleteUDF" 	required="false" 	type="string"	default="onDIComplete" hint="After Dependencies are injected, this method will look for this UDF and call it if it exists.">
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
	<cffunction name="getNewMDEntry" access="private" returntype="struct" hint="Get a new metadata entry structure" output="false" >
		<cfscript>
			var mdEntry = structNew();
			
			mdEntry.autowire = false;
			mdEntry.dependencies = Arraynew(1);
			
			return mdEntry;
		</cfscript>
	</cffunction>

	<!--- Get Set DI CACHE Dictionary --->
	<cffunction name="getDICacheDictionary" access="private" output="false" returntype="coldbox.system.util.BaseDictionary" hint="Get DICacheDictionary">
		<cfreturn instance.DICacheDictionary/>
	</cffunction>
	<cffunction name="setDICacheDictionary" access="private" output="false" returntype="void" hint="Set DICacheDictionary">
		<cfargument name="DICacheDictionary" type="coldbox.system.util.BaseDictionary" required="true"/>
		<cfset instance.DICacheDictionary = arguments.DICacheDictionary/>
	</cffunction>
	
</cfcomponent>
