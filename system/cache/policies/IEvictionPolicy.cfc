<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	The CacheBox eviction policy Interface
----------------------------------------------------------------------->
<cfinterface hint="The CacheBox eviction policy interface">

	<!--- execute --->
	<cffunction name="execute" output="false" access="public" returntype="void" hint="Execute the eviction policy on the associated cache">
	</cffunction>
	
	<!--- Get Associated Cache --->
	<cffunction name="getAssociatedCache" access="public" returntype="any" output="false" hint="Get the Associated Cache Provider of type: coldbox.system.cache.ICacheProvider">
	</cffunction>
		
</cfinterface>