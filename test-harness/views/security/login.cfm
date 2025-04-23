<cfoutput>
	<form action="/security/doLogin" method="post">
		<label for="username">Username:</label>
		<input type="text" id="username" name="username" required>

		<label for="password">Password:</label>
		<input type="password" id="password" name="password" required>

		<button type="submit">Login</button>
	</form>
</cfoutput>