<cfsetting enablecfoutputonly=true>
<!---
	Name         : profile.cfm
	Author       : Raymond Camden 
	Created      : July 5, 2004
	Last Updated : November 3, 2006
	History      : Changes due to subscriptions (7/29/05)
				   Removed mappings (rkc 8/27/05)
				   title fix (rkc 8/4/06)
				   signature fix, email fix (rkc 11/3/06)
	Purpose		 : Displays form to edit your settings.
--->

<!--- Get collection references --->
<cfset user = Event.getValue("user")>
<cfset subs = Event.getValue("subs")>

<cfoutput>
<p>
<table width="500" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td class="tableHeader">Profile</td>
	</tr>
	<tr class="tableRowMain">
		<td>
		Please use the form below to edit your profile.
		<cfif Event.getValue("confirm","") eq "profile">
			#getPlugin("messagebox").renderit()#
		</cfif>
		</td>
	</tr>
	<tr class="tableRowMain">
		<td>
		<form action="#cgi.script_name#" method="post">
		<input type="hidden" name="event" value="#Event.getValue("xehSaveProfile")#">
		<table>
			<tr>
				<td><b>Username:</b></td>
				<td>#user.username#</td>
			</tr>
			<tr>
				<td><b>Email Address:</b></td>
				<td><input type="text" name="emailaddress" value="#user.emailaddress#" class="formBox"></td>
			</tr>
			<tr>
				<td><b>New Password:</b></td>
				<td><input type="password" name="password_new" class="formBox"></td>
			</tr>
			<tr>
				<td><b>Confirm Password:</b></td>
				<td><input type="password" name="password_confirm" class="formBox"></td>
			</tr>
			<tr valign="top">
				<td><b>Signature (1000 character max):</b></td>
				<td><textarea name="signature" class="formTextArea">#user.signature#</textarea></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td align="right"><input type="image" src="images/btn_save.gif" alt="Save" width="49" height="19" name="save"></td>
			</tr>
		</table>
		</form>
		</td>
	</tr>

</table>
</p>

<p>
<table width="500" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td class="tableHeader">Subscriptions</td>
	</tr>
	<cfif Event.getValue("confirm","") eq "subscribe">
	<tr class="tableRowMain">
		<td>
		#getPlugin("messagebox").renderit()#
		</td>
	</tr>
	</cfif>
	<tr class="tableRowMain">
		<td>
		<cfif subs.recordCount is 0>
			You are not currently subscribed to anything.
		<cfelse>
			The following are your subscription(s):
			<p>
			<table>
			<cfloop query="subs">
				<tr>
					<td>
					<cfif len(conferenceidfk)>
						<cfset data = application.conference.getConference(conferenceidfk)>
						<cfset label = "Conference">
						<cfset link = "index.cfm?event=#Event.getValue("xehForums")#&conferenceid=#conferenceidfk#">
					<cfelseif len(forumidfk)>
						<cfset data = application.forum.getForum(forumidfk)>
						<cfset label = "Forum">
						<cfset link = "index.cfm?event=#Event.getValue("xehThreads")#&forumid=#threadidfk#">
					<cfelse>
						<cfset data = application.thread.getThread(threadidfk)>
						<cfset label = "Thread">
						<cfset link = "index.cfm?event=#Event.getValue("xehMessages")#&threadid=#threadidfk#">
					</cfif>
					#label#:
					</td>
					<td><a href="#link#">#data.name#</a></td> 
					<td>[<a href="index.cfm?event=#Event.getValue("xehRemoveSub")#&removeSub=#id#">Unsubscribe</a>]</td>
			</cfloop>
			</table>
			</p>
		</cfif>
		</td>
	</tr>

</table>
</p>

</cfoutput>
	

<cfsetting enablecfoutputonly=false>
