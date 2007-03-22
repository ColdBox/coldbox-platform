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
02/15/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="ioc"
			 hint="An Inversion Of Control plugin."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true"
			 cachetimeout="0">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="coldbox.system.plugin" output="false">
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
		<cfset configure()>
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="configure" access="public" returntype="void" hint="Configure the IoC Plugin. Loads the IoC Factory and configures it." output="false">

		<!--- Check the services file First --->
		<cfset validateDefinitionFile()>

		<!--- Load the appropriate ioc Framework Bean Factory --->
		<cfswitch expression="#lcase(instance.IOCFramework)#">

			<cfcase value="coldspring">
				<cfset instance.IoCFactory = createColdspring()>
			</cfcase>

			<cfcase value="lightwire">
				<cfthrow message="Lightwire is not supported as of yet. Still in beta.">
			</cfcase>

			<cfdefaultcase>
				<cfthrow type="Framework.plugins.ioc.InvalidIoCFramework" message="The only available IoC supported frameworks are coldspring and lightwire. You choose: #instance.IOCFramework#">
			</cfdefaultcase>
		</cfswitch>

	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="reloadDefinitionFile" access="public" output="false" returntype="string" hint="Reloads the IoC factory with the Definition File">
		<cfswitch expression="#lcase(instance.IOCFramework)#">

			<cfcase value="coldspring">
				<cfset instance.IoCFactory.loadBeansFromXmlFile( instance.ExpandedIOCDefinitionFile )>
			</cfcase>

			<cfcase value="lightwire">
				<cfthrow message="Lightwire is not supported as of yet. Still in beta.">
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
			<cfswitch expression="#lcase(instance.IOCFramework)#">
				<cfcase value="coldspring">
					<cfset oBean = instance.IoCFactory.getBean(arguments.beanName)>
				</cfcase>

				<cfcase value="lightwire">
					<cfthrow message="Lightwire is not supported as of yet. Still in beta.">
				</cfcase>
			</cfswitch>
			<!--- If Caching on, then set object in cache --->
			<cfif objCaching>
				<!--- Get Object's MetaData, For Caching --->
				<cfset MetaData = getMetaData(oBean)>
				<!--- By Default, services with no cache flag are set to true --->
				<cfif not structKeyExists(MetaData,"cache") or not isBoolean(MetaData.cache)>
					<cfset MetaData.cache = true>
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
		//Relative Path Check
		if ( fileExists(ExpandedPath) ){
			instance.ExpandedIOCDefinitionFile = ExpandedPath;
		}
		//Full Path Check
		else if ( fileExists(instance.IOCDefinitionFile)){
			instance.ExpandedIOCDefinitionFile = instance.IOCDefinitionFile;
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
		<cfthrow message="Lightwire is not supported as of yet. Still in beta.">
	</cffunction>

</cfcomponent>