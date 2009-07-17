<!---
	Name         : c:\projects\blog\org\camden\blog\Application.cfm
	Author       : Raymond Camden 
	Created      : 01/22/06
	Last Updated : 
	History      : 
--->

<cfif listlast(cgi.script_name, "/") is "blog.ini.cfm">
	<cfabort>
</cfif>
