<cfcomponent extends="coldbox.system.EventHandler" output="false">		<cfscript>		this.event_cache_suffix = "";		this.prehandler_only 	= "";		this.prehandler_except 	= "";		this.posthandler_only 	= "";		this.posthandler_except = "";		/* HTTP Methods Allowed for actions. */		/* Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'} */		this.allowedMethods = structnew();	</cfscript><!----------------------------------------- IMPLICIT EVENTS ------------------------------------------>
	<!--- UNCOMMENT HANDLER IMPLICIT EVENTS		<!--- preHandler --->
	<cffunction name="preHandler" returntype="void" output="false" hint="Executes before any event in this handler">
		<cfargument name="event" required="true">		<cfargument name="action" hint="The intercepted action"/>
		<cfscript>	
			var rc = event.getCollection();
		</cfscript>
	</cffunction>		<!--- postHandler --->
	<cffunction name="postHandler" returntype="void" output="false" hint="Executes after any event in this handler">
		<cfargument name="event" required="true">		<cfargument name="action" hint="The intercepted action"/>		<cfscript>				var rc = event.getCollection();		</cfscript>
	</cffunction>		<!--- onMissingAction --->
	<cffunction name="onMissingAction" returntype="void" output="false" hint="Executes if a request action (method) is not found in this handler">
		<cfargument name="event" 		 required="true">		<cfargument name="MissingAction" required="true" hint="The requested action string"/>
		<cfscript>				var rc = event.getCollection();		</cfscript>
	</cffunction>		---><!------------------------------------------- PUBLIC EVENTS ------------------------------------------>
	<!--- Default Action --->	<cffunction name="index" returntype="void" output="false" hint="My main event">		<cfargument name="event" required="true">		<cfset var rc = event.getCollection()>				<cfset rc.welcomeMessage = "Welcome to ColdBox!">					<cfset event.setView("home")>	</cffunction>		<!--- Do Something Action --->	<cffunction name="doSomething" returntype="void" output="false" hint="Do Something">		<cfargument name="event" required="true">		<cfset var rc = event.getCollection()>				<cfset setNextEvent("general.index")>	</cffunction><!------------------------------------------- PRIVATE EVENTS ------------------------------------------>
	</cfcomponent>