<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This cfc takes care of debugging settings.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="debuggerService" output="false" hint="The coldbox debugger service" extends="coldbox.system.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="DebuggerService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			/* Set Controller */
			setController(arguments.controller);
			/* set the unique cookie name */
			setCookieName("coldbox_debugmode_#controller.getAppHash()#");
			/* Create persistent profilers */
			setProfilers(arrayNew(1));
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- timerStart --->
	<cffunction name="timerStart" output="false" access="public" returntype="string" hint="Start an internal code timer and get a hash of the timer storage">
		<cfargument name="label" type="string" required="true" hint="The timer label to record"/>
		<cfscript>
			var labelHash = 0;
			var timerInfo = 0;
			/* Verify Debug Mode */
			if( getDebugMode() ){
				/* Check if DebugTimers Query is set, else create it for this request */
				if ( not structKeyExists(request,"DebugTimers") ){
					request.DebugTimers = QueryNew("Id,Method,Time,Timestamp,RC");
				}
				/* Create Timer Hash */
				labelHash = hash(arguments.label);
				/* Create timer Info */
				timerInfo = structnew();
				timerInfo.stime = getTickCount();
				timerInfo.label = arguments.label;
				/* Persist in request */
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
			/* Verify Debug Mode and timer label exists, else do nothing. */
			if( getDebugMode() and structKeyExists(request,arguments.labelHash) ){
				/* Get Timer Info */
				timerInfo = request[arguments.labelHash];
				/* Save timer */
				QueryAddRow(request.DebugTimers,1);
				QuerySetCell(request.DebugTimers, "Id", createUUID());
				QuerySetCell(request.DebugTimers, "Method", timerInfo.label);
				QuerySetCell(request.DebugTimers, "Time", getTickCount() - timerInfo.stime);
				QuerySetCell(request.DebugTimers, "Timestamp", now());
				/* Request Context SnapShot */
				if ( not findnocase("rendering",timerInfo.label) ){
					/* Save Collection */
					QuerySetCell(request.DebugTimers, "RC", htmlEditFormat(controller.getRequestService().getContext().getCollection().toString()) );
				}
				else{
					QuerySetCell(request.DebugTimers, "RC", '');
				}
				/* Cleanup */
				structDelete(request,arguments.labelHash);
			}
		</cfscript>
	</cffunction>
	
	<!--- Get the debug mode flag --->
	<cffunction name="getDebugMode" access="public" hint="I Get the current user's debugmode" returntype="boolean"  output="false">
		<cfif structKeyExists(cookie,getCookieName())>
			<cfif isBoolean(cookie[getCookieName()])>
				<cfreturn cookie[getCookieName()]>
			<cfelse>
				<cfset structDelete(cookie, getCookieName())>
			</cfif>
		</cfif>
		<!--- Return default of false. --->
		<cfreturn false>
	</cffunction>

	<!--- Set the debug mode flag --->
	<cffunction name="setDebugMode" access="public" hint="I set the current user's debugmode" returntype="void"  output="false">
		<cfargument name="mode" type="boolean" required="true" >
		<cfif arguments.mode>
			<cfcookie name="#getCookieName()#" value="true">
		<cfelseif structKeyExists(cookie,getCookieName())>
			<cfcookie name="#getCookieName()#" value="false" expires="#now()#">
		</cfif>
	</cffunction>

	<!--- render the debug log --->
	<cffunction name="renderDebugLog" access="public" hint="Return the debug log." output="false" returntype="Any">
		<cfset var RenderedDebugging = "">
		<cfset var Event = controller.getRequestService().getContext()>

		<!--- Set local Variables --->
		<cfset var itemTypes = controller.getColdboxOCM().getItemTypes()>
		<cfset var cacheMetadata = "">
		<cfset var cacheKeyList = "">
		<cfset var cacheKeyIndex = 1>

		<!--- Setup Local Variables --->
		<cfset var debugStartTime = GetTickCount()>
		<cfset var RequestCollection = Event.getCollection()>

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
		<cfset var RenderedDebugging = "">

		<!--- Set local Variables --->
		<cfset var itemTypes = controller.getColdboxOCM().getItemTypes()>
		<cfset var cacheMetadata = controller.getColdboxOCM().getpool_metadata()>
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
	<cffunction name="getdebuggerConfigBean" access="public" output="false" returntype="coldbox.system.beans.debuggerConfigBean" hint="Get debuggerConfigBean">
		<cfreturn instance.debuggerConfigBean/>
	</cffunction>	
	<cffunction name="setdebuggerConfigBean" access="public" output="false" returntype="void" hint="Set debuggerConfigBean">
		<cfargument name="debuggerConfigBean" type="coldbox.system.beans.debuggerConfigBean" required="true"/>
		<cfset instance.debuggerConfigBean = arguments.debuggerConfigBean/>
	</cffunction>
	
	<!--- Persistent Profilers --->
	<cffunction name="getProfilers" access="public" output="false" returntype="array" hint="Get Profilers">
		<cfreturn instance.Profilers/>
	</cffunction>
	<cffunction name="setProfilers" access="public" output="false" returntype="void" hint="Set Profilers">
		<cfargument name="Profilers" type="array" required="true"/>
		<cfset instance.Profilers = arguments.Profilers/>
	</cffunction>
	
	<!--- Push a profiler --->
	<cffunction name="pushProfiler" access="public" returntype="void" hint="Push a profiler record" output="false" >
		<cfargument name="profilerRecord" required="true" type="query" hint="The profiler query for this request">
		<cfscript>
			var newRecord = structnew();
			
			/* Size Check */
			if( ArrayLen(getProfilers()) gte getDebuggerConfigBean().getmaxPersistentRequestProfilers() ){
				popProfiler();
			}
			/* Append the new profiler */
			newRecord.datetime = now();
			newRecord.ip = cgi.REMOTE_ADDR;
			newRecord.timers = arguments.profilerRecord;
			
			ArrayAppend(getProfilers(),newRecord);
		</cfscript>
		
	</cffunction>
	
	<!--- Pop a profiler --->
	<cffunction name="popProfiler" access="public" returntype="void" hint="Pop a profiler record" output="false" >
		<cfscript>
			/* Delete eldest Entry */
			ArrayDeleteAt(getProfilers(),1);
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>