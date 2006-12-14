<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------

Author: Luis Majano
Date:   July 28, 2006
Description: This is the framework's simple bean factory.

Modifications:
07/29/2006 - Added more hints.
12/08/2006 - Added makeBean method thanks to Sana Ullah. It will create and or populate a bean with the same request collection field names.
----------------------------------------------------------------------->
<cfcomponent name="beanFactory" hint="I am a simple bean factory and you can use me if you want." extends="coldbox.system.plugin">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfscript>
		super.Init();
		variables.instance.pluginName = "Bean Factory";
		variables.instance.pluginVersion = "1.0";
		variables.instance.pluginDescription = "I am a simple bean factory";
		return this;
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="create" hint="Create a named bean, simple as that. This method will append {Bean} to the path+name passed in." access="public" output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="bean" 		required="true"  type="string" hint="The type of bean to create and return. Uses full cfc path mapping.Ex: coldbox.beans.exceptionBean">
		<cfargument name="callInitFlag"	required="false" type="boolean" default="false" hint="Flag to call an init method on the bean.">
		<!--- ************************************************************* --->
		<cfscript>
		try{
			if ( arguments.callInit )
				return createObject("component","#arguments.bean#").init();
			else
				return createObject("component","#arguments.bean#");
		}
		Catch(Any e){
			throw("Error creating bean: #arguments.bean#Bean","#e.Detail#<br>#e.message#","Framework.plugins.beanFactory.BeanCreationException");
		}
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="populateBean" access="public" output="false" returntype="Any" hint="Populate a named or instantiated bean (java/cfc)">
		<!--- ************************************************************* --->
		<cfargument name="FormBean" required="true" type="any" hint="The type of bean to populate. Full instantiation path as string. Or an already instantiated bean. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<!--- ************************************************************* --->
		<cfset var instance = "" />
		<cfset var FieldKey = "" />
		<cfset var fields = rc />
		
		<cftry>
			<cfif isSimpleValue(arguments.FormBean)>
				<cfset instance = CreateObject("component",arguments.FormBean)>
				<cfif structKeyExists(instance,"init")>
					<cfset instance.init()>
				</cfif>
			<cfelse>
				<cfset instance = arguments.FormBean>
			</cfif>
			
			<cfloop collection="#fields#" item="FieldKey">
				<cfif structKeyExists(instance, "set" & FieldKey)>
					<cfinvoke component="#instance#" method="set#FieldKey#">
						<cfinvokeargument name="#FieldKey#" value="#fields[FieldKey]#">
					</cfinvoke>
				</cfif>
			</cfloop>
			
			<cfreturn instance />
			
			<cfcatch type="any">
				<cfthrow type="Framework.plugins.beanFactory.PopulateBeanException" message="Error creating bean: #arguments.FormBean#" detail="#cfcatch.Detail#<br>#cfcatch.message#">
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>
