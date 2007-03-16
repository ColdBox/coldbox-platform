<cfoutput>

<!--- HELPBOX --->
<div id="helpbox" class="helpbox" style="display: none">

	<div class="helpbox_header">
	  <div class="helpbox_header_title"><img src="images/icons/icon_guide_help.gif" align="absmiddle"> Help Tip</div>
	</div>
	
	<div class="helpbox_message" >
	  <ul>
	  	<li>This section is the actual live documentation of your framework installation.  The default view is  for the 
		  	core components: controller, eventhandler and plugin
	    </li>
	    <li>You can switch to the various component sections: Beans, Plugins, and Util to render their live documentation.</li>
	  </ul>
	</div>
	<div align="right" style="margin-right:5px;">
	<input type="button" value="Close" onClick="helpToggle()" style="font-size:9px">
	</div>
</div>
	
<!--- Placed under content div --->
<div class="maincontentbox">
	
	<div class="contentboxes_header">
		<div class="contentboxes_title"><img src="images/icons/cfcapi_icon.gif" align="absbottom" />&nbsp; CFC API Documentation</div>
	</div>
	
	<div class="contentboxes">
	This is your current ColdBox Framework CFC Documentation. Use the dropdown below to choose the documentation type:<br><br>
	
	<DIV align="right">
	<Strong>Documentation Type:</Strong>
	<select name="show" id="show" onChange="doEvent('#Event.getValue("xehCFCDocs")#', 'content', {show:this.value})">
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