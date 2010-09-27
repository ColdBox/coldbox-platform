<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	August 21, 2006
Description :
	IoC Plugin, acts as a IoC Factory Decorator and Facade.

Modification History:
07/24/2007 - LightWire integration added by Aaron Roberson
02/15/2007 - Created
----------------------------------------------------------------------->
<cfcomponent hint="An Inversion Of Control plugin that interfaces with major ColdFusion IoC/DI frameworks such as ColdSpring and LightWire"
			 extends="coldbox.system.Plugin"
			 output="false"
			 singleton=true>

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="IOC" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<!--- ************************************************************* --->
		<cfscript>
			super.Init(arguments.controller);
			
			// Plugin Properties
			setpluginName("IOC");
			setpluginVersion("2.2");
			setpluginDescription("This is an inversion of control plugin.");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			
			// Setup the framework chosen in the config
			setIOCFramework( getSetting("IOCFramework") );
			// Setup the IOC definition file or cfc from the config
			setIOCDefinitionFile( getSetting("IOCDefinitionFile") );
			// Setup the initial expanded file 
			setExpandedIOCDefinitionFile("");
			// Create an empty factory placeholder
			setIOCFactory( structNew() );
			
			// Default Locations:
			setCOLDSPRING_FACTORY( getSetting("ColdspringBeanFactory",true) );
			setLIGHTWIRE_FACTORY( getSetting("LightWireBeanFactory",true) );
			
			// This can be overriden by the custom settings now:
			if( settingExists('ColdspringBeanFactory') ){
				setCOLDSPRING_FACTORY( getSetting("ColdspringBeanFactory") );
			}
			if( settingExists('LightWireBeanFactory') ){
				setLIGHTWIRE_FACTORY( getSetting("LightWireBeanFactory") );
			}
			
			// Configure the factory for operation
			configure();
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Configure the plugin --->
	<cffunction name="configure" access="public" returntype="void" hint="Configure or Re-Configure the IoC Plugin. Loads the chosen IoC Factory and configures it for usage" output="false">
		<!--- Load the appropriate IOC Framework Bean Factory --->
		<cfswitch expression="#lcase(getIOCFramework())#">

			<cfcase value="coldspring">
				<!--- Check the services file First --->
				<cfset validateDefinitionFile()>
				<cfset setIoCFactory( createColdspring() )>
			</cfcase>

			<cfcase value="lightwire">
				<cfset setIoCFactory( createLightWire() )>
			</cfcase>

			<cfdefaultcase>
				<cfthrow type="plugins.IOC.InvalidIoCFramework" message="The only available IoC supported frameworks are coldspring and lightwire. You chose: #getIOCFramework()#">
			</cfdefaultcase>
		</cfswitch>

	</cffunction>

	<!--- Reload the Definition File --->
	<cffunction name="reloadDefinitionFile" access="public" output="false" returntype="void" hint="Reloads the IoC factory with the Definition File or Object">
		
		<cfswitch expression="#lcase(getIOCFramework())#">

			<cfcase value="coldspring">
				<cfset getIoCFactory().loadBeansFromXmlFile( getExpandedIOCDefinitionFile() )>
			</cfcase>

			<cfcase value="lightwire">
				<cfset getIoCFactory().init( createLightwireConfigBean() )>
			</cfcase>

		</cfswitch>
	</cffunction>

	<!--- Get a Bean --->
	<cffunction name="getBean" access="public" output="false" returntype="any" hint="Get a Bean from the loaded object factory">
		<!--- ************************************************************* --->
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">
		<!--- ************************************************************* --->
		<cfset var oBean = 0>
		<cfset var beanKey = "ioc_" & arguments.beanName>
		<cfset var MetaData = structNew()>
		<cfset var objCaching = getSetting("IOCObjectCaching")>

		<!--- Check if IOC Caching is set, and if we have it cached. --->
		<cfif objCaching and getColdBoxOCM().lookup(beanKey)>
			<cfset oBean = getColdBoxOCM().get(beanKey)>
		<cfelse>
			<!--- Get Bean from IOC Framework --->
			<cfset oBean = getIoCFactory().getBean(arguments.beanName)>
			<!--- Get Object's MetaData --->
			<cfset MetaData = getMetaData(oBean)>
			
			<!--- Caching & Autowire only for CFC's Not Java objects --->
			<cfif isStruct(MetaData)>
				<!--- Autowire Support For IoC Objects --->
				<cfset getPlugin("BeanFactory").autowire(target=oBean,annotationCheck=true)>
				<!--- If Caching on, then set object in cache --->
				<cfif objCaching>
					<!--- By Default, services with no cache flag are set to false --->
					<cfif not structKeyExists(MetaData,"cache") or not isBoolean(MetaData.cache)>
						<cfset MetaData.cache = false>
					</cfif>
					<!--- Test for caching parameters --->
					<cfif MetaData["cache"]>
						<!--- Cache Metadata --->
						<cfif not structKeyExists(MetaData,"cachetimeout") or not isNumeric(metadata.cacheTimeout) >
							<cfset MetaData.cacheTimeout = "">
						</cfif>
						<cfif not structKeyExists(MetaData,"cacheLastAccessTimeout") or not isNumeric(metadata.cacheLastAccessTimeout) >
							<cfset MetaData.cacheLastAccessTimeout = "">
						</cfif>
						<!--- Cache the object --->
						<cflock name="IOC.objectCaching.#arguments.beanName#" type="exclusive" timeout="30" throwontimeout="true">
							<cfset getColdboxOCM().set(beanKey,oBean,metadata.cacheTimeout,metadata.cacheLastAccessTimeout)>
						</cflock>
					</cfif>
				</cfif>	
			</cfif>						
		</cfif>
		
		<!--- Return Bean --->
		<cfreturn oBean>
	</cffunction>

<!------------------------------------------- ACCESSOR/MUTATORS ------------------------------------------->


	<!--- get/set the actual IoC Factory --->
	<cffunction name="getIoCFactory" access="public" output="false" returntype="any" hint="Returns the IoC Factory in use.">
		<cfreturn instance.IoCFactory>
	</cffunction>
	<cffunction name="setIoCFactory" access="public" output="false" returntype="void" hint="Override and set the IoCFactory the plugin will interface with">
		<cfargument name="IoCFactory" type="any" required="true"/>
		<cfset instance.IoCFactory = arguments.IoCFactory/>
	</cffunction>

	<!--- get/set which IoC Framework is Used --->
	<cffunction name="getIOCFramework" access="public" output="false" returntype="string" hint="Gets the IoC Framework string used: lightwire or coldspring">
		<cfreturn instance.IOCFramework/>
	</cffunction>
	<cffunction name="setIOCFramework" access="public" output="false" returntype="void" hint="Set the IoC Framework used: lightwire or coldspring">
		<cfargument name="IOCFramework" type="string" required="true"/>
		<cfset instance.IOCFramework = arguments.IOCFramework/>
	</cffunction>

	<!--- get/set The Definition file --->
	<cffunction name="getIOCDefinitionFile" access="public" output="false" returntype="string" hint="Get the definition file configured for this plugin">
		<cfreturn instance.IOCDefinitionFile/>
	</cffunction>
	<cffunction name="setIOCDefinitionFile" access="public" output="false" returntype="void" hint="Set the definition file configured for this plugin">
		<cfargument name="IOCDefinitionFile" type="string" required="true" hint="The relative or absolute location of the coldspring main xml file."/>
		<cfset instance.IOCDefinitionFile = arguments.IOCDefinitionFile/>
	</cffunction>

	<!--- Get/set the Expanded IoC Definiton File --->
	<cffunction name="getExpandedIOCDefinitionFile" access="public" output="false" returntype="string" hint="Get the full expanded path of the configuration file, only used for coldspring">
		<cfreturn instance.ExpandedIOCDefinitionFile/>
	</cffunction>
	<cffunction name="setExpandedIOCDefinitionFile" access="public" output="false" returntype="void" hint="Set the full expanded path of the definition file">
		<cfargument name="ExpandedIOCDefinitionFile" type="string" required="true" hint="The expanded path of the main coldspring xml file"/>
		<cfset instance.ExpandedIOCDefinitionFile = arguments.ExpandedIOCDefinitionFile/>
	</cffunction>

	<!--- get/set the Coldspring Factory Path --->
	<cffunction name="getCOLDSPRING_FACTORY" access="public" output="false" returntype="string" hint="Get COLDSPRING_FACTORY. This is the instantiation path for coldspring">
		<cfreturn instance.COLDSPRING_FACTORY/>
	</cffunction>
	<cffunction name="setCOLDSPRING_FACTORY" access="public" output="false" returntype="void" hint="Set the instantiation path for ColdSpring.">
		<cfargument name="COLDSPRING_FACTORY" type="string" required="true" hint="The instantiation path for coldspring"/>
		<cfset instance.COLDSPRING_FACTORY = arguments.COLDSPRING_FACTORY/>
	</cffunction>	
	
	<!--- get/set the Lightwire factory path --->
	<cffunction name="getLIGHTWIRE_FACTORY" access="public" output="false" returntype="string" hint="Get LIGHTWIRE_FACTORY. This is the instantiation path for lightwire">
		<cfreturn instance.LIGHTWIRE_FACTORY/>
	</cffunction>	
	<cffunction name="setLIGHTWIRE_FACTORY" access="public" output="false" returntype="void" hint="Set the instantiation path for LightWire">
		<cfargument name="LIGHTWIRE_FACTORY" type="string" required="true" hint="This is the instantiation path for lightwire"/>
		<cfset instance.LIGHTWIRE_FACTORY = arguments.LIGHTWIRE_FACTORY/>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Validate the definition file --->
	<cffunction name="validateDefinitionFile" access="private" output="false" returntype="void" hint="Validate the IoC Definition File. Called internally to verify the file location and get the correct path to it.">
		<cfscript>
			var foundFilePath = "";
			
			/* Try to locate the path */
			foundFilePath = locateFilePath(getIOCDefinitionFile());
			/* Validate it */
			if( len(foundFilePath) eq 0 ){
				$throw("The definition file: #getIOCDefinitionFile()# does not exist. Please check your path","","plugins.IOC.InvalidDefitinionFile");
			}
			/* Save the found location path */
			setExpandedIOCDefinitionFile( foundFilePath );
		</cfscript>
	</cffunction>
	
	<!--- Create Coldspring --->
	<cffunction name="createColdspring" access="private" output="false" returntype="any" hint="Creates the coldspring factory and configures it">
		<cfscript>
			var coldpsring = "";
			var settingsStruct = StructNew();
			var ConfigContents = "";
			
			//Copy the settings Structure
			structAppend(settingsStruct, getSettingStructure());
			//Create the Coldspring Factory
			coldpsring = createObject("component",getCOLDSPRING_FACTORY()).init(structnew(),settingsStruct);
			/* Read the XML File and do string replacement First */
			ConfigContents = getPlugin("FileUtils").readFile(getExpandedIOCDefinitionFile());
			ConfigContents = getPlugin("Utilities").placeHolderReplacer(ConfigContents,settingsStruct);	
			/* Load BEan Definitions */
			coldpsring.loadBeansFromXmlRaw( ConfigContents );
			
			return coldpsring;
		</cfscript>
	</cffunction>

	<!--- Create Lightwire --->
	<cffunction name="createLightwire" access="private" output="false" returntype="any" hint="Creates the lightwire factory and configures it">
		<cfscript>
			var lightwire = "";
			
			// Create the LightWire Factory
			lightwire = createObject("component", getLIGHTWIRE_FACTORY()).init(createLightwireConfigBean());
			
			return lightwire;
		</cfscript>
	</cffunction>
	
	<!--- Create Lightwire Config Bean --->
	<cffunction name="createLightwireConfigBean" output="false" access="private" returntype="any" hint="Creates the lightwire config bean">
		<cfscript>
			var lightwireBeanConfig = "";
			var isUsingXML = listLast(getIOCDefinitionFile(),".") eq "xml" or listLast(getIOCDefinitionFile(),".") eq "cfm";
			var settingsStruct = StructNew();
			var oMethodInjector = getPlugin("MethodInjector");
			
			/* Create the lightwire Config Bean. */
			if( not isUsingXML ){
				/* Create the declared config bean, but do not init it */
				lightwireBeanConfig = CreateObject("component", getIOCDefinitionFile());
			}
			else{
				/* Create base ColdBox config Bean */
				lightwireBeanConfig = CreateObject("component", "coldbox.system.ioc.lightwire.BaseConfigObject").init();	
				/* validate definiton file */
				validateDefinitionFile();
				/* Copy the settings Structure */
				structAppend(settingsStruct, getSettingStructure());			
			}
			
			/* Mixin start */
			oMethodInjector.start(lightwireBeanConfig);
			
			/* Inject controller methods */
			lightWireBeanConfig.injectMixin( oMethodInjector.setController );
			lightWireBeanConfig.injectMixin( oMethodInjector.getController );
			
			/* Mixin stop */
			oMethodInjector.stop(lightwireBeanConfig);
			
			/* setter dependency on coldbox */
			lightwireBeanConfig.setController(getController());
			
			/* Do we need to configure */
			if( isUsingXML ){
				/* Read in and parse the XML */
				lightwireBeanConfig.parseXMLConfigFile(getExpandedIOCDefinitionFile(),settingsStruct);
				return lightwireBeanConfig;
			}
			else{
				return lightwireBeanConfig.init();
			}					
		</cfscript>
	</cffunction>

</cfcomponent>