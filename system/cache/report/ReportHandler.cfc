<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :

	The ColdBox CacheBox Report Handler
	
----------------------------------------------------------------------->
<cfcomponent hint="The ColdBox CacheBox Report Handler" output="false" serializable="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
		
	<!--- init --->
	<cffunction name="init" access="public" returntype="ReportHandler" hint="Constructor" output="false" >
		<cfargument name="cacheBox" 	 	type="coldbox.system.cache.CacheFactory" required="true" hint="The cache factory binded to"/>
		<cfargument name="baseURL" 		 	type="string" 	required="true" hint="The baseURL used for reporting"/>
		<cfargument name="skin" 		 	type="string" 	required="true" hint="The skin to use for reporting"/>
		<cfargument name="attributes" 		type="struct" 	required="true" hint="The incoming attributes"/>
		<cfargument name="caller" 			type="any" 		required="true" hint="Access to the caller tag"/>
		<cfscript>
			variables.cacheBox  = arguments.cacheBox;
			variables.baseURL 	= arguments.baseURL;
			variables.runtime	= createObject("java", "java.lang.Runtime");
			variables.skin		= arguments.skin;
			variables.skinPath  = "/coldbox/system/cache/report/skins/#arguments.skin#";
			// Store tag attributes so they are available on skin templates.
			variables.attributes = arguments.attributes;
			// Caller references
			variables.caller 	= arguments.caller;
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- processCommands --->
    <cffunction name="processCommands" output="false" access="public" returntype="boolean" hint="Process CacheBox Commands">
    	<cfargument name="command" 		type="string" 	required="false" default="" hint="The command to process"/>
		<cfargument name="cacheName" 	type="string" 	required="false" default="default" hint="The cache name"/>
		<cfargument name="cacheEntry" 	type="string" 	required="false" default="" hint="The cache entry to act upon"/>
		<cfscript>
    		// Commands
			switch(arguments.command){
				// Cache Commands
				case "expirecache"    		: { cacheBox.getCache(arguments.cacheName).expireAll(); break; }
				case "clearcache"    		: { cacheBox.getCache(arguments.cacheName).clearAll(); break; }
				case "reapcache"  	  		: { cacheBox.getCache(arguments.cacheName).reap(); break;}
				case "delcacheentry"  		: { cacheBox.getCache(arguments.cacheName).clear( arguments.cacheEntry );break;}
				case "expirecacheentry"  	: { cacheBox.getCache(arguments.cacheName).expireObject( arguments.cacheEntry );break;}
				case "clearallevents" 		: { cacheBox.getCache(arguments.cacheName).clearAllEvents();break;}
				case "clearallviews"  		: { cacheBox.getCache(arguments.cacheName).clearAllViews();break;}
				case "cacheBoxReapAll"		: { cacheBox.reapAll();break;}
				case "cacheBoxExpireAll"	: { cacheBox.expireAll();break;}
				case "gc"			 		: { runtime.getRuntime().gc(); break;}
				
				default: return false;
			}
			
			return true;
		</cfscript>
    </cffunction>
	
	<!--- Render the cache panel --->
	<cffunction name="renderCachePanel" access="public" hint="Renders the caching panel." output="false" returntype="any">
		<cfscript>
			var content			= "";
			var cacheNames		= cacheBox.getCacheNames();
			var URLBase			= baseURL;
		</cfscript>
		
		<!--- Generate Debugging --->
		<cfsavecontent variable="content"><cfinclude template="#skinPath#/CachePanel.cfm"></cfsavecontent>
		
		<cfreturn content>
	</cffunction>	
	
	<!--- renderCacheReport --->
    <cffunction name="renderCacheReport" output="false" access="public" returntype="any" hint="Render a cache report for a specific cache">
    	<cfargument name="cacheName" type="any" required="true" default="default" hint="The cache name"/>
    	<cfscript>
    		var content 		= "";
			
			// Cache info
			var cacheProvider 	= cacheBox.getCache( arguments.cacheName );
			var cacheConfig		= "";
			var cacheStats		= "";
			var cacheSize		= cacheProvider.getSize();		
			var isCacheBox		= true;	
			
			// JVM Data
			var JVMRuntime 		= runtime.getRuntime();
			var JVMFreeMemory 	= JVMRuntime.freeMemory()/1024;
			var JVMTotalMemory 	= JVMRuntime.totalMemory()/1024;
			var JVMMaxMemory 	= JVMRuntime.maxMemory()/1024;
				
			// URL Base
			var URLBase			= baseURL;
			
			// Prepare cache report for cachebox
			cacheConfig 	= cacheProvider.getConfiguration();
			cacheStats  	= cacheProvider.getStats();
    	</cfscript>	
		
		<!--- Generate Debugging --->
		<cfsavecontent variable="content"><cfinclude template="#skinPath#/CacheReport.cfm"></cfsavecontent>
		
		<cfreturn content>
	</cffunction>
	
	<!--- renderCacheContentReport --->
    <cffunction name="renderCacheContentReport" output="false" access="public" returntype="any" hint="Render a cache's content report">
    	<cfargument name="cacheName" type="any" required="true" default="default" hint="The cache name"/>
		<cfscript>
    		var thisKey			= "";
			var x				= "";
			var content			= "";
			var cacheProvider 	= cacheBox.getCache( arguments.cacheName );
			var cacheKeys		= "";
			var cacheKeysLen	= 0;
			var cacheMetadata	= "";
			var cacheMDKeyLookup = structnew();
			
			// URL Base
			var URLBase			= baseURL;
			
			// Cache Data
			cacheMetadata 		= cacheProvider.getStoreMetadataReport();
			cacheMDKeyLookup 	= cacheProvider.getStoreMetadataKeyMap();
			cacheKeys			= cacheProvider.getKeys(); 
			cacheKeysLen		= arrayLen( cacheKeys );							
			
			// Sort Keys
			arraySort( cacheKeys ,"textnocase" );
    	</cfscript>
		
		<!--- Render content out --->
		<cfsavecontent variable="content"><cfinclude template="#skinPath#/CacheContentReport.cfm"></cfsavecontent>
				
		<cfreturn content>		
    </cffunction>
	
	<!--- Render Cache Dumpver --->
	<cffunction name="renderCacheDumper" access="public" hint="Renders the caching key value dumper." output="false" returntype="Any">
		<cfargument name="cacheName" 	type="any" 		required="true" default="default" hint="The cache name"/>
		<cfargument name="cacheEntry" 	type="string" 	required="true" hint="The cache entry to dump"/>
		<cfset var cachekey 		= URLDecode(arguments.cacheEntry)>
		<cfset var cacheValue 		= "">
		<cfset var dumperContents 	= "NOT_FOUND">
		<cfset var cache 			= cacheBox.getCache( arguments.cacheName )>
		
		<!--- check key --->
		<cfif NOT len(cacheKey) OR NOT cache.lookup( cacheKey )>
			<cfreturn dumperContents>
		</cfif>
		
		<!--- Get Data --->
		<cfset cacheValue = cache.get( cacheKey )>
		
		<!--- Dump it out --->
		<cfif isSimpleValue(cacheValue)>
			<cfsavecontent variable="dumperContents"><cfoutput><strong>#cachekey#</strong> = #cacheValue#</cfoutput></cfsavecontent>
		<cfelse>
			<cfsavecontent variable="dumperContents"><cfdump var="#cacheValue#" label="#cachekey#" top="5"></cfsavecontent>
		</cfif>
		
		<!--- Return it --->
		<cfreturn dumperContents>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>	

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
	
</cfcomponent>