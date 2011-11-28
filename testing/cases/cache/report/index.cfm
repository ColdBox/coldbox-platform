<!--- Import Report Tags --->
<cfimport prefix="cachebox" taglib="/coldbox/system/cache/report">

<!--- Create CacheBox --->
<cfif structKeyExists(url,"reinit") OR NOT structKeyExists(application,"cacheBox")>
	<cfset configPath = "coldbox.testing.cases.cache.report.CacheBox">
	<cfset config     = createObject("component","coldbox.system.cache.config.CacheBoxConfig").init(CFCConfigPath=configPath)>
	<cfset application.cacheBox   = createObject("component","coldbox.system.cache.CacheFactory").init(config)>
	<cflocation url="index.cfm" addtoken="false" />
<cfelse>
	<cfset cachebox = application.cacheBox>
	<cfset default = cacheBox.getDefaultCache()>
	<cfscript>
		for(x=1; x lt 100; x++){
			default.set("Entry#x#", now(), randRange(1,200));
		}
	</cfscript>
</cfif>

<!--- Tests --->
<cfset default.get("Test")>
<cfset default.get("Entry2")>
<cfset default.get("Invalid")>

<cfoutput>
<html>

	<head>
		<title>CacheBox Monitor Tool</title>
	</head>
	<body>

	<!--- Special ToolBar --->
	<div id="toolbar">
		<input type="button" value="Reinit" onclick="window.location='index.cfm?reinit'"/>
		<p><b>CacheFactory</b> v#cacheBox.getVersion()# ID:#cacheBox.getFactoryID()#</p>
	</div>
	
	<!--- Render Report Here --->
	<cachebox:monitor cacheFactory="#cacheBox#"/>

	<!--- Footer --->
	<div id="footer">Copyright Ortus Solutions, Corp</div>
	</body>
</html>
</cfoutput>