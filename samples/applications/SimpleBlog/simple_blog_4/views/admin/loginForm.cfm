<cfoutput>
<div id="loginForm">
<h1>Login</h1>
<p>Please login using your username and password.</p>

<!--- display any messages in the event --->
#getPlugin("messagebox").renderit()#

<form name="loginForm" method="POST" action="#event.buildLink('admin/doLogin')#">
	<p>Username:<br/>
	<input type="text" name="username">
	<p>Password:<br/>
	<input type="password" name="password">
	<p>
	<input type="submit" value="Login" name="submit">
</form>
</div>
</cfoutput>