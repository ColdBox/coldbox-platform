<!---
	Name         : scopeCache
	Author       : Raymond Camden (jedimaster@mindseye.com)
	Created      : December 12, 2002
	Last Updated : November 6, 2003
	History      : Allow for clearAll (rkc 11/6/03)
				 : Added dependancies, timeout, other misc changes (rkc 1/8/04)
	Purpose		 : Allows you to cache content in various scopes.
	Documentation:
	
	This tag allows you to cache content and data in various RAM based scopes. 
	The tag takes the following attributes:

	name/cachename:	The name of the data. (required)
	scope: 			The scope where cached data will reside. Must be either session, 
					application, or server. (required)
	timeout: 		When the cache will timeout. By default, the year 3999 (i.e., never). 
					Value must be either a date/time stamp or a number representing the
					number of seconds until the timeout is reached. (optional)
	dependancies:	This allows you to mark other cache items as dependant on this item. 
					When this item is cleared or timesout, any child will also be cleared.
					Also, any children of those children will also be cleared. (optional)
	clear:			If passed and if true, will clear out the cached item. Note that
					this option will NOT recreate the cache. In other words, the rest of
					the tag isn't run (well, mostly, but don't worry).
	clearAll:		Removes all data from this scope. Exits the tag immidiately.
	disabled:		Allows for a quick exit out of the tag. How would this be used? You can 
					imagine using disabled="#request.disabled#" to allow for a quick way to
					turn on/off caching for the entire site. Of course, all calls to the tag
					would have to use the same value.

	License		 : Use this as you will. If you enjoy it and it helps your application, 
				   consider sending me something from my Amazon wish list:
				   http://www.amazon.com/o/registry/2TCL1D08EZEYE
--->
<cfprocessingdirective pageencoding="utf-8">

<!--- allow for quick exit --->
<cfif isDefined("attributes.disabled") and attributes.disabled>
	<cfexit method="exitTemplate">
</cfif>

<!--- Allow for cachename in case we use cfmodule --->
<cfif isDefined("attributes.cachename")>
	<cfset attributes.name = attributes.cachename>
</cfif>

<!--- Attribute validation --->
<cfif (not isDefined("attributes.name") or not isSimpleValue(attributes.name)) and not isDefined("attributes.clearall")>
	<cfthrow message="scopeCache: The name attribute must be passed as a string.">
</cfif>
<cfif not isDefined("attributes.scope") or not isSimpleValue(attributes.scope) or not listFindNoCase("application,session,server",attributes.scope)>
	<cfthrow message="scopeCache: The scope attribute must be passed as one of: application, session, or server.">
</cfif>

<!--- The default timeout is no timeout, so we use the year 3999. --->
<cfparam name="attributes.timeout" default="#createDate(3999,1,1)#">
<!--- Default dependancy list --->
<cfparam name="attributes.dependancies" default="" type="string">

<cfif not isDate(attributes.timeout) and (not isNumeric(attributes.timeout) or attributes.timeout lte 0)>
	<cfthrow message="scopeCache: The timeout attribute must be either a date/time or a number greather zero.">
<cfelseif isNumeric(attributes.timeout)>
	<!--- convert seconds to a time --->
	<cfset attributes.timeout = dateAdd("s",attributes.timeout,now())>
</cfif>

<!--- create pointer to scope --->
<cfset ptr = structGet(attributes.scope)>

<!--- init cache root --->
<cfif not structKeyExists(ptr,"scopeCache")>
	<cfset ptr["scopeCache"] = structNew()>
</cfif>

<cfif isDefined("attributes.clearAll")>
	<cfset structClear(ptr["scopeCache"])>
	<cfexit method="exitTag">
</cfif>

<!--- This variable will store all the guys we need to update --->
<cfset cleanup = "">
<!--- This variable determines if we run the caching. This is used when we clear a cache --->
<cfset dontRun = false>

<cfif isDefined("attributes.clear") and attributes.clear and structKeyExists(ptr.scopeCache,attributes.name) and thisTag.executionMode is "start">
	<cfset cleanup = ptr.scopeCache[attributes.name].dependancies>
	<cfset structDelete(ptr.scopeCache,attributes.name)>
	<cfset dontRun = true>
</cfif>

<cfif not dontRun>
	<cfif thisTag.executionMode is "start">
		<!--- determine if we have the info in cache already --->
		<cfif structKeyExists(ptr.scopeCache,attributes.name)>
			<cfif dateCompare(now(),ptr.scopeCache[attributes.name].timeout) is -1>
				<cfif not isDefined("attributes.r_Data")>
					<cfoutput>#ptr.scopeCache[attributes.name].value#</cfoutput>
				<cfelse>
					<cfset caller[attributes.r_Data] = ptr.scopeCache[attributes.name].value>
				</cfif>
				<cfexit>
			</cfif>
		</cfif>
	<cfelse>
		<!--- It is possible I'm here because I'm refreshing. If so, check my dependancies --->
		<cfif structKeyExists(ptr.scopeCache,attributes.name)>
			<cfset cleanup = listAppend(cleanup, ptr.scopeCache[attributes.name].dependancies)>
		</cfif>
		<cfset ptr.scopeCache[attributes.name] = structNew()>
		<cfif not isDefined("attributes.data")>
			<cfset ptr.scopeCache[attributes.name].value = thistag.generatedcontent>
		<cfelse>
			<cfset ptr.scopeCache[attributes.name].value = attributes.data>
		</cfif>
		<cfset ptr.scopeCache[attributes.name].timeout = attributes.timeout>
		<cfset ptr.scopeCache[attributes.name].dependancies = attributes.dependancies>
		<cfif isDefined("attributes.r_Data")>
			<cfset caller[attributes.r_Data] = ptr.scopeCache[attributes.name].value>
		</cfif>
	</cfif>
</cfif>

<!--- Do I need to clean up? --->
<cfset z = 1>
<cfloop condition="listLen(cleanup)">
	<cfset z = z+1><cfif z gt 100><cfthrow message="ack"></cfif>
	<cfset toKill = listFirst(cleanup)>
	<cfset cleanUp = listRest(cleanup)>
	<cfif structKeyExists(ptr.scopeCache, toKill)>
		<cfloop index="item" list="#ptr.scopeCache[toKill].dependancies#">
			<cfif not listFindNoCase(cleanup, item)>
				<cfset cleanup = listAppend(cleanup, item)>
			</cfif>
		</cfloop>
		<cfset structDelete(ptr.scopeCache,toKill)>
	</cfif>
</cfloop>