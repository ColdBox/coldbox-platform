<cfset myFeed = getValue("myFeed","")>
<cfoutput>

<h1>Add New Feed</h1>

<cfif not getValue("FeedValidated")>
	<form name="frm" method="post" action="javascript:doFormEvent('#getValue("xehNewFeed")#','centercontent',document.frm)">
		<p>Please use the form below to add a new feed URL that you would like to add to your ColdBox Reader. The reader will try to validate this URL.</p>
		<b>Feed URL:</b>
		<input type="text" name="feedURL" value="#getValue("feedURL","")#" size="50" style="padding:3px;font-size:12px;font-family:Verdana, Arial, Helvetica, sans-serif;" />
		<br><br>
		<div align="center">
		<input type="button" value="Go Back" onClick="doEvent('ehGeneral.dspReader','centercontent',{})" />
		<input type="submit" value="Continue >>" name="continue_button" id="continue_button" />
		</div>
	</form>
<cfelse>
	<form name="frm" method="post" action="javascript:doFormEvent('#getValue("xehAddFeed")#','centercontent',document.frm)">
		<p>The feed you entered has been validated successfully. You can see the feed's details below.</p>
		<input type="hidden" name="feedID" value="#getValue("feedID","")#">
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
				<td><b>Last Updated:</b></td>
				<td><input type="text" name="feedAuthor" value="#myFeed.date#" size="50" /></td>
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
					<input type="button" value="Go Back" onClick="doEvent('#getValue("xehNewFeed")#','centercontent',{})" />
					<input type="submit" value="Add Feed"  />
					</div>
				</td>
			</tr>
		</table>
	</form>
</cfif>
</cfoutput>