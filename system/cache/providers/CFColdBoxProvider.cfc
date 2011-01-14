/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author: Luis Majano
Description:
	
This CacheBox provider communicates with the built in caches in
the Adobe ColdFusion Engine for ColdBox applications.

*/
component serializable="false" extends="coldbox.system.cache.providers.CFProvider" implements="coldbox.system.cache.IColdboxApplicationCache"{

	CFColdBoxProvider function init() output=false{
		super.init();
		
		// Prefixes
		this.VIEW_CACHEKEY_PREFIX 			= "cf_view-";
		this.EVENT_CACHEKEY_PREFIX 			= "cf_event-";
		this.HANDLER_CACHEKEY_PREFIX 		= "cf_handler-";
		this.INTERCEPTOR_CACHEKEY_PREFIX 	= "cf_interceptor-";
		this.PLUGIN_CACHEKEY_PREFIX 		= "cf_plugin-";
		this.CUSTOMPLUGIN_CACHEKEY_PREFIX 	= "cf_customplugin-";
		
		
		// URL Facade Utility
		instance.eventURLFacade		= CreateObject("component","coldbox.system.cache.util.EventURLFacade").init(this);
		
		return this;
	}
	
	// Cache Key prefixes
	any function getViewCacheKeyPrefix() output=false{ return this.VIEW_CACHEKEY_PREFIX; }
	any function getEventCacheKeyPrefix() output=false{ return this.EVENT_CACHEKEY_PREFIX; }
	any function getHandlerCacheKeyPrefix() output=false{ return this.HANDLER_CACHEKEY_PREFIX; }
	any function getInterceptorCacheKeyPrefix() output=false{ return this.INTERCEPTOR_CACHEKEY_PREFIX; }
	any function getPluginCacheKeyPrefix() output=false{ return this.PLUGIN_CACHEKEY_PREFIX; }
	any function getCustomPluginCacheKeyPrefix() output=false{ return this.CUSTOMPLUGIN_CACHEKEY_PREFIX; }
	
	// set the coldbox controller
	void function setColdbox(required any coldbox) output=false{
		variables.coldbox = arguments.coldbox;
	}
	
	// Get ColdBox
	any function getColdbox() output=false{ return coldbox; }
	
	// Get Event URL Facade Tool
	any function getEventURLFacade() output=false{ return instance.eventURLFacade; }
	
	// Get Item Type Counts
	any function getItemTypes() output=false{
		var x 			= 1;
		var itemList 	= getKeys();
		var itemTypes	= new coldbox.system.cache.util.ItemTypeCount();
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
	}
	
	/**
	* Clear all events
	*/
	void function clearAllEvents(async=false) output=false{
		var threadName = "clearAllEvents_#replace(instance.uuidHelper.randomUUID(),"-","","all")#";
		
		// Async? IF so, do checks
		if( arguments.async AND NOT instance.utility.inThread() ){
			thread name="#threadName#"{
				instance.elementCleaner.clearAllEvents();
			}
		}
		else{
			instance.elementCleaner.clearAllEvents();
		}		
	}
	
	/**
	* Clear all views
	*/
	void function clearAllViews(async=false) output=false{
		var threadName = "clearAllViews_#replace(instance.uuidHelper.randomUUID(),"-","","all")#";
		
		// Async? IF so, do checks
		if( arguments.async AND NOT instance.utility.inThread() ){
			thread name="#threadName#"{
				instance.elementCleaner.clearAllViews();
			}
		}
		else{
			instance.elementCleaner.clearAllViews();
		}
	}
	
	/**
	* Clear event
	*/
	void function clearEvent(required eventsnippet, queryString="") output=false{
		instance.elementCleaner.clearEvent(arguments.eventsnippet,arguments.queryString);
	}
	
	/**
	* Clear multiple events
	*/
	void function clearEventMulti(required eventsnippets,queryString="") output=false{
		instance.elementCleaner.clearEventMulti(arguments.eventsnippets,arguments.queryString);
	}
	
	/**
	* Clear view
	*/
	void function clearView(required viewSnippet) output=false{
		instance.elementCleaner.clearView(arguments.viewSnippet);
	}
	
	/**
	* Clear multiple view
	*/
	void function clearViewMulti(required viewsnippets) output=false{
		instance.elementCleaner.clearView(arguments.viewsnippets);
	}
	
}