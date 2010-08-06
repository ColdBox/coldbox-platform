<cfset cachePut("test",now(), createTimeSpan(0,0,3,0))>
<cfset test = cacheGet("test")>

<cfdump var="#cacheGetMetadata("test")#">
