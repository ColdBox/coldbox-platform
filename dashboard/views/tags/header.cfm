<cfoutput>
<div class="logo"></div>

<div class="headerbar">

	<div style="float:right;clear:both;margin-right:10px">
		<!--- HOME --->
		<div id="topbuttons" >
			<a href="?event=#Event.getValue("xehHome")#" target="mainframe" onmouseover="rollover('btn_home')" onmouseout="rollout('btn_home')"><img  src="images/icons/home.gif" border="0" id="btn_home" srcoff="images/icons/home.gif" srcon="images/icons/home_on.gif"><br>
			Home</a>
		</div>
		<!--- SETTINGS --->
		<div id="topbuttons" >
			<a href="?event=#Event.getValue("xehSettings")#" target="mainframe" onmouseover="rollover('btn_settings')" onmouseout="rollout('btn_settings')"><img  src="images/icons/settings.gif" border="0" id="btn_settings" srcoff="images/icons/settings.gif" srcon="images/icons/settings_on.gif"><br>
			Settings</a>
		</div>
		<!--- TOOLS
		<div id="topbuttons" >
			<a href="?event=#Event.getValue("xehTools")#" target="mainframe" onmouseover="rollover('btn_tools')" onmouseout="rollout('btn_tools')"><img  src="images/icons/tools.gif" border="0" id="btn_tools" srcoff="images/icons/tools.gif" srcon="images/icons/tools_on.gif"><br>
			Tools</a>
		</div>--->
		<!--- BD/CFADMIN --->
		<cfif not getColdboxOCM().get("isBD")>
		<div id="topbuttons" >
			<a href="/CFIDE/administrator/login.cfm" target="_blank" onmouseover="rollover('btn_cfadmin')" onmouseout="rollout('btn_cfadmin')"><img  src="images/icons/cfadmin.gif" border="0" id="btn_cfadmin" srcoff="images/icons/cfadmin.gif" srcon="images/icons/cfadmin_on.gif"><br>
			CF Admin</a>
		</div>
		<cfelse>
		<div id="topbuttons" >
			<a href="/bluedragon" target="mainframe" onmouseover="rollover('btn_bd')" onmouseout="rollout('btn_bd')"><img  src="images/icons/bluedragon.gif" border="0" id="btn_bd" srcoff="images/icons/bluedragon.gif" srcon="images/icons/bluedragon_on.gif"><br>
			BlueDragon</a>
		</div>
		</cfif>
		<!--- UPDATE --->
		<div id="topbuttons">
			<a href="?event=#Event.getValue("xehUpdate")#" target="mainframe" onmouseover="rollover('btn_update')" onmouseout="rollout('btn_update')"><img  src="images/icons/update.gif" border="0" id="btn_update" srcoff="images/icons/update.gif" srcon="images/icons/update_on.gif"><br>
			Update</a>
		</div>
		<!--- BUG REPORTS --->
		<div id="topbuttons">
			<a href="?event=#Event.getValue("xehBugs")#" target="mainframe" onmouseover="rollover('btn_bugs')" onmouseout="rollout('btn_bugs')"><img  src="images/icons/bugreports.gif" border="0" id="btn_bugs" srcoff="images/icons/bugreports.gif" srcon="images/icons/bugreports_on.gif"><br>
			Submit Bug</a>
		</div>
	</div>

</div>

<div class="statusbar">
	<form id="searchdocs" name="searchdocs" action="#getSetting("tracsite")#trac.cgi/search" method="get" target="mainframe">

	<div class="browserbuttonsbar">
		<cfif not findnocase("MSIE",cgi.HTTP_USER_AGENT)>
		<a href="javascript:parent.mainframe.history.back()" title="Go Back!" ><img src="images/icons/back_browser.gif" border="0" align="absmiddle" id="btn_browserback" srcoff="images/icons/back_browser.gif" srcon="images/icons/back_browser_on.gif" onMouseOver="rollover(this)" onMouseOut="rollout(this)"></a>
		<a href="javascript:parent.mainframe.history.forward()" title="Go Forward!"><img src="images/icons/forward_browser.gif" border="0" align="absmiddle" id="btn_browserforward" srcoff="images/icons/forward_browser.gif" srcon="images/icons/forward_browser_on.gif" onMouseOver="rollover(this)" onMouseOut="rollout(this)"></a>
		&nbsp;
		</cfif>
		<input type="text" name="q" size="20" accesskey="s" value="Search Docs" style="font-size:9px" onclick="(this.value=='Search Docs')?this.value='':null" title="Search the documentation, tickets and changeset" onBlur="(this.value=='')?this.value='Search Docs':null" />
		<a href="javascript:document.searchdocs.submit()" title="Search!"><img src="images/icons/search_icon.gif" align="absmiddle" border="0" alt="Search"></a>
	</div>

	<div id="myloader" style="display: none">
		<div class="myloader"><img src="images/ajax-loader.gif" width="220" height="19" align="absmiddle" title="Loading..." /></div>
	</div>
	</form>
</div>
</cfoutput>