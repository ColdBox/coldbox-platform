<!-----------------------------------------------------------------------Author 	 :	Your NameDate     :	September 25, 2005Description : 				This is a ColdBox event handler for general methods.Please note that the extends needs to point to the eventhandler.cfcin the ColdBox system directory.extends = coldbox.system.EventHandler	-----------------------------------------------------------------------><cfcomponent name="general" extends="coldbox.system.EventHandler" output="false">	<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
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
	<!--- Default Action --->	<cffunction name="index" access="public" returntype="void" output="false">		<cfargument name="Event" type="any">				<!--- Do Your Logic Here to prepare a view --->		<cfset Event.setValue("welcomeMessage","Welcome to ColdBox!")>					<!--- Set the View To Display, after Logic --->		<cfset Event.setView("home")>	</cffunction>	<!------------------------------------------- PRIVATE EVENTS ------------------------------------------>
	</cfcomponent>