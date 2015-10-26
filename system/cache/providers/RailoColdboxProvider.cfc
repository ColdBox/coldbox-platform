/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
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
		this.VIEW_CACHEKEY_PREFIX 	= "railo_view-";
		this.EVENT_CACHEKEY_PREFIX 	= "railo_event-";
		
		// URL Facade Utility
		instance.eventURLFacade		= CreateObject("component","coldbox.system.cache.util.EventURLFacade").init(this);
		
		return this;
	}
	
	// Cache Key prefixes
	any function getViewCacheKeyPrefix() output=false{ return this.VIEW_CACHEKEY_PREFIX; }
	any function getEventCacheKeyPrefix() output=false{ return this.EVENT_CACHEKEY_PREFIX; }
	
	// set the coldbox controller
	void function setColdbox(required any coldbox) output=false{
		variables.coldbox = arguments.coldbox;
	}
	
	// Get ColdBox
	any function getColdbox() output=false{ return coldbox; }
	
	// Get Event URL Facade Tool
	any function getEventURLFacade() output=false{ return instance.eventURLFacade; }
	
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