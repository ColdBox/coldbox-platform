<cfoutput>
<link rel="stylesheet" href="/coldbox/system/includes/cfcviewer.css" type="text/css" />
#renderView("tags/rollovers")#

<!--- Title Bar --->
<div class="sidemenu_title">
    <div class="sidemenu_title_img"  ><img src="images/icons/home_27.gif"></div>
	<div class="sidemenu_title_text" >System Information</div>
</div>

<!--- Sub Menu Links --->
<ul>
	<li><a href="javascript:doEvent('#Context.getValue("xehSystemInfo")#', 'content', {})" onMouseOver="getHint('sysinfo')" onMouseOut="resetHint()">System Information</a></li>
	
	<li><a href="javascript:doEvent('#Context.getValue("xehResources")#', 'content', {})" onMouseOver="getHint('onlineresources')" onMouseOut="resetHint()">Online Resources</a></li>
	
	<cfif not application.isBD>
		<li><a href="javascript:doEvent('#Context.getValue("xehCFCDocs")#', 'content', {})" onMouseOver="getHint('cfcdocs')" onMouseOut="resetHint()">CFC Documentation</a></li>
	</cfif>
</ul>
	

<script language="javascript">
//Populate system info
doEvent('#Context.getValue("xehSystemInfo")#', 'content', {});
</script>
</cfoutput>