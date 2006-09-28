<cfoutput>
#renderView("tags/rollovers")#

<table height="100%" width="100%" cellpadding="0" cellspacing="0" border="0">	
	<tr>
		<td valign="top" height="600" align="center">
		<!--- Content --->
		<div id="content"></div>
		</td>
		
		<td class="sidemenu" height="100%" valign="top">
		<!--- Title Bar --->
		<div class="sidemenu_title">
		    <div class="sidemenu_title_img"  ><img src="images/icons/tools_27.gif"></div>
			<div class="sidemenu_title_text" >Tools</div>
		</div>
		
		<!--- Sub Menu Links --->
		<ul>
			<li><a href="javascript:doEvent('#getValue("xehAppBuilder")#', 'content', {})" onMouseOver="getHint('appbuilder')" onMouseOut="resetHint()">ColdBox Application Builder</a></li>
			
			<li><a href="javascript:doEvent('#getValue("xehLogViewer")#', 'content', {})" onMouseOver="getHint('logviewer')" onMouseOut="resetHint()">ColdBox Log Viewer</a></li>
			
			<li><a href="javascript:doEvent('#getValue("xehCFCGenerator")#', 'content', {})" onMouseOver="getHint('cfcgenerator')" onMouseOut="resetHint()">Illidium CFC Generator</a></li>
			
		</ul>
		
		#renderview("tags/sidemenu_tools")#
		
		</td>
	</tr>
</table>

<script language="javascript">
//Populate system info
doEvent('#getValue("xehAppBuilder")#', 'content', {});
</script>
</cfoutput>