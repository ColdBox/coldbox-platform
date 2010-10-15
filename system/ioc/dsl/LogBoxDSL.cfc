<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	CacheBox DSL Processor
	
----------------------------------------------------------------------->
<cfcomponent implements="coldbox.system.ioc.dsl.IDSLNamespace" hint="CacheBox DSL Processor">

	<!--- process --->
    <cffunction name="process" output="false" access="public" returntype="any" hint="Process an incoming DSL definition and produce an object with it.">
		<cfargument name="injectDSL" type="string" required="true" hint="The injection dsl string to process"/>    	
    </cffunction>
	
</cfcomponent>