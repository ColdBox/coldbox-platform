<cfparam name="session.userID" default="">

<cfset qryData = getValue("qryData")>
<cfset feedID = getValue("feedID")>

<cfif session.userID neq "">
	<cfif qryData.recordCount gt 0>
		<cfquery name="qryMyTags" dbtype="query">
			SELECT *
				FROM qryData
				WHERE CreatedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.userid#">
		</cfquery>
	<cfelse>
		<cfset qryMyTags = QueryNew("")>
	</cfif>
</cfif>

<p style="line-height:20px;">
	<b>All Tags:</b><br />
	<cfoutput query="qryData">
		<a href="javascript:doEvent('ehFeed.doSearchByTag','centercontent',{tag:'#tag#'});">#tag#</a>&nbsp;&nbsp;
	</cfoutput>
	<cfif qryData.recordCount eq 0>
		<em>No Tags</em>
	</cfif>
</p>

<cfif session.userID neq "">
	<p style="line-height:20px;">
		<b>My Tags:</b><br />
		<cfoutput query="qryMyTags">
			<a href="javascript:doEvent('ehFeed.doSearchByTag','centercontent',{tag:'#tag#'});">#tag#</a>&nbsp;&nbsp;
		</cfoutput>
		<cfif qryMyTags.recordCount eq 0>
			<em>No Tags</em>
		</cfif>
	</p>
	<cfoutput>
	<form name="frmAddTag" method="post" action="javascript:doFormEvent('ehFeed.doAddTags','rightcontent1',document.frmAddTag)">
		<input type="hidden" value="#feedID#" name="feedID" />
		<input type="text" value="" name="tags" width="15" />
		<input type="submit" value="Add Tag" name="btnAddTag" />
	</form>
	</cfoutput>
</cfif>

