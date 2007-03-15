<cfoutput>
<!--- HELPBOX --->
<div id="helpbox" class="helpbox" style="display: none">

	<div class="helpbox_header">
	  <div class="helpbox_header_title"><img src="images/icons/icon_guide_help.gif" align="absmiddle"> Help Tip</div>
	</div>
	
	<div class="helpbox_message" >
	  <ul>
	  	<li>You can see from ths screen wether an update is available or not. You can then choose to download
			the update or use the Dashboard's auto-update feature to install it.</li>
		<li>When you perform an auto-update for the framework, the updater will have to delete all the old
		files and make backups. If you have running applications, the installation might be corrupted or
		not possible. So please make sure all your applications are offline.</li>
		<li>You can only do one auto-update at a time, for Now!!</li>
	  </ul>
	</div>
	<div align="right" style="margin-right:5px;">
	<input type="button" value="Close" onClick="helpoff()" style="font-size:9px">
	</div>
</div>

<!--- CONTENT BOX --->
<div class="maincontentbox">
	
	<div class="contentboxes_header">
		<div class="contentboxes_title"><img src="images/icons/update_27.gif" align="absmiddle" />&nbsp; ColdBox Update Center</div>
	</div>
	
	<div class="contentboxes">
	<p>Below you can see the results of the distribution checks. If you choose to do an auto-update for ColdBox or the Dashboard, the
		installer will automatically create a backup copy of either application in your backups directory. If you ever need to revert to a
		specified version, you can.
	</p>
	<br>
	<p align="center" class="redtext">When you do an auto-update, make sure there are no running applications.</p>
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
		<th width="50" style="text-align:center"><strong>Current Version</strong></th>
		<th width="50" style="text-align:center"><strong>Available Version</strong></th>
		<th width="50" style="text-align:center"><strong>File Size</strong></th>
		<th width="150" style="text-align:center"><strong>Commands</strong></th>
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
		<input type="submit" name="btn_update" value="Auto-Update" style="font-size:9px" onclick="return confirmUpdate('framework')" />
		<input type="button" name="btn_update" value="Download" style="font-size:9px" onclick="window.open('#rc.updateResults.coldboxDistro.updateurl#')"/>
		<cfelse>
		<span class="redtext">Latest Installed</span>
		</cfif>
		</td>
	  </tr>
	  
	  <cfif rc.updateResults.coldboxavailableupdate>
	  <tr bgcolor="##FFFFF0"> 
	    <td colspan="5" style="border:1px solid ##999999;">
		<div class="updatertext">#HTMLCODEFORMAT(rc.updateResults.ColdboxDistro.Description)#</div>
		</td>
	  </tr>
	  </cfif>
	  
	  <tr bgcolor="f5f5f5">
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
		<input type="submit" name="btn_update" value="Auto-Update" style="font-size:9px" onclick="return confirmUpdate('dashboard')" />
		<input type="button" name="btn_update" value="Download" style="font-size:9px" onclick="window.open('#rc.updateResults.dashboardDistro.updateurl#')"/>
		<cfelse>
		<span class="redtext">Latest Installed</span>
		</cfif>
		</td>
	  </tr>
	  
	   <cfif rc.updateResults.dashboardavailableupdate>
	   <tr bgcolor="##FFFFF0"> 
	    <td colspan="5" style="border:1px solid ##999999">
		<div class="updatertext">#HTMLCODEFORMAT(rc.updateResults.dashboardDistro.Description)#</div>
		</td>
	  </tr>
	  </cfif>
	  
	</table>
	
	
	</form>
	</div>
	
</div>
</cfoutput>