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
component serializable="false" extends="coldbox.system.cache.providers.RailoProvider" implements="coldbox.system.cache.IColdboxApplicationCache"{

	/**
    * Constructor
    */
	CFColdBoxProvider function init() output=false{
		super.init();
		return this;
	}
	
	string function getViewCacheKeyPrefix() output=false{}
	string function getEventCacheKeyPrefix() output=false{}
	string function getHandlerCacheKeyPrefix() output=false{}
	string function getInterceptorCacheKeyPrefix() output=false{}
	string function getPluginCacheKeyPrefix() output=false{}
	string function getCustomPluginCacheKeyPrefix() output=false{}
	
	Controller function getColdbox() output=false{}
	
	void function getColdbox(Controller coldbox) output=false{}
	
	coldbox.system.cache.util.EventURLFacade function getEventURLFacade() output=false{
	}
	
	coldbox.system.cache.util.ItemTypeCount function getItemTypesCount(){
	}
	
	void function clearAllEvents() output=false{}
	
	void function clearEvent(required string eventsnippet, required string queryString) output=false{}
	void function clearView(required string viewSnippet) output=false{}
	void function clearAllViews() output=false{}
	
	
	
	
	
}
			 
