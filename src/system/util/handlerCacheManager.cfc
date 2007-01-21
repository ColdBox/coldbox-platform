<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This is a cfc that handles caching of event handlers.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="handlerCacheManager" hint="Manages handler caching." output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="handlerCacheManager">
		<cfset application.coldbox_handlers = structnew()>
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if a handler is in cache.">
		<!--- ************************************************************* --->
		<cfargument name="handlerKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfset var HandlerFound = false>
		<cfif structKeyExists(application.coldbox_handlers, arguments.handlerKey ) >
			<cfset HandlerFound = true>
		</cfif>
		<cfreturn HandlerFound>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get a handler from cache.">
		<!--- ************************************************************* --->
		<cfargument name="handlerKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfreturn application.coldbox_handlers[arguments.handlerKey]>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="set" access="public" output="false" returntype="any" hint="set a handler in cache.">
		<!--- ************************************************************* --->
		<cfargument name="handlerKey" 		type="string" required="true">
		<cfargument name="HandlerObject"	type="any" 	  required="true">
		<!--- ************************************************************* --->
		<cflock type="exclusive" scope="application" timeout="120">
			<cfset application.coldbox_handlers[arguments.handlerKey] = arguments.HandlerObject>
		</cflock>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="clear" access="public" output="false" returntype="void" hint="Clears the handler cache.">
		<cflock type="exclusive" scope="application" timeout="120">
			<cfset structClear(application.coldbox_handlers)>
		</cflock>
	</cffunction>

	<!--- ************************************************************* --->
	
<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>