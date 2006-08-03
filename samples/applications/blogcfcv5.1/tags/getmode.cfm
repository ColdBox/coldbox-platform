<!---
	Name         : c:\projects\blog\client\tags\getmode.cfm
	Author       : Raymond Camden 
	Created      : 02/09/06
	Last Updated : 
	History      : 
	
	Updated by Luis Majano for ColdBox
--->
<!--- Since this page is called as a module, it has its own scope, So I add a reference to the controller. --->
<cfif caller.getValue("mode","") eq "">
	<cfset caller.setValue("mode","")>
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
<cfif caller.getValue("startrow",1) eq 1>
	<cfset caller.setValue("startrow",1)>
</cfif>
<cfif not isNumeric(caller.getValue("startrow")) or caller.getValue("startrow") lte 0 or round(caller.getValue("startrow")) neq caller.getValue("startrow")>
	<cfset caller.setValue("startrow",1)>
</cfif>

<!--- Handle cleaning of day, month, year --->
<cfif caller.valueExists("day") and (not isNumeric(caller.getValue("day")) or val(caller.getValue("day")) is not caller.getValue("day"))>
	<cfset structDelete(request.reqCollection,"day")>
</cfif>
<cfif caller.valueExists("month") and (not isNumeric(caller.getValue("month")) or val(caller.getValue("month")) is not caller.getValue("month"))>
	<cfset structDelete(request.reqCollection,"month")>
</cfif>
<cfif caller.valueExists("year") and (not isNumeric(caller.getValue("year")) or val(caller.getValue("year")) is not caller.getValue("year"))>
	<cfset structDelete(request.reqCollection,"year")>
</cfif>

<cfif caller.getValue("mode") is "day" and caller.valueExists("day") and caller.valueExists("month") and caller.getValue("month") gte 1 and caller.getValue("month") lte 12 and caller.valueExists("year")>
	<cfset params.byDay = val(caller.getValue("day"))>
	<cfset params.byMonth = val(caller.getValue("month"))>
	<cfset params.byYear = val(caller.getValue("year"))>
	<cfset month = val(caller.getValue("month"))>
	<cfset year = val(caller.getValue("year"))>
<cfelseif caller.getValue("mode") is "month" and caller.valueExists("month") and caller.getValue("month") gte 1 and caller.getValue("month") lte 12 and caller.valueExists("year")>
	<cfset params.byMonth = val(caller.getValue("month"))>
	<cfset params.byYear = val(caller.getValue("year"))>
	<cfset month = val(caller.getValue("month"))>
	<cfset year = val(caller.getValue("year"))>
<cfelseif caller.getValue("mode") is "cat" and caller.valueExists("catid")>
	<cfset params.byCat = caller.getValue("catid")>
<cfelseif caller.getValue("mode") is "search" and (caller.valueExists("search"))>
<!---	All in request Collection now.
	<cfif caller.valueExists("search")>
		<cfset form.search = url.search>
	</cfif> --->
	<cfset params.searchTerms = htmlEditFormat(caller.getValue("search"))>
	<!--- dont log pages --->
	<cfif caller.getValue("startrow") neq 1>
		<cfset params.dontlogsearch = true>
	</cfif>
<cfelseif caller.getValue("mode") is "entry" and caller.valueExists("entry")>
	<cfset params.byEntry = caller.getValue("entry")>
<cfelseif caller.getValue("mode") is "alias" and caller.valueExists("alias") and len(trim(caller.getValue("alias")))>
	<cfset params.byAlias = caller.getValue("alias")>
<cfelse>
	<!--- For default view, limit by date and max entries --->
	<cfset params.lastXDays = 30>
	<cfset caller.setValue("mode","")>
</cfif>

<cfset caller[attributes.r_params] = params>

<cfexit method="exitTag">
