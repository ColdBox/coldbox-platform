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
			
			// Set the unique cookie name per ColdBox application
			instance.cookieName = "coldbox_debugmode_#controller.getAppHash()#";
			// This will store the secret key
			instance.secretKey = "";
			// Create persistent profilers
			instance.profilers = arrayNew(1);
			// Create persistent tracers
			instance.tracers = arrayNew(1);
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
			instance.debugPassword = controller.getSetting("debugPassword");
			
			// Initialize secret key
			rotateSecretKey();
			
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
				if ( NOT findnocase("rendering",timerInfo.label) AND instance.DebuggerConfig.getShowRCSnapshots() ){
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
			var secretKey = getSecretKey();
			
			// If no secretKey has been set, don't allow debug mode
			if( not(len(secretKey)) ) {
				return false;
			}
			
			// If Cookie exists, it's value is used. 
			if( isDebugCookieValid() ){
				
				// Must be equal to the current secret key
				if( cookie[instance.cookieName] == secretKey ) {
					return true;	
				} else {
					return false;
				}
			}
			
			// If there is no cookie, then use default to app setting
			return instance.debugMode;
		</cfscript>
	</cffunction>
	
	<!--- isDebugCookieValid --->
    <cffunction name="isDebugCookieValid" output="false" access="public" returntype="any" hint="Checks if the debug cookie is a valid cookie. Boolean">
	    <cfscript>
	    	return structKeyExists(cookie, instance.cookieName );
	    </cfscript>
    </cffunction>

	<!--- Set the debug mode flag --->
	<cffunction name="setDebugMode" access="public" hint="I set the current user's debugmode" returntype="void"  output="false">
		<cfargument name="mode" type="boolean" required="true" >
		
		<!--- True --->
		<cfif arguments.mode>
			<cfcookie name="#getCookieName()#" value="#getSecretKey()#">
		<!--- False --->
		<cfelse>
			<cfcookie name="#instance.cookieName#" value="_disabled_" expires="#now()#">
		</cfif>
	</cffunction>
	
	<!--- Generate a new secret key.  --->
	<cffunction name="rotateSecretKey" access="public" hint="I generate a secret key value for the cookie which enables debug mode" returntype="void" output="false">
		<cfscript>
			/* 
				This secret key is what the value of the user's cookie must equal to enable debug mode.
				This key will be different every time it is generated.  It is unique based on the application,
				current debugPassword and a random salt.  The salt also protects against someone being able to
				reverse engineer the orignal password from an intercepted cookie value.
			*/
			var salt = createUUID();
			var appHash = controller.getAppHash(); 
			setSecretKey( hash( appHash & instance.debugPassword & salt , "SHA-256") );
		</cfscript>
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
		<cfset loadedModules = controller.getModuleService().getLoadedModules()>
		<cfset moduleSettings = controller.getSetting("modules")>
		
		<!--- URL Base --->
		<cfif NOT event.isSES()>
			<cfset URLBase = listlast(cgi.script_name,"/")>
		</cfif>
		
		<!--- Render debuglog --->
		<cfsavecontent variable="renderedDebugging"><cfinclude template="/coldbox/system/includes/Debug.cfm"></cfsavecontent>
		
		<cfreturn renderedDebugging>
	</cffunction>
	
	<!--- Render Profilers --->
	<cffunction name="renderProfiler" access="public" hint="Renders the execution profilers." output="false" returntype="Any">
		<cfset var profilerContents = "">
		<cfset var profilers 		= instance.profilers>
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
	
	<!--- Get set the secret key --->
	<cffunction name="getSecretKey" access="private" output="false" returntype="any" hint="Get secret key">
		<cfreturn instance.secretKey/>
	</cffunction>
	<cffunction name="setSecretKey" access="private" output="false" returntype="void" hint="Set secret key">
		<cfargument name="secretKey" type="string" required="true"/>
		<cfset instance.secretKey = arguments.secretKey/>
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
		<cfreturn instance.profilers/>
	</cffunction>
	<cffunction name="setProfilers" access="public" output="false" returntype="void" hint="Set Profilers">
		<cfargument name="Profilers" type="array" required="true"/>
		<cfset instance.profilers = arguments.Profilers/>
	</cffunction>
	
	<!--- resetProfilers --->
    <cffunction name="resetProfilers" output="false" access="public" returntype="void" hint="Reset all profilers">
    	<cfset instance.profilers = arrayNew(1)>
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
			if( ArrayLen( instance.profilers ) gte getDebuggerConfig().getmaxPersistentRequestProfilers() ){
				popProfiler();
			}
			
			// New Profiler
			newRecord.datetime = now();
			newRecord.ip = cgi.REMOTE_ADDR;
			newRecord.timers = arguments.profilerRecord;
			
			ArrayAppend( instance.profilers,newRecord);
		</cfscript>		
	</cffunction>
	
	<!--- Pop a profiler --->
	<cffunction name="popProfiler" access="public" returntype="void" hint="Pop a profiler record" output="false" >
		<cfscript>
			ArrayDeleteAt( instance.profilers,1);
		</cfscript>
	</cffunction>
	
	<!--- Get Set Tracers --->
	<cffunction name="getTracers" access="public" output="false" returntype="array" hint="Get Tracers">
		<cfreturn instance.tracers/>
	</cffunction>
	<cffunction name="setTracers" access="public" output="false" returntype="void" hint="Set Tracers">
		<cfargument name="Tracers" type="array" required="true"/>
		<cfset instance.tracers = arguments.Tracers/>
	</cffunction>
	
	<!--- Push a tracer --->
	<cffunction name="pushTracer" access="public" returntype="void" hint="Push a new tracer" output="false" >
		<cfargument name="message"    required="true" 	type="string" hint="Message to Send" >
		<cfargument name="extraInfo"  required="false"  type="any" default="" hint="Extra Information to dump on the trace">
		<cfscript>
			var tracerEntry = StructNew();
			
			// Max Check
			if( arrayLen( instance.tracers ) gte instance.maxTracers) { resetTracers(); }
			
			// Create Message
			tracerEntry["message"] = arguments.message;
			tracerEntry["extraInfo"] = arguments.extraInfo;
			
			ArrayAppend( instance.tracers,tracerEntry);
		</cfscript>
	</cffunction>
	
	<!--- removeTracers --->
    <cffunction name="resetTracers" output="false" access="public" returntype="void" hint="Reset all Tracers">
    	<cfset instance.tracers = arrayNew(1)>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>