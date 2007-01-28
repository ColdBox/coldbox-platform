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

	<cffunction name="init" access="public" output="false" returntype="handlerCacheManager" hint="Constructor">
		<cfscript>
		variables.cb_handlers = structnew();
		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if a handler is in cache.">
		<!--- ************************************************************* --->
		<cfargument name="handlerKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfset var HandlerFound = false>
		<cfif structKeyExists(variables.cb_handlers, arguments.handlerKey ) >
			<cfset HandlerFound = true>
		</cfif>
		<cfreturn HandlerFound>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get a handler from cache. If it doesn't exist it return a blank structure.">
		<!--- ************************************************************* --->
		<cfargument name="handlerKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfif lookup(arguments.handlerKey)>
			<cfreturn variables.cb_handlers[arguments.handlerKey]>
		<cfelse>
			<cfreturn structNew()>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="set" access="public" output="false" returntype="any" hint="set a handler in cache.">
		<!--- ************************************************************* --->
		<cfargument name="handlerKey" 		type="string" required="true">
		<cfargument name="HandlerObject"	type="any" 	  required="true">
		<!--- ************************************************************* --->
		<cfset variables.cb_handlers[arguments.handlerKey] = arguments.HandlerObject>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="clear" access="public" output="false" returntype="void" hint="Clears the handler cache.">
		<cfset structClear(variables.cb_handlers)>
	</cffunction>

	<!--- ************************************************************* --->
	
<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>