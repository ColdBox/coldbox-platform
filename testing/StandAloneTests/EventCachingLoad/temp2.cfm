<cffunction name="getWebURL" access="public" output="false" returntype="string" hint="Gets the absolute path to the current web folder.">
    <cfargument name="url" required="false" default="#getPageContext().getRequest().getRequestURI()#" hint="Defaults to the current path_info" />
    <cfargument name="ext" required="false" default="\.(cfml?.*|html?.*|[^.]+)" hint="Define the regex to find the extension. The default will work in most cases, unless you have really funky urls like: /folder/file.cfm/extra.path/info" />
    <!---// trim the path to be safe //--->
    <cfset var sPath = trim(arguments.url) />
	<cfset var returnURL = "">
    <!---// find the where the filename starts (should be the last wherever the last period (".") is) //--->
    <cfset var sEndDir = reFind("/[^/]+#arguments.ext#$", sPath) />
	<cfset sPath = left(sPath, sEndDir) />
	<cfset returnURL = "http://" & cgi.http_host & sPath />
    <cfreturn returnURL />
</cffunction>

<cfoutput>
	<cfset myURL = #getWebURL()# & "index.cfm?event=general.index&cacheTest=FromTemp2">
	<cfloop from="1" to="400" index="i">
		<cfhttp url="#myURL#">
		<cfset sleep(100)>
		#cfhttp.filecontent#
	</cfloop>
</cfoutput>