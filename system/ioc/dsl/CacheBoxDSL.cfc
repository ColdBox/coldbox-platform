<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The DSL processor for all CacheBox related stuff
	
----------------------------------------------------------------------->
<cfcomponent hint="The DSL processor for all CacheBox related stuff" implements="coldbox.system.ioc.dsl.IDSLBuilder" output="false">

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Configure the DSL for operation and returns itself" colddoc:generic="coldbox.system.ioc.dsl.IDSLBuilder">
    	<cfargument name="injector" type="any" required="true" hint="The linked WireBox injector" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfscript>
			instance = { injector = arguments.injector };
			instance.cacheBox 	= instance.injector.getCacheBox();
			instance.log		= instance.injector.getLogBox().getLogger( this );
			
			return this;
		</cfscript>   
    </cffunction>
	
	<!--- process --->
    <cffunction name="process" output="false" access="public" returntype="any" hint="Process an incoming DSL definition and produce an object with it.">
		<cfargument name="definition" 	required="true" hint="The injection dsl definition structure to process. Keys: name, dsl"/>
		<cfargument name="targetObject" required="false" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>
		<cfscript>
			var thisType 			= arguments.definition.dsl;
			var thisTypeLen 		= listLen(thisType,":");
			var cacheName 			= "";
			var cacheElement 		= "";
			
			// DSL stages
			switch(thisTypeLen){
				// CacheBox
				case 1 : { return instance.cacheBox; }
				// CacheBox:CacheName
				case 2 : {
					cacheName = getToken(thisType,2,":");
					// Verify that cache exists
					if( instance.cacheBox.cacheExists( cacheName ) ){
						return instance.cacheBox.getCache( cacheName );
					}
					else if( instance.log.canDebug() ){
						instance.log.debug("getCacheBoxDSL() cannot find named cache #cacheName# using definition: #arguments.definition.toString()#. Existing cache names are #instance.cacheBox.getCacheNames().toString()#");
					}
					break;
				}
				// CacheBox:CacheName:Element
				case 3 : {
					cacheName 		= getToken(thisType,2,":");
					cacheElement 	= getToken(thisType,3,":");
					// Verify that dependency exists in the Cache container
					if( instance.cacheBox.getCache( cacheName ).lookup( cacheElement ) ){
						return instance.cacheBox.getCache( cacheName ).get( cacheElement );
					}
					else if( instance.log.canDebug() ){
						instance.log.debug("getCacheBoxDSL() cannot find cache Key: #cacheElement# in the #cacheName# cache using definition: #arguments.definition.toString()#");
					}
					break;
				} // end level 3 main DSL
			}
		</cfscript>   	
    </cffunction>		
	
</cfcomponent>