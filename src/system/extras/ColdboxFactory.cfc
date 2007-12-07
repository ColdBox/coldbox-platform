<!-----------------------------------------------------------------------
Template : ColdboxFactory.cfc
Author 	 : Luis Majano
Date     : 5/30/2007 6:10:56 PM
Description :
	This is a proxy factory to return ColdBox components and beans.
	You can set this up via Coldspring to return configured
	ConfigBeans, the ColdBox controller and ColdBox Plugins.
	
	<!-- ColdboxFactory -->
	<bean id="ColdboxFactory" class="coldbox.system.extras.ColdboxFactory" />
	<bean id="ConfigBean" factory-bean="ColdboxFactory" factory-method="getConfigBean" />
	
	<bean id="loggerPlugin" factory-bean="ColdboxFactory" factory-method="getPlugin">
		<constructor-arg name="name">
			<value>logger</value>
		</constructor-arg>
		<constructor-arg name="customPlugin">
			<value>true|false</value>
		</constructor-arg>
	</bean>

Modification History:
5/30/2007 - Created Template
---------------------------------------------------------------------->
<cfcomponent name="ColdboxFactory" output="false" hint="Create Config Beans, Controller, Cache Manager and Plugins of the current running application">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- The beans paths --->
	<cfset variables.configBeanPath = "coldbox.system.beans.configBean">
	<Cfset variables.datasourceBeanPath = "coldbox.system.beans.datasourceBean">
	<cfset variables.mailsettingsBeanPath = "coldbox.system.beans.mailsettingsBean">
	
	<!--- Check App Config --->
	<cfif not structKeyExists(application,"cbController")>
		<cfthrow message="ColdBox controller does not exist" detail="The coldbox controller does not exist in application scope. Most likely the application has not been initialized.">
	</cfif>
		
<!------------------------------------------- HELPERS ------------------------------------------->
	
	<!--- Get a config bean --->
	<cffunction name="getConfigBean" output="false" access="public" returntype="any" hint="Returns an application's config bean">
		<cfscript>
			var ConfigBean = CreateObject("component",configBeanPath);
			ConfigBean.setConfigStruct(application.cbController.getSettingStructure(false,true));
			return ConfigBean;
		</cfscript>
	</cffunction>
	
	<!--- Get the coldbox controller --->
	<cffunction name="getColdbox" output="false" access="public" returntype="any" hint="Get the coldbox controller reference">
		<cfscript>
		return application.cbController;
		</cfscript>
	</cffunction>
	
	<!--- Get the cache manager --->
	<cffunction name="getColdboxOCM" output="false" access="public" returntype="any" hint="Get the coldbox cache manager reference">
		<cfscript>
		return application.cbController.getColdboxOCM();
		</cfscript>
	</cffunction>
	
	<!--- Get a plugin --->
	<cffunction name="getPlugin" access="Public" returntype="any" hint="Plugin factory" output="true">
		<cfargument name="plugin" 		type="string"  hint="The Plugin object's name to instantiate" >
		<cfargument name="customPlugin" type="boolean" required="false" default="false" hint="Used internally to create custom plugins.">
		<cfargument name="newInstance"  type="boolean" required="false" default="false" hint="If true, it will create and return a new plugin. No caching or persistance.">
		<!--- ************************************************************* --->
		<cfscript>
		return application.cbController.getPlugin(argumentCollection=arguments);
		</cfscript>
	</cffunction>
	
	<!--- Get a datasource --->
	<cffunction name="getDatasource" access="public" output="false" returnType="any" hint="I will return to you a datasourceBean according to the alias of the datasource you wish to get from the configstruct">
		<!--- ************************************************************* --->
		<cfargument name="alias" type="string" hint="The alias of the datasource to get from the configstruct (alias property in the config file)">
		<!--- ************************************************************* --->
		<cfscript>
		var datasources = application.cbController.getSetting("Datasources");
		//Check for datasources structure
		if ( structIsEmpty(datasources) ){
			throw("There are no datasources defined for this application.","","Framework.coldboxFactory.DatasourceStructureEmptyException");
		}
		//Try to get the correct datasource.
		if ( structKeyExists(datasources, arguments.alias) ){
			return CreateObject("component",datasourceBeanPath).init(datasources[arguments.alias]);
		}
		else{
			throw("The datasource: #arguments.alias# is not defined.","","Framework.coldboxFactory.DatasourceNotFoundException");
		}
		</cfscript>
	</cffunction>
	
	<!--- Get a mail settings bean --->
	<cffunction name="getMailSettings" access="public" output="false" returnType="any" hint="I will return to you a mailsettingsBean modeled after your mail settings in your config file.">
		<cfscript>
		return CreateObject("component",mailsettingsBeanPath).init(application.cbController.getSetting("MailServer"),
																   application.cbController.getSetting("MailUsername"),
																   application.cbController.getSetting("MailPassword"), 
																   application.cbController.getSetting("MailPort"));
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	

</cfcomponent>