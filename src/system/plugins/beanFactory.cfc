<!-----------------------------------------------------------------------
Author: Luis Majano
Date:   July 28, 2006
Description: This is the framework's simple bean factory.

Modifications:
07/29/2006 - Added more hints.
----------------------------------------------------------------------->
<cfcomponent name="beanFactory" hint="I am a bean factory and you can use me if you want." extends="plugin">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" required="yes" hint="The reference to the framework controller">
		<cfset super.Init(arguments.controller) />
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="create" hint="Create a named bean, simple as that. This method will append {Bean} to the name passed in." access="public" output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="bean" required="true" type="string" hint="The type of bean to create and return. Uses full path mapping.">
		<!--- ************************************************************* --->
		<cftry>
			<cfreturn createObject("component","#arguments.bean#Bean")>
			<cfcatch type="any">
				<cfthrow type="Framework.BeanCreationException" message="Error creating bean: #arguments.bean#. Please see details: #cfcatch.Detail#<br><br>#cfcatch.message#">
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>