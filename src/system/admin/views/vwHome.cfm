<cfoutput>
<cfif not getPlugin("clientstorage").exists("updateResults")>

	<div class="dashboardTitles">#getresource("welcome_title")#</div>
	
	<p>#getresource("welcome_message")#</p>
	
	<table width="100%" border="0" cellspacing="5" cellpadding="0">
	  <tr>
	    <td align="right" class="TablesTitles"><strong>#getresource("codename_txt")#:</strong></td>
	    <td class="TablesCells">#getSetting("codename",1)#</td>
	  </tr>
	  <tr>
	    <td width="23%" align="right" class="TablesTitles"><strong> Version: </strong></td>
	    <td width="77%" class="TablesCells">#getsetting("version",1)# #getSetting("suffix",1)#</td>
	  </tr>
	  <tr>
	    <td align="right" valign="top" class="TablesTitles"><strong>Website: </strong></td>
	    <td class="TablesCells"><a href="#getsetting("AuthorWebsite",1)#" target="_blank">#getSetting("AuthorWebsite",1)#</a></td>
	  </tr>
	  <tr>
	    <td align="right" valign="top" class="TablesTitles"><strong>Support Email: </strong></td>
	    <td class="TablesCells"><a href="mailto:#getsetting("AuthorEmail",1)#" target="_blank">#getSetting("AuthorEmail",1)#</a></td>
	  </tr>
	  <tr>
	    <td align="right" valign="top" class="TablesTitles"><strong>#getresource("description_txt")#:</strong></td>
	    <td class="TablesCells">#getSetting("description",1)#</td>
	  </tr>
	</table>
	
	<br />
	<hr />
</cfif>

<div class="dashboardTitles">#getresource("onlineupdates")# </div>

<cfif getPlugin("clientstorage").exists("updateResults")>
	#getPlugin("messagebox").render()#
	<cfset updateStruct = getPlugin("clientstorage").getVar("UpdateResults")>
	<cfif updateStruct.AvailableUpdate>
	<p>#getresource("udpatemessage")#</p>
	<form id="updateForm" name="updateForm" method="post" action="#cgi.SCRIPT_NAME#">
		<table width="99%" border="0" cellspacing="5" cellpadding="0">
		  <tr>
			<td width="19%" align="right" class="TablesTitles"><strong>Version:</strong></td>
			<td width="81%" class="TablesCells">#updateStruct.updateStruct.version#	</td>
		  </tr>
		  <tr>
			<td align="right" class="TablesTitles"><strong>#getresource("filesize")#: </strong></td>
			<td class="TablesCells">#NumberFormat(updateStruct.updateStruct.FileSize)# Bytes</td>
		  </tr>
		  <tr>
			<td align="right" class="TablesTitles"><strong>  #getresource("date")#: </strong></td>
			<td class="TablesCells">#dateFormat(UpdateStruct.updateStruct.FileDate,"MMMM DD, YYYY")#</td>
		  </tr>
		  <tr>
			<td colspan="2" class="TablesTitles"><strong>#getresource("readme")#</strong></td>
		  </tr>
		  <tr>
			<td colspan="2" class="TablesCells">
			<textarea readonly="readonly" name="text" class="textboxes" rows="18" cols="70">#UpdateStruct.updateStruct.ReadmeFile#</textarea>			</td>
		  </tr>
		</table>
		<div align="center">
		  <input name="button_download" type="button" class="buttons" onclick="getUpdate('#JSStringFormat(updateStruct.updateStruct.updateFile)#')" value="#getresource("download_button")#"/>
		  <input name="button_update" type="button" class="buttons" onclick="confirmUpdate()" value="#getresource("update_button")#"/>
		  <input name="event" type="hidden" id="event" value="ehColdBox.doGetUpdate" />
		  <input name="updateFile" type="hidden" id="updateFile" value="#updateStruct.updateStruct.updateFile#" />
		   <input name="FileSize" type="hidden" id="FileSize" value="#updateStruct.updateStruct.FileSize#" />
		  <input name="version" type="hidden" id="version" value="#updateStruct.updateStruct.version#" />
		</div>
	</form>
	</cfif>
	<cfset getPlugin("clientstorage").deleteVar("UpdateResults")>
	<br><hr><br>
<cfelse>

<p>#getresource("checkforupdates_message")#</p>

<form id="updateInfoForm" name="updateInfoForm" method="post" action="#cgi.SCRIPT_NAME#" onSubmit="checkupdate()">
  <div align="center">
    <textarea type="text" name="distrourl" cols="70" class="textboxes" rows=2 readonly="true">#getPlugin("webservices").getws("DistributionWS")#</textarea>
    <br>
    <input type="hidden" name="event" value="ehColdbox.doCheckUpdates" />
	<input type="submit" name="button_check" id="button_check" value="#getresource("checkforupdates_button")#" class="buttons" />
	<div id="loadmovie" style="display:none">
	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
		codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=7,0,19,0" width="158" height="22">
        <param name="movie" value="installer/load.swf" />
		<param name="quality" value="high" />
		<embed src="installer/load.swf" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="158" height="22"></embed>
	</object>
	</div>
  </div>
</form>
</cfif>
<p>&nbsp;</p>
</cfoutput>