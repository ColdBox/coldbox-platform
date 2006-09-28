<cfoutput>
#renderView("tags/rollovers")#

<!--- StyleSheet For cfc Viewer --->
<link rel="stylesheet" href="/coldbox/system/includes/cfcviewer.css" type="text/css" />

<table height="100%" width="100%" cellpadding="0" cellspacing="0" border="0">	
	<tr>
		<td valign="top" height="600" align="center">
		<!--- Content --->
		<div id="content"></div>
		</td>
		
		<td class="sidemenu" height="100%" valign="top">
		<!--- Title Bar --->
		<div class="sidemenu_title">
		    <div class="sidemenu_title_img"  ><img src="images/icons/home_27.gif"></div>
			<div class="sidemenu_title_text" >System Information</div>
		</div>
		
		<!--- Sub Menu Links --->
		<ul>
			<li><a href="javascript:doEvent('#getValue("xehSystemInfo")#', 'content', {})" onMouseOver="getHint('sysinfo')" onMouseOut="resetHint()">System Information</a></li>
			
			<li><a href="javascript:doEvent('#getValue("xehResources")#', 'content', {})" onMouseOver="getHint('onlineresources')" onMouseOut="resetHint()">Online Resources</a></li>
			
			<cfif not application.isBD>
				<li><a href="javascript:doEvent('#getValue("xehCFCDocs")#', 'content', {})" onMouseOver="getHint('cfcdocs')" onMouseOut="resetHint()">CFC Documentation</a></li>
			</cfif>
		</ul>
		
		#renderview("tags/sidemenu_tools")#
		</td>
	</tr>
</table>

<script language="javascript">
//Populate system info
doEvent('#getValue("xehSystemInfo")#', 'content', {});
</script>
</cfoutput>