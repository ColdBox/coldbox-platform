<!---
	Name         : c:\projects\blog\client\tags\getmode.cfm
	Author       : Raymond Camden 
	Created      : 02/09/06
	Last Updated : 
	History      : 
	
	Updated by Luis Majano for ColdBox
--->
<!--- Since this page is called as a module, it has its own scope, So I add a reference to the controller. --->
<cfif caller.Context.getValue("mode","") eq "">
	<cfset caller.Context.setValue("mode","")>
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
<cfif caller.Context.getValue("startrow",1) eq 1>
	<cfset caller.Context.setValue("startrow",1)>
</cfif>
<cfif not isNumeric(caller.Context.getValue("startrow")) or caller.Context.getValue("startrow") lte 0 or round(caller.Context.getValue("startrow")) neq caller.Context.getValue("startrow")>
	<cfset caller.Context.setValue("startrow",1)>
</cfif>

<!--- Handle cleaning of day, month, year --->
<cfif caller.Context.valueExists("day") and (not isNumeric(caller.Context.getValue("day")) or val(caller.Context.getValue("day")) is not caller.Context.getValue("day"))>
	<cfset structDelete(request.reqCollection,"day")>
</cfif>
<cfif caller.Context.valueExists("month") and (not isNumeric(caller.Context.getValue("month")) or val(caller.Context.getValue("month")) is not caller.Context.getValue("month"))>
	<cfset structDelete(request.reqCollection,"month")>
</cfif>
<cfif caller.Context.valueExists("year") and (not isNumeric(caller.Context.getValue("year")) or val(caller.Context.getValue("year")) is not caller.Context.getValue("year"))>
	<cfset structDelete(request.reqCollection,"year")>
</cfif>

<cfif caller.Context.getValue("mode") is "day" and caller.Context.valueExists("day") and caller.Context.valueExists("month") and caller.Context.getValue("month") gte 1 and caller.Context.getValue("month") lte 12 and caller.Context.valueExists("year")>
	<cfset params.byDay = val(caller.Context.getValue("day"))>
	<cfset params.byMonth = val(caller.Context.getValue("month"))>
	<cfset params.byYear = val(caller.Context.getValue("year"))>
	<cfset month = val(caller.Context.getValue("month"))>
	<cfset year = val(caller.Context.getValue("year"))>
<cfelseif caller.Context.getValue("mode") is "month" and caller.Context.valueExists("month") and caller.Context.getValue("month") gte 1 and caller.Context.getValue("month") lte 12 and caller.Context.valueExists("year")>
	<cfset params.byMonth = val(caller.Context.getValue("month"))>
	<cfset params.byYear = val(caller.Context.getValue("year"))>
	<cfset month = val(caller.Context.getValue("month"))>
	<cfset year = val(caller.Context.getValue("year"))>
<cfelseif caller.Context.getValue("mode") is "cat" and caller.Context.valueExists("catid")>
	<cfset params.byCat = caller.Context.getValue("catid")>
<cfelseif caller.Context.getValue("mode") is "search" and (caller.Context.valueExists("search"))>
<!---	All in request Collection now.
	<cfif caller.Context.valueExists("search")>
		<cfset form.search = url.search>
	</cfif> --->
	<cfset params.searchTerms = htmlEditFormat(caller.Context.getValue("search"))>
	<!--- dont log pages --->
	<cfif caller.Context.getValue("startrow") neq 1>
		<cfset params.dontlogsearch = true>
	</cfif>
<cfelseif caller.Context.getValue("mode") is "entry" and caller.Context.valueExists("entry")>
	<cfset params.byEntry = caller.Context.getValue("entry")>
<cfelseif caller.Context.getValue("mode") is "alias" and caller.Context.valueExists("alias") and len(trim(caller.Context.getValue("alias")))>
	<cfset params.byAlias = caller.Context.getValue("alias")>
<cfelse>
	<!--- For default view, limit by date and max entries --->
	<cfset params.lastXDays = 30>
	<cfset caller.Context.setValue("mode","")>
</cfif>

<cfset caller[attributes.r_params] = params>

<cfexit method="exitTag">
