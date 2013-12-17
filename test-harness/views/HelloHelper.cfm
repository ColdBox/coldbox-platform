<cffunction name="RenderToday" access="public" returntype="string" hint="Render Today Helper" output="false" >
	<cfreturn dateformat(now(),"full") & " " & timeformat(now(),"full")>
</cffunction>