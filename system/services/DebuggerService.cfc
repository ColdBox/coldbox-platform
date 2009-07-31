<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
 This is the service that powers the ColdBox Debugger.

----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is the service that powers the ColdBox Debugger." extends="coldbox.system.services.BaseService">

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
			// Set a maximum tracers possible.
			instance.maxTracers = 100;
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- timersExist --->
    <cffunction name="timersExist" output="false" access="public" returntype="boolean" hint="Do we have any request timers">
    	<cfreturn structKeyExists(request, "DebugTimers")>
    </cffunction>
	
	<!--- getTimers --->
    <cffunction name="getTimers" output="false" access="public" returntype="query" hint="Get the timers query from the request. Empty query if it does not exist.">
    	<cfscript>
    		if( NOT timersExist() ){
				request.debugTimers = QueryNew("Id,Method,Time,Timestamp,RC");
			}
			return request.debugTimers;
    	</cfscript>
    </cffunction>
	
	<!--- timerStart --->
	<cffunction name="timerStart" output="false" access="public" returntype="string" hint="Start an internal code timer and get a hash of the timer storage">
		<cfargument name="label" type="string" required="true" hint="The timer label to record"/>
		<cfscript>
			var labelHash = 0;
			var timerInfo = 0;
			
			/* Verify Debug Mode */
			if( getDebugMode() ){
				/* Check if DebugTimers Query is set, else create it for this request */
				getTimers();
				/* Create Timer Hash */
				labelHash = hash(arguments.label);
				/* Create timer Info */
				timerInfo = structnew();
				timerInfo.stime = getTickCount();
				timerInfo.label = arguments.label;
				/* Persist in request for timing */
				request[labelHash] = timerInfo;
			}
			return labelHash;
		</cfscript>
	</cffunction>
	
	<!--- timerEnd --->
	<cffunction name="timerEnd" output="false" access="public" returntype="void" hint="End an internal code timer">
		<cfargument name="labelHash" type="string" required="true" default="" hint="The timer label hash to stop"/>
		<cfscript>
			var timerInfo = 0;
			var qTimers = "";
			var id = "";
			
			// Verify Debug Mode and timer label exists, else do nothing.
			if( getDebugMode() and structKeyExists(request,arguments.labelHash) ){
				// Get Timer Info
				timerInfo = request[arguments.labelHash];
				qTimers = getTimers();
				
				// ID: FRIGGING CF7 SUPPORT, JUST DIE!!!
				if( controller.oCFMLEngine.isMT() ){
					id = createobject("java", "java.util.UUID").randomUUID();
				}
				else{
					id = createUUID();
				}
				
				// Save timer
				QueryAddRow(qTimers,1);
				QuerySetCell(qTimers, "Id", id);
				QuerySetCell(qTimers, "Method", timerInfo.label);
				QuerySetCell(qTimers, "Time", getTickCount() - timerInfo.stime);
				QuerySetCell(qTimers, "Timestamp", now());
				
				// RC Snapshot
				if ( not findnocase("rendering",timerInfo.label) ){
					// Save collection
					QuerySetCell(qTimers, "RC", htmlEditFormat(controller.getRequestService().getContext().getCollection().toString()) );
				}
				else{
					QuerySetCell(qTimers, "RC", '');
				}
				// Cleanup
				structDelete(request,arguments.labelHash);
			}
		</cfscript>
	</cffunction>
	
	<!--- Get the debug mode flag --->
	<cffunction name="getDebugMode" access="public" hint="I Get the current user's debugmode" returntype="boolean"  output="false">
		<cfscript>
			// Check global debug Mode and cookie setup, else init their debug cookie
			if( controller.getSetting('debugMode') AND NOT isDebugCookieValid() ){
				setDebugmode(true);
			}
			// Check vapor cookie
			if( structKeyExists(cookie,getCookieName()) ){
				if( isBoolean(cookie[getCookieName()]) ){
					return cookie[getCookieName()];
				}
				else{
					structDelete(cookie, getCookieName());
				}
			}
			return false;
		</cfscript>
	</cffunction>
	
	<!--- isDebugCookieValid --->
    <cffunction name="isDebugCookieValid" output="false" access="public" returntype="boolean" hint="Checks if the debug cookie is a valid cookie">
	    <cfscript>
	    	if( structKeyExists(cookie, getCookieName() ) AND isBoolean(cookie[getCookieName()]) ){ 
				return true;
			}
			else{
				return false;
			}
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
			<cfcookie name="#getCookieName()#" value="false">
		<!--- Flase with global False --->
		<cfelse>
			<cfcookie name="#getCookieName()#" value="false" expires="#now()#">
		</cfif>
	</cffunction>

	<!--- render the debug log --->
	<cffunction name="renderDebugLog" access="public" hint="Return the debug log." output="false" returntype="Any">
		<cfset var RenderedDebugging = "">
		<cfset var Event = controller.getRequestService().getContext()>
		<cfset var rc = event.getCollection()>
		<cfset var prc = event.getCollection(private=true)>

		<!--- Set local Variables --->
		<cfset var itemTypes = controller.getColdboxOCM().getItemTypes()>
		<cfset var cacheMetadata = "">
		<cfset var cacheKeyList = "">
		<cfset var cacheKeyIndex = 1>

		<!--- Setup Local Variables --->
		<cfset var debugStartTime = GetTickCount()>
		<cfset var thisCollection = "">
		<cfset var thisCollectionType = "">
		<cfset var debugTimers = getTimers()>

		<!--- Debug Rendering Type --->
		<cfset var renderType = "main">

		<!--- JVM Data --->
		<cfset var JVMRuntime = controller.getColdboxOCM().getJavaRuntime().getRuntime()>
		<cfset var JVMFreeMemory = JVMRuntime.freeMemory()/1024>
		<cfset var JVMTotalMemory = JVMRuntime.totalMemory()/1024>
		<cfset var JVMMaxMemory = JVMRuntime.maxMemory()/1024>

		<!--- Render debuglog --->
		<cfsavecontent variable="RenderedDebugging"><cfinclude template="../includes/Debug.cfm"></cfsavecontent>
		<cfreturn RenderedDebugging>
	</cffunction>

	<!--- Render the cache panel --->
	<cffunction name="renderCachePanel" access="public" hint="Renders the caching panel." output="false" returntype="Any">
		<cfset var event = controller.getRequestService().getContext()>
		<cfset var rc = event.getCollection()>
		<cfset var RenderedDebugging = "">

		<!--- Set local Variables --->
		<cfset var itemTypes = controller.getColdboxOCM().getItemTypes()>
		<cfset var cacheMetadata = controller.getColdboxOCM().getPoolMetadata()>
		<cfset var cacheKeyList = listSort(structKeyList(cacheMetaData),"textnocase")>
		<cfset var cacheKeyIndex = 1>

		<!--- Setup Local Variables --->
		<cfset var RequestCollection = Event.getCollection()>

		<!--- JVM Data --->
		<cfset var JVMRuntime = controller.getColdboxOCM().getJavaRuntime().getRuntime()>
		<cfset var JVMFreeMemory = JVMRuntime.freeMemory()/1024>
		<cfset var JVMTotalMemory = JVMRuntime.totalMemory()/1024>
		<cfset var JVMMaxMemory = JVMRuntime.maxMemory()/1024>

		<!--- Debug Rendering Type --->
		<cfset var renderType = "CachePanel">

		<!--- Generate Debugging --->
		<cfsavecontent variable="RenderedDebugging"><cfinclude template="/coldbox/system/includes/panels/CachePanel.cfm"></cfsavecontent>
		<cfreturn RenderedDebugging>
	</cffunction>
	
	<!--- Render Cache Dumpver --->
	<cffunction name="renderCacheDumper" access="public" hint="Renders the caching key value dumper." output="false" returntype="Any">
		<cfset var event = controller.getRequestService().getContext()>
		<cfset var rc = event.getCollection()>
		<cfset var cachekey = URLDecode(event.getValue('key',''))>
		<cfset var cacheValue = controller.getColdboxOCM().get(cachekey)>
		<cfset var dumperContents = "">
		
		<cfif isSimpleValue(cacheValue)>
			<cfsavecontent variable="dumperContents"><cfoutput><strong>#cachekey#</strong> = #cacheValue#</cfoutput></cfsavecontent>
		<cfelse>
			<cfsavecontent variable="dumperContents"><cfdump var="#cacheValue#" label="#cachekey#"></cfsavecontent>
		</cfif>
		
		<cfreturn dumperContents>
	</cffunction>
	
	<!--- Render Profilers --->
	<cffunction name="renderProfiler" access="public" hint="Renders the execution profilers." output="false" returntype="Any">
		<cfset var profilerContents = "">
		<cfset var profilers = getProfilers()>
		<cfset var profilersCount = ArrayLen(profilers)>
		<cfset var x = 1>
		<cfset var refLocal = structnew()>
		
		<cfsavecontent variable="profilerContents"><cfinclude template="/coldbox/system/includes/panels/ProfilerPanel.cfm"></cfsavecontent>
				
		<cfreturn profilerContents>
	</cffunction>
	
	<!--- Get set the cookie name --->
	<cffunction name="getcookieName" access="public" output="false" returntype="string" hint="Get cookieName">
		<cfreturn instance.cookieName/>
	</cffunction>
	<cffunction name="setcookieName" access="public" output="false" returntype="void" hint="Set cookieName">
		<cfargument name="cookieName" type="string" required="true"/>
		<cfset instance.cookieName = arguments.cookieName/>
	</cffunction>
	
	<!--- Configuration Bean --->
	<cffunction name="getDebuggerConfig" access="public" output="false" returntype="coldbox.system.beans.DebuggerConfig" hint="Get DebuggerConfig">
		<cfreturn instance.DebuggerConfig/>
	</cffunction>	
	<cffunction name="setDebuggerConfig" access="public" output="false" returntype="void" hint="Set DebuggerConfig">
		<cfargument name="DebuggerConfig" type="coldbox.system.beans.DebuggerConfig" required="true"/>
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
			
			// Active Check
			if( NOT getDebuggerConfig().getPersistentTracers() ){ return; }
			
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