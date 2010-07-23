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
			// superSize Me
			super.init();
		
			// Prefixes
			instance.viewPrefix  		= "cbox-view-";
			instance.eventPrefix 		= "cbox-event-";
			instance.handlerPrefix 		= "cbox-handler-";
			instance.interceptorPrefix	= "cbox-interceptor-";
			instance.pluginPrefix		= "cbox-plugin-";
			instance.cpluginPrefix		= "cbox-cplugin-";
			
			// URL Facade Utility
			instance.eventURLFacade		= CreateObject("component","coldbox.system.cache.util.EventURLFacade").init(this);
			// Element Cleaner Helper
			instance.elementCleaner		= CreateObject("component","coldbox.system.cache.util.ElementCleaner").init(this);
			
			// Utilities
			instance.utility			= createObject("component","coldbox.system.core.util.Util");
			instance.uuidHelper			= createobject("java", "java.util.UUID");
			
			// ColdBox linkage
			instance.coldbox 			= "";
					
			return this;
		</cfscript>
	</cffunction>	

<!------------------------------------------- ColdBox Application Related Operations ------------------------------------------>

	<!--- getViewCacheKeyPrefix --->
    <cffunction name="getViewCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the cached view key prefix">
    	<cfreturn instance.viewPrefix>
    </cffunction>

	<!--- getEventCacheKeyPrefix --->
    <cffunction name="getEventCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the event cache key prefix">
    	<cfreturn instance.eventPrefix>
    </cffunction>

	<!--- getHandlerCacheKeyPrefix --->
    <cffunction name="getHandlerCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the handler cache key prefix">
    	<cfreturn instance.handlerPrefix>
    </cffunction>

	<!--- getInterceptorCacheKeyPrefix --->
    <cffunction name="getInterceptorCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the interceptor cache key prefix">
    	<cfreturn instance.interceptorPrefix>
    </cffunction>

	<!--- getPluginCacheKeyPrefix --->
    <cffunction name="getPluginCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the plugin cache key prefix">
    	<cfreturn instance.pluginPrefix>
    </cffunction>

	<!--- getCustomPluginCacheKeyPrefix --->
    <cffunction name="getCustomPluginCacheKeyPrefix" output="false" access="public" returntype="string" hint="Get the custom plugin cache key prefix">
    	<cfreturn instance.cpluginPrefix>
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
    <cffunction name="getEventURLFacade" output="false" access="public" returntype="coldbox.system.cache.util.EventURLFacade" hint="Get the event caching URL facade utility">
    	<cfreturn instance.eventURLFacade>
    </cffunction>

	<!--- getItemTypes --->
	<cffunction name="getItemTypesCount" access="public" output="false" returntype="coldbox.system.cache.util.ItemTypeCount" hint="Get the item types counts of the cache. These are calculated according to the prefixes set.">
		<cfscript>
		var x 			= 1;
		var itemList 	= getKeys();
		var itemTypes	= createObject("component","coldbox.system.cache.util.ItemTypeCount");
		var itemLen		= arrayLen(itemList);
		
		//Sort the listing.
		arraySort(itemList, "textnocase");

		//Count objects
		for (x=1; x lte itemLen; x++){
			
			if ( findnocase( getPluginCacheKeyPrefix() , itemList[x]) )
				itemTypes.plugins++;
			else if ( findnocase( getCustomPluginCacheKeyPrefix() , itemList[x]) )
				itemTypes.customPlugins++;
			else if ( findnocase( getHandlerCacheKeyPrefix() , itemList[x]) )
				itemTypes.handlers++;
			else if ( findnocase( getInterceptorCacheKeyPrefix() , itemList[x]) )
				itemTypes.interceptors++;
			else if ( findnocase( getEventCacheKeyPrefix() , itemList[x]) )
				itemTypes.events++;
			else if ( findnocase( getViewCacheKeyPrefix() , itemList[x]) )
				itemTypes.views++;
			else
				itemTypes.other++;
		}
		
		return itemTypes;
		</cfscript>
	</cffunction>
	
	<!--- Clear By Key Snippet --->
	<cffunction name="clearByKeySnippet" access="public" returntype="void" hint="Clears keys using the passed in object key snippet" output="false" >
		<cfargument name="keySnippet"  	type="string" required="true"  hint="the cache key snippet to use">
		<cfargument name="regex" 		type="boolean" hint="Use regex or not">
		<cfargument name="async" 		type="boolean" hint="Run command asynchronously or not"/>
		
		<cfset var threadName = "clearByKeySnippet_#replace(instance.uuidHelper.randomUUID(),"-","","all")#">
		
		<!--- check if async and not in thread --->
		<cfif arguments.async AND NOT instance.util.inThread()>
			
			<cfthread name="#threadName#">
				<cfset instance.elementCleaner.clearByKeySnippet(arguments.keySnippet,arguments.regex)>
			</cfthread>
		
		<cfelse>
			<cfset instance.elementCleaner.clearByKeySnippet(arguments.keySnippet,arguments.regex)>
		</cfif>
		
	</cffunction>
	
	<!--- Clear All the Events form the cache --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<cfargument name="async" type="boolean" hint="Run command asynchronously or not"/>
		
		<cfset var threadName = "clearAllEvents_#replace(instance.uuidHelper.randomUUID(),"-","","all")#">
		
		<!--- check if async and not in thread --->
		<cfif arguments.async AND NOT instance.util.inThread()>
			
			<cfthread name="#threadName#">
				<cfset instance.elementCleaner.clearAllEvents()>
			</cfthread>
		
		<cfelse>
			<cfset instance.elementCleaner.clearAllEvents()>
		</cfif>
	</cffunction>
	
	<!--- clearEvent --->
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to snippet and querystring. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippet" type="string" 	required="true"  hint="The event snippet to clear on. Can be partial or full">
		<cfargument name="queryString" 	type="string" 	required="false" default="" hint="If passed in, it will create a unique hash out of it. For purging purposes"/>
		<cfset elementCleaner.clearEvent(arguments.eventsnippet,arguments.queryString)>
	</cffunction>
	
	<!--- Clear an event Multi --->
	<cffunction name="clearEventMulti" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to the list of snippets and querystrings. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippets"    type="any"   	required="true"  hint="The comma-delimmitted list event snippet to clear on. Can be partial or full">
		<cfargument name="queryString"      type="string"   required="false" default="" hint="The comma-delimmitted list of queryStrings passed in. If passed in, it will create a unique hash out of it. For purging purposes.  If passed in the list length must be equal to the list length of the event snippets passed in."/>
    	<cfset elementCleaner.clearEventMulti(arguments.eventsnippets,arguments.queryString)>
	</cffunction>
	
	<!--- clearView --->
	<cffunction name="clearView" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippet"  required="true" type="string" hint="The view name snippet to purge from the cache">
		<cfset elementCleaner.clearView(arguments.viewSnippet)>
	</cffunction>
	
	<!--- clearViewMulti --->
	<cffunction name="clearViewMulti" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippets"    type="any"   required="true"  hint="The comma-delimmitted list or array of view snippet to clear on. Can be partial or full">
		<cfset elementCleaner.clearViewMulti(arguments.viewSnippets)>
	</cffunction>

	<!--- Clear All The Views from the Cache. --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<cfargument name="async" type="boolean" hint="Run command asynchronously or not"/>
		
		<cfset var threadName = "clearAllViews_#replace(instance.uuidHelper.randomUUID(),"-","","all")#">
		
		<!--- check if async and not in thread --->
		<cfif arguments.async AND NOT instance.util.inThread()>
			
			<cfthread name="#threadName#">
				<cfset instance.elementCleaner.clearAllViews()>
			</cfthread>
		
		<cfelse>
			<cfset instance.elementCleaner.clearAllViews()>
		</cfif>
		
	</cffunction>

</cfcomponent>