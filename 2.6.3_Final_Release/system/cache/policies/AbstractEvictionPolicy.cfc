<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is an AbstractEviction Policy object.
----------------------------------------------------------------------->
<cfcomponent name="AbstractEvictionPolicy" hint="An abstract cache eviction policy" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>


<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- execute --->
	<cffunction name="execute" output="false" access="public" returntype="void" hint="Execute the policy">
		<!--- Implemented by Concrete Classes --->
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- The Cache Manager --->
	<cffunction name="getcacheManager" access="private" returntype="coldbox.system.cache.CacheManager" output="false">
		<cfreturn instance.cacheManager>
	</cffunction>
	<cffunction name="setcacheManager" access="private" returntype="void" output="false">
		<cfargument name="cacheManager" type="coldbox.system.cache.CacheManager" required="true">
		<cfset instance.cacheManager = arguments.cacheManager>
	</cffunction>

</cfcomponent>