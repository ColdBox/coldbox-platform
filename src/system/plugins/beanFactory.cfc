<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author: Luis Majano
Date:   July 28, 2006
Description: This is the framework's simple bean factory.

Modifications:
07/29/2006 - Added more hints.
12/08/2006 - Added makeBean method thanks to Sana Ullah. It will create and or populate a bean with the same request collection field names.
----------------------------------------------------------------------->
<cfcomponent name="beanFactory" hint="I am a simple bean factory and you can use me if you want." extends="coldbox.system.plugin" cache="true">

	<!--- ************************************************************* --->

	<cffunction name="init" access="public" returntype="coldbox.system.plugin" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
		super.Init(arguments.controller);
		setpluginName("Bean Factory");
		setpluginVersion("1.0");
		setpluginDescription("I am a simple bean factory");
		return this;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="create" hint="Create a named bean, simple as that. This method will append {Bean} to the path+name passed in." access="public" output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="bean" 		required="true"  type="string" hint="The type of bean to create and return. Uses full cfc path mapping.Ex: coldbox.beans.exceptionBean">
		<cfargument name="callInitFlag"	required="false" type="boolean" default="false" hint="Flag to call an init method on the bean.">
		<!--- ************************************************************* --->
		<cfscript>
		try{
			if ( arguments.callInitFlag )
				return createObject("component","#arguments.bean#").init();
			else
				return createObject("component","#arguments.bean#");
		}
		Catch(Any e){
			throw("Error creating bean: #arguments.bean#","#e.Detail#<br>#e.message#","Framework.plugins.beanFactory.BeanCreationException");
		}
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="populateBean" access="public" output="false" returntype="Any" hint="Populate a named or instantiated bean (java/cfc) from the request collection items">
		<!--- ************************************************************* --->
		<cfargument name="FormBean" required="true" type="any" hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<!--- ************************************************************* --->
		<cfset var beanInstance = "" />
		<cfset var FieldKey = "" />
		<cfset var fields = controller.getRequestService().getContext().getCollection() />

		<cftry>
			<cfif isSimpleValue(arguments.FormBean)>
				<cfset beanInstance = CreateObject("component",arguments.FormBean)>
				<cfif structKeyExists(beanInstance,"init")>
					<cfset beanInstance.init()>
				</cfif>
			<cfelse>
				<cfset beanInstance = arguments.FormBean>
			</cfif>
			<!--- Populate Bean --->
			<cfloop collection="#fields#" item="FieldKey">
				<cfif structKeyExists(beanInstance, "set" & FieldKey)>
					<cfinvoke component="#beanInstance#" method="set#FieldKey#">
						<cfinvokeargument name="#FieldKey#" value="#fields[FieldKey]#">
					</cfinvoke>
				</cfif>
			</cfloop>

			<cfcatch type="any">
				<cfthrow type="Framework.plugins.beanFactory.PopulateBeanException" message="Error populating bean." detail="#cfcatch.Detail#<br>#cfcatch.message#">
			</cfcatch>
		</cftry>

		<cfreturn beanInstance />
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>
