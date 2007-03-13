<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : calendar
	Author       : Raymond Camden + Paul Hastings
	Created      : February 11, 2003
	Last Updated : May 1, 2006
	History      : Reset history for version 5.0
	Purpose		 : Handles blog calendar
--->

<cfset offset = application.blog.getProperty("offset")>
<cfset now = dateAdd("h", offset, now())>

<!---<cfparam name="month" default="#month(now)#">
<cfparam name="year" default="#year(now)#"> --->
<cfset month = Event.getValue("month", month(now))>
<cfset year = Event.getValue("year", year(now))>

<cfmodule template="../../tags/podlayout.cfm" title="#getResource("calendar")#">

<cfscript>
	/* no idea why this was so hard to conceive
	Moved to UDF
	function getFirstWeekPAD(firstDOW) {
		var firstWeekPad=0;
		var weekStartsOn=getPlugin("i18n").weekStarts();
		switch (weekStartsON) {
			case 1:
				firstWeekPAD=firstDOW-1;
			break;
			case 2:
				firstWeekPAD=firstDOW-2;
				if (firstWeekPAD LT 0) firstWeekPAD=firstWeekPAD+7; // handle leap years
			break;
			case 7:
				firstWeekPAD=7-abs(firstDOW-7);
				if (firstWeekPAD EQ 7) firstWeekPAD=0;
			break;
		}
		return firstWeekPAD;
	}
	*/

	localizedDays=getPlugin("i18n").getLocalizedDays();
	localizedMonth=getPlugin("i18n").getLocalizedMonth(month);
	localizedYear=getPlugin("i18n").getLocalizedYear(year);
	firstDay=createDate(year,month,1);
	firstDOW=dayOfWeek(firstDay);
	dim=daysInMonth(firstDay);
	firstWeekPAD=getFirstWeekPAD(firstDOW);
	lastMonth=dateAdd("m",-1,firstDay);
	nextMonth=dateAdd("m",1,firstDay);
	dayList=application.blog.getActiveDays(year,month);
	dayCounter=1;
	rowCounter=1;
</cfscript>


<!--- swap navigation buttons if BIDI is true --->
<cfoutput>
	<div class="header">
	<cfif getPlugin("i18n").isBIDI()>
		<a href="#application.blog.getProperty("blogurl")#/#year(nextmonth)#/#month(nextmonth)#" rel="nofollow">&lt;&lt;</a>
		<a href="#application.blog.getProperty("blogurl")#/#year#/#month#" rel="nofollow">#localizedMonth# #localizedYear#</a>
		<a href="#application.blog.getProperty("blogurl")#/#year(lastmonth)#/#month(lastmonth)#" rel="nofollow">&gt;&gt;</a>
	<cfelse>
		<a href="#application.blog.getProperty("blogurl")#/#year(lastmonth)#/#month(lastmonth)#" rel="nofollow">&lt;&lt;</a>
		<a href="#application.blog.getProperty("blogurl")#/#year#/#month#" rel="nofollow">#localizedMonth# #localizedYear#</a>
		<a href="#application.blog.getProperty("blogurl")#/#year(nextmonth)#/#month(nextmonth)#" rel="nofollow">&gt;&gt;</a>
	</cfif>
	</div>
</cfoutput>
<cfoutput>
<table border=0 class="calendarTable" id="calendar">
<thead>
<tr>
	<!--- emit localized days in proper week start order --->
	<cfloop index="i" from="1" to="#arrayLen(localizedDays)#">
	<th>#localizedDays[i]#</th>
	</cfloop>
</tr>
</thead>
<tbody>
</cfoutput>
<!--- loop until 1st --->
<cfoutput><tr></cfoutput>
<cfloop index="x" from=1 to="#firstWeekPAD#">
	<cfoutput><td>&nbsp;</td></cfoutput>
</cfloop>

<!--- note changed loop to start w/firstWeekPAD+1 and evaluated vs dayCounter instead of X --->
<cfloop index="x" from="#firstWeekPAD+1#" to="7">
	<cfoutput><td <cfif month(now) eq month and dayCounter eq day(now) and year(now) eq year> class="calendarToday"</cfif>><cfif listFind(dayList,dayCounter)><a href="index.cfm?mode=day&day=#dayCounter#&month=#month#&year=#year#" rel="nofollow">#dayCounter#</a><cfelse>#dayCounter#</cfif></td></cfoutput>
	<cfset dayCounter = dayCounter + 1>
</cfloop>
<cfoutput></tr></cfoutput>
<!--- now loop until month days --->
<cfloop index="x" from="#dayCounter#" to="#dim#">
	<cfif rowCounter is 1>
		<cfoutput><tr></cfoutput>
	</cfif>
	<cfoutput>
		<td <cfif month(now) eq month and x eq day(now) and year(now) eq year> class="calendarToday"</cfif>>
		<cfif listFind(dayList,x)><a href="#application.blog.getProperty("blogurl")#/#year#/#month#/#x#" rel="nofollow">#x#</a><cfelse>#x#</cfif>
		</td>
	</cfoutput>
	<cfset rowCounter = rowCounter + 1>
	<cfif rowCounter is 8>
		<cfoutput></tr></cfoutput>
		<cfset rowCounter = 1>
	</cfif>
</cfloop>
<!--- now finish up last row --->
<cfif rowCounter GT 1> <!--- test if ran out of days --->
	<cfloop index="x" from="#rowCounter#" to=7>
		<cfoutput><td>&nbsp;</td></cfoutput>
	</cfloop>
	<cfoutput></tr></cfoutput>
</cfif>
<cfoutput>
</tbody>
</table>
</cfoutput>

</cfmodule>

<cfsetting enablecfoutputonly=false>