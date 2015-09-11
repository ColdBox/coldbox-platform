<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	This is another implementation of the CacheBox provider so it can work
	with ColdBox Applications.
----------------------------------------------------------------------->
<cfcomponent output="false" extends="coldbox.system.cache.providers.CacheBoxProvider" implements="coldbox.system.cache.IColdboxApplicationCache">

	<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor">
		<cfscript>
			// superSize Me
			super.init();
		
			// Prefixes
			this.VIEW_CACHEKEY_PREFIX 			= "cbox_view-";
			this.EVENT_CACHEKEY_PREFIX 			= "cbox_event-";
			
			// URL Facade Utility
			instance.eventURLFacade		= CreateObject("component","coldbox.system.cache.util.EventURLFacade").init(this);
			
			// ColdBox linkage
			instance.coldbox 			= "";
					
			return this;
		</cfscript>
	</cffunction>	

<!------------------------------------------- ColdBox Application Related Operations ------------------------------------------>

	<!--- getViewCacheKeyPrefix --->
    <cffunction name="getViewCacheKeyPrefix" output="false" access="public" returntype="any" hint="Get the cached view key prefix">
    	<cfreturn this.VIEW_CACHEKEY_PREFIX>
    </cffunction>

	<!--- getEventCacheKeyPrefix --->
    <cffunction name="getEventCacheKeyPrefix" output="false" access="public" returntype="any" hint="Get the event cache key prefix">
    	<cfreturn this.EVENT_CACHEKEY_PREFIX>
    </cffunction>

	<!--- getColdbox --->
    <cffunction name="getColdbox" output="false" access="public" returntype="any" hint="Get the coldbox application reference as coldbox.system.web.Controller" colddoc:generic="coldbox.system.web.Controller">
    	<cfreturn instance.coldbox>
    </cffunction>

	<!--- setColdbox --->
    <cffunction name="setColdbox" output="false" access="public" returntype="void" hint="Set the coldbox application reference">
    	<cfargument name="coldbox" type="any" required="true" hint="The coldbox application reference as coldbox.system.web.Controller" colddoc:generic="coldbox.system.web.Controller"/>
    	<cfset instance.coldbox = arguments.coldbox>
	</cffunction>

	<!--- getEventURLFacade --->
    <cffunction name="getEventURLFacade" output="false" access="public" returntype="any" hint="Get the event caching URL facade utility">
    	<cfreturn instance.eventURLFacade>
    </cffunction>

	<!--- Clear All the Events form the cache --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<cfargument name="async" type="any" default="false" hint="Run command asynchronously or not"/>
		
		<cfset var threadName = "clearAllEvents_#replace(instance.uuidHelper.randomUUID(),"-","","all")#">
		
		<!--- check if async and not in thread --->
		<cfif arguments.async AND NOT instance.utility.inThread()>
			
			<cfthread name="#threadName#">
				<cfset instance.elementCleaner.clearAllEvents()>
			</cfthread>
		
		<cfelse>
			<cfset instance.elementCleaner.clearAllEvents()>
		</cfif>
	</cffunction>
	
	<!--- clearEvent --->
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to snippet and querystring. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippet" type="any" 	required="true"  hint="The event snippet to clear on. Can be partial or full">
		<cfargument name="queryString" 	type="any" 	required="false" default="" hint="If passed in, it will create a unique hash out of it. For purging purposes"/>
		<cfset instance.elementCleaner.clearEvent(arguments.eventsnippet,arguments.queryString)>
	</cffunction>
	
	<!--- Clear an event Multi --->
	<cffunction name="clearEventMulti" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to the list of snippets and querystrings. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippets"    type="any"   	required="true"  hint="The comma-delimmitted list event snippet to clear on. Can be partial or full">
		<cfargument name="queryString"      type="any"   required="false" default="" hint="The comma-delimmitted list of queryStrings passed in. If passed in, it will create a unique hash out of it. For purging purposes.  If passed in the list length must be equal to the list length of the event snippets passed in."/>
    	<cfset instance.elementCleaner.clearEventMulti(arguments.eventsnippets,arguments.queryString)>
	</cffunction>
	
	<!--- clearView --->
	<cffunction name="clearView" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippet"  required="true" type="any" hint="The view name snippet to purge from the cache">
		<cfset instance.elementCleaner.clearView(arguments.viewSnippet)>
	</cffunction>
	
	<!--- clearViewMulti --->
	<cffunction name="clearViewMulti" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippets"    type="any"   required="true"  hint="The comma-delimmitted list or array of view snippet to clear on. Can be partial or full">
		<cfset instance.elementCleaner.clearViewMulti(arguments.viewSnippets)>
	</cffunction>

	<!--- Clear All The Views from the Cache. --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<cfargument name="async" type="any" default="false" hint="Run command asynchronously or not"/>
		
		<cfset var threadName = "clearAllViews_#replace(instance.uuidHelper.randomUUID(),"-","","all")#">
		
		<!--- check if async and not in thread --->
		<cfif arguments.async AND NOT instance.utility.inThread()>
			
			<cfthread name="#threadName#">
				<cfset instance.elementCleaner.clearAllViews()>
			</cfthread>
		
		<cfelse>
			<cfset instance.elementCleaner.clearAllViews()>
		</cfif>
		
	</cffunction>

</cfcomponent>