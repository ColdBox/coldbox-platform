<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	The multi-threaded cache manager

Modification History:
01/18/2007 - Created

----------------------------------------------------------------------->
<cfcomponent name="MTCacheManager" hint="The multi-threaded cache manager." extends="cacheManager" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="reap" access="public" output="false" returntype="void" hint="Reap the cache.">
		<cfset var ThreadName = "coldbox.cache.reap_#replace(createUUID(),"-","","all")#">
		<cfthread name="#threadName#">  
			<cfscript>  
				super.reap(); 
			</cfscript>
		</cfthread>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permuations from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="eventsnippet" type="string" required="true" hint="The event snippet to clear on. Can be partial or full">
		<cfargument name="queryString" 	type="string" 	required="false" default="" hint="If passed in, it will create a unique hash out of it. For purging purposes"/>
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.clearEvent_#replace(createUUID(),"-","","all")#">
		<cfif arguments.async>
			<cfthread name="#threadName#"
					  eventsnippet="#arguments.eventsnippet#"
					  queryString="#arguments.queryString#">  
				<cfscript>  
					super.clearEvent(Attributes.eventsnippet,Attributes.queryString); 
				</cfscript>
			</cfthread>
		<cfelse>
			<cfscript>
				super.clearEvent(argumentCollection=arguments);
			</cfscript>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
		
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.clearAllEvents_#replace(createUUID(),"-","","all")#">
		<cfif arguments.async>
			<cfthread name="#threadName#">  
				<cfscript>  
					super.clearAllEvents();  
				</cfscript>          
			</cfthread>
		<cfelse>
			<cfscript>  
				super.clearAllEvents();  
			</cfscript>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.clearAllViews_#replace(createUUID(),"-","","all")#">
		<cfif arguments.async>
			<cfthread name="#threadName#">  
				<cfscript>  
					super.clearAllViews();  
				</cfscript>          
			</cfthread>
		<cfelse>
			<cfscript>  
				super.clearAllViews();  
			</cfscript>
		</cfif>
	</cffunction>
	
</cfcomponent>