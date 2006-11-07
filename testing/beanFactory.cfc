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
	
	<!--- ************************************************************* --->
	<cffunction name="MakeBean" hint="Populate bean. " access="public" output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="Type" required="true" type="string" hint="The type of bean to populate">
		<cfset var instance = "" />
		<cfset var i = "" />
		<cfset var fields = rc />
		
		<cftry>
			<cfif isSimpleValue(arguments.type)>
				<cfset instance = createObject("component", "#getSetting('AppMapping')#.model.#arguments.type#") />
				<cfif structKeyExists(instance, "init")>
					<cfset instance.init() />
				</cfif>
			<cfelse>
				<cfset instance = arguments.type />
			</cfif>
	
			<cfloop list="#structKeyList(fields)#" index="i">
				<cfif structKeyExists(instance, "Set" & i)>
					<cfinvoke component="#instance#" method="Set#i#">
						<cfinvokeargument name="#i#" value="#getValue(i,'')#" />
					</cfinvoke>
				</cfif>
			</cfloop>
	
			<cfreturn instance />
			
			<cfcatch type="any">
				<cfthrow type="Framework.plugins.beanFactory.BeanCreationException" message="Error creating bean: #arguments.bean#Bean" detail="#cfcatch.Detail#<br>#cfcatch.message#">
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>
