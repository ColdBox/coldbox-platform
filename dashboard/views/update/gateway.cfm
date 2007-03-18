<cfoutput>
<script language="javascript">
$(document).ready(function() {
	//Populate system info
	doEvent('#Event.getValue("xehUpdater")#', 'content', {});
});
</script>

<!--- Help Rollovers --->
#renderView("tags/rollovers")#

<!--- Title Bar --->
<div class="sidemenu_title">
    <div class="sidemenu_title_img"  ><img src="images/icons/update_27.gif"></div>
	<div class="sidemenu_title_text" >Update Center</div>
</div>

<!--- Sub Menu Links --->
<ul>
	<li><a href="javascript:doEvent('#Event.getValue("xehUpdater")#', 'content', {})" onMouseOver="getHint('updater')" onMouseOut="resetHint()">Update Checker</a></li>
</ul>
</cfoutput>