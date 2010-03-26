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
    	<cfargument name="family" type="string" required="true" hint="The family to covert it to: handler, plugin, interceptor"/>
		<cfargument name="target" type="any" 	required="true" hint="The target object"/>
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
	<cffunction name="getcontroller" access="package" output="false" returntype="any" hint="Get controller">
		<cfreturn controller/>
	</cffunction>
	
	<!--- Set Controller --->
	<cffunction name="setcontroller" access="package" output="false" returntype="void" hint="Set controller">
		<cfargument name="controller" type="any" required="true"/>
		<cfset variables.controller = arguments.controller/>
	</cffunction>
	
	<!--- Get OCM Facade --->	
	<cffunction name="getColdboxOCM" access="package" output="false" returntype="any" hint="Get the Coldbox Cache Manager">
		<cfreturn controller.getColdboxOCM()/>
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

	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn util/>
	</cffunction>
	
	<cffunction name="debug" access="private" returntype="void" hint="Send debug to log file" output="false" >
		<cfargument name="content" required="true" type="any" hint="">
		<cfset controller.getPlugin("Logger").logEntry("debug",content)>
	</cffunction>
	
	<cffunction name="getLogger" access="private" returntype="coldbox.system.plugins.Logger" hint="Get a logger plugin" output="false" >
		<cfreturn controller.getPlugin("Logger")>
	</cffunction>
	
</cfcomponent>