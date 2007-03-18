<cfoutput>
<!--- HELPBOX --->
#renderView("tags/help")#

<!--- Placed under content div --->
<div class="maincontentbox">

	<div class="contentboxes_header">
		<div class="contentboxes_title"><img src="images/icons/cfcapi_icon.gif" align="absbottom" />&nbsp; CFC API Documentation</div>
	</div>

	<div class="contentboxes">
	This is your current ColdBox Framework CFC Documentation. Use the dropdown below to choose the documentation type:<br><br>

	<DIV align="right">
	<Strong>Documentation Type:</Strong>
	<select name="show" id="show" onChange="doEvent('#Event.getValue("xehCFCDocs")#', 'content', {show:this.value})" style="width:100px">
	 <option value="core" <cfif Event.getValue("show") eq "core">selected</cfif>>Core</option>
	 <option value="plugins" <cfif Event.getValue("show") eq "plugins">selected</cfif>>Plugins</option>
	 <option value="beans" <cfif Event.getValue("show") eq "beans">selected</cfif>>Beans</option>
	 <option value="util" <cfif Event.getValue("show") eq "util">selected</cfif>>Util</option>
	</select>
	</div>
	#Event.getValue("cfcViewer").render()#
	</div>

</div>
</cfoutput>