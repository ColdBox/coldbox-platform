<cfset user = structnew()>
<cfset user.uid = createUUID()>
<cfset user.username = "admin">
<cfset user.password = hash("admin","SHA")>
<cfdump var="#user#">

<cfxml variable="userxml">
<cfoutput>
<users>
	<user id="#user.uid#" username="#user.username#" password="#user.password#" />
</users>
</cfoutput>
</cfxml>
<cffile action="write" file="#ExpandPath(".")#/users.xml.cfm" output="#userxml#">