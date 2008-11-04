<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Date     		: June 6, 2007
Description		: This is a unit test controller that basically overrides the setNextEvent
				  in order to unit test with set next events.
----------------------------------------------------------------------->
<cfcomponent name="testcontroller" hint="This is the ColdBox Unit Test Front Controller." output="false" extends="coldbox.system.controller">

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Event Context Methods --->
	<cffunction name="setNextEvent" access="Public" returntype="void" hint="I Set the next event to run and relocate the browser to that event."  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event"  			type="string" 	required="false" default="#getSetting("DefaultEvent")#" hint="The name of the event to run.">
		<cfargument name="queryString"  	type="string" 	required="false" default="" hint="The query string to append, if needed.">
		<cfargument name="addToken"			type="boolean" 	required="false" default="false" hint="Wether to add the tokens or not. Default is false">
		<cfargument name="persist" 			type="string" 	required="false" default="" hint="What request collection keys to persist in the relocation">
		<cfargument name="varStruct" 		type="struct" 	required="false" default="#structNew()#" hint="A structure key-value pairs to persist.">
		<!--- ************************************************************* --->
		<!--- Nothing In here to validate Unit Tests --->
		<cfif len(trim(arguments.queryString)) eq 0>
			<cfset getRequestService().getContext().setValue("setnextevent","#arguments.event#")>
		<cfelse>
			<cfset getRequestService().getContext().setValue("setnextevent","#arguments.event#&#arguments.queryString#")>
		</cfif>
		<!--- Save also the persist collection keys --->
		<cfset getRequestService().getContext().setValue("persistKeys","#arguments.persist#")>
		<!--- Save also the persist collection keys --->
		<cfset getRequestService().getContext().setValue("persistVarStruct","#arguments.varStruct#")>
	</cffunction>
	
	<!--- Event Context Methods --->
	<cffunction name="setNextRoute" access="Public" returntype="void" hint="I Set the next ses route to relocate to. This method pre-pends the baseURL"  output="false">
		<!--- ************************************************************* --->
		<!--- ************************************************************* --->
		<cfargument name="route"  		required="yes" 	 type="string"  hint="The route to relocate to, do not prepend the baseURL or /.">
		<cfargument name="persist" 		required="false" type="string"  default="" hint="What request collection keys to persist in the relocation">
		<cfargument name="varStruct" 	required="false" type="struct"  default="#structnew()#" hint="A structure key-value pairs to persist.">
		<cfargument name="addToken"		required="false" type="boolean" default="false"	hint="Wether to add the tokens or not. Default is false">
		<!--- ************************************************************* --->
		<!--- Save the route --->
		<cfset getRequestService().getContext().setValue("setNextRoute","#arguments.route#")>

		<!--- Save also the persist collection keys --->
		<cfset getRequestService().getContext().setValue("persistKeys","#arguments.persist#")>
		<!--- Save also the persist collection keys --->
		<cfset getRequestService().getContext().setValue("persistVarStruct","#arguments.varStruct#")>
	</cffunction>

</cfcomponent>