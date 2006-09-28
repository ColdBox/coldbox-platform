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
		    <div class="sidemenu_title_img"  ><img src="images/icons/bugreports_27.gif"></div>
			<div class="sidemenu_title_text" >Submit Bugs</div>
		</div>
		
		<!--- Sub Menu Links --->
		<ul>
			<li><a href="javascript:doEvent('#getValue("xehSubmitBug")#', 'content', {})" onMouseOver="getHint('submitbug')" onMouseOut="resetHint()">Submit Bugs</a></li>
			
			<li><a href="#getSetting("TracSite")#/trac.cgi/report" onMouseOver="getHint('tracdatabase')" onMouseOut="resetHint()">Official Bug Database</a></li>
			
		</ul>
		
		#renderview("tags/sidemenu_tools")#
		</td>
	</tr>
</table>

<script language="javascript">
//Populate system info
doEvent('#getValue("xehSubmitBug")#', 'content', {});
</script>
</cfoutput>