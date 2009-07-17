<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This proxy is an inherited coldbox remote proxy used for enabling
	coldbox as a model framework.
----------------------------------------------------------------------->
<cfcomponent name="coldboxproxy" output="false" extends="coldbox.system.extras.ColdboxProxy">

	<!--- You can override this method if you want to intercept before and after. --->
	<cffunction name="process" output="false" access="public" returntype="any" hint="Process a remote call and return data/objects back.">
		<cfset var results = "">
		
		<!--- Anything before --->
		
		<!--- Call the actual proxy --->
		<cfset results = super.process(argumentCollection=arguments)>
		
		<!--- Anything after --->
		
		<cfreturn results>
	</cffunction>
	
</cfcomponent>