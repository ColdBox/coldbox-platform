<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
 This is the service that powers the ColdBox Debugger.

----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is the service that powers the ColdBox Debugger." extends="coldbox.system.web.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="DebuggerService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			// set the unique cookie name
			setCookieName("coldbox_debugmode_#controller.getAppHash()#");
			// Create persistent profilers
			setProfilers(arrayNew(1));
			// Create persistent tracers
			setTracers(arrayNew(1));
			// Set a maximum tracers possible
			instance.maxTracers = 75;
			
			// Runtime
			instance.jvmRuntime = createObject("java", "java.lang.Runtime");
			
			return this;
		</cfscript>
	</cffunction>


<!------------------------------------------- INTERNAL COLDBOX EVENTS ------------------------------------------->

	<!--- onConfigurationLoad --->
    <cffunction name="onConfigurationLoad" output="false" access="public" returntype="void" hint="Called by loader service when configuration file loads">
    	<cfscript>
			instance.debugMode = controller.getSetting("debugMode");
    	</cfscript>
    </cffunction>
    
<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- timersExist --->
    <cffunction name="timersExist" output="false" access="public" returntype="any" hint="Do we have any request timers. Boolean">
    	<cfreturn structKeyExists(request, "DebugTimers")>
    </cffunction>
	
	<!--- getTimers --->
    <cffunction name="getTimers" output="false" access="public" returntype="any" hint="Get the timers query from the request. Empty query if it does not exist. Query">
    	<cfscript>
    		if( NOT timersExist() ){
				request.debugTimers = QueryNew("ID,Method,Time,Timestamp,RC,PRC");
			}
			return request.debugTimers;
    	</cfscript>
    </cffunction>
	
	<!--- timerStart --->
	<cffunction name="timerStart" output="false" access="public" returntype="any" hint="Start an internal code timer and get a hash of the timer storage">
		<cfargument name="label" type="any" required="true" hint="The timer label to record"/>
		<cfscript>
			var labelHash = 0;
			var timerInfo = 0;
			
			// Verify Debug Mode
			if( getDebugMode() ){
				// Check if DebugTimers Query is set, else create it for this request
				getTimers();
				
				// Create Timer Hash
				labelHash = hash(arguments.label);
				
				// Create timer Info
				timerInfo = structnew();
				timerInfo.stime = getTickCount();
				timerInfo.label = arguments.label;
				
				// Persist in request for timing
				request[labelHash] = timerInfo;
			}
			return labelHash;
		</cfscript>
	</cffunction>
	
	<!--- timerEnd --->
	<cffunction name="timerEnd" output="false" access="public" returntype="void" hint="End an internal code timer">
		<cfargument name="labelHash" type="any" required="true" default="" hint="The timer label hash to stop"/>
		<cfscript>
			var timerInfo = 0;
			var qTimers = "";
			var context = ""; 
			
			// Verify Debug Mode and timer label exists, else do nothing.
			if( getDebugMode() and structKeyExists(request,arguments.labelHash) ){
				// Get Timer Info
				timerInfo 	= request[arguments.labelHash];
				qTimers 	= getTimers();
				context 	= controller.getRequestService().getContext();
				
				// Save timer
				QueryAddRow(qTimers,1);
				QuerySetCell(qTimers, "ID", hash( getTickCount() & timerInfo.label) );
				QuerySetCell(qTimers, "Method", timerInfo.label);
				QuerySetCell(qTimers, "Time", getTickCount() - timerInfo.stime);
				QuerySetCell(qTimers, "Timestamp", now());
				
				// RC Snapshot
				if ( not findnocase("rendering",timerInfo.label) ){
					// Save collection
					QuerySetCell(qTimers, "RC", htmlEditFormat(left(context.getCollection().toString(),5000)) );
					QuerySetCell(qTimers, "PRC", htmlEditFormat(left(context.getCollection(private=true).toString(),5000)) );
				}
				else{
					QuerySetCell(qTimers, "RC", '');
					QuerySetCell(qTimers, "PRC", '');
				}
				
				// Cleanup
				structDelete(request,arguments.labelHash);
			}
		</cfscript>
	</cffunction>
	
	<!--- Get the debug mode flag --->
	<cffunction name="getDebugMode" access="public" hint="I Get the current user's debugmode. Boolean" returntype="any"  output="false" colddoc:generic="Boolean">
		<cfscript>
			// Check global debug Mode and cookie setup, else init their debug cookie
			if( instance.debugMode AND NOT isDebugCookieValid() ){
				setDebugmode(true);
			}
			// Check vapor cookie
			if( structKeyExists(cookie,instance.cookieName) ){
				if( isBoolean(cookie[instance.cookieName]) ){
					return cookie[instance.cookieName];
				}
				structDelete(cookie, instance.cookieName);
			}
			return false;
		</cfscript>
	</cffunction>
	
	<!--- isDebugCookieValid --->
    <cffunction name="isDebugCookieValid" output="false" access="public" returntype="any" hint="Checks if the debug cookie is a valid cookie. Boolean">
	    <cfscript>
	    	if( structKeyExists(cookie, instance.cookieName ) AND isBoolean(cookie[instance.cookieName]) ){ 
				return true;
			}
			return false;
	    </cfscript>
    </cffunction>

	<!--- Set the debug mode flag --->
	<cffunction name="setDebugMode" access="public" hint="I set the current user's debugmode" returntype="void"  output="false">
		<cfargument name="mode" type="boolean" required="true" >
		<!--- True --->
		<cfif arguments.mode>
			<cfcookie name="#getCookieName()#" value="true">
		<!--- False with global True --->
		<cfelseif structKeyExists(cookie,getCookieName()) AND controller.getSetting('debugMode')>
			<cfcookie name="#instance.cookieName#" value="false">
		<!--- Flase with global False --->
		<cfelse>
			<cfcookie name="#instance.cookieName#" value="false" expires="#now()#">
		</cfif>
	</cffunction>

	<!--- render the debug log --->
	<cffunction name="renderDebugLog" access="public" hint="Return the debug log." output="false" returntype="Any">
		<cfset var renderedDebugging = "">
		<cfset var event = controller.getRequestService().getContext()>
		<cfset var rc = event.getCollection()>
		<cfset var prc = event.getCollection(private=true)>
		<cfset var loc = structnew()>
		
		<!--- Setup Local Variables --->
		<cfset var debugStartTime = GetTickCount()>
		<cfset var thisCollection = "">
		<cfset var thisCollectionType = "">
		<cfset var debugTimers = getTimers()>
		<cfset var loadedModules = arrayNew(1)>
		<cfset var moduleSettings = structnew()>

		<!--- Debug Rendering Type --->
		<cfset var renderType = "main">
		
		<!--- URL Base --->
		<cfset var URLBase = event.getsesBaseURL()>

		<!--- Modules Stuff --->
		<cfif controller.getCFMLEngine().isMT()>
			<cfset loadedModules = controller.getModuleService().getLoadedModules()>
			<cfset moduleSettings = controller.getSetting("modules")>
		</cfif>
		
		<!--- URL Base --->
		<cfif NOT event.isSES()>
			<cfset URLBase = listlast(cgi.script_name,"/")>
		</cfif>
		
		<!--- Render debuglog --->
		<cfsavecontent variable="renderedDebugging"><cfinclude template="/coldbox/system/includes/Debug.cfm"></cfsavecontent>
		
		<cfreturn renderedDebugging>
	</cffunction>

	<!--- Render the cache panel --->
	<cffunction name="renderCachePanel" access="public" hint="Renders the caching panel." output="false" returntype="any">
		<cfargument name="monitor" type="boolean" required="false" default="false" hint="monitor or panel"/>
		<cfscript>
			var event 			= controller.getRequestService().getContext();
			var content			= "";
			var cacheNames		= arrayNew(1);
			// CacheType Rendering
			var isMonitor		= arguments.monitor;
			// URL Base
			var URLBase			= event.getSESBaseURL();
			
			// Command URL Base if not using SES
			if( NOT event.isSES() ){
				URLBase = listlast(cgi.script_name,"/");
			}
			
			// Caches
			if( isObject(controller.getCacheBox()) ){
				cacheNames = controller.getCacheBox().getCacheNames();
			}
			else{
				cacheNames[1] = "default";
			}
			
		</cfscript>
		
		<!--- Param the monitor frequency if used --->
		<cfparam name="url.frequency" default="0" type="numeric" min="0">
		
		<!--- Generate Debugging --->
		<cfsavecontent variable="content"><cfinclude template="/coldbox/system/includes/panels/CachePanel.cfm"></cfsavecontent>
		
		<cfreturn content>
	</cffunction>
	
	<!--- renderCacheReport --->
    <cffunction name="renderCacheReport" output="false" access="public" returntype="any" hint="Render a cache report for a specific cache">
    	<cfargument name="cacheName" type="any" required="true" default="default" hint="The cache name"/>
    	<cfscript>
    		var content 		= "";
			var event 			= controller.getRequestService().getContext();
			
			// Cache info
			var cacheProvider 	= controller.getColdboxOCM( arguments.cacheName );
			var itemTypes		= cacheProvider.getItemTypes();
			var cacheConfig		= "";
			var cacheStats		= "";
			var cacheSize		= cacheProvider.getSize();		
			var isCacheBox		= true;	
			
			// JVM Data
			var JVMRuntime 		= instance.jvmRuntime.getRuntime();
			var JVMFreeMemory 	= JVMRuntime.freeMemory()/1024;
			var JVMTotalMemory 	= JVMRuntime.totalMemory()/1024;
			var JVMMaxMemory 	= JVMRuntime.maxMemory()/1024; 
				
			// URL Base
			var URLBase			= event.getSESBaseURL();
			
			// Command URL Base if not using SES
			if( NOT event.isSES() ){
				URLBase = listlast(cgi.script_name,"/");
			}
			
			// Prepare cache report for cachebox
			if( isObject(controller.getCacheBox()) ){
				cacheConfig 	= cacheProvider.getConfiguration();
				cacheStats  	= cacheProvider.getStats();			
			}
			// COMPAT MODE: REMOVE LATER, cf7 and compat
			else{
				cacheConfig 	= cacheProvider.getCacheConfig().getMemento();
				cacheStats  	= cacheProvider.getCacheStats();
				isCacheBox		= false;				
			}
    	</cfscript>	
		
		<!--- Generate Debugging --->
		<cfsavecontent variable="content"><cfinclude template="/coldbox/system/includes/panels/CacheReport.cfm"></cfsavecontent>
		
		<cfreturn content>
	</cffunction>

	<!--- renderCacheContentReport --->
    <cffunction name="renderCacheContentReport" output="false" access="public" returntype="any" hint="Render a cache's content report">
    	<cfargument name="cacheName" type="any" required="true" default="default" hint="The cache name"/>
		<cfscript>
    		var thisKey			= "";
			var x				= "";
			var content			= "";
			var cacheProvider 	= controller.getColdboxOCM( arguments.cacheName );
			var cacheKeys		= "";
			var cacheKeysLen	= 0;
			var cacheMetadata	= "";
			var cacheMDKeyLookup = structnew();
			var isCacheBox		= true;
			
			// URL Base
			var event 			= controller.getRequestService().getContext();
			var URLBase			= event.getSESBaseURL();
			
			// Command URL Base if not using SES
			if( NOT event.isSES() ){
				URLBase = listlast(cgi.script_name,"/");
			}
			
			// Prepare cache report for cachebox
			if( isObject(controller.getCacheBox()) ){
				cacheMetadata 		= cacheProvider.getStoreMetadataReport();
				cacheMDKeyLookup 	= cacheProvider.getStoreMetadataKeyMap();
				cacheKeys			= cacheProvider.getKeys(); 
				cacheKeysLen		= arrayLen( cacheKeys );							
			}
			// COMPAT MODE: REMOVE LATER, cf7 and compat
			else{
				cacheMetadata 	= cacheProvider.getPoolMetadata();
				cacheKeys		= structKeyArray( cacheMetadata ); 
				cacheKeysLen	= arrayLen( cacheKeys );
				// I DETEST CF7
				cacheMDKeyLookup = structnew();
				cacheMDKeyLookup["timeout"] = "timeout";
				cacheMDKeyLookup["lastAccessTimeout"] = "lastAccessTimeout";
				cacheMDKeyLookup["hits"] = "hits";
				cacheMDKeyLookup["lastAccesed"] = "lastAccesed";
				cacheMDKeyLookup["created"] = "created";
				cacheMDKeyLookup["isExpired"] = "isExpired";								
			}
			
			// Sort Keys
			arraySort( cacheKeys ,"textnocase" );
    	</cfscript>
		
		<!--- Render content out --->
		<cfsavecontent variable="content"><cfinclude template="/coldbox/system/includes/panels/CacheContentReport.cfm"></cfsavecontent>
				
		<cfreturn content>		
    </cffunction>
	
	<!--- Render Cache Dumpver --->
	<cffunction name="renderCacheDumper" access="public" hint="Renders the caching key value dumper." output="false" returntype="Any">
		<cfargument name="cacheName" type="any" required="true" default="default" hint="The cache name"/>
		<cfset var event 			= controller.getRequestService().getContext()>
		<cfset var cachekey 		= URLDecode(event.getTrimValue('key',''))>
		<cfset var cacheValue 		= "">
		<cfset var dumperContents 	= "NOT_FOUND">
		<cfset var cache 			= controller.getColdboxOCM( arguments.cacheName )>
		
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
	
	<!--- Render Profilers --->
	<cffunction name="renderProfiler" access="public" hint="Renders the execution profilers." output="false" returntype="Any">
		<cfset var profilerContents = "">
		<cfset var profilers 		= getProfilers()>
		<cfset var profilersCount 	= ArrayLen(profilers)>
		<cfset var x 				= 1>
		<cfset var refLocal 		= structnew()>
		<cfset var event 			= controller.getRequestService().getContext()>
		<cfset var URLBase 			= event.getsesBaseURL()>
		
		<!--- URL Base --->
		<cfif NOT event.isSES()>
			<cfset URLBase = listlast(cgi.script_name,"/")>
		</cfif>
		
		<cfsavecontent variable="profilerContents"><cfinclude template="/coldbox/system/includes/panels/ProfilerPanel.cfm"></cfsavecontent>
				
		<cfreturn profilerContents>
	</cffunction>
	
	<!--- Get set the cookie name --->
	<cffunction name="getCookieName" access="public" output="false" returntype="any" hint="Get cookieName">
		<cfreturn instance.cookieName/>
	</cffunction>
	<cffunction name="setCookieName" access="public" output="false" returntype="void" hint="Set cookieName">
		<cfargument name="cookieName" type="string" required="true"/>
		<cfset instance.cookieName = arguments.cookieName/>
	</cffunction>
	
	<!--- Configuration Bean --->
	<cffunction name="getDebuggerConfig" access="public" output="false" returntype="any" hint="Get DebuggerConfig: coldbox.system.web.config.DebuggerConfig">
		<cfreturn instance.DebuggerConfig/>
	</cffunction>	
	<cffunction name="setDebuggerConfig" access="public" output="false" returntype="void" hint="Set DebuggerConfig">
		<cfargument name="DebuggerConfig" type="coldbox.system.web.config.DebuggerConfig" required="true"/>
		<cfset instance.DebuggerConfig = arguments.DebuggerConfig/>
	</cffunction>
	
	<!--- Persistent Profilers --->
	<cffunction name="getProfilers" access="public" output="false" returntype="array" hint="Get Profilers">
		<cfreturn instance.Profilers/>
	</cffunction>
	<cffunction name="setProfilers" access="public" output="false" returntype="void" hint="Set Profilers">
		<cfargument name="Profilers" type="array" required="true"/>
		<cfset instance.Profilers = arguments.Profilers/>
	</cffunction>
	
	<!--- resetProfilers --->
    <cffunction name="resetProfilers" output="false" access="public" returntype="void" hint="Reset all profilers">
    	<cfset setProfilers(arrayNew(1))>
    </cffunction>
	
	
	<!--- recordProfiler --->
    <cffunction name="recordProfiler" output="false" access="public" returntype="void" hint="This method will try to push a profiler record">
    	<cfscript>
    		if( getDebugMode() AND timersExist() ){
				pushProfiler(getTimers());
			}		
		</cfscript>
    </cffunction>
	
	<!--- Push a profiler --->
	<cffunction name="pushProfiler" access="public" returntype="void" hint="Push a profiler record" output="false" >
		<cfargument name="profilerRecord" required="true" type="query" hint="The profiler query for this request">
		<cfscript>
			var newRecord = structnew();
			
			if( NOT getDebuggerConfig().getPersistentRequestProfiler() ){ return; }
			
			// size check
			if( ArrayLen(getProfilers()) gte getDebuggerConfig().getmaxPersistentRequestProfilers() ){
				popProfiler();
			}
			
			// New Profiler
			newRecord.datetime = now();
			newRecord.ip = cgi.REMOTE_ADDR;
			newRecord.timers = arguments.profilerRecord;
			
			ArrayAppend(getProfilers(),newRecord);
		</cfscript>		
	</cffunction>
	
	<!--- Pop a profiler --->
	<cffunction name="popProfiler" access="public" returntype="void" hint="Pop a profiler record" output="false" >
		<cfscript>
			ArrayDeleteAt(getProfilers(),1);
		</cfscript>
	</cffunction>
	
	<!--- Get Set Tracers --->
	<cffunction name="getTracers" access="public" output="false" returntype="array" hint="Get Tracers">
		<cfreturn instance.Tracers/>
	</cffunction>
	<cffunction name="setTracers" access="public" output="false" returntype="void" hint="Set Tracers">
		<cfargument name="Tracers" type="array" required="true"/>
		<cfset instance.Tracers = arguments.Tracers/>
	</cffunction>
	
	<!--- Push a tracer --->
	<cffunction name="pushTracer" access="public" returntype="void" hint="Push a new tracer" output="false" >
		<cfargument name="message"    required="true" 	type="string" hint="Message to Send" >
		<cfargument name="extraInfo"  required="false"  type="any" default="" hint="Extra Information to dump on the trace">
		<cfscript>
			var tracerEntry = StructNew();
			
			// Max Check
			if( arrayLen(getTracers()) gte instance.maxTracers) { resetTracers(); }
			
			// Create Message
			tracerEntry["message"] = arguments.message;
			tracerEntry["extraInfo"] = arguments.extraInfo;
			
			ArrayAppend(getTracers(),tracerEntry);
		</cfscript>
	</cffunction>
	
	<!--- removeTracers --->
    <cffunction name="resetTracers" output="false" access="public" returntype="void" hint="Reset all Tracers">
    	<cfset setTracers(arrayNew(1))>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>