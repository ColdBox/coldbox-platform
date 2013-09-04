<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	August 21, 2006
Description :
	IoC Plugin, acts as a IoC Factory Adapter
----------------------------------------------------------------------->
<cfcomponent hint="An Inversion Of Control plugin that interfaces with major ColdFusion IoC/DI frameworks"
			 extends="coldbox.system.Plugin"
			 output="false"
			 singleton>

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="IOC" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<!--- ************************************************************* --->
		<cfscript>
			super.init(arguments.controller);
			
			// Plugin Properties
			setpluginName("IOC");
			setpluginVersion("4.0");
			setpluginDescription("This is an inversion of control plugin.");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			
			// The adapter used by this ioc plugin
			instance.adapter = "";
			
			// Setup depenedencies
			instance.objCaching 	= getSetting("IOCObjectCaching");
			instance.beanFactory 	= getPlugin("BeanFactory");
			instance.IOCFramework 	= getSetting("IOCFramework");
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Configure the plugin --->
	<cffunction name="configure" access="public" returntype="void" hint="Configure or Re-Configure the IoC Plugin. Loads the chosen IoC Factory and configures it for usage" output="false">
		<cfscript>
			var definitionFile  	= getSetting("IOCDefinitionFile");
			var parentFramework		= getSetting("IOCParentFactory");
			var paretDefinitionFile	= getSetting("IOCParentFactoryDefinitionFile");
			var parentAdapter		= "";
			
			if( log.canInfo() ){
				log.info("IOC integration detected, beginning configuration of IOC Factory");
			}
			
			// build adapter using application chosen properties
			instance.adapter = buildAdapter(instance.IOCFramework, definitionFile);
			
			// Do we have a parent to build?
			if( len( parentFramework ) ){
				
				if( log.canDebug() ){
					log.debug("Parent Factory detected: #parentFramework#:#paretDefinitionFile# and loading...");
				}
				
				// Build parent adapter and set it on original adapter factory.
				parentAdapter = buildAdapter(parentFramework, paretDefinitionFile);
				instance.adapter.setParentFactory( parentAdapter.getFactory() );
			}			
		</cfscript>
	</cffunction>

	<!--- reloadDefinitionFile --->
	<cffunction name="reloadDefinitionFile" access="public" output="false" returntype="void" hint="Reloads the IoC factory. Basically calls configure again. DEPRECATED">
		<cfscript>
			if( log.canInfo() ){
				log.info("Reloading ioc definition files...");
			}
			configure();
		</cfscript>
	</cffunction>

	<!--- Get a Bean --->
	<cffunction name="getBean" access="public" output="false" returntype="any" hint="Get a Bean from the loaded object factory">
		<cfargument name="beanName" required="true" hint="The bean name to retrieve from the object factory">
		<cfscript>
			var refLocal 		= structnew();
			var beanKey 		= "ioc_" & arguments.beanName;
			
			// Check if Ioc Caching
			if( instance.objCaching ){
				// get bean and verify its existence
				refLocal.oBean = getColdBoxOCM().get( beanKey );
				if( structKeyExists(refLocal,"oBean") and isObject(refLocal.oBean) ){
					return refLocal.oBean;
				}				
			}
			
			// get object from adapter factory
			refLocal.oBean = instance.adapter.getBean( arguments.beanName );
			
			// process WireBox autowires only if not wireBox.
			instance.beanFactory.autowire(target=refLocal.oBean, annotationCheck=true);
			
			// processObjectCaching?
			if( instance.objCaching ){
				processObjectCaching( refLocal.oBean, beanKey);
			}
			
			return refLocal.oBean;	
		</cfscript>
	</cffunction>
	
	<!--- containsBean --->
	<cffunction name="containsBean" access="public" returntype="any" hint="Check if the bean factory contains a bean" output="false" colddoc:generic="boolean">
		<cfargument name="beanName" required="true" hint="The bean name to retrieve from the object factory">	
		<cfreturn instance.adapter.containsBean( arguments.beanName )>
	</cffunction>

	<!--- getAdapter --->
    <cffunction name="getAdapter" output="false" access="public" returntype="any" hint="Get the IoC Factory Adapter in use by this plugin">
    	<cfreturn instance.adapter>
    </cffunction>

	<!--- get the IoC Factory in use --->
	<cffunction name="getIoCFactory" access="public" output="false" returntype="any" hint="Returns the IoC Factory in use">
		<cfreturn instance.adapter.getFactory()>
	</cffunction>

	<!--- get which IoC Framework is Used --->
	<cffunction name="getIOCFramework" access="public" output="false" returntype="any" hint="Get the IoC framework name defined for this plugin">
		<cfreturn instance.IOCFramework/>
	</cffunction>

	<!--- get The Definition file --->
	<cffunction name="getIOCDefinitionFile" access="public" output="false" returntype="any" hint="Get the definition file configured for this plugin">
		<cfreturn getSetting("IOCFrameworkDefinitionFile")/>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- processObjectCaching --->
    <cffunction name="processObjectCaching" output="false" access="private" returntype="void" hint="Process IoC object Caching">
    	<cfargument name="target" 	required="true" hint="The bean target to inspect"/>
		<cfargument name="cacheKey" required="true" hint="CacheKey to use if necessary"/>
		<!--- Get Object's MetaData --->
		<cfset var metaData = getMetaData(arguments.target)>
			
		<!--- Caching & Autowire only for CFC's Not Java objects --->
		<cfif isStruct( metadata )>
			<cflock name="IOC.objectCaching.#metaData.name#" type="exclusive" timeout="30" throwontimeout="true">
			<cfscript>
				// cache defaults
				if( not structKeyExists(metadata,"cache") or not isBoolean(metadata.cache) ){
					metadata.cache = false;
				}
				// Are we doing cache buffering
				if( metadata.cache ){
					if( not structKeyExists(MetaData,"cachetimeout") or not isNumeric(metadata.cacheTimeout) ){
						metaData.cacheTimeout = "";
					}
					if( not structKeyExists(MetaData,"cacheLastAccessTimeout") or not isNumeric(metadata.cacheLastAccessTimeout) ){
						metaData.cacheLastAccessTimeout = "";
					}
					
					if( log.canDebug() ){
						log.debug("Bean: #metadata.name# ioc caching detected, saving on buffer cache");
					}
					
					getColdboxOCM().set(arguments.cacheKey,target,metadata.cacheTimeout,metadata.cacheLastAccessTimeout);
				}
			</cfscript>
			</cflock>
		</cfif>
    </cffunction>
	
	<!--- buildAdapter --->
    <cffunction name="buildAdapter" output="false" access="private" returntype="any" hint="Build an IoC framework adapter and returns it">
    	<cfargument name="framework"		required="true" hint="The framework adapter to build"/>
		<cfargument name="definitionFile" 	required="true" hint="The framework definition file to load"/>
		<cfscript>	
			var adapterPath = "";
			var thisAdapter = "";

			switch( arguments.framework ){
				case "coldspring" 	: { adapterPath = "coldbox.system.ioc.adapters.ColdSpringAdapter"; break; }
				case "coldspring2" 	: { adapterPath = "coldbox.system.ioc.adapters.ColdSpring2Adapter"; break; }
				case "lightwire" 	: { adapterPath = "coldbox.system.ioc.adapters.LightWireAdapter"; break; }
				case "wirebox" 		: { adapterPath = "coldbox.system.ioc.adapters.WireBoxAdapter"; break; }
				// Default as custom object class
				default				: { adapterPath = arguments.framework; break;}	
			}
			
			// Create Adapter First
			try{
				thisAdapter = createObject( "component", adapterPath ).init( validateDefinitionFile( arguments.definitionFile ), controller.getConfigSettings(), controller );
				
				if( log.canDebug() ){
					log.debug("ioc factory adapter: #adapterPath# built successfully");
				}
			}
			catch(Any e){
				log.error("Error creating ioc factory adapter (#adapterPath#). Arguments: #arguments.toString()#, Message: #e.message# #e.detail# #e.stacktrace#");
				$throw(message="Error Creating ioc factory adapter (#adapterPath#) : #e.message#",detail="#e.detail# #e.stacktrace#",type="IOC.AdapterCreationException");
			}
			
			// Create Adapter Factory it represents second
			try{
				thisAdapter.createFactory();
				
				if( log.canDebug() ){
					log.debug("ioc framework: #getMetadata( thisAdapter.getFactory() ).name# loaded successfully and ready for operation.");
				}
			}
			catch(Any e){
				log.error("Error creating ioc factory from adapter. Arguments: #arguments.toString()#, Message: #e.message# #e.detail# #e.stacktrace#");
				$throw(message="Error Creating ioc factory: #e.message#",detail="#e.detail# #e.stacktrace#",type="IOC.AdapterFactoryCreationException");
			}
			
			if( log.canInfo() ){
				log.info("IoC factory: #arguments.framework#:#arguments.definitionFile# loaded and configured for operation");
			}
			
			return thisAdapter;
		</cfscript>
    </cffunction>
	
	<!--- Validate the definition file --->
	<cffunction name="validateDefinitionFile" access="private" output="false" returntype="any" hint="Validate the IoC Definition File. Called internally to verify the file location and get the correct path to it.">
		<cfargument name="definitionFile" required="true" hint="The definition file to verify for loading"/>
		<cfscript>
			var foundFilePath = "";
			
			// Is this an xml or cfm file or a CFC path?
			if( NOT listFindNoCase("xml,cfm", listLast(arguments.definitionFile,".")) ){
				return arguments.definitionFile;
			}
			
			// Try to locate the path
			foundFilePath = locateFilePath( arguments.definitionFile );
			
			// Validate it
			if( len(foundFilePath) eq 0 ){
				$throw("The definition file: #arguments.definitionFile# does not exist. Please check your path","","IOC.InvalidDefitinionFile");
			}
			
			return foundFilePath;
		</cfscript>
	</cffunction>
	
</cfcomponent>