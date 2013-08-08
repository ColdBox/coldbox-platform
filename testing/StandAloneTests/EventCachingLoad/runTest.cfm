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

<!--- set the URL's for our test --->
<cfset test1URL = #getWebURL()# & "index.cfm?event=general.index&cacheTest=FromTest1">
<cfset test2URL = #getWebURL()# & "index.cfm?event=general.index&cacheTest=FromTest2">
<cfset clearEventsURL = #getWebURL()# & "index.cfm?event=general.clearEvents">


<cfoutput>
	<!--- Run the second test in a cfthread so it happens at the same time as the second test --->
	<cfthread name="test1">
	<cfloop from="1" to="400" index="i">
		<cfhttp url="#test1URL#">
		<!--- random sleep time so they don't always run at the same time --->
		<cfset sleeptime = randRange(50,100)>
		<cfset sleep(#sleeptime#)>
		#cfhttp.filecontent#
	</cfloop>
	</cfthread>

	<!--- Run the second test in a cfthread so it happens at the same time as the first test --->
	<cfthread name="test2">
	<cfloop from="1" to="400" index="i">
		<cfhttp url="#test2URL#">
		<!--- random sleep time so they don't always run at the same time --->
		<cfset sleeptime = randRange(50,100)>
		<cfset sleep(#sleeptime#)>
		#cfhttp.filecontent#
	</cfloop>
	</cfthread>

	<!--- Run the clear in a cfthread it is clearing the cache at the same time the tests are running --->
	<cfthread name="clear">
	<cfloop from="1" to="40" index="i">
		<cfhttp url="#clearEventsURL#">
		<!--- clear the events from cache at random internals --->
		<cfset sleeptime = randRange(500,1000)>
		<cfset sleep(#sleeptime#)>
		#cfhttp.filecontent#
	</cfloop>
	</cfthread>

	<!--- Wait until all the tests finish, then join them together --->
	<cfthread name="test1,test2,clear" action="join" timeout="600000">

	<!--- Check the output from each of the tests for the output from the other test, if it exists, the test failed --->
	<cfif test1.output contains "FromTest2" OR test2.output contains "FromTest1">
		<h1 style="color:red;">Test Failed, a collision appeared</h1>
	<cfelse>
		<h1 style="color:blue;">Test Passed, no collisions appeared</h1>
	</cfif>

</cfoutput>