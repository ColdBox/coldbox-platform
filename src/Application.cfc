<cfcomponent output="false">

<cfset this.name = "coldbox">
<cfset this.clientManagement = true>
<cfset this.sessionManagement = true>
<cfset this.sessionTimeout = createTimeSpan(0,0,30,0)>
<cfset this.setClientCookies = true>
<cfset this.loginStorage = "session">

<cffunction name="onApplicationStart" returnType="boolean" output="false">
	<cfreturn true>
</cffunction>

<cffunction name="onApplicationEnd" returnType="void"  output="false">
	<cfargument name="applicationScope" required="true">
</cffunction>

<cffunction name="onSessionStart" returnType="void" output="false">
	<!--- Set on session start event --->
	<cfset form.event = "ehGeneral.onSessionStart">
</cffunction>

<cffunction name="onSessionEnd" returnType="void" output="false">
	<cfargument name="sessionScope" type="struct" required="true">
	<cfargument name="appScope" type="struct" required="false">
</cffunction>

</cfcomponent>