<cfset sTime = getTickCount()>
<cfset output = new Sublime().run()>
<textarea rows="30" cols="160">
<cfoutput>#output#</cfoutput>
</textarea>
<cfdump var="#getTickCount() - sTime# ms" label="Total Time">