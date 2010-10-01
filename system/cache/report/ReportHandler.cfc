<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :

	The ColdBox CacheBox Report Handler
	
----------------------------------------------------------------------->
<cfcomponent hint="The ColdBox CacheBox Report Handler" output="false" serializable="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
		
	<!--- init --->
	<cffunction name="init" access="public" returntype="ReportHandler" hint="Constructor" output="false" >
		<cfargument name="cacheBox" type="coldbox.system.cache.CacheFactory" required="true" default="" hint="The cache factory binded to"/>
		<cfargument name="baseURL" type="string" required="true" default="" hint="The baseURL used for reporting"/>
		<cfscript>
			variables.cacheBox  = arguments.cacheBox;
			variables.baseURL 	= arguments.baseURL;
			variables.runtime	= createObject("java", "java.lang.Runtime");
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- processCommands --->
    <cffunction name="processCommands" output="false" access="public" returntype="boolean" hint="Process CacheBox Commands">
    	<cfscript>
    		var rc 			= captureRequest();
			var cacheName	= "default";
			var cacheEntry	= "";
			
			// Verify command, else just exit out
			if( NOT len(rc.cbox_command) ){ return false; }
			
			// Verify incoming cacheName
			if( len(rc.cbox_cacheName) ){ cacheName = rc.cbox_cacheName; }
			
			// Verify incoming cacheEntry
			if( len(rc.cbox_cacheentry) ){ cacheEntry = rc.cbox_cacheEntry; }
			
			// Commands
			switch(rc.cbox_command){
				// Cache Commands
				case "expirecache"    		: { cacheBox.getCache(cacheName).expireAll(); break; }
				case "reapcache"  	  		: { cacheBox.getCache(cacheName).reap(); break;}
				case "delcacheentry"  		: { cacheBox.getCache(cacheName).clear( cacheEntry );break;}
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
		<cfargument name="monitor" type="boolean" required="false" default="false" hint="monitor or panel"/>
		<cfscript>
			var content			= "";
			var cacheNames		= cacheBox.getCacheNames();
			var URLBase			= baseURL;
		</cfscript>
		
		<!--- Generate Debugging --->
		<cfsavecontent variable="content"><cfinclude template="/coldbox/system/cache/report/panels/CachePanel.cfm"></cfsavecontent>
		
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
		<cfsavecontent variable="content"><cfinclude template="/coldbox/system/cache/report/panels/CacheReport.cfm"></cfsavecontent>
		
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
		<cfsavecontent variable="content"><cfinclude template="/coldbox/system/cache/report/panels/CacheContentReport.cfm"></cfsavecontent>
				
		<cfreturn content>		
    </cffunction>
	
	<!--- Render Cache Dumpver --->
	<cffunction name="renderCacheDumper" access="public" hint="Renders the caching key value dumper." output="false" returntype="Any">
		<cfargument name="cacheName" type="any" required="true" default="default" hint="The cache name"/>
		<cfset var rc				= captureRequest()>
		<cfset var cachekey 		= URLDecode(rc.key)>
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
			<cfsavecontent variable="dumperContents"><cfdump var="#cacheValue#" label="#cachekey#" top="1"></cfsavecontent>
		</cfif>
		
		<!--- Return it --->
		<cfreturn dumperContents>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>	

	<!--- captureRequest --->
    <cffunction name="captureRequest" output="false" access="private" returntype="struct" hint="Capture incoming report request">
    	<cfscript>
    		var rc = {};
			// Capture Request
			if( isDefined("URL") ){ structAppend(rc,URL,true); }
			if( isDefined("FORM") ){ structAppend(rc,FORM,true); }
			return rc;
		</cfscript>
    </cffunction>

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>
	
</cfcomponent>