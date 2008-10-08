<!---
	Name         : c:\projects\blog\client\tags\getmode.cfm
	Author       : Raymond Camden 
	Created      : 02/09/06
	Last Updated : 
	History      : 
	
	Updated by Luis Majano for ColdBox
--->
<!--- Since this page is called as a module, it has its own scope, So I add a reference to the controller. --->
<cfif caller.Event.getValue("mode","") eq "">
	<cfset caller.Event.setValue("mode","")>
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
<cfif caller.Event.getValue("startrow",1) eq 1>
	<cfset caller.Event.setValue("startrow",1)>
</cfif>
<cfif not isNumeric(caller.Event.getValue("startrow")) or caller.Event.getValue("startrow") lte 0 or round(caller.Event.getValue("startrow")) neq caller.Event.getValue("startrow")>
	<cfset caller.Event.setValue("startrow",1)>
</cfif>

<!--- Handle cleaning of day, month, year --->
<cfif caller.Event.valueExists("day") and (not isNumeric(caller.Event.getValue("day")) or val(caller.Event.getValue("day")) is not caller.Event.getValue("day"))>
	<cfset structDelete(request.reqCollection,"day")>
</cfif>
<cfif caller.Event.valueExists("month") and (not isNumeric(caller.Event.getValue("month")) or val(caller.Event.getValue("month")) is not caller.Event.getValue("month"))>
	<cfset structDelete(request.reqCollection,"month")>
</cfif>
<cfif caller.Event.valueExists("year") and (not isNumeric(caller.Event.getValue("year")) or val(caller.Event.getValue("year")) is not caller.Event.getValue("year"))>
	<cfset structDelete(request.reqCollection,"year")>
</cfif>

<cfif caller.Event.getValue("mode") is "day" and caller.Event.valueExists("day") and caller.Event.valueExists("month") and caller.Event.getValue("month") gte 1 and caller.Event.getValue("month") lte 12 and caller.Event.valueExists("year")>
	<cfset params.byDay = val(caller.Event.getValue("day"))>
	<cfset params.byMonth = val(caller.Event.getValue("month"))>
	<cfset params.byYear = val(caller.Event.getValue("year"))>
	<cfset month = val(caller.Event.getValue("month"))>
	<cfset year = val(caller.Event.getValue("year"))>
<cfelseif caller.Event.getValue("mode") is "month" and caller.Event.valueExists("month") and caller.Event.getValue("month") gte 1 and caller.Event.getValue("month") lte 12 and caller.Event.valueExists("year")>
	<cfset params.byMonth = val(caller.Event.getValue("month"))>
	<cfset params.byYear = val(caller.Event.getValue("year"))>
	<cfset month = val(caller.Event.getValue("month"))>
	<cfset year = val(caller.Event.getValue("year"))>
<cfelseif caller.Event.getValue("mode") is "cat" and caller.Event.valueExists("catid")>
	<cfset params.byCat = caller.Event.getValue("catid")>
<cfelseif caller.Event.getValue("mode") is "search" and (caller.Event.valueExists("search"))>
<!---	All in request Collection now.
	<cfif caller.Event.valueExists("search")>
		<cfset form.search = url.search>
	</cfif> --->
	<cfset params.searchTerms = htmlEditFormat(caller.Event.getValue("search"))>
	<!--- dont log pages --->
	<cfif caller.Event.getValue("startrow") neq 1>
		<cfset params.dontlogsearch = true>
	</cfif>
<cfelseif caller.Event.getValue("mode") is "entry" and caller.Event.valueExists("entry")>
	<cfset params.byEntry = caller.Event.getValue("entry")>
<cfelseif caller.Event.getValue("mode") is "alias" and caller.Event.valueExists("alias") and len(trim(caller.Event.getValue("alias")))>
	<cfset params.byAlias = caller.Event.getValue("alias")>
<cfelse>
	<!--- For default view, limit by date and max entries --->
	<cfset params.lastXDays = 30>
	<cfset caller.Event.setValue("mode","")>
</cfif>

<cfset caller[attributes.r_params] = params>

<cfexit method="exitTag">
