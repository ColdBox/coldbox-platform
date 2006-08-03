<!--- Account Actions view --->
<cfset isLoggedIn = getValue("isLoggedIn",false)>
<cfset username = getValue("username","")>
	
<cfif IsLoggedIn>
	 Logged in as <cfoutput><strong>#username#</strong></cfoutput>&nbsp;
	 (<a href="javascript:doEvent('ehUser.doLogout','centercontent',{})"><strong>Sign out</strong></a>)
<cfelse>
	<a href="javascript:doEvent('ehUser.dspLogin','centercontent',{})"><strong>Sign-in</strong></a>&nbsp;&nbsp;&nbsp;
	<a href="javascript:doEvent('ehUser.dspSignUp','centercontent',{})"><strong>Create an Account</strong></a>
</cfif>