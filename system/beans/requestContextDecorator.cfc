<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	This is the base request context decorator object
----------------------------------------------------------------------->
<cfcomponent name="requestContextDecorator" hint="This is the base request context decorator" output="false" extends="coldbox.system.beans.requestContext">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
		
	<cffunction name="init" access="public" output="false" hint="constructor" returntype="requestContextDecorator">
		<!--- ************************************************************* --->
		<cfargument name="oContext" 	type="any" 	required="true" hint="The original context we are decorating. coldbox.system.beans.requestContext">
		<cfargument name="controller" 	type="any" 	required="true"	hint="The coldbox controller">
		<!--- ************************************************************* --->
		<cfscript>
			/* Set the memento state */
			setMemento(arguments.oContext.getMemento());
			
			/* Set Controller */
			instance.controller = arguments.controller;
			
			/* Composite the original context */
			setRequestContext(arguments.oContext);
			
			/* Configure this decorated request context. */
			configure();
			
			return this;
		</cfscript>		
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Configure --->
	<cffunction name="Configure" access="public" returntype="void" hint="Override to provide a pseudo-constructor for your decorator" output="false" >
	</cffunction>
	
	<!--- Get the original context --->
	<cffunction name="getrequestContext" access="public" output="false" returntype="any" hint="Get the original request context. coldbox.system.beans.requestContext">
		<cfreturn instance.requestContext/>
	</cffunction>
	
	<!--- Set the original context --->
	<cffunction name="setrequestContext" access="public" output="false" returntype="void" hint="DO NOT OVERRIDE: Set the original request context.">
		<cfargument name="requestContext" type="any" required="true"/>
		<cfset instance.requestContext = arguments.requestContext/>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Get Set Controller --->
	<cffunction name="getcontroller" access="private" output="false" returntype="any" hint="Get controller: coldbox.system.controller">
		<cfreturn instance.controller/>
	</cffunction>	

</cfcomponent>