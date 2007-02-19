<!---
	Name         : c:\projects\blog\client\tags\getmode.cfm
	Author       : Raymond Camden 
	Created      : 02/09/06
	Last Updated : 
	History      : 
	
	Updated by Luis Majano for ColdBox
--->
<!--- Since this page is called as a module, it has its own scope, So I add a reference to the controller. --->
<cfif caller.requestContext.getValue("mode","") eq "">
	<cfset caller.requestContext.setValue("mode","")>
</cfif>

<cfparam name="attributes.r_params" type="variableName">

<cfset params = structNew()>

<!--- 
	  SES parsing is abstracted out. This file is getting a bit large so I want to keep things nice and simple.
	  Plus if folks don't like this, they can just get rid of it.
	  Of course, the Blog makes use of it... but I'll worry about that later.
--->
<cfinclude template="parseses.cfm" />

<!--- starting index --->
<cfif caller.requestContext.getValue("startrow",1) eq 1>
	<cfset caller.requestContext.setValue("startrow",1)>
</cfif>
<cfif not isNumeric(caller.requestContext.getValue("startrow")) or caller.requestContext.getValue("startrow") lte 0 or round(caller.requestContext.getValue("startrow")) neq caller.requestContext.getValue("startrow")>
	<cfset caller.requestContext.setValue("startrow",1)>
</cfif>

<!--- Handle cleaning of day, month, year --->
<cfif caller.requestContext.valueExists("day") and (not isNumeric(caller.requestContext.getValue("day")) or val(caller.requestContext.getValue("day")) is not caller.requestContext.getValue("day"))>
	<cfset structDelete(request.reqCollection,"day")>
</cfif>
<cfif caller.requestContext.valueExists("month") and (not isNumeric(caller.requestContext.getValue("month")) or val(caller.requestContext.getValue("month")) is not caller.requestContext.getValue("month"))>
	<cfset structDelete(request.reqCollection,"month")>
</cfif>
<cfif caller.requestContext.valueExists("year") and (not isNumeric(caller.requestContext.getValue("year")) or val(caller.requestContext.getValue("year")) is not caller.requestContext.getValue("year"))>
	<cfset structDelete(request.reqCollection,"year")>
</cfif>

<cfif caller.requestContext.getValue("mode") is "day" and caller.requestContext.valueExists("day") and caller.requestContext.valueExists("month") and caller.requestContext.getValue("month") gte 1 and caller.requestContext.getValue("month") lte 12 and caller.requestContext.valueExists("year")>
	<cfset params.byDay = val(caller.requestContext.getValue("day"))>
	<cfset params.byMonth = val(caller.requestContext.getValue("month"))>
	<cfset params.byYear = val(caller.requestContext.getValue("year"))>
	<cfset month = val(caller.requestContext.getValue("month"))>
	<cfset year = val(caller.requestContext.getValue("year"))>
<cfelseif caller.requestContext.getValue("mode") is "month" and caller.requestContext.valueExists("month") and caller.requestContext.getValue("month") gte 1 and caller.requestContext.getValue("month") lte 12 and caller.requestContext.valueExists("year")>
	<cfset params.byMonth = val(caller.requestContext.getValue("month"))>
	<cfset params.byYear = val(caller.requestContext.getValue("year"))>
	<cfset month = val(caller.requestContext.getValue("month"))>
	<cfset year = val(caller.requestContext.getValue("year"))>
<cfelseif caller.requestContext.getValue("mode") is "cat" and caller.requestContext.valueExists("catid")>
	<cfset params.byCat = caller.requestContext.getValue("catid")>
<cfelseif caller.requestContext.getValue("mode") is "search" and (caller.requestContext.valueExists("search"))>
<!---	All in request Collection now.
	<cfif caller.requestContext.valueExists("search")>
		<cfset form.search = url.search>
	</cfif> --->
	<cfset params.searchTerms = htmlEditFormat(caller.requestContext.getValue("search"))>
	<!--- dont log pages --->
	<cfif caller.requestContext.getValue("startrow") neq 1>
		<cfset params.dontlogsearch = true>
	</cfif>
<cfelseif caller.requestContext.getValue("mode") is "entry" and caller.requestContext.valueExists("entry")>
	<cfset params.byEntry = caller.requestContext.getValue("entry")>
<cfelseif caller.requestContext.getValue("mode") is "alias" and caller.requestContext.valueExists("alias") and len(trim(caller.requestContext.getValue("alias")))>
	<cfset params.byAlias = caller.requestContext.getValue("alias")>
<cfelse>
	<!--- For default view, limit by date and max entries --->
	<cfset params.lastXDays = 30>
	<cfset caller.requestContext.setValue("mode","")>
</cfif>

<cfset caller[attributes.r_params] = params>

<cfexit method="exitTag">
