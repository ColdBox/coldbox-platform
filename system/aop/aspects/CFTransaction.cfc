<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A simple ColdFusion transaction Aspect for WireBox
----------------------------------------------------------------------->
<cfcomponent implements="coldbox.system.aop.MethodInterceptor"
			 hint="A simple ColdFusion transaction Aspect for WireBox"
			 output="false"
			 classMatcher="any" methodMatcher="annotatedWith:transactional">

	<!--- Dependencies --->
	<cfproperty name="log" inject="logbox:logger:{this}">

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

	<!--- invokeMethod --->
    <cffunction name="invokeMethod" output="false" access="public" returntype="any" hint="Invoke an AOP method invocation">
    	<cfargument name="invocation" required="true" hint="The method invocation object: coldbox.system.aop.MethodInvocation" colddoc:generic="coldbox.system.aop.MethodInvocation">
		<cfscript>
			var refLocal = {};

			// Are we already in a transaction?
			if( structKeyExists(request,"cbox_aop_transaction") ){
				// debug?
				if( log.canDebug() ){ log.debug("Call to '#arguments.invocation.getTargetName()#.#arguments.invocation.getMethod()#()' already transactioned, just executing it"); }
				// Just execute and return;
				return arguments.invocation.proceed();
			}
		</cfscript>

		<cftry>

			<cftransaction>
				<!--- In Transaction --->
				<cfset request["cbox_aop_transaction"] = true>
				<!--- Log --->
				<cfif log.canDebug()>
					<cfset log.debug("Call to '#arguments.invocation.getTargetName()#.#arguments.invocation.getMethod()#()' is now transactioned and begins execution")>
				</cfif>
				<!--- Execute Transactioned method --->
				<cfset refLocal.results = arguments.invocation.proceed()>
			</cftransaction>

			<cfcatch>
				<!--- remove transaction pointer --->
				<cfset structDelete(request,"cbox_aop_transaction")>
				<!--- Log Error --->
				<cfset log.error("An exception ocurred in the AOPed transactio for target: #arguments.invocation.getTargetName()#, method: #arguments.invocation.getMethod()#: #cfcatch.message# #cfcatch.detail#", cfcatch)>
				<!--- Rethrow --->
				<cfrethrow>
			</cfcatch>

		</cftry>

		<!--- remove transaction pointer --->
		<cfset structDelete(request,"cbox_aop_transaction")>

		<!--- Return Results --->
		<cfif structKeyExists(refLocal,"results")>
			<cfreturn refLocal.results>
		</cfif>
    </cffunction>

</cfcomponent>