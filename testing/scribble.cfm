<cfset test = new coldbox.system.cache.providers.CFProvider()>
<cfdump var="#test#">

<cfset cachePut("test",now())>
<cfset mdata = cacheGetSession("object")>

<cfdump var="#mdata#">
<cfdump var="#cacheGetAllIds()#">

<cfset mdata.removeQuiet("TEST")>
<cfdump var="#cacheGetAllIds()#">

