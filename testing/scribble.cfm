<cfset pool = CreateObject("java","java.util.concurrent.ConcurrentHashMap").init()>

<cfset refLocal = {}>

<cfset refLocal.test1 = pool.get("hello")>
<cfset refLocal.test2 = pool["hello"]>

<cfdump var="#refLocal#">
<cfoutput>



</cfoutput>