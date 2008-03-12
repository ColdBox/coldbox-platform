<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	August 21, 2006
Description :
	IoC Plugin, acts as a IoC Factory Decorator and Facade.

Modification History:
07/24/2007 - LightWire integration added by Aaron Roberson
02/15/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="ioc"
			 hint="An Inversion Of Control plugin."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true"
			 cachetimeout="0">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="ioc" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("IoC")>
		<cfset setpluginVersion("1.0")>
		<cfset setpluginDescription("This is an inversion of control plugin.")>
		
		<!--- Local properties --->
		<cfset instance.IOCFramework = getSetting("IOCFramework")>
		<cfset instance.IOCDefinitionFile = getSetting("IOCDefinitionFile")>
		<cfset instance.ExpandedIOCDefinitionFile = "">
		<cfset instance.IoCFactory = structNew()>
		
		<!--- Constants --->
		<cfset instance.COLDSPRING_FACTORY = getSetting("ColdspringBeanFactory",true)>
		<cfset instance.LIGHTWIRE_FACTORY = getSetting("LightWireBeanFactory",true)>
		
		<!--- Return Instance --->
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="configure" access="public" returntype="void" hint="Configure the IoC Plugin. Loads the IoC Factory and configures it." output="false">

		<!--- Load the appropriate ioc Framework Bean Factory --->
		<cfswitch expression="#lcase(instance.IOCFramework)#">

			<cfcase value="coldspring">
				<!--- Check the services file First --->
				<cfset validateDefinitionFile()>
				<cfset instance.IoCFactory = createColdspring()>
			</cfcase>

			<cfcase value="lightwire">
				<cfset instance.IoCFactory = createLightWire()>
			</cfcase>

			<cfdefaultcase>
				<cfthrow type="Framework.plugins.ioc.InvalidIoCFramework" message="The only available IoC supported frameworks are coldspring and lightwire. You chose: #instance.IOCFramework#">
			</cfdefaultcase>
		</cfswitch>

	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="reloadDefinitionFile" access="public" output="false" returntype="void" hint="Reloads the IoC factory with the Definition File">
		<cfswitch expression="#lcase(instance.IOCFramework)#">

			<cfcase value="coldspring">
				<cfset instance.IoCFactory.loadBeansFromXmlFile( instance.ExpandedIOCDefinitionFile )>
			</cfcase>

			<cfcase value="lightwire">
				<cfset instance.IoCFactory.init(createLightwireConfigBean())>
			</cfcase>

		</cfswitch>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getBean" access="public" output="false" returntype="any" hint="Facade to get Bean">
		<cfargument name="beanName" type="string" required="true">
		<cfset var oBean = "">
		<cfset var beanKey = "ioc_" & arguments.beanName>
		<cfset var MetaData = structNew()>
		<cfset var objTimeout = "">
		<cfset var objCaching = getSetting("IOCObjectCaching")>

		<!--- Check if IOC Caching is set --->
		<cfif objCaching and getColdBoxOCM().lookup(beanKey)>
			<cfset oBean = getColdBoxOCM().get(beanKey)>
		<cfelse>
			<!--- Get Bean from IOC Framework --->
			<cfif lcase(instance.IOCFramework) eq "coldspring">
				<cfset oBean = instance.IoCFactory.getBean(arguments.beanName)>
			<cfelseif lcase(instance.IOCFramework) eq "lightwire">
				<cfset oBean = instance.IoCFactory.getBean(arguments.beanName)>
			</cfif>
			<!--- If Caching on, then set object in cache --->
			<cfif objCaching>
				<!--- Get Object's MetaData, For Caching --->
				<cfset MetaData = getMetaData(oBean)>
				<!--- By Default, services with no cache flag are set to false --->
				<cfif not structKeyExists(MetaData,"cache") or not isBoolean(MetaData.cache)>
					<cfset MetaData.cache = false>
				</cfif>
				<!--- Test for caching parameters --->
				<cfif MetaData["cache"]>
					<cfif structKeyExists(MetaData,"cachetimeout") >
						<cfset objTimeout = MetaData["cachetimeout"]>
					</cfif>
					<cfset getColdboxOCM().set(beanKey,oBean,objTimeout)>
				</cfif>
			</cfif>
		</cfif>
		<!--- Return Bean --->
		<cfreturn oBean>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getIoCFactory" access="public" output="false" returntype="any" hint="Returns the IoC Factory in use.">
		<cfreturn instance.IoCFactory>
	</cffunction>
	<cffunction name="setIoCFactory" access="public" output="false" returntype="void" hint="Override and set the IoCFactory">
		<cfargument name="IoCFactory" type="string" required="true"/>
		<cfset instance.IoCFactory = arguments.IoCFactory/>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getIOCFramework" access="public" output="false" returntype="string" hint="Get IOCFramework">
		<cfreturn instance.IOCFramework/>
	</cffunction>
	<cffunction name="setIOCFramework" access="public" output="false" returntype="void" hint="Set IOCFramework">
		<cfargument name="IOCFramework" type="string" required="true"/>
		<cfset instance.IOCFramework = arguments.IOCFramework/>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getIOCDefinitionFile" access="public" output="false" returntype="string" hint="Get IOCDefinitionFile">
		<cfreturn instance.IOCDefinitionFile/>
	</cffunction>
	<cffunction name="setIOCDefinitionFile" access="public" output="false" returntype="void" hint="Set IOCDefinitionFile">
		<cfargument name="IOCDefinitionFile" type="string" required="true"/>
		<cfset instance.IOCDefinitionFile = arguments.IOCDefinitionFile/>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getExpandedIOCDefinitionFile" access="public" output="false" returntype="string" hint="Get ExpandedIOCDefinitionFile">
		<cfreturn instance.ExpandedIOCDefinitionFile/>
	</cffunction>

	<cffunction name="setExpandedIOCDefinitionFile" access="public" output="false" returntype="void" hint="Set ExpandedIOCDefinitionFile">
		<cfargument name="ExpandedIOCDefinitionFile" type="string" required="true"/>
		<cfset instance.ExpandedIOCDefinitionFile = arguments.ExpandedIOCDefinitionFile/>
	</cffunction>

	<!--- ************************************************************* --->

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="validateDefinitionFile" access="private" output="false" returntype="void" hint="Validate the IoC Definition File">
		<cfscript>
		var ExpandedPath = ExpandPath(instance.IOCDefinitionFile);
		var appRoot = getController().getAppRootPath();
		
		/* Clean app root */
		if( right(appRoot,1) neq getSetting("OSFileSeparator",true) ){
			appRoot = appRoot & getSetting("OSFileSeparator",true);
		}		
		/* Absolute Path Check */
		if( fileExists(getIOCDefinitionFile()) ){
			setExpandedIOCDefinitionFile( getIOCDefinitionFile() );
		}
		/* Relative App Path Check */
		else if( fileExists(appRoot & getIOCDefinitionFile()) ){
			setExpandedIOCDefinitionFile( appRoot & getIOCDefinitionFile() );
		}
		/* Expand Path Check */
		else if( fileExists( expandPath(getIOCDefinitionFile()) ){
			setExpandedIOCDefinitionFile( ExpandPath(getIOCDefinitionFile()) );
		}
		else{
			throw("The definition file: #instance.IOCDefinitionFile# does not exist. Please check your path","","Framework.plugins.ioc.InvalidDefitinionFile");
		}
		</cfscript>
	</cffunction>

	<cffunction name="createColdspring" access="private" output="false" returntype="any" hint="Creates the coldspring factory and configures it">
		<cfscript>
		var coldpsring = "";
		//Get properties structure and add an element called coldbox_controller as a reference to the controller
		var settingsStruct = StructNew();
		//insert coldbox_controller
		structInsert(settingsStruct,"coldbox_controller",controller);
		//Copy the settings Structure
		structAppend(settingsStruct, getSettingStructure());
		//Create the Coldspring Factory
		coldpsring = createObject("component",instance.COLDSPRING_FACTORY).init(structnew(),settingsStruct);
		//Load Definition File
		coldpsring.loadBeansFromXmlFile( instance.ExpandedIOCDefinitionFile );
		return coldpsring;
		</cfscript>
	</cffunction>

	<cffunction name="createLightwire" access="private" output="false" returntype="any" hint="Creates the lightwire factory and configures it">
		<cfscript>
			var lightwire = "";
			// Create the LightWire Factory
			lightwire = createObject("component", instance.LIGHTWIRE_FACTORY).init(createLightwireConfigBean());
			return lightwire;
		</cfscript>
	</cffunction>
	
	<cffunction name="createLightwireConfigBean" output="false" access="private" returntype="any" hint="Creates the lightwire config bean">
		<cfscript>
			var lightwireBeanConfig = "";
			//Create the lightwire Config Bean.
			lightwireBeanConfig = CreateObject("component", instance.IOCDefinitionFile);
			//setter dependency on coldbox
			lightwireBeanConfig.setController(getController());
			//return it			
			return lightwireBeanConfig.init();
		</cfscript>
	</cffunction>

</cfcomponent>