<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This cfc takes care of debugging settings.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="debuggerService" output="false" hint="The coldbox debugger service" extends="baseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="debuggerService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			/* set the unique cookie name */
			setCookieName("coldbox_debugmode_#controller.getAppHash()#");
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get the debug mode flag --->
	<cffunction name="getDebugMode" access="public" hint="I Get the current user's debugmode" returntype="boolean"  output="false">
		<cfif structKeyExists(cookie,getCookieName())>
			<cfreturn cookie[getCookieName()]>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<!--- Set the debug mode flag --->
	<cffunction name="setDebugMode" access="public" hint="I set the current user's debugmode" returntype="void"  output="false">
		<cfargument name="mode" type="boolean" required="true" >
		<cfif arguments.mode>
			<cfcookie name="#getCookieName()#" value="true">
		<cfelseif structKeyExists(cookie,getCookieName())>
			<cfcookie name="#getCookieName()#" value="false" expires="#now()#">
		</cfif>
	</cffunction>

	<!--- render the debug log --->
	<cffunction name="renderDebugLog" access="public" hint="Return the debug log." output="false" returntype="Any">
		<cfset var RenderedDebugging = "">
		<cfset var Event = controller.getRequestService().getContext()>

		<!--- Set local Variables --->
		<cfset var itemTypes = controller.getColdboxOCM().getItemTypes()>
		<cfset var cacheMetadata = "">
		<cfset var cacheKeyList = "">
		<cfset var cacheKeyIndex = 1>

		<!--- Setup Local Variables --->
		<cfset var debugStartTime = GetTickCount()>
		<cfset var RequestCollection = Event.getCollection()>

		<!--- Debug Rendering Type --->
		<cfset var renderType = "main">

		<!--- JVM Data --->
		<cfset var JVMRuntime = controller.getColdboxOCM().getJavaRuntime().getRuntime()>
		<cfset var JVMFreeMemory = JVMRuntime.freeMemory()/1024>
		<cfset var JVMTotalMemory = JVMRuntime.totalMemory()/1024>

		<!--- Render debuglog --->
		<cfsavecontent variable="RenderedDebugging"><cfinclude template="../includes/debug.cfm"></cfsavecontent>
		<cfreturn RenderedDebugging>
	</cffunction>

	<!--- Render the cache panel --->
	<cffunction name="renderCachePanel" access="public" hint="Renders the caching panel." output="false" returntype="Any">
		<cfset var event = controller.getRequestService().getContext()>
		<cfset var RenderedDebugging = "">

		<!--- Set local Variables --->
		<cfset var itemTypes = controller.getColdboxOCM().getItemTypes()>
		<cfset var cacheMetadata = controller.getColdboxOCM().getpool_metadata()>
		<cfset var cacheKeyList = listSort(structKeyList(cacheMetaData),"textnocase")>
		<cfset var cacheKeyIndex = 1>

		<!--- Setup Local Variables --->
		<cfset var RequestCollection = Event.getCollection()>

		<!--- JVM Data --->
		<cfset var JVMRuntime = controller.getColdboxOCM().getJavaRuntime().getRuntime()>
		<cfset var JVMFreeMemory = JVMRuntime.freeMemory()/1024>
		<cfset var JVMTotalMemory = JVMRuntime.totalMemory()/1024>

		<!--- Debug Rendering Type --->
		<cfset var renderType = "cachepanel">

		<!--- Generate Debugging --->
		<cfsavecontent variable="RenderedDebugging"><cfinclude template="../includes/cachepanel.cfm"></cfsavecontent>
		<cfreturn RenderedDebugging>
	</cffunction>
	
	<!--- Render Cache Dumpver --->
	<cffunction name="renderCacheDumper" access="public" hint="Renders the caching key value dumper." output="false" returntype="Any">
		<cfset var event = controller.getRequestService().getContext()>
		<cfset var cachekey = URLDecode(event.getValue('key',''))>
		<cfset var cacheValue = controller.getColdboxOCM().get(cachekey)>
		<cfset var dumperContents = "">
		
		<cfif isSimpleValue(cacheValue)>
			<cfsavecontent variable="dumperContents"><cfoutput><strong>#cachekey#</strong> = #cacheValue#</cfoutput></cfsavecontent>
		<cfelse>
			<cfsavecontent variable="dumperContents"><cfdump var="#cacheValue#" label="#cachekey#"></cfsavecontent>
		</cfif>
		
		<cfreturn dumperContents>
	</cffunction>
	
	<!--- Get set the cookie name --->
	<cffunction name="getcookieName" access="public" output="false" returntype="string" hint="Get cookieName">
		<cfreturn instance.cookieName/>
	</cffunction>
	<cffunction name="setcookieName" access="public" output="false" returntype="void" hint="Set cookieName">
		<cfargument name="cookieName" type="string" required="true"/>
		<cfset instance.cookieName = arguments.cookieName/>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>