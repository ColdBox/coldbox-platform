<cfoutput>
<cfset cachePut("test",now())>
<cfdump var="#cacheGetMetadata("test","object")#">

</cfoutput>