<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	March 05 2008
Description :	Lightwire implmentation.
----------------------------------------------------------------------->
<cfcomponent name="ehLightwire" extends="coldbox.system.eventhandler" output="false">
	
	<!--- This init format is mandatory if you are writing init code else is optional, include the super.init(arguments.controller). ---> 
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" type="any">
		<cfset super.init(arguments.controller)>
		<!--- Any constructor code here --->
		<cfreturn this>
	</cffunction>


</cfcomponent>
