<cfsetting enablecfoutputonly=true>
<!---
	Name         : messages.cfm
	Author       : Raymond Camden 
	Created      : June 10, 2004
	Last Updated : November 6, 2006
	History      : Support for UUID (rkc 1/27/05)
				   Update to allow posting here (rkc 3/31/05)
				   Fixed code that gets # of pages (rkc 4/8/05)
				   Hide the darn error msg if errors is blank, links to messages (rkc 7/15/05)
				   Form posts so that if error, you go back down to form. If no error, you cflocate to top (rkc 7/29/05)
				   Have subscribe option (rkc 7/29/05)
				   Refresh user cache on post, change links a bit (rkc 8/3/05)				
				   Fix typo (rkc 8/9/05)
				   Fix pages. Add anchor for last post (rkc 9/15/05)
				   It's possible form.title and form.body may not exist and my code didn't handle it (rkc 10/7/05)
				   IE cflocation bug fix, ensure logged on before posting (rkc 10/10/05)
				   Simple size change (rkc 7/27/06)
				   gravatar, sig, attachments (rkc 11/3/06)
				   bug when no attachment (rkc 11/6/06)
	Purpose		 : Displays messages for a thread
--->

<!--- Get References --->

<cfset data = Event.getValue("data")>
<!--- Displays pagination on right side, plus left side buttons for threads --->
<cfmodule template="../tags/pagination.cfm" pages="#Event.getValue("pages")#" mode="messages" />

<!--- Now display the table. This changes based on what our data is. --->
<cfoutput>
<a name="top" />
<p>
<cfif not getPlugin("messagebox").isEmpty()>
<h3>Please scroll down to correct your error(s):</h3>
#getPlugin("messagebox").renderit(false)#<br>
</cfif>
	
<table width="100%" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td colspan="2" class="tableHeader">Thread: #request.thread.name#</td>
	</tr>
	
	<tr class="tableSubHeader">
		<td class="tableSubHeader" colspan="2">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
				<td><b>Created on:</b> #dateFormat(request.thread.dateCreated,"mm/dd/yy")# #timeFormat(request.thread.dateCreated,"hh:mm tt")#</td>
				<td align="right"><b>Replies:</b> #max(0,data.recordCount-1)#</td>
				</tr>
			</table>
		</td>
	</tr>
	
	<cfif data.recordCount>
		<cfloop query="data" startrow="#(rc.page-1)*application.settings.perpage+1#" endrow="#(rc.page-1)*application.settings.perpage+application.settings.perpage#">
			<cfset uinfo = cachedUserInfo(username)>
			<tr class="tableRow#currentRow mod 2#" valign="top">
				<td width="170" class="tableMessageCell" rowspan="2"><b>#username#</b><br>
				#uInfo.rank#<br>
				<cfif application.settings.allowgravatars>
				<img src="http://www.gravatar.com/avatar.php?gravatar_id=#hash(uinfo.emailaddress)#&amp;rating=PG&amp;size=80&amp;default=#application.settings.rooturl#/images/gravatar.gif" alt="#username#'s Gravatar" border="0">
				</cfif>
				<br>
				<b>Joined:</b> #dateFormat(uInfo.dateCreated,"mm/dd/yy")#<br>
				<b>Posts:</b> #uInfo.postcount#</td>
				<td class="tableMessageCellRight">
					<a name="#currentRow#"></a>
					<cfif currentRow is recordCount><a name="last"></a></cfif>
					<b>#title#</b><br>
					#dateFormat(posted,"mm/dd/yy")# #timeFormat(posted,"h:mm tt")#<br>
					<cfif len(attachment)>Attachment: <a href="index.cfm?event=#Event.getValue("xehAttachment")#&id=#id#">#attachment#</a><br></cfif>
					<br>
					<!---
					#paragraphFormat2(activateURL(body))#
					--->
					#application.message.render(body)#
					
					<cfif len(uinfo.signature)><div class="signature">#uinfo.signature#</div></cfif>
					
					<cfif isLoggedOn() and application.utils.isUserInAnyRole2("forumsadmin,forumsmoderator")>
						<p align="right"><a href="index.cfm?event=#Event.getValue("xehMessageEdit")#&id=#id#">[Edit Post]</a></p>
					</cfif>
				</td>
			</tr>
			<tr>
				<td class="tableMessageCellRight" align="right">
				<cfif isBoolean(cgi.server_port_secure) and cgi.server_port_secure>
					<cfset pre = "https">
				<cfelse>
					<cfset pre = "http">
				</cfif>
				<cfset link = "#pre#://#cgi.server_name##cgi.script_name#?#cgi.query_string####currentrow#">
				<span class="linktext"><a href="#link#">Link</a> | <a href="##top">Top</a> | <a href="##bottom">Bottom</a></span>
				</td>
			</tr>
		</cfloop>
	<cfelse>
		<tr class="tableRow1">
			<td colspan="2">Sorry, but there are no messages available for this thread.</td>
		</tr>
	</cfif>
</table>
</p>
<a name="bottom" />
</cfoutput>

<cfoutput>
<a name="newpost" />
<p>
<table width="100%" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td class="tableHeader">New Post</td>
	</tr>
	<cfif Event.valueExists("posterrors") or not getPlugin("messagebox").isEmpty()>
	<tr class="tableRowMain">
		<td>
		#getPlugin("messagebox").renderit()#
		</td>
	</tr>
	</cfif>
	<tr class="tableRowMain">
		<td>
		<form action="#cgi.script_name#?##newpost" method="post" enctype="multipart/form-data">
		<input type="hidden" name="event" value="#Event.getValue("xehMessagePost")#">
		<input type="hidden" name="threadid" value="#Event.getValue("threadid")#">
		<table>
			<cfif not isLoggedOn()>
				<cfset thisPage = cgi.script_name & "?" & cgi.query_string & "&##newpost">
				<cfset link = "index.cfm?event=#Event.getValue("xehLogin")#&ref=#urlEncodedFormat(thisPage)#">

				<tr>
					<td>Please <a href="#link#">login</a> to post a response.</td>
				</tr>
			<cfelseif application.utils.isUserInAnyRole2("forumsadmin,forumsmoderator") or not Event.getValue("readonly")>
				<tr>
					<td><b>Title: </b></td>
					<td><input type="text" name="post_title" value="#Event.getValue("post_title")#" class="formBox"></td>
				</tr>
				<tr>
					<td colspan="2"><b>Body: </b><br>
					<p>
					#application.message.renderHelp()#
					</p>
					<textarea name="body" cols="50" rows="20">#Event.getValue("body")#</textarea></td>
				</tr>
				<tr>
					<td><b>Subscribe to Thread: </b></td>
					<td><select name="subscribe">
					<option value="true" <cfif Event.getValue("subscribe")>selected</cfif>>Yes</option>
					<option value="false" <cfif not Event.getValue("subscribe")>selected</cfif>>No</option>
					</select></td>
				</tr>
				<cfif isBoolean(request.forum.attachments) and request.forum.attachments>
				<tr>
					<td><b>Attach File:</b></td>
					<td>
					<input type="file" name="attachment">
					<cfif len(rc.oldattachment)>
					<input type="hidden" name="oldattachment" value="#rc.oldattachment#">
					<input type="hidden" name="filename" value="#rc.filename#">
					<br>
					File already attached: #rc.oldattachment#
					</cfif>
					</td>
				</tr>
				</cfif>
				<tr>
					<td>&nbsp;</td>
					<td align="right"><cfif not isDefined("request.thread")><input type="image" src="images/btn_new_topic.gif" alt="New Topic" title="New Topic" width="71" height="19" name="post"><cfelse><input type="image" src="images/btn_reply.gif" alt="Reply" title="Reply" width="52" height="19" name="post"></cfif></td>
				</tr>
			<cfelse>
				<tr>
					<td><b>Sorry, but this area is readonly.</b></td>
				</tr>
			</cfif>
		</table>
		</form>
		</td>
	</tr>
</table>
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>
