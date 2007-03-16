<cfoutput>
#renderView("tags/rollovers")#

<!--- Title Bar --->
<div class="sidemenu_title">
    <div class="sidemenu_title_img"  ><img src="images/icons/tools_27.gif"></div>
	<div class="sidemenu_title_text" >Tools</div>
</div>

<!--- Sub Menu Links --->
<ul>
	<li><a href="javascript:doEvent('#Event.getValue("xehAppBuilder")#', 'content', {})" onMouseOver="getHint('appbuilder')" onMouseOut="resetHint()">ColdBox Application Builder</a></li>
	
	<li><a href="javascript:doEvent('#Event.getValue("xehLogViewer")#', 'content', {})" onMouseOver="getHint('logviewer')" onMouseOut="resetHint()">ColdBox Log Viewer</a></li>
	
	<li><a href="javascript:doEvent('#Event.getValue("xehCFCGenerator")#', 'content', {})" onMouseOver="getHint('cfcgenerator')" onMouseOut="resetHint()">Illidium PU-36 CFC Generator</a></li>
	
</ul>
		
<script language="javascript">
//Populate system info
doEvent('#Event.getValue("xehAppBuilder")#', 'content', {});
</script>
</cfoutput>