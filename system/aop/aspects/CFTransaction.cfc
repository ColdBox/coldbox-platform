<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A simple interceptor that logs method calls and their results
----------------------------------------------------------------------->
<cfcomponent output="false" implements="coldbox.system.aop.MethodInterceptor" hint="A simple interceptor that logs method calls and their results">
	
	<!--- Dependencies --->
	<cfproperty name="log" inject="logbox:logger:{this}">
	
	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">
		<cfargument name="logResults" type="boolean" required="false" default="true" hint="Do we log results or not?"/>
		<cfscript>	
			instance = {
				logResults = arguments.logResults
			};
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- invokeMethod --->    
    <cffunction name="invokeMethod" output="false" access="public" returntype="any" hint="Invoke an AOP method invocation">    
    	<cfargument name="invocation" type="any" hint="The method invocation object: coldbox.system.ioc.aop.MethodInvocation" colddoc:generic="coldbox.system.ioc.aop.MethodInvocation">
		<cfscript>
			var refLocal = {};
			
			// log incoming call
			log.debug("target: #arguments.invocation.getTargetName()# method: #arguments.invocation.getMethod()#", arguments.invocation.getArgs());
			
			// proceed execution
			refLocal.results = arguments.invocation.proceed();
			
			if( instance.logResults ){
				log.debug("target-results: #arguments.invocation.getTargetName()#", refLocal.results);
			}
			
			if( structKeyExists(refLocal,"results") ){ return refLocal.results; }
		</cfscript>
    </cffunction>
	
</cfcomponent>