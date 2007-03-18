<!--- HELPBOX --->
<div id="helpbox" class="helpbox" style="display: none">

	<div class="helpbox_header">
	  <div class="helpbox_header_title"><img src="images/icons/icon_guide_help.gif" align="absmiddle">Help Tip</div>
	</div>

	<div class="helpbox_message" >
	<cfoutput>#event.getValue("help","")#</cfoutput>
	</div>

	<div align="center">
		<a class="action silver" href="javascript:helpToggle()">
			<span>Close</span>
		</a>
	</div>
</div>