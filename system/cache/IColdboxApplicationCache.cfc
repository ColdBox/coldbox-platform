<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface to produce a ColdBox Application cache.

----------------------------------------------------------------------->
<cfinterface extends="coldbox.system.cache.ICacheProvider" hint="The main interface to produce a ColdBox Application cache">

	<!--- getViewCacheKeyPrefix --->
    <cffunction name="getViewCacheKeyPrefix" output="false" access="public" returntype="any" hint="Get the cached view key prefix">
    </cffunction>

	<!--- getEventCacheKeyPrefix --->
    <cffunction name="getEventCacheKeyPrefix" output="false" access="public" returntype="any" hint="Get the event cache key prefix">
    </cffunction>

	<!--- getColdbox --->
    <cffunction name="getColdbox" output="false" access="public" returntype="any" hint="Get the coldbox application reference as coldbox.system.web.Controller" colddoc:generic="coldbox.system.web.Controller">
    </cffunction>

	<!--- setColdbox --->
    <cffunction name="setColdbox" output="false" access="public" returntype="void" hint="Set the coldbox application reference">
    	<cfargument name="coldbox" type="any" required="true" hint="The coldbox application reference as type: coldbox.system.web.Controller" colddoc:generic="coldbox.system.web.Controller"/>
    </cffunction>

	<!--- getEventURLFacade --->
    <cffunction name="getEventURLFacade" output="false" access="public" returntype="any" hint="Get the event caching URL facade utility" colddoc:generic="coldbox.system.cache.util.EventURLFacade">
    </cffunction>

	<!--- Clear All the Events form the cache --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<cfargument name="async" type="any" hint="Run command asynchronously or not" colddoc:generic="boolean"/>
	</cffunction>
	
	<!--- clearEvent --->
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to snippet and querystring. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippet" type="any" 	required="true"  hint="The event snippet to clear on. Can be partial or full">
		<cfargument name="queryString" 	type="any" 	required="false" default="" hint="If passed in, it will create a unique hash out of it. For purging purposes"/>
	</cffunction>
	
	<!--- Clear an event Multi --->
	<cffunction name="clearEventMulti" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to the list of snippets and querystrings. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippets"    type="any"   	required="true"  hint="The comma-delimmitted list event snippet to clear on. Can be partial or full">
		<cfargument name="queryString"      type="any"   required="false" default="" hint="The comma-delimmitted list of queryStrings passed in. If passed in, it will create a unique hash out of it. For purging purposes.  If passed in the list length must be equal to the list length of the event snippets passed in."/>
      </cffunction>
	
	<!--- clearView --->
	<cffunction name="clearView" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippet"  required="true" type="any" hint="The view name snippet to purge from the cache">
	</cffunction>
	
	<!--- clearViewMulti --->
	<cffunction name="clearViewMulti" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippets"    type="any"   required="true"  hint="The comma-delimmitted list or array of view snippet to clear on. Can be partial or full">
	</cffunction>

	<!--- Clear All The Views from the Cache. --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<cfargument name="async" type="any" hint="Run command asynchronously or not" colddoc:generic="Boolean"/>
	</cffunction>
	
</cfinterface>