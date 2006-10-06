<cfoutput>
<!--- HELPBOX --->
<div id="helpbox" class="helpbox" style="display: none">

	<div class="helpbox_header">
	  <div class="helpbox_header_title"><img src="images/icons/icon_guide_help.gif" align="absmiddle"> Help Tip</div>
	</div>
	
	<div class="helpbox_message" >
	  <ul>
	  	<li>From this screen you can connect to the official ColdBox distribution site and check if there
		  	is an update to the framework.</li>
		<li>You have the option to download the update or actually do a live update of your system.</li>
		<li>If you are doing a live update of the system, make sure that your applications are offline.</li>
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
	<p>Welcome to the online update section of the ColdBox Framework. You can connect to the distribution site and verify that you are
	running the latest version of the framework and dashboard.  You can then decide to download the update or auto-update it.
	</p>
	<br>
	<p align="center" class="redtext">When you do an auto-update, make sure there are no running applications.</p>
	<br /><br />
	<form id="updateform" name="updateform" method="post" action="javascript:doFormEvent('#getValue("xehCheck")#','content',document.updateform)" onSubmit="document.updateform.button_check.disabled=true">
	  <div align="center">
	    <strong>Distribution URL</strong><br />
	    <textarea type="text" name="distrourl" cols="70" class="textboxes" rows=2 readonly="true">#getPlugin("webservices").getws("DistributionWS")#</textarea>
	    <br>
		<input type="submit" name="button_check" id="button_check" value="Check For Updates" class="buttons" />
	  </div>
	</form>
	</div>
	
</div>
</cfoutput>