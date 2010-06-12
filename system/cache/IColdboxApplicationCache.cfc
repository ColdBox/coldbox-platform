<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface to produce a ColdBox Application cache.

----------------------------------------------------------------------->
<cfinterface extends="coldbox.system.cache.ICacheProvider" hint="The main interface to produce a ColdBox Application cache">

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
	
</cfinterface>