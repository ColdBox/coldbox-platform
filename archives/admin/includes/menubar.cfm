<cfoutput>
<cfset setClass = "menuItem">
<cfif findnocase("home", getValue("event"))>
	<cfset setClass = "menuItemOn">
</cfif>
<div class="#setclass#">
<a href="index.cfm?event=ehColdbox.dspHome">#getresource("home")#</a>
</div>

<cfset setClass = "menuItem">
<cfif findnocase("ConfigEditor", getValue("event"))>
	<cfset setClass = "menuItemOn">
</cfif>
<div class="#setClass#">
<a href="index.cfm?event=ehColdbox.dspConfigEditor">#getresource("configeditor")# </a>
</div>

<cfset setClass = "menuItem">
<cfif findnocase("api", getValue("event"))>
	<cfset setClass = "menuItemOn">
</cfif>
<div class="#setClass#">
<a href="index.cfm?event=ehColdbox.dspAPI">#getresource("myapi")#</a>
</div>

<cfset setClass = "menuItem">
<cfif findnocase("backups", getValue("event"))>
	<cfset setClass = "menuItemOn">
</cfif>
<div class="#setClass#">
<a href="index.cfm?event=ehColdbox.dspBackups">#getresource("backupspanel")# </a>
</div>

<!--- ****************************************************************************** --->
<!--- Guides start --->
<!--- ****************************************************************************** --->
<cfset setClass = "menuItem">
<cfif findnocase("help", getValue("event"))>
	<cfset setClass = "menuItemOn">
</cfif>
<div class="#setClass#">
<a href="javascript:toggleGuides()">#getresource("guides_menu")# </a>
</div>

<div id="help_guides_div" class="hidelayer">
	<cfset setClass = "menuItem">
	<cfif findnocase("ConfigHelp", getValue("event"))>
		<cfset setClass = "menuItemOn">
	</cfif>
	<div class="#setClass#">
	<a href="index.cfm?event=ehColdbox.dspConfigHelp">#getresource("configxmlguide")# </a>
	</div>
	
	<cfset setClass = "menuItem">
	<cfif findnocase("settings", getValue("event"))>
		<cfset setClass = "menuItemOn">
	</cfif>
	<div class="#setClass#">
	<a href="index.cfm?event=ehColdbox.dspSettings">#getresource("settingsguide")# </a>
	</div>
	
	<cfset setClass = "menuItem">
	<cfif findnocase("handlersHelp", getValue("event"))>
		<cfset setClass = "menuItemOn">
	</cfif>
	<div class="#setClass#">
	<a href="index.cfm?event=ehColdbox.dspHandlersHelp">#getresource("eventhandlersguide")# </a>
	</div>
</div>

<!--- ****************************************************************************** --->
<!--- end of guides --->
<!--- ****************************************************************************** --->

<cfset setClass = "menuItem">
<cfif findnocase("modifyLog", getValue("event"))>
	<cfset setClass = "menuItemOn">
</cfif>
<div class="#setclass#">
<a href="index.cfm?event=ehColdbox.dspModifyLog">#getresource("readme")# </a>
</div>

<cfset setClass = "menuItem">
<cfif findnocase("password", getValue("event"))>
	<cfset setClass = "menuItemOn">
</cfif>
<div class="#setClass#">
<a href="index.cfm?event=ehColdbox.dspPassword">#getresource("changepassword")# </a>
</div>

<div class="menuItem">
<a href="javascript:logout()">#getresource("logout")#</a>
</div>
</cfoutput>