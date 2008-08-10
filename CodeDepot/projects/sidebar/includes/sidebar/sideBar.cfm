<!-----------------------------------------------------------------------
Author 	 :	Ernst van der Linden
Date     :	7/31/2008
Description : Shows the ColdBox Sidebar 
		
Modification History:
08/08/2008 evdlinden : Removed Spry plugin calls, added yOffset interceptor property, skinning posibility 
08/09/2008 evdlinden : Links and custom links combined
08/09/2008 evdlinden : sideBar struct deleted, only use interceptor properties now
08/10/2008 evdlinden : all local vars to interceptor scope and request collection. Enable/disable sideBar through url param sbIsEnabled=1; FireFox problem solved
----------------------------------------------------------------------->

<cfhtmlhead text='<script language="javascript" src="includes/sidebar/sideBar.js" type="text/javascript"></script>' />
<cfhtmlhead text='<link rel="stylesheet" href="#getproperty('cssPath')#" type="text/css" media="screen">' />

<cfoutput>
<div id="SideBarContainer" style="visibility:hidden;position:absolute;left:0px;top:#getproperty('yOffset')#px;z-index:20;width:#getproperty('width')#px">
	<div id="SideBar" style="position:absolute;left:-#( getproperty('invisibleWidth'))#px;top:0;z-Index:20;" onmouseover="moveOut()" onmouseout="moveBack()">
		<form id="sbForm" style="margin:0;">
		<table border="0" cellpadding="0" cellspacing="0" width="#getproperty('width')#">
			<tr>
				<td class="top" width="#getproperty('invisibleWidth')#" nowrap><h1>Settings</h1></td>
				<td background="" rowspan="#(12 + ArrayLen(links))#" width="#getproperty('visibleWidth')#" nowrap class="bar" valign="#getproperty('imageVAlign')#" align="left"><img src="#getproperty('imagePath')#" width="22" height="160" border="0" /></td>
			</tr>
			<tr>
				<td><input type="checkbox" name="sbIsEnabled" value="1" checked  onclick="location.href='#rc.enableHref#'"><span class="checkboxlabel">Show SideBar</span></td>
			</tr>	
			<tr>
				<td><h1>Debug</h1></td>
			</tr>
			<tr>
				<td><input type="checkbox" name="sbIsDebugmode" value="1" onclick="location.href='#rc.debugModeHref#'" #iif(getDebugMode(),DE('checked'),'')#><span class="checkboxlabel">Show Debug Panel</span></td>
			</tr>	
			<!--- DebugMode? --->
			<cfif getDebugMode()>
			<tr>
				<td><span class="inputlabel">Dump Variable</span>
					<input type="text" id="sbDumpVar" style="width:75px;">
					<input type="button" value="Dump" onclick="#rc.dumpvarHref#">
				</td>
			</tr>	
			<tr>
				<td><a onclick="#rc.cachePanelHref#">Open Cache Monitor</a></td>
			</tr>	
			<tr>
				<td><a onclick="#rc.profilerHref#">Open Profiler Monitor</a></td>
			</tr>	
			</cfif>
			<tr>
				<td><h1>Reset</h1></td>
			</tr>
			<tr>
				<td><a href="#rc.fwReInitHref#">Reload Framework</a></td>
			</tr>	
			<tr>
				<td><a href="#rc.clearCacheHref#">Clear Cache</a></td>
			</tr>	
			<tr>
				<td><span class="inputlabel">Clear Scope</span>
				<select id="sbClearScope" name="sbClearScope" size="1" style="width:75px;">
					<option value="session">Session</option>
					<option value="client">Client</option>
				</select>
				<input type="button" value="Clear" onclick="#rc.clearScopeHref#">
				</td>
			</tr>	
			<tr>
				<td><a href="#rc.clearLogHref#">Clear Log</a></td>
			</tr>	
			<tr>
				<td><h1>Search</h1></td>
			</tr>
			<tr>
				<td><span class="inputlabel">ColdBox Live Docs</span>
					<input type="text" id="sbSearchCBLiveDocs" style="width:75px;">
					<input type="button" value="Search" onclick="#rc.searchCBLiveDocsHref#">
				</td>
			</tr>				
			<tr>
				<td><span class="inputlabel">ColdBox Forums</span>
					<input type="text" id="sbSearchCBForums" style="width:75px;">
					<input type="button" value="Search" onclick="#rc.searchCBForumsHref#">
				</td>
			</tr>				
			<!--- Links? --->
			<cfif ArrayLen(links)>
				<tr>
					<td><h1>Links</h1></td>
				</tr>
				<!--- Loop custom links --->
				<cfloop index="i" from="1" to="#ArrayLen(links)#">
				<tr>
					<td class="bottom"><a href="#links[i].href#" target="_blank">#links[i].desc#</a></td>
				</tr>						
				</cfloop>
			</cfif>
		</table>
		</form>
	</div>
</div>	

<script type="text/javascript">
	// Left and width correction?
	if (NS6){
		document.getElementById("SideBar").style.left = parseInt(document.getElementById("SideBar").style.left)+10+"px"; 
		sideBarWidth= #getproperty('invisibleWidth')# - 10;
	} else {
		sideBarWidth= #getproperty('invisibleWidth')#;
	}
	slideSpeed=20 
	waitTime=100; 
	setTimeout('initSideBar();', 1)
</script>
</cfoutput>