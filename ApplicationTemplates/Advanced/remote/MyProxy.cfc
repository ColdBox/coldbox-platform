<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This proxy is an inherited coldbox remote proxy used for enabling
	coldbox as a model framework.
----------------------------------------------------------------------->
<cfcomponent name="MyProxy" output="false" extends="coldbox.system.remote.ColdboxProxy">

	<cffunction name="yourRemoteCall" output="false" access="remote" returntype="YourType" hint="Your Hint">
		<cfset var results = "">
		
		<!--- Set the event to execute --->
		<cfset arguments.event = "">
		
		<!--- Call to process a coldbox event cycle, always check the results as they might not exist. --->
		<cfset results = super.process(argumentCollection=arguments)>
		
		<cfreturn results>
	</cffunction>
	
</cfcomponent>