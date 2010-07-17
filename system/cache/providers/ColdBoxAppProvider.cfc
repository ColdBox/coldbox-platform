<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	This is another implementation of the CacheBox provider so it can work
	with ColdBox Applications.
----------------------------------------------------------------------->
<cfcomponent output="false" extends="coldbox.system.cache.providers.CacheBoxProvider" implements="coldbox.system.cache.IColdboxApplicationCache">

	<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor">
		<cfscript>
			// super size me
			super.init();
		
			return this;
		</cfscript>
	</cffunction>	

<!------------------------------------------- ColdBox Application Related Operations ------------------------------------------>

	<!--- getViewCacheKeyPrefix --->
    <cffunction name="getViewCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the cached view key prefix">
    </cffunction>

	<!--- getEventCacheKeyPrefix --->
    <cffunction name="getEventCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the event cache key prefix">
    </cffunction>

	<!--- getHandlerCacheKeyPrefix --->
    <cffunction name="getHandlerCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the handler cache key prefix">
    </cffunction>

	<!--- getInterceptorCacheKeyPrefix --->
    <cffunction name="getInterceptorCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the interceptor cache key prefix">
    </cffunction>

	<!--- getPluginCacheKeyPrefix --->
    <cffunction name="getPluginCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the plugin cache key prefix">
    </cffunction>

	<!--- getCustomPluginCacheKeyPrefix --->
    <cffunction name="getCustomPluginCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the custom plugin cache key prefix">
    </cffunction>

	<!--- getColdbox --->
    <cffunction name="getColdbox" output="false" access="public" returntype="coldbox.system.web.Controller" hint="Get the coldbox application reference">
    </cffunction>

	<!--- setColdbox --->
    <cffunction name="setColdbox" output="false" access="public" returntype="void" hint="Set the coldbox application reference">
    	<cfargument name="coldbox" type="coldbox.system.web.Controller" required="true" hint="The coldbox application reference"/>
    </cffunction>

	<!--- getEventURLFacade --->
    <cffunction name="getEventURLFacade" output="false" access="public" returntype="coldbox.system.cache.util.EventURLFacade" hint="Get the event caching URL facade utility">
    </cffunction>

	<!--- getItemTypes --->
	<cffunction name="getItemTypesCount" access="public" output="false" returntype="coldbox.system.cache.util.ItemTypeCount" hint="Get the item types counts of the cache. These are calculated according to the prefixes set.">
	</cffunction>
	
	<!--- Clear All the Events form the cache --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
	</cffunction>
	
	<!--- Clear an event --->
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to snippet and querystring. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<!--- ************************************************************* --->
		<cfargument name="eventsnippet" type="string" 	required="true"  hint="The event snippet to clear on. Can be partial or full">
		<cfargument name="queryString" 	type="string" 	required="false" default="" hint="If passed in, it will create a unique hash out of it. For purging purposes"/>
		<!--- ************************************************************* --->
	</cffunction>
	
	<!--- clear View --->
	<cffunction name="clearView" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<!--- ************************************************************* --->
		<cfargument name="viewSnippet"  required="true" type="string" hint="The view name snippet to purge from the cache">
		<!--- ************************************************************* --->
	</cffunction>

	<!--- Clear All The Views from the Cache. --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
	</cffunction>

</cfcomponent>