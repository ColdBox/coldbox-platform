<cfset stime = "May-13-2007 06:01:02 PM ">
<cfset minutes = dateDiff("n", stime, now() )>
<cfoutput>#stime#</cfoutput><br>
<cfoutput>#now()#</cfoutput><br>
<cfoutput>#minutes#</cfoutput>
