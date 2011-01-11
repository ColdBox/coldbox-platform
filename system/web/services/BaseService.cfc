<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date         :	August 25, 2007
Description :
	This is a base coldbox service. All services built for coldbox will
	be based on this taxonomy.

Modification History:
08/25/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="BaseService" hint="A ColdBox base internal service" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		variables.instance 		= structnew();
		variables.controller 	= structnew();
		variables.util 			= CreateObject("component","coldbox.system.core.util.Util");
	</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- convertToColdBox --->
    <cffunction name="convertToColdBox" output="false" access="public" returntype="void" hint="Decorate an object as a ColdBox object">
    	<cfargument name="family" type="any" required="true" hint="The family to covert it to: handler, plugin, interceptor"/>
		<cfargument name="target" type="any" required="true" hint="The target object"/>
		<cfscript>
			return getUtil().convertToColdBox(argumentCollection=arguments);
		</cfscript>
    </cffunction>
	
	<!--- isFamilyType --->
    <cffunction name="isFamilyType" output="false" access="public" returntype="boolean" hint="Checks if an object is of the passed in family type">
    	<cfargument name="family" type="string" required="true" hint="The family to covert it to: handler, plugin, interceptor"/>
		<cfargument name="target" type="any" 	required="true" hint="The target object"/>
		<cfscript>
			return getUtil().isFamilyType(argumentCollection=arguments);
		</cfscript>		
    </cffunction>

	<!--- Get Controller --->
	<cffunction name="getController" access="package" output="false" returntype="any" hint="Get controller">
		<cfreturn controller/>
	</cffunction>
	
	<!--- Set Controller --->
	<cffunction name="setController" access="package" output="false" returntype="void" hint="Set controller">
		<cfargument name="controller" type="any" required="true"/>
		<cfset variables.controller = arguments.controller/>
	</cffunction>
	
	<!--- Get OCM Facade --->	
	<cffunction name="getColdboxOCM" access="public" output="false" returntype="any" hint="Get ColdboxOCM: coldbox.system.cache.CacheManager or new CacheBox providers">
		<cfargument name="cacheName" type="string" required="false" default="default" hint="The cache name to retrieve"/>
		<cfreturn controller.getColdboxOCM(arguments.cacheName)/>
	</cffunction>
	
<!------------------------------------------- INTERNAL EVENTS ------------------------------------------>	
	
	<!--- onConfigurationLoad --->
    <cffunction name="onConfigurationLoad" output="false" access="public" returntype="void" hint="Called by loader service when configuration file loads">
    	<!--- Implemented by Concrete Services --->
    </cffunction>
	
	<!--- onAspectsLoad --->
    <cffunction name="onAspectsLoad" output="false" access="public" returntype="void" hint="Called by loader service after aspects load">
    	<!--- Implemented by Concrete Services --->
    </cffunction>
	
	<!--- onShutdown --->
    <cffunction name="onShutdown" output="false" access="public" returntype="void" hint="Called by bootstrapper, whenever the application shuts down">
    	<!--- Implemented by Concrete Services --->
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- getUtil --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn util/>
	</cffunction>
	
</cfcomponent>