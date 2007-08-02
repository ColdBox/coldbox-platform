<div id="topMenu">
<cfif getPlugin('sessionstorage').exists('loggedIn') and getPlugin('sessionstorage').getVar('loggedIn')>
	<a href="index.cfm?event=ehAccount.doLogout">Logout</a>
<cfelse>
	<a href="index.cfm?event=ehAccount.dspLogin">Login</a>
</cfif>
</div>