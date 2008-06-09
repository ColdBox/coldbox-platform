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
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("Bean Factory");
			setpluginVersion("2.0");
			setpluginDescription("I am a simple bean factory");
			
			/* Setup the Autowire DI Dictionary */
			setDICacheDictionary(CreateObject("component","coldbox.system.util.baseDictionary").init('DIMetadata'));
			
			
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Just create and call init, simple --->
	<cffunction name="create" hint="Create a named bean, simple as that" access="public" output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="bean" 		required="true"  type="string" hint="The type of bean to create and return. Uses full cfc path mapping.Ex: coldbox.beans.exceptionBean">
		<cfargument name="callInitFlag"	required="false" type="boolean" default="false" hint="[DEPRECATED] Flag to call an init method on the bean.">
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

	<!--- Populate a bean from the request Collection --->
	<cffunction name="populateBean" access="public" output="false" returntype="Any" hint="Populate a named or instantiated bean (java/cfc) from the request collection items">
		<!--- ************************************************************* --->
		<cfargument name="FormBean" required="true" type="any" hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<!--- ************************************************************* --->
		<cfscript>
			var rc = controller.getRequestService().getContext().getCollection();
			
			/* Inflate from Request Collection */
			return populateFromStruct(arguments.FormBean,rc);			
		</cfscript>
	</cffunction>
	
	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromJSON" access="public" returntype="any" hint="Populate a named or instantiated bean from a json string" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="FormBean" 	required="true" type="any" 		hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="JSONString"   required="true" type="string" 	hint="The JSON string to populate the object with. It has to be valid JSON and also a structure with name-key value pairs. ">
		<!--- ************************************************************* --->
		<cfscript>
			var inflatedStruct = "";
			
			/* Inflate JSON */
			inflatedStruct = getPlugin("json").decode(arguments.JSONString);
			
			/* populate and return */
			return populateFromStruct(arguments.FormBean,inflatedStruct);
		</cfscript>
	</cffunction>

	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromStruct" access="public" returntype="any" hint="Populate a named or instantiated bean from a structure" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="FormBean" required="true" type="any" 		hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="memento"  required="true" type="struct" 	hint="The structure to populate the object with.">
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
				/* Populate Bean */
				for(key in arguments.memento){
					/* Check if setter exists */
					if( structKeyExists(beanInstance,"set" & key) ){
						evaluate("beanInstance.set#key#(arguments.memento[key])");
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

	<!--- Populate from Query --->
	<cffunction name="populateFromQuery" access="public" returntype="Any" hint="Populate a named or instantiated bean from query" output="false">
		<!--- ************************************************************* --->
		<cfargument name="FormBean"  required="true"  type="any" 	 hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="qry"       required="true"  type="query"   hint="The query to popluate the bean object with">
		<cfargument name="RowNumber" required="false" type="Numeric" hint="The query row number to use for population" default="1">
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
			return populateFromStruct(arguments.FormBean, stReturn);
		</cfscript>
	</cffunction>
	
	<!--- Autowire --->
	<cffunction name="autowire" access="public" returntype="void" output="false" hint="Autowire an object using the IoC plugin.">
		<!--- ************************************************************* --->
		<cfargument name="target" 				required="true" 	type="any" 		hint="The object to autowire">
		<cfargument name="useSetterInjection" 	required="false" 	type="boolean" 	default="true"	hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence.">
		<cfargument name="annotationCheck" 		required="false" 	type="boolean"  default="false" hint="This value determines if we check if the target contains an autowire annotation in the cfcomponent tag: autowire=true|false. The default is false.">
		<cfargument name="onDICompleteUDF" 		required="false" 	type="string"	default="onDIComplete" hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete">
		<cfargument name="debugMode" 			required="false" 	type="boolean"  default="false" hint="Whether to log debug messages. Default is false">
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
			var oMethodInjector = '';
				
			/* Do we have the incoming target object's data in the cache? */
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
					mdEntry.dependencies = parseMetadata(MetaData,mdEntry.dependencies,arguments.useSetterInjection);
				}
				
				/* Set Entry in dictionary */
				getDICacheDictionary().setKey(targetCacheKey,mdEntry);
			}
			
			/* We are now assured that the DI cache has data. */
			targetDIEntry = getDICacheDictionary().getKey(targetCacheKey);
			/* Do we Inject Dependencies, are we AutoWiring */
			if ( targetDIEntry.autowire ){
				/* Dependencies Length */
				dependenciesLength = arrayLen(targetDIEntry.dependencies);
				
				/* References */
				oMethodInjector = getPlugin("methodInjector");
				oIOC = getPlugin("ioc");
				
				/* Let's inject our mixins */
				oMethodInjector.start(targetObject);
				
				/* Loop over dependencies and inject. */
				for(x=1; x lte dependenciesLength;x=x+1){
					
					/* Defaults */
					thisDependency = targetDIEntry.dependencies[x];
					thisScope = "";
					
					/* Check for property and scopes */
					if( listlen(thisDependency) gt 1 ){
						thisDependency = listFirst(targetDIEntry.dependencies[x]);
						thisScope = listLast(targetDIEntry.dependencies[x]);
					}
					
					/* Verify that bean exists in the IOC container. */
					if( oIOC.getIOCFactory().containsBean(thisDependency) ){
						
						/* Inject dependency */
						injectBean(targetBean=targetObject,
								   beanName=thisDependency,
								   beanObject=oIOC.getBean(thisDependency),
								   scope=thisScope);
						
						/* Debug Mode Check */
						if( arguments.debugMode ){
							getPlugin("logger").logEntry("information","Bean: #thisDependency#,Scope: #thisScope# --> injected into #targetCacheKey#.");
						}
					}
					else if( arguments.debugMode ){
						getPlugin("logger").logEntry("warning","Bean: #thisDependency#,Scope: #thisScope# --> not found in factory");
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

	<!--- Get an object's dependencies via metadata --->
	<cffunction name="parseMetadata" returntype="array" access="private" output="false" hint="I get a components dependencies via searching for 'setters'">
		<!--- ************************************************************* --->
		<cfargument name="metadata" 			required="true" type="any" 		hint="The recursive metadata">
		<cfargument name="dependencies" 		required="true" type="array" 	hint="The dependencies">
		<cfargument name="useSetterInjection" 	required="false" 	type="boolean" 	default="true"	hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence.">
		<!--- ************************************************************* --->
		<cfscript>
			var x = 1;
			var md = arguments.metadata;
			var cbox_reserved_functions = "setSetting,setDebugMode,setNextEvent,setNextRoute,setController,settingExists,setPluginName,setPluginVersion,setPluginDescription,setProperty,setproperties";
			
			/* Look For cfProperties */
			if( structKeyExists(md,"properties") and ArrayLen(md.properties) gt 0){
				for(x=1; x lte ArrayLen(md.properties); x=x+1 ){
					
					/* Check if type is ioc */
					if( structKeyExists(md.properties[x],"type") and md.properties[x].type eq "ioc" ){
						/* Scope Check */
						if( not structKeyExists(md.properties[x],"scope") ){
							md.properties[x].scope = "variables";
						}		
						/* Cleanup Name */
						md.properties[x].name = replace(md.properties[x].name,".","_","all");
						/* Add Property Dependency */
						ArrayAppend( arguments.dependencies, md.properties[x].name & "," & md.properties[x].scope );
					}
					
				}//end for loop		
			}//end if properties found.
			
			/* Look for cfFunctions and if setter injection is enabled. */		
			if( arguments.useSetterInjection and structKeyExists(md, "functions") ){
				for(x=1; x lte ArrayLen(md.functions); x=x+1 ){
					/* Verify we have a setter */
					if( left(md.functions[x].name,3) eq "set" and not listFindNoCase(cbox_reserved_functions,md.functions[x].name) ){
						/* Found Setter, append property Name */
						ArrayAppend(arguments.dependencies,Right(md.functions[x].name, Len(md.functions[x].name)-3));
					
					}//end if setter found.
				}//end loop of functions
			}//end if functions found
			
			/* Start Registering inheritances */
			if ( structKeyExists(md, "extends") and 
				 ( md.extends.name neq "coldbox.system.plugin" or
				   md.extends.name neq "coldbox.system.eventhandler" or
				   md.extends.name neq "coldbox.system.interceptor" )
			){
				/* Recursive lookup */
				arguments.dependencies = parseMetadata(md.extends,dependencies);
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
	<cffunction name="getDICacheDictionary" access="private" output="false" returntype="coldbox.system.util.baseDictionary" hint="Get DICacheDictionary">
		<cfreturn instance.DICacheDictionary/>
	</cffunction>
	<cffunction name="setDICacheDictionary" access="private" output="false" returntype="void" hint="Set DICacheDictionary">
		<cfargument name="DICacheDictionary" type="coldbox.system.util.baseDictionary" required="true"/>
		<cfset instance.DICacheDictionary = arguments.DICacheDictionary/>
	</cffunction>
	
</cfcomponent>
