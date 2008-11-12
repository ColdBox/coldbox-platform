<!-----------------------------------------------------------------------Author 	 :	Your NameDate     :	September 25, 2005Description : 				This is a ColdBox event handler for general methods.Please note that the extends needs to point to the eventhandler.cfcin the ColdBox system directory.extends = coldbox.system.eventhandler	-----------------------------------------------------------------------><cfcomponent name="general" extends="coldbox.system.eventhandler" output="false">		<!--- Event Caching Suffix: It will be appended to every event cached key. This can be a locale, dynamic, etc. --->	<cfset this.EVENT_CACHE_SUFFIX = "">	<!--- Pre Handler Execute only if action in this list --->	<cfset this.PREHANDLER_ONLY = "">	<!--- Pre Handler Do not execute if action in this except list --->	<cfset this.PREHANDLER_EXCEPT = "">	<!--- Post Handler Execute only if action in this list --->	<cfset this.POSTHANDLER_ONLY = "">	<!--- Post Handler Do not execute if action in this except list --->	<cfset this.POSTHANDLER_EXCEPT = "">	<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	<!--- This init is mandatory, including the super.init(). ---> 	<cffunction name="init" access="public" returntype="general" output="false">		<cfargument name="controller" type="any">		<cfset super.init(arguments.controller)>		<!--- Any constructor code here --->		<cfreturn this>	</cffunction><!----------------------------------------- IMPLICIT EVENTS ------------------------------------------>
	<!--- UNCOMMENT HANDLER IMPLICIT EVENTS		<!--- preHandler --->
	<cffunction name="preHandler" access="public" returntype="void" output="false" hint="Executes before any event in this handler">
		<cfargument name="Event" type="any" required="yes">
		<cfset var rc = event.getCollection()>
		<cfscript>	
	
		</cfscript>
	</cffunction>		<!--- postHandler --->
	<cffunction name="postHandler" access="public" returntype="void" output="false" hint="Executes after any event in this handler">
		<cfargument name="Event" type="any" required="yes">
		<cfset var rc = event.getCollection()>
		<cfscript>	
	
		</cfscript>
	</cffunction>		<!--- onMissingAction --->
	<cffunction name="onMissingAction" access="public" returntype="void" output="false" hint="Executes if a request action (method) is not found in this handler">
		<cfargument name="Event" 			type="any" required="yes">		<cfargument name="MissingAction" 	type="any" required="true" hint="The requested action string"/>
		<cfset var rc = event.getCollection()>
		<cfscript>	
	
		</cfscript>
	</cffunction>		---><!------------------------------------------- PUBLIC EVENTS ------------------------------------------>
	<!--- Default Action --->	<cffunction name="index" access="public" returntype="void" output="false">		<cfargument name="Event" type="any">		<!--- RC Reference --->		<cfset var rc = event.getCollection()>				<!--- Do Your Logic Here to prepare a view --->		<cfset Event.setValue("welcomeMessage","Welcome to ColdBox!")>					<!--- Set the View To Display, after Logic --->		<cfset Event.setView("home")>	</cffunction>		<!--- Do Something Action --->	<cffunction name="doSomething" access="public" returntype="void" output="false">		<cfargument name="Event" type="any">		<!--- RC Reference --->		<cfset var rc = event.getCollection()>				<!--- Do Your Logic Here, call to models, etc.--->		<!--- Set the next event to run, after Logic, this relocates the browser--->		<cfset setNextEvent("general.index")>	</cffunction><!------------------------------------------- PRIVATE EVENTS ------------------------------------------>
	</cfcomponent>