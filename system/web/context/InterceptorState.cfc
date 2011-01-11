<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
	    <cfargument name="state" 		type="string" 	required="true" hint="The interception state I model">
	    <!--- ************************************************************* --->
		<cfscript>
			super.init(argumentCollection=arguments);			
			
			// md ref map
			instance.MDMap = structnew();
			// java system
			instance.javaSystem = createObject('java','java.lang.System');
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Register a new interceptor with this state --->
	<cffunction name="register" access="public" returntype="void" hint="Register an interceptor class with this state" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptorKey" 	required="true" type="string" 	hint="The interceptor key class to register">
		<cfargument name="interceptor" 		required="true" type="any" 		hint="The interceptor reference from the cache.">
		<!--- ************************************************************* --->
		<cfset super.register(arguments.interceptorKey,arguments.interceptor)>
	</cffunction>
	
	<!--- Remove an interceptor key from this state --->
	<cffunction name="unregister" access="public" returntype="void" hint="Unregister an interceptor class from this state" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptorKey" 	required="true" type="string" 	hint="The interceptor key class to Unregister">
		<!--- ************************************************************* --->
		<cfset super.unregister(arguments.interceptorKey)>
	</cffunction>	
	
	<!--- exists --->
	<cffunction name="exists" output="false" access="public" returntype="boolean" hint="Checks if the passed interceptor key already exists">
		<!--- ************************************************************* --->
		<cfargument name="interceptorKey" 	required="true" type="string" 	hint="The interceptor key class to register">
		<!--- ************************************************************* --->
		<cfreturn super.exists(arguments.interceptorKey)>
	</cffunction>
	
	<cffunction name="getInterceptor" access="public" returntype="any" hint="Get an interceptor from this state. Else return a blank structure if not found" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptorKey" 	required="true" type="string" 	hint="The interceptor key class to Unregister">
		<!--- ************************************************************* --->
		<cfreturn super.getObject(arguments.interceptorKey)>
	</cffunction>
	
	<!--- Process the Interceptors --->
	<cffunction name="process" access="public" returntype="void" hint="Process this state's interceptors" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" 	type="any"  hint="The event context object.">
		<cfargument name="interceptData" required="true" 	type="any" 	hint="A data structure used to pass intercepted information.">
		<!--- ************************************************************* --->
		<cfscript>
		var key 			= "";
		var stopChain 		= "";
		var thisInterceptor = "";
		var interceptors    = getInterceptors();
		
		// Loop and execute each interceptor as registered in order
		for( key in interceptors ){
			thisInterceptor = interceptors.get(key);
			
			// Check if we can execute this Interceptor
			if( isExecutable(thisInterceptor,arguments.event) ){
				// Invoke the execution point
				if ( invoker( thisInterceptor, arguments.event, arguments.interceptData ) ){ break; }
			}
		}		
		</cfscript>
	</cffunction>
	
	<!--- isExecutable --->
	<cffunction name="isExecutable" output="false" access="public" returntype="any" hint="Checks if an interceptor is executable or not. Boolean">
		<cfargument name="target" type="any" required="true" hint="The target interceptor to check"/>
		<cfargument name="event"  type="any" required="true" hint="The event context object.">
		<cfscript>
			var state			= getState();
			var idCode 			= instance.javaSystem.identityHashCode(arguments.target) & state;
			var fncMetadata 	= "";
			
			// check md if it exists, else set it
			if( NOT structKeyExists(instance.MDMap, idCode) ){
				instance.MDMap[idCode] = getMetadata(arguments.target[state]);
			}
			// Get md now
			fncMetadata = instance.MDMap[idCode];
			
			// Check if the event pattern matches the current event, else return false
			if( structKeyExists(fncMetadata,"eventPattern") AND
				len(fncMetadata.eventPattern) AND
			    NOT reFindNoCase(fncMetadata.eventPattern, arguments.event.getCurrentEvent()) ){
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

	<!--- Interceptor Invoker --->
	<cffunction name="invoker" access="private" returntype="any" hint="Execute an interceptor execution point" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptor" 		required="true" type="any" 		hint="The interceptor reference from cache">
		<cfargument name="event" 		 	required="true" type="any" 		hint="The event context">
		<cfargument name="interceptData" 	required="true" type="any" 		hint="A metadata structure used to pass intercepted information.">
		<!--- ************************************************************* --->
		<cfset var refLocal = structnew()>
		
		<!--- Invoke the interceptor --->
		<cfinvoke component="#arguments.interceptor#" method="#getstate()#" returnvariable="refLocal.results">
			<cfinvokeargument name="event" 			value="#arguments.event#">
			<cfinvokeargument name="interceptData" 	value="#arguments.interceptData#">
		</cfinvoke>
		
		<!--- Check if we have results --->
		<cfif structKeyExists(refLocal,"results") and isBoolean(refLocal.results)>
			<cfreturn refLocal.results>
		<cfelse>
			<cfreturn false>
		</cfif>			
	</cffunction>
	
</cfcomponent>	