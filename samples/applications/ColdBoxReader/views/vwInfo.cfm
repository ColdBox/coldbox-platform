<p style="line-height:20px;">
	<div class="nicebox">
	<cfoutput>
		
	<cfif not Session.oUserBean.getVerified()>
		<div style="margin-bottom:10px;">
			<strong>Welcome To ColdBox Reader</strong>
		</div>

		To Add a Feed, your must first <a href="javascript:doEvent('#getValue("xehLogin")#','centercontent',{})"><strong>Sign-in</strong></a> to your account
		or <a href="javascript:doEvent('#getValue("xehSignup")#','centercontent',{})"><strong>Create an Account</strong></a>.
	<cfelse>
		<div style="margin-bottom:10px;">
			<strong>Welcome to your ColdBox Reader.</strong>
		</div>
		<strong>Your Email:</strong><br>
		#session.oUserBean.getemail()#<Br><br />

		<strong>Last Login:</strong><br />
		#dateFormat(session.oUserBean.getlastLogin(), "MMM DD, YYYY")# at  #TimeFormat(session.oUserBean.getlastLogin(), "hh:MM:SS tt")#<br /><br />

		<strong>Account Created On:</strong><br />
		#dateFormat(session.oUserBean.getCreatedOn(), "MMM DD, YYYY")#  at  #TimeFormat(session.oUserBean.getCreatedOn(), "hh:MM:SS tt")#<br />
	</cfif>
	</cfoutput>
	</div>
</p>