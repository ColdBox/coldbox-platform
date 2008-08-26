<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	March 05 2008
Description :	ColdBox Plugins are very powerfull for AOP, I will try to have sample of each one.
----------------------------------------------------------------------->
<cfcomponent name="ehPlugin" extends="coldbox.system.eventhandler" output="false">
	
	<!--- This init format is mandatory if you are writing init code else is optional, include the super.init(arguments.controller). ---> 
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" type="any">
		<cfset super.init(arguments.controller)>
		<!--- Any constructor code here --->
		<cfreturn this>
	</cffunction>
	
	<cffunction name="preHandler" output="false" returntype="void" access="public">
	  <cfargument name="Event" type="coldbox.system.beans.requestContext">
	  <cfscript>
	  //Execute any pre-event code here. Like AOP logging, etc.
	  </cfscript>
	</cffunction>

	<cffunction name="dspHome" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- Do Your Logic Here to prepare a view --->
		<cfset Event.setValue("welcomeMessage","Welcome to ColdBox!")>	
		<!--- Set the View To Display, after Logic --->
		<cfset Event.setView("plugin/vwPluginHome")>
	</cffunction>
	
	<!--- application storage plugin  ---> 
	<cffunction name="dspApplicationStorage" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- get Request Collection --->
		<cfset var rc = event.getCollection() />
		
		<!--- rc scope will be available in our .cfc files, so set plugin rc scope---> 
		<cfset rc.plugin = controller.getPlugin("applicationstorage") />
		
		<cfif not rc.plugin.exists("MyTestComp")>
			 <cfset rc.plugin.setVar(name = "MyTestComp", value= CreateObject("component","coldbox.samples.applications.CF8Ajax.model.test1")) />		
		</cfif>
		
		<!--- Set the View To Display, after Logic --->
		<cfset Event.setView("plugin/vwApplicationStorage")>
	</cffunction>
	
	<!--- Session Storage plugin  --->
	<cffunction name="dspSessionStorage" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- get Request Collection --->
		<cfset var rc = event.getCollection() />
		
		<!--- rc scope will be available in our .cfc files, so set plugin rc scope---> 
		<cfset rc.plugin = controller.getPlugin("applicationstorage") />
		
		<cfif not rc.plugin.exists("MyTestComp")>
			 <cfset rc.plugin.setVar(name = "MyTestComp", value= CreateObject("component","coldbox.samples.applications.CF8Ajax.model.test1")) />		
		</cfif>
		
		<!--- Set the View To Display, after Logic --->
		<cfset Event.setView("plugin/vwSessionStorage")>
	</cffunction>
	
	<!--- Session Storage plugin  --->
	<cffunction name="dspCookieStorage" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- get Request Collection --->
		<cfset var rc = event.getCollection() />
		<cfset var UserInfo = structNew() />
		<cfset var SimpleValue = "This value was encrypted by cookie plugin" />
		
		<cfset UserInfo["FirtName"] = "Sana" />
		<cfset UserInfo["LastName"] = "Ullah" />
		<cfset UserInfo["Role"] = "Moderator" />
		<cfset UserInfo["Email"] = "test31@test31.co.uk" />
		
		<!--- rc scope will be available in our .cfc files, so set plugin rc scope---> 
		<cfset rc.plugin = controller.getPlugin("cookiestorage") />
		
		<cfif not rc.plugin.exists("UserInfo")>
			 <cfset rc.plugin.setVar(name = "UserInfo", value= UserInfo, expires= 1) />
			 <cfset rc.plugin.setVar(name = "SimpleValue", value= SimpleValue, expires= 1) />		
		</cfif>
		
		<!--- Set the View To Display, after Logic --->
		<cfset Event.setView("plugin/vwCookieStorage")>
	</cffunction>
	
	<cffunction name="postHandler" output="false" returntype="void" access="public">
	  <cfargument name="Event" type="coldbox.system.beans.requestContext">
	  <cfscript>
	  //Execute any pre-event code here. Like AOP logging, etc.
	  </cfscript>
	</cffunction>
	
</cfcomponent>
