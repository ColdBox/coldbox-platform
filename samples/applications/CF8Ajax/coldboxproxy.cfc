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
	<cffunction name="process" output="false" access="remote" returntype="any" hint="Process a remote call and return data/objects back.">
		<cfset var results = "">
		
		<!--- Anything before --->
		
		<!--- Call the actual proxy --->
		<cfset results = super.process(argumentCollection=arguments)>
		
		<!--- Anything after --->
		
		<cfreturn results>
	</cffunction>
	
	<cffunction name="getData" output="false" access="remote" returntype="any" hint="Process a remote call and return data/objects back.">
		<cfargument name="page">
		<cfargument name="pageSize">
		<cfargument name="gridsortcolumn">
		<cfargument name="gridstartdirection">
		
		<cfset var results = "">
		
		<!--- Bind to which event has the data --->
		<cfset arguments["event"] = "ehGeneral.doData">
		
		<!--- Call the actual proxy --->
		<cfset results = super.process(argumentCollection=arguments)>
		
		<!--- Convert Query for Paging --->
		<cfreturn QueryConvertForGrid(results,page,pageSize)>
	</cffunction>
	
	<cffunction name="lookupName" output="false" access="remote" returntype="any" hint="Process a remote call and return data/objects back.">
		<cfargument name="search" type="any" required="false" default="">
		<cfset var qry = "">
		<cfset var results = ArrayNew(1)>
		
		<!--- Bind to which event has the data --->
		<cfset arguments["event"] = "ehGeneral.doLookupName">
		
		<!--- Call the actual proxy --->
		<cfset results = super.process(argumentCollection=arguments)>
		<!--- Cleanup --->
		
		<!--- Anything after --->
		<cfreturn results>
	</cffunction>
	
	<cffunction name="getEmployees" output="false" access="remote" returnFormat="json" hint="Process a remote call and return data/objects back.">
		<cfargument name="id" type="any" required="false" default="0">
		<cfset var qry = "">
		
		<cfset arguments["event"] = "ehGeneral.doEmployees">
		<!--- Anything before --->
		
		<!--- Call the actual proxy --->
		<cfset qry = super.process(argumentCollection=arguments)>

		<!--- Anything after --->
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getNames" output="false" access="remote" returntype="Any"  hint="Process a remote call and return data/objects back.">
		<cfset var qry  =  "" />
		<!--- CFSELECT (bind )  --->
		<cfset var TwoDimensionalArray =  ArrayNew(2) />
		<cfset arguments["event"] = "ehGeneral.doEmployees">
		<!--- Anything before --->
		
		<!--- Call the actual proxy --->
		<cfset qry = super.process(argumentCollection=arguments)>
		
		<!--- <cfset TwoDimensionalArray[1][1] = '0' />
		<cfset TwoDimensionalArray[1][2] = 'Please select' /> --->
		
		<cfloop query="qry">
			<cfset TwoDimensionalArray[qry.CurrentRow][1] = trim(qry.idt)>
            <cfset TwoDimensionalArray[qry.CurrentRow][2] = trim(qry.fname)>
		</cfloop>

		<!--- Anything after --->
		<cfreturn TwoDimensionalArray>
	</cffunction>
	
	<cffunction name="validateCredentials" output="false" access="remote" returntype="boolean" hint="Process a remote call and return data/objects back.">
		<cfargument name="username" type="string">
		<cfargument name="password" type="string">
		<!--- set event handler --->
		<cfset arguments["event"] = "ehGeneral.validateCredentials">
		
		<!--- Call the actual proxy --->
		<!--- <cfset qry = super.process(argumentCollection=arguments)> --->
		<!--- this is dummy code to verify username and [password] --->
		<cfif username eq "guest" and password eq "guest">
			<cfreturn true>	
		<cfelse>
			<cfreturn false>	
		</cfif>
	</cffunction>
	
	<cffunction name="dspTab2" output="false" access="remote" returntype="any" hint="Process a remote call and return data/objects back.">
		<cfset results = "" />
		<!--- call even handler to get query data etc --->
		<cfset arguments["event"] = "ehGeneral.dspTab2">

		<!--- Call the actual proxy --->
		<cfset results = super.process(argumentCollection=arguments)>
		<cfreturn results>
	</cffunction>
	
</cfcomponent>
