<cfset pool = CreateObject("java","java.util.concurrent.ConcurrentHashMap").init()>

<cfoutput>

<cfset stime = getTickcount()>
<cfloop from="1" to="500" index="i">
	<cfset pool["test"] = i>
</cfloop>
time: #getTickCount()- stime#<br /><br />


<cfset stime = getTickcount()>
<cfloop from="1" to="500" index="i">
	<cfset pool.put("test", i)>
</cfloop>
time: #getTickCount()- stime#

</cfoutput>