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
	
	<cffunction name="getAllArtist" output="false" access="remote" returntype="any" hint="Process a remote call and return data/objects back.">
		<cfargument name="page">
		<cfargument name="pageSize">
		<cfargument name="gridsortcolumn">
		<cfargument name="gridstartdirection">
		
		<cfset var results = "">
		<!--- Its very iteresting.. how I am intracting with service-layer, just bypassing controller layer --->
		
		<cfset results = getBean("ArtService").getAllArtist() />
		<!--- ColdBox is making things so simple -- just one line of code --->
		
		<!--- Convert Query for Paging --->
		<cfreturn QueryConvertForGrid(results,page,pageSize)>
	</cffunction>
	
	<cffunction name="SearchName" output="false" access="remote" returntype="Any" hint="Process a remote call and return data/objects back.">
		<cfargument name="search" type="any" required="false" default="">
		
		<cfset var results = "">
		<cfset var plugin = "" />
		<cfset var ReturnValue = "" />
		
		<!--- Its very iteresting.. how I am intracting with service-layer, just bypassing controller layer --->
		<cfset results = getBean("ArtService").getFindByName(arguments.search) />
		<!--- get plugin to convert query values into Array --->
		<cfset plugin = getPlugin("queryHelper") />
		
		<cfset ReturnValue = plugin.getColumnArray(qry = results, ColumnName = "ARTNAME") />
		<!--- <cfdump var="#ReturnValue#"> <cfabort> --->
		<cfreturn ReturnValue>
	</cffunction>

	<cffunction name="getArtists" output="false" access="remote" returntype="Any" hint="Process a remote call and return data/objects back.">
		<cfargument name="ARTISTID" type="numeric" required="false" default="0">
		<cfset var ReturnValue = "" />
		<!--- Its very iteresting.. how I am intracting with service-layer, just bypassing controller layer --->
		<cfset ReturnValue = getBean("ArtService").getArtist(argumentCollection=arguments) />
		
		<cfreturn ReturnValue>
	</cffunction>
	
	<cffunction name="getNames" output="false" access="remote" returntype="Any"  hint="Process a remote call and return data/objects back.">
		<cfset var qry  =  "" />
		<!--- CFSELECT (bind )  --->
		<cfset var TwoDimensionalArray =  ArrayNew(2) />
		
		<!--- Get Qry Directly from ArtService.cfc --->
		<cfset qry = getBean("ArtService").getArtist() />
		
		<cfset TwoDimensionalArray[1][1] = '0' />
		<cfset TwoDimensionalArray[1][2] = 'Please select' />
		
		<cfloop query="qry">
			<cfset TwoDimensionalArray[qry.CurrentRow + 1][1] = trim(qry.ARTISTID)>
            <cfset TwoDimensionalArray[qry.CurrentRow + 1][2] = trim(qry.FIRSTNAME & chr(32) & qry.LASTNAME)>
		</cfloop>

		<!--- Anything after --->
		<cfreturn TwoDimensionalArray>
	</cffunction>
	
	<cffunction name="validateCredentials" output="false" access="remote" returntype="boolean" hint="Process a remote call and return data/objects back.">
		<cfargument name="username" type="string">
		<cfargument name="password" type="string">
		<!--- set event handler --->
		<cfset arguments["event"] = "ehAjax.validateCredentials">
		
		<!--- Call the actual proxy --->
		<!--- <cfset qry = super.process(argumentCollection=arguments)> --->
		<!--- this is dummy code to verify username and [password] --->
		<cfif username eq "guest" and password eq "guest">
			<cfreturn true>	
		<cfelse>
			<cfreturn false>	
		</cfif>
	</cffunction>
	
	<cffunction name="dspTab2" output="false" access="remote" returnformat="plain" hint="Process a remote call and return data/objects back.">
		<cfset var results = "" />
		<!--- call even handler to get query data etc --->
		<cfset arguments["event"] = "ehAjax.dspTab2">

		<!--- Call the actual proxy --->
		<cfset results = super.process(argumentCollection=arguments)>
		<!--- <cfdump var="#results#"><cfabort> --->
		<cfreturn results>
	</cffunction>
	
	<cffunction name="process2" output="false" access="remote" returnformat="plain" hint="Process a remote call and return data/objects back.">
		<cfargument name="Args" type="Any">
		<cfset var results = "" />
		<cfset results = super.process(argumentCollection=Args)>
		<!--- <cfdump var="#results#"><cfabort> --->
		<cfreturn results>
	</cffunction>
</cfcomponent>
