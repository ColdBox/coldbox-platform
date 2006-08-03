<cfset feedID = getValue("feedID","")>
<cfset feedName = getValue("feedName","")>
<cfset feedURL = getValue("feedURL","")>
<cfset feedAuthor = getValue("feedAuthor","")>
<cfset description = getValue("description","")>
<cfset imgURL = getValue("imgURL","")>
<cfset siteURL = getValue("siteURL","")>

<cfoutput>
<cfif feedID eq "" and feedURL eq "">
	<form name="frm" method="post" action="javascript:doFormEvent('ehFeed.doParseFeed','centercontent',document.frm)">
		<b>Feed URL:</b>
		<input type="text" name="feedURL" value="#feedURL#" size="40" style="padding:3px;font-size:12px;font-family:Verdana, Arial, Helvetica, sans-serif;" />

		
		<input type="submit" value="Continue >>" />
		<input type="button" value="Go Back" onClick="doEvent('ehGeneral.dspReader','centercontent',{})" />

	</form>	
<cfelse>
	<form name="frm" method="post" action="javascript:doFormEvent('ehFeed.doAddFeed','centercontent',document.frm)">
		<input type="hidden" name="feedID" value="#feedID#">
		<table>
			<tr>
				<td><b>URL:</b></td>
				<td>
					#feedURL#
					<input type="hidden" name="feedURL" value="#feedURL#" />
				</td>
			</tr>
			<tr>
				<td><b>Name:</b></td>
				<td><input type="text" name="feedName" value="#feedName#" /></td>
			</tr>
			<tr>
				<td><b>Author:</b></td>
				<td><input type="text" name="feedAuthor" value="#feedAuthor#" /></td>
			</tr>
			<tr>
				<td><b>Image:</b></td>
				<td><input type="text" name="imgURL" value="#imgURL#" /></td>
			</tr>		
			<tr>
				<td><b>Website:</b></td>
				<td><input type="text" name="siteURL" value="#siteURL#" /></td>
			</tr>			
			<tr>
				<td valign="top"><b>description:</b></td>
				<td><textarea name="description" cols="30" rows="5">#description#</textarea></td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td>&nbsp;</td>
				<td>
					<input type="submit" value="Add Feed" />
					<input type="button" value="Go Back" onClick="doEvent('ehFeed.dspAddFeed','centercontent',{})" />
				</td>
			</tr>
		</table>
	</form>
</cfif>
</cfoutput>