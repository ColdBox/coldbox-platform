<cfoutput>
#renderView("tags/rollovers")#

<!--- Title Bar --->
<div class="sidemenu_title">
    <div class="sidemenu_title_img"  ><img src="images/icons/update_27.gif"></div>
	<div class="sidemenu_title_text" >Update Center</div>
</div>

<!--- Sub Menu Links --->
<ul>
	<li><a href="javascript:doEvent('#getValue("xehUpdater")#', 'content', {})" onMouseOver="getHint('updater')" onMouseOut="resetHint()">Update Checker</a></li>
</ul>

<script language="javascript">
//Populate system info
doEvent('#getValue("xehUpdater")#', 'content', {});
</script>
</cfoutput>