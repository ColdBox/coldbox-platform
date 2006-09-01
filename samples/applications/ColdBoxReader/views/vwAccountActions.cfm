<!--- Account Actions view --->
<cfset isLoggedIn = getValue("isLoggedIn",false)>
<cfset username = getValue("username","")>

<cfoutput>	
<cfif IsLoggedIn>
	 Logged in as <strong>#username#</strong>&nbsp;
	 (<a href="javascript:doEvent('#getValue("xehLogout")#','centercontent',{})"><strong>Sign out</strong></a>)
<cfelse>
	<a href="javascript:doEvent('#getValue("xehLogin")#','centercontent',{})"><strong>Sign-in</strong></a>&nbsp;&nbsp;&nbsp;
	<a href="javascript:doEvent('#getValue("xehSignup")#','centercontent',{})"><strong>Create an Account</strong></a>
</cfif>
</cfoutput>