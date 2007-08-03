<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Date     		: June 6, 2007
Description		: This is a unit test controller that basically overrides the setNextEvent
				  in order to unit test with set next events.
----------------------------------------------------------------------->
<cfcomponent name="testcontroller" hint="This is the ColdBox Unit Test Front Controller." output="false" extends="controller">

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Event Context Methods --->
	<cffunction name="setNextEvent" access="Public" returntype="void" hint="I Set the next event to run and relocate the browser to that event."  output="false">
		<cfargument name="event"  			hint="The name of the event to run." 			type="string" required="No" default="#getSetting("DefaultEvent")#" >
		<cfargument name="queryString"  	hint="The query string to append, if needed."   type="string" required="No" default="" >
		<cfargument name="addToken"			hint="Wether to add the tokens or not. Default is false" type="boolean" required="false" default="false"	>
		<!--- ************************************************************* --->
		<!--- Nothing In here to validate Unit Tests --->
		<cfset getRequestService().getContext().setValue("setnextevent","#arguments.event#&#arguments.queryString#")>
	</cffunction>

</cfcomponent>