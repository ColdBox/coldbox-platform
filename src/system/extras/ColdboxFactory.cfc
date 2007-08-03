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

	<!--- The configBean Path --->
	<cfset variables.configBeanPath = "coldbox.system.beans.configBean">
	<!--- Check App Config --->
	<cfif not structKeyExists(application,"cbController")>
		<cfthrow message="ColdBox controller does not exist" detail="The coldbox controller does not exist in application scope. Most likely the application has not been initialized.">
	</cfif>
		
<!------------------------------------------- HELPERS ------------------------------------------->

	<cffunction name="getConfigBean" output="false" access="public" returntype="any" hint="Returns an application's config bean">
		<cfscript>
			var ConfigBean = CreateObject("component",configBeanPath);
			ConfigBean.setConfigStruct(application.cbController.getSettingStructure(false,true));
			return ConfigBean;
		</cfscript>
	</cffunction>
	
	<cffunction name="getColdbox" output="false" access="public" returntype="any" hint="Get the coldbox controller reference">
		<cfscript>
		return application.cbController;
		</cfscript>
	</cffunction>
	
	<cffunction name="getColdboxOCM" output="false" access="public" returntype="any" hint="Get the coldbox cache manager reference">
		<cfscript>
		return application.cbController.getColdboxOCM();
		</cfscript>
	</cffunction>
	
	<cffunction name="getPlugin" access="Public" returntype="any" hint="Plugin factory" output="true">
		<cfargument name="plugin" 		type="string"  hint="The Plugin object's name to instantiate" >
		<cfargument name="customPlugin" type="boolean" required="false" default="false" hint="Used internally to create custom plugins.">
		<cfargument name="newInstance"  type="boolean" required="false" default="false" hint="If true, it will create and return a new plugin. No caching or persistance.">
		<!--- ************************************************************* --->
		<cfscript>
		return application.cbController.getPlugin(arguments.name,arguments.customPlugin,arguments.newInstance);
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	

</cfcomponent>