<cfset myFeed = Event.getValue("myFeed","")>

<cfoutput>

<h1>Add New Feed</h1>

<cfif not Event.getValue("FeedValidated")>
	<form name="addform" id="addform" method="post" action="javascript:doFormEvent('#Event.getValue("xehNewFeed")#','centercontent',document.addform)">
		<p>Please use the form below to add a new feed URL that you would like to add to your ColdBox Reader. The reader will try to validate this URL.</p>
		<b>Feed URL:</b>
		<input type="text" name="feedURL" value="#Event.getValue("feedURL","")#" size="50" style="padding:3px;font-size:12px;font-family:Verdana, Arial, Helvetica, sans-serif;" />
		<br><br>
		<div align="center">
		<input type="button" value="Go Back" onClick="doEvent('general.dspReader','centercontent',{})" />
		<input type="submit" value="Continue >>" name="continue_button" id="continue_button" />
		</div>
	</form>
<cfelse>
	<form name="addform" id="addform" method="post" action="javascript:doFormEvent('#Event.getValue("xehAddFeed")#','centercontent',document.addform)">
		<p>The feed you entered has been validated successfully. You can see the feed's details below.</p>
		<input type="hidden" name="feedID" value="#Event.getValue("feedID","")#">
		<table>
			<tr>
				<td><b>URL:</b></td>
				<td>
					<input type="text" name="feedURL" value="#rc.feedURL#" size="50" readonly="true" />
				</td>
			</tr>
			<tr>
				<td><b>Name:</b></td>
				<td><input type="text" name="feedName" value="#myFeed.title#" size="50" /></td>
			</tr>
			<tr>
				<td><b>Author:</b></td>
				<td><input type="text" name="feedAuthor" value="" size="50" /></td>
			</tr>
			<tr>
				<td><b>Last Updated:</b></td>
				<td><input type="text" name="feedDate" value="#myFeed.date#" size="50" /></td>
			</tr>
			<tr>
				<td><b>Image:</b></td>
				<td><input type="text" name="imgURL" value="#myFeed.image.url#" size="50" /></td>
			</tr>
			<tr>
				<td><b>Website:</b></td>
				<td><input type="text" name="siteURL" value="#myFeed.link#" size="50" /></td>
			</tr>
			<tr>
				<td valign="top"><b>Description:</b></td>
				<td><textarea name="description" cols="40" rows="5">#myFeed.description#</textarea></td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td>&nbsp;</td>
				<td>
					<div align="center">
					<input type="button" value="Go Back" onClick="doEvent('#Event.getValue("xehNewFeed")#','centercontent',{})" />
					<input type="submit" value="Add Feed"  />
					</div>
				</td>
			</tr>
		</table>
	</form>
</cfif>
</cfoutput>