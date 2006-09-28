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
		    <div class="sidemenu_title_img"  ><img src="images/icons/settings_27.gif"></div>
			<div class="sidemenu_title_text" >Settings</div>
		</div>
		
		<!--- Sub Menu Links --->
		<ul>
			<li><a href="javascript:doEvent('#getValue("xehSettings")#', 'content', {})" onMouseOver="getHint('frameworksettings')" onMouseOut="resetHint()">General Settings</a></li>
			
			<li><a href="javascript:doEvent('#getValue("xehLogSettings")#', 'content', {})" onMouseOver="getHint('logfilesettings')" onMouseOut="resetHint()">Log File Settings</a></li>
			
			<li><a href="javascript:doEvent('#getValue("xehEncodingSettings")#', 'content', {})" onMouseOver="getHint('encodingsettings')" onMouseOut="resetHint()">File Encoding Settings</a></li>
			
			<li><a href="javascript:doEvent('#getValue("xehPassword")#', 'content', {})" onMouseOver="getHint('passwordsettings')" onMouseOut="resetHint()">Change Dashboard Password</a></li>
			
			<li><a href="javascript:doEvent('#getValue("xehProxy")#', 'content', {})" onMouseOver="getHint('proxysettings')" onMouseOut="resetHint()">Proxy Settings</a></li>
		</ul>
		
		#renderview("tags/sidemenu_tools")#
		
		</td>
	</tr>
</table>

<script language="javascript">
//Populate system info
doEvent('#getValue("xehSettings")#', 'content', {});
</script>
</cfoutput>