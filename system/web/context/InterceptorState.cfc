<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	This object models an interception state
----------------------------------------------------------------------->
<cfcomponent hint="I am a pool of interceptors that can execute on a state or interception value." output="false" extends="coldbox.system.core.events.EventPool">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- init --->
	<cffunction name="init" access="public" output="false" hint="constructor" returntype="InterceptorState">
	    <!--- ************************************************************* --->
	    <cfargument name="state" 	type="any" required="true" hint="The interception state I model">
		<cfargument name="logbox" 	type="any" required="true" hint="An instance of logbox"/>
	    <!--- ************************************************************* --->
		<cfscript>
			super.init(argumentCollection=arguments);			
			
			// md ref map
			instance.metadataMap = structnew();
			// java system
			instance.javaSystem = createObject('java','java.lang.System');
			// Utilities
			instance.utility = createObject("component","coldbox.system.core.util.Util");
			// UUID Helper
			instance.uuidHelper	= createobject("java", "java.util.UUID");
			// Logger Object
			instance.log = arguments.logbox.getLogger( this );
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!---Get metadata map --->
	<cffunction name="getMetadataMap" access="public" returntype="any" output="false" hint="Return the state's metadata map for it's registered interecptors">    
		<cfargument name="interceptorKey" required="false" hint="Pass a key and retrieve that interceptor's metadata map only"/>
    	<cfscript>
			if( structKeyExists( arguments, "interceptorKey") ){
				return instance.metadataMap[ arguments.interceptorKey ];
			}
			return instance.metadataMap;
		</cfscript>
    </cffunction>

	<!--- Register a new interceptor with this state --->
	<cffunction name="register" access="public" returntype="any" hint="Register an interceptor class with this state" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptorKey" 	required="true" hint="The interceptor key class to register">
		<cfargument name="interceptor" 		required="true" hint="The interceptor reference from the cache.">
		<cfargument name="interceptorMD" 	required="true" hint="The interceptor state metadata.">
		<!--- ************************************************************* --->
		<cfscript>
			// Register interceptor object
			super.register( arguments.interceptorKey, arguments.interceptor );
			// Register interceptor metadata
			instance.metadataMap[ arguments.interceptorKey ] = arguments.interceptorMD;
			
			return this; 			
		</cfscript>
	</cffunction>
	
	<!--- Remove an interceptor key from this state --->
	<cffunction name="unregister" access="public" returntype="any" hint="Unregister an interceptor class from this state" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptorKey" 	required="true" hint="The interceptor key class to Unregister">
		<!--- ************************************************************* --->
		<cfscript>
			// unregister object
			var results = super.unregister( arguments.interceptorKey );
			// unregister metadata map
			structDelete( instance.metadataMap, arguments.interceptorKey );
			
			return results;			
		</cfscript>
	</cffunction>	
	
	<!--- exists --->
	<cffunction name="exists" output="false" access="public" returntype="boolean" hint="Checks if the passed interceptor key already exists">
		<!--- ************************************************************* --->
		<cfargument name="interceptorKey" 	required="true" hint="The interceptor key class to verify it exists">
		<!--- ************************************************************* --->
		<cfreturn super.exists( arguments.interceptorKey )>
	</cffunction>
	
	<cffunction name="getInterceptor" access="public" returntype="any" hint="Get an interceptor from this state. Else return a blank structure if not found" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptorKey" 	required="true" hint="The interceptor key class to retrieve">
		<!--- ************************************************************* --->
		<cfreturn super.getObject( arguments.interceptorKey )>
	</cffunction>
	
	<!--- Process the Interceptors --->
	<cffunction name="process" access="public" returntype="any" hint="Process this state's interceptors. If you use the asynchronous facilities, you will get a thread structure report as a result." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 		required="true" 	type="any"  hint="The event context object.">
		<cfargument name="interceptData"	required="true" 	type="any" 	hint="A data structure used to pass intercepted information.">
		<cfargument name="async" 				required="false" 	type="boolean" 	default="false" hint="If true, the entire interception chain will be ran in a separate thread."/>
		<cfargument name="asyncAll" 			required="false" 	type="boolean" 	default="false" hint="If true, each interceptor in the interception chain will be ran in a separate thread and then joined together at the end."/>
		<cfargument name="asyncAllJoin"		required="false" 	type="boolean" 	default="true" hint="If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize."/>
		<cfargument name="asyncPriority" 	required="false" 	type="string"	default="NORMAL" hint="The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL"/>
		<cfargument name="asyncJoinTimeout"	required="false" 	type="numeric"	default="0" hint="The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout."/>
		<cfargument name="buffer" 		 		required="true" 	type="any"  hint="The request buffer object that can be used to produce output from interceptor chains">
		<!--- ************************************************************* --->
		
		<!--- Process master asynchronously if not already in thread, if already in thread it will process in synch --->
		<cfif arguments.async AND NOT instance.utility.inThread()>
			<cfreturn processAsync( event=arguments.event, interceptData=arguments.interceptData, asyncPriority=arguments.asyncPriority, buffer=arguments.buffer )>
		<!---Process all asynchronously if not already in a thread --->
		<cfelseif arguments.asyncAll AND NOT instance.utility.inThread()>
			<cfreturn processAsyncAll(argumentCollection=arguments)>
		<!--- Process synchronously --->
		<cfelse>
			<cfset processSync( event=arguments.event, interceptData=arguments.interceptData, buffer=arguments.buffer )>
		</cfif>
	</cffunction>
	
	<!--- processAsync --->    
    <cffunction name="processAsync" output="false" access="private" returntype="any" hint="Process an execution asynchronously">    
    	<cfargument name="event" 		 	hint="The event context object.">
		<cfargument name="interceptData"	hint="A data structure used to pass intercepted information.">
		<cfargument name="asyncPriority" 	required="false" default="NORMAL" hint="The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL"/>
		<cfargument name="buffer" 		 	hint="The request buffer object that can be used to produce output from interceptor chains">
		
		<!--- Prepare thread safe name --->
		<cfset var threadName = "cbox_ichain_#replace( instance.uuidHelper.randomUUID(), "-", "", "all" )#">
		<!--- Log It --->
		<cfif instance.log.canDebug()>
			<cfset instance.log.debug("Threading interceptor chain: '#getState()#' with thread name: #threadName#, priority: #arguments.asyncPriority#")>
		</cfif>
		<!--- Thread master chain --->
		<cfthread name="#threadName#" 
				  action="run" 
				  priority="#arguments.asyncPriority#" 
				  event="#arguments.event#" 
				  interceptData="#arguments.interceptData#" 
				  threadName="#threadName#"
				  buffer="#arguments.buffer#">
			<!--- Process interception --->
			<cfset variables.processSync( event=attributes.event, interceptData=attributes.interceptData, buffer=attributes.buffer )>
			<!--- Log It --->
			<cfif instance.log.canDebug()>
				<cfset instance.log.debug("Finished threaded interceptor chain: #getState()# with thread name: #attributes.threadName#", thread)>
			</cfif>
		</cfthread>
		<!---Return the thread information --->
		<cfreturn cfthread[ threadName ]>
    </cffunction>
    
    <!--- processAsyncAll --->    
    <cffunction name="processAsyncAll" output="false" access="private" returntype="any" hint="Process an execution asynchronously for each interceptor state">    
    	<cfargument name="event" 		 		hint="The event context object.">
		<cfargument name="interceptData"		hint="A data structure used to pass intercepted information.">
		<cfargument name="asyncAllJoin"			required="false" 	default="true" 		hint="If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize."/>
		<cfargument name="asyncPriority" 		required="false" 	default="NORMAL" 	hint="The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL"/>
		<cfargument name="asyncJoinTimeout" 	required="false" 	default="0" 		hint="The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout."/>
		<cfargument name="buffer" 		 		hint="The request buffer object that can be used to produce output from interceptor chains">
		
		<!--- Get reference to all interceptors --->
		<cfset var interceptors 	= getInterceptors()>
		<cfset var threadnames 		= []>
		<cfset var thisThreadName 	= "">
		<cfset var key				= "">
		<cfset var threadData		= {}>
		<cfset var threadIndex		= "">
		
		<!--- Log It --->
		<cfif instance.log.canDebug()>
			<cfset instance.log.debug("AsyncAll interceptor chain starting for: '#getState()#' with join: #arguments.asyncAllJoin#, priority: #arguments.asyncPriority#, timeout: #arguments.asyncJoinTimeout#")>
		</cfif>
		
		<!---Iterate over interceptors --->
		<cfloop collection="#interceptors#" item="key">
			<!--- Prepare thread safe name --->
			<cfset thisThreadName = "ichain_#key#_#replace( instance.uuidHelper.randomUUID(), "-", "", "all" )#">
			<cfset arrayAppend( threadNames, thisThreadName )>
			
			<!--- Thread Interceptor Call --->
			<cfthread name="#thisThreadName#" 
					  action="run" 
					  priority="#arguments.asyncPriority#" 
					  event="#arguments.event#" 
					  interceptData="#arguments.interceptData#" 
					  threadName="#thisThreadName#"
					  buffer="#arguments.buffer#" 
					  key="#key#">
			<cfscript>
				// Retrieve interceptor to fire.
				var thisInterceptor = this.getInterceptors().get( attributes.key );
				// Check if we can execute this Interceptor
				if( variables.isExecutable( thisInterceptor, attributes.event, attributes.key ) ){
					// Invoke the execution point
					variables.invoker(interceptor=thisInterceptor, event=attributes.event, interceptData=attributes.interceptData, interceptorKey=attributes.key, buffer=attributes.buffer); 
					// Debug interceptions
					if( instance.log.canDebug() ){
						instance.log.debug("Interceptor '#getMetadata( thisInterceptor ).name#' fired in asyncAll chain: '#this.getState()#'");
					} 
				}	
			</cfscript>				
			</cfthread>			
		</cfloop>
		
		<!--- Do we need to join? --->
		<cfif arguments.asyncAllJoin>
			<!--- Log It --->
			<cfif instance.log.canDebug()>
				<cfset instance.log.debug("AsyncAll interceptor chain waiting for join: '#getState()#', timeout: #arguments.asyncJoinTimeout# ")>
			</cfif>
			<!--- Wait it --->
			<cfthread action="join" name="#arrayToList( threadNames )#" timeout="#arguments.asyncJoinTimeout#" />
		</cfif>
		
		<!--- Log It --->
		<cfif instance.log.canDebug()>
			<cfset instance.log.debug("AsyncAll interceptor chain ended for: '#getState()#' with join: #arguments.asyncAllJoin#, priority: #arguments.asyncPriority#, timeout: #arguments.asyncJoinTimeout#")>
		</cfif>
		
		<!--- Return cfthread information --->
		<cfloop array="#threadNames#" index="threadIndex">
			<cfset threadData[ threadIndex ] = cfthread[ threadIndex ]>
		</cfloop> 		
		<cfreturn threadData>		
    </cffunction>
	
	<!--- processSync --->    
    <cffunction name="processSync" output="false" access="private" returntype="any" hint="Process an execution synchronously">    
    	<cfargument name="event" 		 		hint="The event context object.">
		<cfargument name="interceptData"		hint="A data structure used to pass intercepted information.">
		<cfargument name="buffer" 		 		hint="The request buffer object that can be used to produce output from interceptor chains">
		<cfscript>	
			var key 			= "";
			var interceptors 	= getInterceptors();
			var thisInterceptor = "";
			
			// Debug interceptions
			if( instance.log.canDebug() ){
				instance.log.debug("Starting '#getState()#' chain with #structCount( interceptors )# interceptors");
			}
			
			// Loop and execute each interceptor as registered in order
			for( key in interceptors ){
				// Retreive interceptor
				thisInterceptor = interceptors.get( key );
				
				// Check if we can execute this Interceptor
				if( isExecutable( thisInterceptor, arguments.event, key ) ){
					
					// Async Execution only if not in a thread already, no buffer sent for async calls
					if( instance.metadataMap[ key ].async AND NOT instance.utility.inThread() ){
						invokerAsync(event=arguments.event, interceptData=arguments.interceptData, interceptorKey=key, asyncPriority=instance.metadataMap[ key ].asyncPriority);
					}
					// Invoke the execution point synchronously
					else if( invoker(interceptor=thisInterceptor, event=arguments.event, interceptData=arguments.interceptData, interceptorKey=key, buffer=arguments.buffer) ){ 
						break; 
					}
				}
				
			}	
			
			// Debug interceptions
			if( instance.log.canDebug() ){
				instance.log.debug("Finished '#getState()#' execution chain");
			}    
    	</cfscript>    
    </cffunction>
	
	<!--- isExecutable --->
	<cffunction name="isExecutable" output="false" access="public" returntype="any" hint="Checks if an interceptor is executable or not. Boolean">
		<cfargument name="target" 		type="any" required="true" hint="The target interceptor to check"/>
		<cfargument name="event" 		type="any" required="true" hint="The event context object.">
		<cfargument name="targetKey" 	type="any" required="true" hint="The target interceptor key to check.">
		<cfscript>
			// Get interceptor metadata
			var iData = instance.metadataMap[ arguments.targetKey ];
			
			// Check if the event pattern matches the current event, else return false
			if( len( iData.eventPattern ) AND
			    NOT reFindNoCase( iData.eventPattern, arguments.event.getCurrentEvent() ) ){
			    
			    // Log it	
			    if( instance.log.canDebug() ){
					instance.log.debug("Interceptor '#getMetadata( arguments.target ).name#' did NOT fire in chain: '#getState()#' due to event pattern mismatch: #iData.eventPattern#.");
				} 
				
				return false;
			}
			
			// No event pattern found, we can execute.
			return true;
		</cfscript>	
	</cffunction>
	
	<!--- getInterceptors --->
	<cffunction name="getInterceptors" access="public" output="false" returntype="any" hint="Get the interceptors linked hash map">
		<cfreturn super.getPool() />
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Interceptor Async Invoker --->
	<cffunction name="invokerAsync" access="private" returntype="any" hint="Execute an interceptor execution point asynchronously" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 	required="true" 	type="any" 		hint="The event context">
		<cfargument name="interceptData" 	required="true" 	type="any" 		hint="A metadata structure used to pass intercepted information.">
		<cfargument name="interceptorKey" 	required="true" 	type="any" 		hint="The interceptor key to invoke">
		<cfargument name="asyncPriority" 	required="false" 	type="any" default="normal"	hint="The thread priority for the execution">
		<!--- ************************************************************* --->
		
		<!--- Prepare thread safe name --->
		<cfset var thisThreadName = "asyncInterceptor_#arguments.interceptorKey#_#replace( instance.uuidHelper.randomUUID(), "-", "", "all" )#">
		
		<!--- Log It --->
		<cfif instance.log.canDebug()>
			<cfset instance.log.debug("Async interception starting for: '#getState()#', interceptor: #arguments.interceptorKey#, priority: #arguments.asyncPriority#")>
		</cfif>
		
		<!--- Thread Interceptor Call --->
		<cfthread name="#thisThreadName#" 
				  action="run" 
				  priority="#arguments.asyncPriority#" 
				  event="#arguments.event#"
				  interceptData="#arguments.interceptData#" 
				  threadName="#thisThreadName#" 
				  key="#arguments.interceptorKey#">
			
			<!--- Invoke the interceptor --->
			<cfinvoke component="#this.getInterceptors().get( attributes.key )#" method="#this.getstate()#">
				<cfinvokeargument name="event" 				value="#attributes.event#">
				<cfinvokeargument name="interceptData" 	value="#attributes.interceptData#">
			</cfinvoke>
			
			<!--- Log It --->
			<cfif instance.log.canDebug()>
				<cfset instance.log.debug("Async interception ended for: '#this.getState()#', interceptor: #attributes.key#, threadName: #attributes.threadName#")>
			</cfif>
			
		</cfthread>
		
	</cffunction>
	
	<!--- Interceptor Invoker --->
	<cffunction name="invoker" access="private" returntype="any" hint="Execute an interceptor execution point" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptor" 		required="true" type="any" 		hint="The interceptor reference from cache">
		<cfargument name="event" 		 		required="true" type="any" 		hint="The event context">
		<cfargument name="interceptData" 	required="true" type="any" 		hint="A metadata structure used to pass intercepted information.">
		<cfargument name="interceptorKey" 	required="true" type="any" 		hint="The interceptor key to invoke">
		<cfargument name="buffer" 		 		required="true" type="any"		hint="The request buffer object that can be used to produce output from interceptor chains">
		<!--- ************************************************************* --->
		<!--- Results reference --->
		<cfset var refLocal = structnew()>
		
		<!--- Log It --->
		<cfif instance.log.canDebug()>
			<cfset instance.log.debug("Interception started for: '#getState()#', key: #arguments.interceptorKey#")>
		</cfif>
		
		<!--- Invoke the interceptor --->
		<cfinvoke component="#arguments.interceptor#" method="#getstate()#" returnvariable="refLocal.results">
			<cfinvokeargument name="event" 				value="#arguments.event#">
			<cfinvokeargument name="interceptData" 	value="#arguments.interceptData#">
			<cfinvokeargument name="buffer" 				value="#arguments.buffer#">
		</cfinvoke>
		
		<!--- Log It --->
		<cfif instance.log.canDebug()>
			<cfset instance.log.debug("Interception ended for: '#getState()#', key: #arguments.interceptorKey#")>
		</cfif>
		
		<!--- Check if we have results --->
		<cfif structKeyExists( refLocal, "results" ) and isBoolean( refLocal.results )>
			<cfreturn refLocal.results>
		<cfelse>
			<cfreturn false>
		</cfif>			
	</cffunction>
	
</cfcomponent>	