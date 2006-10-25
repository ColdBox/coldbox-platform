<cfsetting enablecfoutputonly=true>
<!---
	Name         : messages.cfm
	Author       : Raymond Camden 
	Created      : June 10, 2004
	Last Updated : October 10, 2005
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
	Purpose		 : Displays messages for a thread
--->

<!--- Get References --->
<cfset data = getValue("data")>
<!--- Displays pagination on right side, plus left side buttons for threads --->
<cfmodule template="../tags/pagination.cfm" pages="#Getvalue("pages")#" mode="messages" />

<!--- Now display the table. This changes based on what our data is. --->
<cfoutput>
<a name="top" />
<p>
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
		<cfloop query="data" startrow="#(getValue("page")-1)*application.settings.perpage+1#" endrow="#(getValue("page")-1)*application.settings.perpage+application.settings.perpage#">
			<cfset uinfo = request.udf.cachedUserInfo(username)>
			<tr class="tableRow#currentRow mod 2#" valign="top">
				<td width="170" class="tableMessageCell" rowspan="2"><b>#username#</b><br>
				#uInfo.rank#<br><br>
				<b>Joined:</b> #dateFormat(uInfo.dateCreated,"mm/dd/yy")#<br>
				<b>Posts:</b> #uInfo.postcount#</td>
				<td class="tableMessageCellRight">
					<a name="#currentRow#"></a>
					<cfif currentRow is recordCount><a name="last"></a></cfif>
					<b>#title#</b><br>
					#dateFormat(posted,"mm/dd/yy")# #timeFormat(posted,"h:mm tt")#<br><br>
					#request.udf.paragraphFormat2(request.udf.activateURL(body))#
					<cfif request.udf.isLoggedOn() and application.utils.isUserInAnyRole("forumsadmin,forumsmoderator")>
						<p align="right"><a href="index.cfm?event=#getValue("xehMessageEdit")#&id=#id#">[Edit Post]</a></p>
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
	<cfif valueExists("posterrors")>
	<tr class="tableRowMain">
		<td>
		#getPlugin("messagebox").renderit()#
		</td>
	</tr>
	</cfif>
	<tr class="tableRowMain">
		<td>
		<form action="#cgi.script_name#?##newpost" method="post">
		<input type="hidden" name="event" value="#getValue("xehMessagePost")#">
		<input type="hidden" name="threadid" value="#getValue("threadid")#">
		<table>
			<cfif not request.udf.isLoggedOn()>
				<cfset thisPage = cgi.script_name & "?" & cgi.query_string & "&##newpost">
				<cfset link = "index.cfm?event=#getValue("xehLogin")#&ref=#urlEncodedFormat(thisPage)#">

				<tr>
					<td>Please <a href="#link#">login</a> to post a response.</td>
				</tr>
			<cfelseif application.utils.isUserInAnyRole("forumsadmin,forumsmoderator") or not getValue("readonly")>
				<tr>
					<td><b>Title: </b></td>
					<td><input type="text" name="post_title" value="#getValue("post_title","")#" class="formBox" maxlength="50"></td>
				</tr>
				<tr>
					<td colspan="2"><b>Body: </b><br>
					<textarea name="body" cols="50" rows="20">#getValue("body","")#</textarea></td>
				</tr>
				<tr>
					<td><b>Subscribe to Thread: </b></td>
					<td><select name="subscribe">
					<option value="true" <cfif getValue("subscribe",true)>selected</cfif>>Yes</option>
					<option value="false" <cfif not getValue("subscribe",true)>selected</cfif>>No</option>
					</select></td>
				</tr>
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
