<p style="line-height:20px;">
	<div class="nicebox">
	<cfoutput>
	<cfif Session.userID eq "">
		<div style="margin-bottom:10px;">
			<strong>Welcome To ColdBox Reader</strong>
		</div>

		To Add a Feed, your must first <a href="javascript:doEvent('#getValue("xehLogin")#','centercontent',{})"><strong>Sign-in</strong></a> to your account
		or <a href="javascript:doEvent('#getValue("xehSignup")#','centercontent',{})"><strong>Create an Account</strong></a>.
	<cfelse>
		<div style="margin-bottom:10px;">
			<strong>Welcome back to your ColdBox Reader.</strong>
		</div>
		<strong>Your Email:</strong><br>
		#session.email#<Br><br />

		<strong>Last Login:</strong><br />
		#dateFormat(session.lastLogin, "MMM DD, YYYY")# at  #TimeFormat(session.lastLogin, "hh:MM:SS tt")#<br /><br />

		<strong>Account Created On:</strong><br />
		#dateFormat(session.CreatedOn, "MMM DD, YYYY")#  at  #TimeFormat(session.CreatedOn, "hh:MM:SS tt")#<br />
	</cfif>
	</cfoutput>
	</div>
</p>