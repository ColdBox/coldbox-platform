<p style="line-height:20px;">
	<div class="nicebox" id="infobox" style="display:block;">
	<cfoutput>
		
	<cfif not rc.oUserBean.getVerified()>
		<div style="margin-bottom:10px;">
			<strong>Welcome To ColdBox Reader</strong>
		</div>

		To Add a Feed, your must first <a href="javascript:doEvent('#Event.getValue("xehLogin")#','centercontent',{})"><strong>Sign-in</strong></a> to your account
		or <a href="javascript:doEvent('#Event.getValue("xehSignup")#','centercontent',{})"><strong>Create an Account</strong></a>.
	<cfelse>
		<div style="margin-bottom:10px;">
			<strong>Welcome to your ColdBox Reader.</strong>
		</div>
		<strong>Your Email:</strong><br>
		#rc.oUserBean.getemail()#<Br><br />

		<strong>Last Login:</strong><br />
		#dateFormat(rc.oUserBean.getlastLogin(), "MMM DD, YYYY")# at  #TimeFormat(rc.oUserBean.getlastLogin(), "hh:MM:SS tt")#<br /><br />

		<strong>Account Created On:</strong><br />
		#dateFormat(rc.oUserBean.getCreatedOn(), "MMM DD, YYYY")#  at  #TimeFormat(rc.oUserBean.getCreatedOn(), "hh:MM:SS tt")#<br />
		
		<div align="center">
		<br />
		<input type="button" value="Update Profile" name="button" onclick="$('infobox').style.display='none';$('infoupdatebox').style.display='block'" />
		</div>
	</cfif>
	</cfoutput>
	</div>
	
	<cfif rc.oUserBean.getVerified()>
	
		<div class="nicebox" id="infoupdatebox" style="display:none;">
		<cfoutput>
		
			<form name="frm" method="post" action="javascript:doFormEvent('#Event.getValue("xehUpdateProfile")#','leftcontent1',document.frm)">
			<p>
				Update your ColdBox Reader profile below.
			</p>
			<table>
				<tr>
					<td><b>Email Address:</b></td>
				</tr>
				<tr>
					<td><input type="text" name="email" value="#rc.oUserBean.getEmail()#" size="20" /></td>
				</tr>
				<tr>
					<td><b>New Password:</b></td>
				</tr>
				<tr>
					<td><input type="password" name="password" value="" size="20" /></td>
				</tr>
				<tr>
					<td><b>Confirm Password:</b></td>
				</tr>
				<tr>
					<td><input type="password" name="confirmpassword" value="" size="20" /></td>
				</tr>
				<tr><td colspan="2">&nbsp;</td></tr>
				
			</table>
			
			<div align="center">
			<input type="button" value="Cancel" name="button" onclick="$('infobox').style.display='block';$('infoupdatebox').style.display='none'" />
			<input type="submit" value="Save" />
			</div>
		</form>
		
		</cfoutput>
		</div>
		
	</cfif>
	
</p>