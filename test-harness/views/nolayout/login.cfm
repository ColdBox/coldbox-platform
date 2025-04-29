<cfoutput>
	<form action="/login" method="post">
		<label for="username">Username:</label>
		<input type="text" id="username" name="username" required>

		<p>&nbsp;</p>

		<label for="password">Password:</label>
		<input type="password" id="password" name="password" required>

		<p>&nbsp;</p>

		<button type="submit">Login</button>
	</form>
</cfoutput>