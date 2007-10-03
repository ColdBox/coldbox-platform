<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	A simple request context trimmer before processing.
----------------------------------------------------------------------->
<cfcomponent name="requestContextTrimmer"
			 hint="This is a simple tracer"
			 output="false"
			 extends="coldbox.system.interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<!--- Nothing --->
		
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->
	
	<!--- Pre execution process --->
	<cffunction name="preProcess" access="public" returntype="void" hint="Executes before any event execution occurs" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
		var rc = event.getCollection();
		var key = "";
		
		/* Clean and trim */
		for( key in rc ){
			if( isSimpleValue(rc[key]) ){
				rc[key] = trim(rc[key]);
			}
		}
		</cfscript>
	</cffunction>
	
</cfcomponent>