<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	This is the base request context decorator object
----------------------------------------------------------------------->
<cfcomponent hint="This is the base request context decorator used as an abstract class for implementing request context decorators" output="false" extends="coldbox.system.web.context.RequestContext">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
		
	<cffunction name="init" access="public" output="false" hint="constructor" returntype="RequestContextDecorator">
		<!--- ************************************************************* --->
		<cfargument name="oContext" 	type="any" 	required="true" hint="The original context we are decorating. coldbox.system.web.context.RequestContext">
		<cfargument name="controller" 	type="any" 	required="true"	hint="The coldbox controller">
		<!--- ************************************************************* --->
		<cfscript>
			// Set the memento state
			setMemento(arguments.oContext.getMemento());
			
			// Set Controller
			instance.controller = arguments.controller;
			
			// Composite the original context
			setRequestContext(arguments.oContext);
			
			// Configure this decorated request context.
			configure();
			
			return this;
		</cfscript>		
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Configure --->
	<cffunction name="configure" access="public" returntype="void" hint="Override to provide a pseudo-constructor for your decorator" output="false" >
	</cffunction>
	
	<!--- Get the original context --->
	<cffunction name="getRequestContext" access="public" output="false" returntype="any" hint="Get the original request context. coldbox.system.web.context.RequestContext">
		<cfreturn instance.requestContext/>
	</cffunction>
	
	<!--- Set the original context --->
	<cffunction name="setRequestContext" access="public" output="false" returntype="void" hint="DO NOT OVERRIDE: Set the original request context.">
		<cfargument name="requestContext" type="any" required="true"/>
		<cfset instance.requestContext = arguments.requestContext/>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Get Set Controller --->
	<cffunction name="getController" access="private" output="false" returntype="any" hint="Get controller: coldbox.system.web.Controller">
		<cfreturn instance.controller/>
	</cffunction>	

</cfcomponent>