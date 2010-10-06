/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author: Luis Majano
Description:
	
This CacheBox provider communicates with the built in caches in
the Railo Engine for ColdBox applications.

*/
component serializable="false" extends="coldbox.system.cache.providers.RailoProvider" implements="coldbox.system.cache.IColdboxApplicationCache"{

	RailoColdboxProvider function init() output=false{
		super.init();
		
		// Cache Prefixes
		this.VIEW_CACHEKEY_PREFIX 			= "railo_view-";
		this.EVENT_CACHEKEY_PREFIX 			= "railo_event-";
		this.HANDLER_CACHEKEY_PREFIX 		= "railo_handler-";
		this.INTERCEPTOR_CACHEKEY_PREFIX 	= "railo_interceptor-";
		this.PLUGIN_CACHEKEY_PREFIX 		= "railo_plugin-";
		this.CUSTOMPLUGIN_CACHEKEY_PREFIX 	= "railo_customplugin-";
		
		
		// URL Facade Utility
		instance.eventURLFacade		= CreateObject("component","coldbox.system.cache.util.EventURLFacade").init(this);
		
		return this;
	}
	
	// Cache Key prefixes
	string function getViewCacheKeyPrefix() output=false{ return this.VIEW_CACHEKEY_PREFIX; }
	string function getEventCacheKeyPrefix() output=false{ return this.EVENT_CACHEKEY_PREFIX; }
	string function getHandlerCacheKeyPrefix() output=false{ return this.HANDLER_CACHEKEY_PREFIX; }
	string function getInterceptorCacheKeyPrefix() output=false{ return this.INTERCEPTOR_CACHEKEY_PREFIX; }
	string function getPluginCacheKeyPrefix() output=false{ return this.PLUGIN_CACHEKEY_PREFIX; }
	string function getCustomPluginCacheKeyPrefix() output=false{ return this.CUSTOMPLUGIN_CACHEKEY_PREFIX; }
	
	// set the coldbox controller
	void function setColdbox(required any coldbox) output=false{
		variables.coldbox = arguments.coldbox;
	}
	
	// Get ColdBox
	any function getColdbox() output=false{ return coldbox; }
	
	// Get Event URL Facade Tool
	coldbox.system.cache.util.EventURLFacade function getEventURLFacade() output=false{ return instance.eventURLFacade; }
	
	// Get Item Type Counts
	coldbox.system.cache.util.ItemTypeCount function getItemTypes() output=false{
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
	void function clearAllEvents(boolean async=false) output=false{
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
	void function clearAllViews(boolean async=false) output=false{
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
	void function clearEvent(required string eventsnippet, string queryString="") output=false{
		instance.elementCleaner.clearEvent(arguments.eventsnippet,arguments.queryString);
	}
	
	/**
	* Clear multiple events
	*/
	void function clearEventMulti(required any eventsnippets,string queryString="") output=false{
		instance.elementCleaner.clearEventMulti(arguments.eventsnippets,arguments.queryString);
	}
	
	/**
	* Clear view
	*/
	void function clearView(required string viewSnippet) output=false{
		instance.elementCleaner.clearView(arguments.viewSnippet);
	}
	
	/**
	* Clear multiple view
	*/
	void function clearViewMulti(required any viewsnippets) output=false{
		instance.elementCleaner.clearView(arguments.viewsnippets);
	}
	
}