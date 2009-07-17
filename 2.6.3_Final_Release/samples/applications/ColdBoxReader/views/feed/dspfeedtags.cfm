<cfset qryData = Event.getValue("qryData")>
<cfset feedID = Event.getValue("feedID")>

<div class="nicebox">

	<div style="line-height:20px;">
		<b>All Tags:</b><br />
		<cfoutput query="qryData">
			<a href="javascript:doEvent('#Event.getValue("xehSearchByTag")#','centercontent',{tag:'#tag#'});">#tag#</a>&nbsp;&nbsp;
		</cfoutput>
		<cfif qryData.recordCount eq 0>
			<em>No Tags</em>
		</cfif>
	</div>
	
	<cfif rc.oUserBean.getVerified()>
		<br>
		<div style="line-height:20px;">
			<b>My Tags:</b><br />
			<cfoutput query="rc.qryMyTags">
				<a href="javascript:doEvent('ehFeed.doSearchByTag','centercontent',{tag:'#tag#'});">#tag#</a>&nbsp;&nbsp;
			</cfoutput>
			<cfif rc.qryMyTags.recordCount eq 0>
				<em>No Tags</em>
			</cfif>
		</div>
		<cfoutput>
		<form name="frmAddTag" method="post" action="javascript:doFormEvent('#Event.getValue("xehAddTag")#','rightcontent1',document.frmAddTag)">
			<input type="hidden" value="#feedID#" name="feedID" />
			<input type="text"   value="" name="tags" size="10"  />
			<input type="submit" value="Add Tag" name="btnAddTag" style="font-size: 9px" />
		</form>
		</cfoutput>
	</cfif>
</div>