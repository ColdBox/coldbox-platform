<!-----------------------------------------------------------------------
Author 	 :	Ernst van der Linden
Date     :	7/31/2008
Description : Shows the ColdBox Sidebar 
		
Modification History:
08/08/2008 evdlinden: Removed Spry plugin calls, added yOffset interceptor property 

To do:
- strip all relevant url params for building proper urls
- Insert custom links feaure
- Set all local vars in interceptor function scope!!
----------------------------------------------------------------------->
<!--- Get Event --->
<cfset rc = Event.getCollection()>

<cfhtmlhead text='<script language="javascript" src="includes/sidebar/sideBar.js" type="text/javascript"></script>' />
<cfhtmlhead text='<link rel="stylesheet" href="includes/sidebar/sideBar.css" type="text/css" media="screen">' />

<!--- 
START: TEMP
evdlinden: will be implemented in plugin or interceptor
 --->

<!--- Set Current URL --->
<cfset currentURL = "#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#">

<!--- REload framework --->
<cfset fwReInitHref = currentURL>
<cfif not REFindNoCase('fwreinit',CGI.QUERY_STRING)>
	<cfset fwReInitHref = currentURL & '&fwreinit=1'>
</cfif>
	
<!--- Enable/disable DebugMode --->
<cfset debugModeHref = currentURL & '&debugmode=#(not getDebugMode())#'>
<!--- Set DebugMode? --->

<!--- Boolean? --->
<cfif isBoolean( Event.getValue('debugmode','') )>
	<cfset setDebugMode(rc.debugmode)>
	<!--- Toggle debugmode --->
	<cfset url["debugmode"] = not getDebugMode()>
	<!--- Hold all url params, so we can generate the new querystring --->
	<cfset urlParams = ArrayNew(1)>
	<!--- Loop url StructKeyList and append to urlParams array --->
	<cfloop index="i" list="#StructKeyList(url)#">
		<!--- Strip fwreinit --->
		<cfif LCASE(i) neq "fwreinit">
			<cfset ArrayAppend(urlParams,'#i#=#url[i]#')>
		</cfif>
	</cfloop>
	<!--- Set debug href --->
	<cfset debugModeHref = CGI.SCRIPT_NAME & '?' & LCASE( ArrayToList(urlParams,"&") )>
</cfif>

<cfset cachePanelJs = "window.open('index.cfm?debugpanel=cache','cache','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=800')">
<cfset profilerJs = "window.open('index.cfm?debugpanel=profiler','profilermonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=800')">

<!--- Clear Cache? --->
<cfif isBoolean( Event.getValue('clearCache','') ) AND Event.getValue('clearCache','')>
	<cfset getColdboxOCM().expireAll()>
	<cfset clearCacheHref = currentURL & "&clearCache=0">
<cfelse>
	<cfset clearCacheHref = currentURL & "&clearCache=1">
</cfif>

<cfoutput>
<div id="SideBarContainer" style="visibility:hidden;position:absolute;left:0px;top:#sideBar.yOffset#px;z-index:20;width:#sideBar.width#px">
	<div id="SideBar" style="position:absolute;left:-#sideBar.invisibleWidth#px;top:0;z-Index:20;" onmouseover="moveOut()" onmouseout="moveBack()">
		<table border="0" cellpadding="0" cellspacing="0" width="#sideBar.width#">
			<tr>
				<td class="top" width="#sideBar.invisibleWidth#" nowrap><h1>Settings</h1></td>
				<td background="" rowspan="#(15 + ArrayLen(sideBar.links))#" width="#sideBar.visibleWidth#" nowrap class="bar" valign="middle" align="left"><img src="includes/sideBar/sideBar.png" width="22" height="160" border="0" /></td>
			</tr>
			<tr>
				<td><input type="checkbox" name="sbIsShowSideBar" value="1" checked><span class="checkboxlabel">Show SideBar</span></td>
			</tr>	
			<tr>
				<td><h1>Debug</h1></td>
			</tr>
			<tr>
				<td><input type="checkbox" name="sbIsShowDebugPanel" value="1" onclick="location.href='#debugModeHref#'" #iif(getDebugMode(),DE('checked'),'')#><span class="checkboxlabel">Show Debug Panel</span></td>
			</tr>	
			<tr>
				<td><span class="inputlabel">Dump Variable</span>
					<input type="text" name="sbDumpVar" value="" style="width:115px;">
				</td>
			</tr>	
			<!--- DebugMode? --->
			<cfif getDebugMode()>
			<tr>
				<td><a onclick="#cachePanelJs#">Open Cache Monitor</a></td>
			</tr>	
			<tr>
				<td><a onclick="#profilerJs#">Open Profiler Monitor</a></td>
			</tr>	
			</cfif>
			<tr>
				<td><h1>Reset</h1></td>
			</tr>
			<tr>
				<td><a href="#fwReInitHref#">Reload Framework</a></td>
			</tr>	
			<tr>
				<td><a href="#clearCacheHref#">Clear Cache</a></td>
			</tr>	
			<tr>
				<td><span class="inputlabel">Clear Scope</span>
				<select name="sbClearScope" size="1" style="width:75px;">
					<option value="session">Session</option>
					<option value="client">Client</option>
				</select>
				<input type="button" value="Clear">
				</td>
			</tr>	
			<tr>
				<td><a href="">Clear Log</a></td>
			</tr>	
			<tr>
				<td><h1>Help</h1></td>
			</tr>
			<tr>
				<td><a href="http://ortus.svnrepository.com/coldbox/trac.cgi" target="_blank">ColdBox Live Docs</a></td>
			</tr>	
			<tr>
				<td><a href="http://www.coldboxframework.com/api/" target="_blank">ColdBox API</a></td>
			</tr>	
			<tr>
				<td><a href="http://groups.google.com/group/coldbox" target="_blank">ColdBox Forums</a></td>
			</tr>	
			<tr>
				<td class="bottom"><a href="http://livedocs.adobe.com/coldfusion/8/htmldocs/help.html?content=Part_3_CFML_Ref_1.html" target="_blank">Coldfusion Live Docs</a></td>
			</tr>	
			<!--- Custom links? --->
			<cfif ArrayLen(sideBar.links)>
				<tr>
					<td><h1>My Links</h1></td>
				</tr>
				<!--- Loop custom links --->
				<cfloop index="i" from="1" to="#ArrayLen(sideBar.links)#">
				<tr>
					<td class="bottom"><a href="#sideBar.links[i].href#" target="_blank">#sideBar.links[i].desc#</a></td>
				</tr>						
				</cfloop>
			</cfif>
		</table>
	</div>
</div>	

<script type="text/javascript">
	slideSpeed=20 
	waitTime=100; 
	sideBarWidth=#sideBar.invisibleWidth#;
	setTimeout('initSideBar();', 1)
</script>
</cfoutput>