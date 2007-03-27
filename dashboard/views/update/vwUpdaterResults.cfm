<cfoutput>
<cfset rc = event.getCollection()>
<!--- HELPBOX --->
#renderView("tags/help")#
<!--- Framework Readme --->
<cfif rc.updateResults.coldboxavailableupdate>
<div id="cbReadme" class="updatertext" style="display:none">
	<div class="updatertext_header">
		<div class="updatertext_header_text">Framework Changelog</div>
		<div class="updatertext_header_close"><a href="javascript:closeReadme('cbReadme');" title="Close Window"><img src="images/close.gif" border="0" title="Close Window" align="absmiddle"></a></div>
	</div>
	<div class="updatertext_content">
	#HTMLCODEFORMAT(rc.updateResults.ColdboxDistro.Description)#
	</div>
</div>
</cfif>

<!--- Dashboard Readme --->
<cfif rc.updateResults.dashboardavailableupdate>
<div id="dbReadme" class="updatertext" style="display:none">
	<div class="updatertext_header">
		<div class="updatertext_header_text">Dashboard Changelog</div>
		<div class="updatertext_header_close"><a href="javascript:closeReadme('dbReadme');" title="Close Window"><img src="images/close.gif" border="0" title="Close Window" align="absmiddle"></a></div>
	</div>
	<div class="updatertext_content">
		#HTMLCODEFORMAT(rc.updateResults.dashboardDistro.Description)#
	</div>
</div>
</cfif>

<!--- CONTENT BOX --->
<div class="maincontentbox">

	<div class="contentboxes_header">
		<div class="contentboxes_title"><img src="images/icons/update_27.gif" align="absmiddle" />&nbsp; ColdBox Update Center</div>
	</div>

	<div class="contentboxes">
	<p>Below you can see the results of the distribution checks. If there is an update available, you will be able to download the update or view the changelog file.
	</p>
	<br /><br />
	#getPlugin("messagebox").renderit()#
	<form id="updateform" name="updateform" method="post" action="index.cfm?event=#Event.getValue("xehdoUpdate")#">
	<input type="hidden" name="updatetype" id="updatetype" value="">

	<input type="button" name="btn_update" value="Refresh" style="font-size:9px" onclick="doEvent('ehUpdater.dspUpdaterResults','content')"/>

	<table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">

	  <tr>
		<td class="sort"><strong>Application
		  </th>
		</strong>
		<th width="95" style="text-align:center"><strong>Current Version</strong></th>
		<th width="95" style="text-align:center"><strong>Available Version</strong></th>
		<th width="60" style="text-align:center"><strong>File Size</strong></th>
		<th width="75" style="text-align:center"><strong>Commands</strong></th>
	  </tr>

	  <tr>
		<td valign="top"><strong>ColdBox Framework</strong></td>
		<td align="center" style="border-left:1px solid ##ddd">#getSetting("version",1)#</td>
		<td align="center" style="border-left:1px solid ##ddd">#rc.updateResults.ColdboxDistro.Version#</td>
		<td align="center" style="border-left:1px solid ##ddd">
		<cfif rc.updateResults.coldboxavailableupdate>
			#NumberFormat(rc.updateResults.ColdboxDistro.FileSize/1024)#kb
		</cfif>
		</td>
		<td style="border-left:1px solid ##ddd" align="center">
		<cfif rc.updateResults.coldboxavailableupdate>
			<a href="javascript:showReadme('cbReadme')" title="View Changelog"><img src="images/edit.gif" align="absmiddle" border="0"></a>
			&nbsp;&nbsp;
			<a href="##" onClick="window.open('#rc.updateResults.coldboxDistro.updateurl#')" title="Download Update"><img src="images/download_icon.gif" align="absmiddle" border="0"></a>
		<cfelse>
		<span class="redtext">Latest Installed</span>
		</cfif>
		</td>
	  </tr>

	  <tr bgcolor="##f5f5f5">
		<td valign="top"><strong>ColdBox Dashboard</strong></td>
		<td align="center" style="border-left:1px solid ##ddd">#getSetting("version")#</td>
		<td align="center"  style="border-left:1px solid ##ddd">#rc.updateResults.dashboardDistro.Version#</td>
		<td align="center" style="border-left:1px solid ##ddd">
		<cfif rc.updateResults.dashboardavailableupdate>
			#NumberFormat(rc.updateResults.dashboardDistro.FileSize/1024)#kb
		</cfif>
		</td>

		<td style="border-left:1px solid ##ddd" align="center">
		<cfif rc.updateResults.dashboardavailableupdate>
			<a href="##" onClick="showReadme('dbReadme')" title="View Changelog"><img src="images/edit.gif" align="absmiddle" border="0"></a>
			&nbsp;&nbsp;
			<a href="##" onClick="window.open('#rc.updateResults.dashboardDistro.updateurl#')" title="Download Update"><img src="images/download_icon.gif" align="absmiddle" border="0"></a>
		<cfelse>
		<span class="redtext">Latest Installed</span>
		</cfif>
		</td>
	  </tr>
	</table>
	</form>

	<div class="legend">
	<b>Legend:</b>
	<img src="images/edit.gif" align="absmiddle" border="0"> Read Changelog &nbsp;
	<img src="images/download_icon.gif" align="absmiddle" border="0"> Download Update
	</div>
	</div>

</div>
</cfoutput>