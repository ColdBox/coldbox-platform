<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Ernst van der Linden ( evdlinden@gmail.com | http://evdlinden.behindthe.net )
Date     :	7/31/2008
Description : Shows the ColdBox Sidebar 
		
Modification History:
08/08/2008 evdlinden : Removed Spry plugin calls, added yOffset interceptor property, skinning posibility 
08/09/2008 evdlinden : Links and custom links combined
08/09/2008 evdlinden : sideBar struct deleted, only use interceptor properties now
08/10/2008 evdlinden : all local vars to interceptor scope and request collection. Enable/disable sideBar through url param sbIsEnabled=1; FireFox problem solved
08/12/2008 evdlinden : getRenderedSideBar, switched from request scope to local var scope. We don't want to show sideBar vars if in debugmode. isScroll property implemented. 
----------------------------------------------------------------------->

<cfhtmlhead text='<script language="javascript" src="#TRIM(getproperty('jsPath'))#" type="text/javascript"></script>' />
<cfhtmlhead text='<link rel="stylesheet" href="#TRIM(getproperty('cssPath'))#" type="text/css" media="screen">' />
<cfoutput>
<!-- 
ColdBox SideBar: created on 7/31/2008 by Ernst van der Linden (evdlinden@gmail.com | http://evdlinden.behindthe.net)
 -->
<div id="ColdBoxSideBarContainer" style="visibility:hidden;position:absolute;left:0px;top:#getproperty('yOffset')#px;z-index:9999;width:#getproperty('width')#px">
	<div id="ColdBoxSideBar" style="position:absolute;left:-#( getproperty('invisibleWidth'))#px;top:0;z-Index:9999;" onmouseover="coldBoxSideBar.moveOut()" onmouseout="coldBoxSideBar.moveBack()">
		<form id="sbForm" style="margin:0;">
		<table id="ColdBoxSideBarTbl" border="0" cellpadding="0" cellspacing="0" width="#getproperty('width')#">
			<tr>
				<td class="ColdBoxSideBarTop" width="#getproperty('invisibleWidth')#" nowrap><h1>Settings</h1></td>
				<td background="" rowspan="#(12 + ArrayLen(local.links))#" width="#getproperty('visibleWidth')#" nowrap class="ColdBoxSideBarImgBar" valign="#getproperty('imageVAlign')#" align="left"><img src="#TRIM(getproperty('imagePath'))#" width="22" height="160" border="0" /></td>
			</tr>
			<tr>
				<td><input type="checkbox" class="ColdBoxSideBarCheckBox" name="sbIsEnabled" value="1" checked  onclick="location.href='#local.enableHref#'"><span class="ColdBoxSideBarCheckboxlabel">Show SideBar</span></td>
			</tr>	
			<tr>
				<td><h1>Debug</h1></td>
			</tr>
			<tr>
				<td><input type="checkbox" class="ColdBoxSideBarCheckBox" name="sbIsDebugmode" value="1" onclick="location.href='#local.debugModeHref#'" #iif(getDebugMode(),DE('checked'),'')#><span class="ColdBoxSideBarCheckboxlabel">Show Debug Panel</span></td>
			</tr>	
			<!--- DebugMode? --->
			<cfif getDebugMode()>
				<!--- Dump var enabled? --->
				<cfif getSetting("EnableDumpVar")>
					<tr>
						<td><span class="ColdBoxSideBarInputlabel">Dump Variable</span>
							<input type="text" class="ColdBoxSideBarText" id="sbDumpVar">
							<input type="button" class="ColdBoxSideBarBtn" value="Dump" onclick="#local.dumpvarHref#">
						</td>
					</tr>	
				</cfif>
				<tr>
					<td><a onclick="#local.cachePanelHref#">Open Cache Monitor</a></td>
				</tr>	
				<tr>
					<td><a onclick="#local.profilerHref#">Open Profiler Monitor</a></td>
				</tr>	
			</cfif>
			<tr>
				<td><h1>Reset</h1></td>
			</tr>
			<tr>
				<td><a href="#local.fwReInitHref#">Reload Framework</a></td>
			</tr>	
			<tr>
				<td><a href="#local.clearCacheHref#">Clear Cache</a></td>
			</tr>	
			<tr>
				<td><span class="ColdBoxSideBarInputlabel">Clear Scope</span>
				<select id="sbClearScope" name="sbClearScope" size="1">
					<option value="session">Session</option>
					<option value="client">Client</option>
				</select>
				<input type="button" class="ColdBoxSideBarBtn" value="Clear" onclick="#local.clearScopeHref#">
				</td>
			</tr>	
			<tr>
				<td><a href="#local.clearLogHref#">Clear Log</a></td>
			</tr>	
			<tr>
				<td><h1>Search</h1></td>
			</tr>
			<tr>
				<td><span class="ColdBoxSideBarInputlabel"><a href="#local.CBLiveDocsHref#" target="_blank">ColdBox Live Docs</a></span>
					<input type="text" class="ColdBoxSideBarText" id="sbSearchCBLiveDocs">
					<input type="button" class="ColdBoxSideBarBtn" value="Search" onclick="#local.searchCBLiveDocsHref#">
				</td>
			</tr>				
			<tr>
				<td><span class="ColdBoxSideBarInputlabel"><a href="#local.CBForumsHref#" target="_blank">ColdBox Forums</a></span>
					<input type="text" class="ColdBoxSideBarText" id="sbSearchCBForums">
					<input type="button" class="ColdBoxSideBarBtn" value="Search" onclick="#local.searchCBForumsHref#">
				</td>
			</tr>				
			<!--- Links? --->
			<cfif ArrayLen(local.links)>
				<tr>
					<td><h1>Links</h1></td>
				</tr>
				<!--- Loop custom links --->
				<cfloop index="i" from="1" to="#ArrayLen(local.links)#">
				<tr>
					<td class="bottom"><a href="#local.links[i].href#" target="_blank">#local.links[i].desc#</a></td>
				</tr>						
				</cfloop>
			</cfif>
		</table>
		</form>
	</div>
</div>	

<script type="text/javascript">
	// Needed to check if ColdBox namespace exists
	coldBoxSideBarTimeOut = setTimeout('setupColdBoxSideBar();', 1);
	
	function setupColdBoxSideBar(){
	
		// ColdBox namespace?
		if (typeof coldbox != 'undefined') {
			// clear time out
			clearTimeout(coldBoxSideBarTimeOut);
			coldBoxSideBarTimeOut=setTimeout('null',1);
					
			// Setup ColdBox SideBar
			coldBoxSideBar = new coldbox.SideBar ( 
									{
										elementId:"ColdBoxSideBar"
										,containerElementId:"ColdBoxSideBarContainer"		
									 	,width: #getproperty("invisibleWidth")#
									 	,slideSpeed:#getproperty("slideSpeed")#
									 	,waitTimeBeforeClose:#getproperty("waitTimeBeforeClose")#
									 	,yOffset:#getproperty("yOffset")#
									 	,isScroll:#getproperty("isScroll")#
									}
								);	
		
		} else {
			// Wait a while and try setting up ColdBox SideBar again
			coldBoxSideBarTimeOut = setTimeout('setupColdBoxSideBar();', 1);
		}	
	}
</script>
</cfoutput>