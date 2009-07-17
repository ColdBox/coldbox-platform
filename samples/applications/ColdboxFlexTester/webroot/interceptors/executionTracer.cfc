<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	This methods just traces what plugin points it intercepted.
----------------------------------------------------------------------->
<cfcomponent name="executionTracer"
			 hint="This is a simple tracer"
			 output="false"
			 extends="coldbox.system.interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="Configuration" output="false" >
		<!--- Nothing --->
		
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<!--- Custom Interception Point --->
	<cffunction name="onLog" access="public" returntype="void" hint="My very own custom interception point. " output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptdata" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<cfset getPlugin("logger").logEntry("warning","I just executed a custom interception point. #arguments.interceptdata.toString()#")>
	</cffunction>

</cfcomponent>