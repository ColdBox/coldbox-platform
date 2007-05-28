<cfset obj = CreateObject("component","updatews")>

<cfset results = obj.GetUpdateInfo("1.1.0","1.1.0")>

<cfdump var="#results#">