<cfcomponent name="ehGeneral" extends="coldbox.system.eventhandler" output="false">
	
	<cffunction name="index" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<!--- Do Your Logic Here to prepare a view --->
		<cfset Event.setValue("welcomeMessage","Welcome to ColdBox!")>	
		<!--- Set the View To Display, after Logic --->
		<cfset Event.setView("home")>
	</cffunction>
	
</cfcomponent>