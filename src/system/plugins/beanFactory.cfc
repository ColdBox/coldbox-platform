<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------

Author: Luis Majano
Date:   July 28, 2006
Description: This is the framework's simple bean factory.

Modifications:
07/29/2006 - Added more hints.
----------------------------------------------------------------------->
<cfcomponent name="beanFactory" hint="I am a simple bean factory and you can use me if you want." extends="coldbox.system.plugin">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfset super.Init() />
		<cfset variables.instance.pluginName = "Bean Factory">
		<cfset variables.instance.pluginVersion = "1.0">
		<cfset variables.instance.pluginDescription = "I am a simple bean factory">
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="create" hint="Create a named bean, simple as that. This method will append {Bean} to the path+name passed in." access="public" output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="bean" required="true" type="string" hint="The type of bean to create and return. Uses full cfc path mapping.Ex: coldbox.beans.exception">
		<!--- ************************************************************* --->
		<cftry>
			<cfreturn createObject("component","#arguments.bean#Bean")>
			<cfcatch type="any">
				<cfthrow type="Framework.plugins.beanFactory.BeanCreationException" message="Error creating bean: #arguments.bean#Bean" detail="#cfcatch.Detail#<br>#cfcatch.message#">
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>