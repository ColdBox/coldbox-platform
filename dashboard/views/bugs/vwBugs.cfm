<cfoutput>
#renderView("tags/rollovers")#

<!--- Title Bar --->
<div class="sidemenu_title">
    <div class="sidemenu_title_img"  ><img src="images/icons/bugreports_27.gif"></div>
	<div class="sidemenu_title_text" >Submit Bugs</div>
</div>

<!--- Sub Menu Links --->
<ul>
	<li><a href="javascript:doEvent('#Event.getValue("xehSubmitBug")#', 'content', {})" onMouseOver="getHint('submitbug')" onMouseOut="resetHint()">Submit Bugs</a></li>
	
	<li><a href="#getSetting("TracSite")#/trac.cgi/report" onMouseOver="getHint('tracdatabase')" onMouseOut="resetHint()">Official Bug Database</a></li>
	
</ul>

<script language="javascript">
//Populate system info
doEvent('#Event.getValue("xehSubmitBug")#', 'content', {});
</script>
</cfoutput>