<!---
	Name         : thread.cfc
	Author       : Raymond Camden 
	Created      : January 26, 2005
	Last Updated : July 27, 2006
	History      : Support for dbtype, and uuid (rkc 1/26/05)
				   New init, tableprefix (rkc 8/27/05)
				   Sticky (rkc 8/29/05)
				   Access dbs did stickies wrong, return conf on getall (rkc 9/9/05)
				   Remove from subscriptions (rkc 11/22/05)
				   limit search length (rkc 10/30/05)
				   show last user (rkc 7/12/06)
				   Simple size change (rkc 7/27/06)
	Purpose		 : 
--->
<cfcomponent displayName="Thread" hint="Handles Threads which contain a collection of message.">

	<cfset variables.dsn = "">
	<cfset variables.dbtype = "">
	<cfset variables.tableprefix = "">
	<cfset variables.settings = "">
	
	<cfset variables.utils = createObject("component","utils")>
		
	<cffunction name="init" access="public" returnType="thread" output="false"
				hint="Returns an instance of the CFC initialized with the correct DSN.">
		<cfargument name="settings" type="struct" required="true" hint="Setting">
				
		<cfset variables.dsn = arguments.settings.dsn>
		<cfset variables.dbtype = arguments.settings.dbtype>
		<cfset variables.tableprefix = arguments.settings.tableprefix>
		<!--- keep a global copy to pass later on --->
		<cfset variables.settings = arguments.settings>
		
		<cfreturn this>
		
	</cffunction>

	<cffunction name="addThread" access="remote" returnType="uuid" output="false"
				hint="Adds a thread.">
				
		<cfargument name="thread" type="struct" required="true">
		<cfset var newthread = "">
		<cfset var newid = createUUID()>
				
		<!--- First see if we can add a thread. Because roles= doesn't allow for OR, we use a UDF --->
		<cfif not variables.utils.isUserInAnyRole2("forumsadmin,forumsmoderator,forumsmember")>
			<cfset variables.utils.throw("ThreadCFC","Unauthorized execution of addThread.")>
		</cfif>
		
		<cfif not validThread(arguments.thread)>
			<cfset variables.utils.throw("ThreadCFC","Invalid data passed to addThread.")>
		</cfif>
		
		<cfquery name="newthread" datasource="#variables.dsn#">
			insert into #variables.tableprefix#threads(id,name,readonly,active,forumidfk,useridfk,datecreated,sticky)
			values(<cfqueryparam value="#newid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
				   <cfqueryparam value="#arguments.thread.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
				   <cfqueryparam value="#arguments.thread.readonly#" cfsqltype="CF_SQL_BIT">,
				   <cfqueryparam value="#arguments.thread.active#" cfsqltype="CF_SQL_BIT">,
				   <cfqueryparam value="#arguments.thread.forumidfk#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
   				   <cfqueryparam value="#arguments.thread.useridfk#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
				   <cfqueryparam value="#arguments.thread.datecreated#" cfsqltype="CF_SQL_TIMESTAMP">,
   				   <cfqueryparam value="#arguments.thread.sticky#" cfsqltype="CF_SQL_BIT">
				   )
		</cfquery>
		
		<cfreturn newid>
	</cffunction>
	
	<cffunction name="deleteThread" access="public" returnType="void" roles="forumsadmin" output="false"
				hint="Deletes a thread along with all of it's children.">

		<cfargument name="id" type="uuid" required="true">
		
		<!--- delete kids --->
		<cfset var messageCFC = createObject("component","message").init(variables.settings)>
		<cfset var msgKids = messageCFC.getMessages(arguments.id)>
		
		<cfloop query="msgKids">
			<cfset messageCFC.deleteMessage(msgKids.id)>
		</cfloop>

		<cfquery datasource="#variables.dsn#">
			delete	from #variables.tableprefix#threads
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
		<!--- clean up subscriptions --->
		<cfquery datasource="#variables.dsn#">
			delete	from #variables.tableprefix#subscriptions
			where	threadidfk = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>
	
	<cffunction name="getThread" access="remote" returnType="struct" output="false"
				hint="Returns a struct copy of the thread.">
		<cfargument name="id" type="uuid" required="true">
		<cfset var qGetThread = "">
				
		<cfquery name="qGetThread" datasource="#variables.dsn#">
			select	id, name, readonly, active, forumidfk, useridfk, datecreated, sticky
			from	#variables.tableprefix#threads
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

		<!--- Throw if invalid id passed --->
		<cfif not qGetThread.recordCount>
			<cfset variables.utils.throw("ThreadCFC","Invalid ID")>
		</cfif>
		
		<!--- Only a ForumsAdmin can get bActiveOnly=false --->
		<cfif not qGetThread.active and not isUserInRole("forumsadmin")>
			<cfset variables.utils.throw("ThreadCFC","Invalid call to getThread")>
		</cfif>
		
		<cfreturn variables.utils.queryToStruct(qGetThread)>
			
	</cffunction>
		
	<cffunction name="getThreads" access="remote" returnType="query" output="false"
				hint="Returns a list of threads.">

		<cfargument name="bActiveOnly" type="boolean" required="false" default="true">
		<cfargument name="forumid" type="uuid" required="false">
		
		<cfset var qGetThreads = "">
		<cfset var getLastUser = "">
		
		<!--- Only a ForumsAdmin can be bActiveOnly=false --->
		<cfif not arguments.bActiveOnly and not isUserInRole("forumsadmin")>
			<cfset variables.utils.throw("ThreadCFC","Invalid call to getThreads")>
		</cfif>
		
		<cfquery name="qGetThreads" datasource="#variables.dsn#">
		select #variables.tableprefix#threads.id, #variables.tableprefix#threads.name, #variables.tableprefix#threads.readonly, 
		#variables.tableprefix#threads.active, #variables.tableprefix#threads.forumidfk, #variables.tableprefix#threads.useridfk, 
		#variables.tableprefix#threads.datecreated, #variables.tableprefix#forums.name as forum, #variables.tableprefix#users.username,
		max(#variables.tableprefix#messages.posted) as lastpost, count(#variables.tableprefix#messages.id) as messagecount, #variables.tableprefix#threads.sticky,
		#variables.tableprefix#conferences.name as conference
		from (((#variables.tableprefix#threads left join #variables.tableprefix#messages on #variables.tableprefix#threads.id = #variables.tableprefix#messages.threadidfk) 
		inner join #variables.tableprefix#forums on #variables.tableprefix#threads.forumidfk = #variables.tableprefix#forums.id)
		inner join #variables.tableprefix#conferences on #variables.tableprefix#forums.conferenceidfk = #variables.tableprefix#conferences.id)

		inner join #variables.tableprefix#users on #variables.tableprefix#threads.useridfk = #variables.tableprefix#users.id

		where 1=1 
		<cfif arguments.bActiveOnly>
			and		#variables.tableprefix#threads.active = 1
		</cfif>
		<cfif isDefined("arguments.forumid")>
			and		#variables.tableprefix#threads.forumidfk = <cfqueryparam value="#arguments.forumid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfif>

		group by #variables.tableprefix#threads.id, #variables.tableprefix#threads.name, #variables.tableprefix#threads.readonly, #variables.tableprefix#threads.active, 
    	#variables.tableprefix#threads.forumidfk, #variables.tableprefix#threads.useridfk, #variables.tableprefix#threads.datecreated, #variables.tableprefix#forums.name, #variables.tableprefix#users.username, #variables.tableprefix#threads.sticky, #variables.tableprefix#conferences.name

		order by #variables.tableprefix#threads.sticky <cfif variables.dbtype is not "msaccess">desc<cfelse>asc</cfif>,
		<cfif variables.dbtype is not "mysql">
			max(#variables.tableprefix#messages.posted) desc		
		<cfelse>
			lastpost desc
		</cfif>
		</cfquery>

		<!--- My ugly hack to add useridfk. There must be a better way to do this. --->
		<cfset queryAddColumn(qGetThreads, "lastuseridfk", arrayNew(1))>
		<cfloop query="qGetThreads">
			<cfif len(lastpost)>
				<cfquery name="getLastUser" datasource="#variables.dsn#">
				select	useridfk
				from	#variables.tableprefix#messages
				where	threadidfk = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#" maxlength="35">
				and		posted = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#lastpost#">
				</cfquery>
				<cfset querySetCell(qGetThreads, "lastuseridfk", getLastUser.useridfk, currentRow)>
			</cfif>
		</cfloop>
		
		<cfreturn qGetThreads>
			
	</cffunction>
	
	<cffunction name="saveThread" access="remote" returnType="void" roles="forumsadmin" output="false"
				hint="Saves an existing thread.">
				
		<cfargument name="id" type="uuid" required="true">
		<cfargument name="thread" type="struct" required="true">
		
		<cfif not validThread(arguments.thread)>
			<cfset variables.utils.throw("ThreadCFC","Invalid data passed to saveThread.")>
		</cfif>
		
		<cfquery datasource="#variables.dsn#">
			update	#variables.tableprefix#threads
			set		name = <cfqueryparam value="#arguments.thread.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
					readonly = <cfqueryparam value="#arguments.thread.readonly#" cfsqltype="CF_SQL_BIT">,
					active = <cfqueryparam value="#arguments.thread.active#" cfsqltype="CF_SQL_BIT">,
					forumidfk = <cfqueryparam value="#arguments.thread.forumidfk#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
					useridfk = <cfqueryparam value="#arguments.thread.useridfk#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
					datecreated = <cfqueryparam value="#arguments.thread.datecreated#" cfsqltype="CF_SQL_TIMESTAMP">,
					sticky = <cfqueryparam value="#arguments.thread.sticky#" cfsqltype="CF_SQL_BIT">
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>

	<cffunction name="search" access="remote" returnType="query" output="false"
				hint="Allows you to search threads.">
		<cfargument name="searchterms" type="string" required="true">
		<cfargument name="searchtype" type="string" required="false" default="phrase" hint="Must be: phrase,any,all">
		
		<cfset var results  = "">
		<cfset var x = "">
		<cfset var joiner = "">	
		<cfset var aTerms = "">

		<cfset arguments.searchTerms = variables.utils.searchSafe(arguments.searchTerms)>
	
		<!--- massage search terms into an array --->		
		<cfset aTerms = listToArray(arguments.searchTerms," ")>
		
		
		<!--- confirm searchtype is ok --->
		<cfif not listFindNoCase("phrase,any,all", arguments.searchtype)>
			<cfset arguments.searchtype = "phrase">
		<cfelseif arguments.searchtype is "any">
			<cfset joiner = "OR">
		<cfelseif arguments.searchtype is "all">
			<cfset joiner = "AND">
		</cfif>
		
		<cfquery name="results" datasource="#variables.dsn#">
			select	id, name
			from	#variables.tableprefix#threads
			where	active = 1
			and (
				<cfif arguments.searchtype is not "phrase">
					<cfloop index="x" from=1 to="#arrayLen(aTerms)#">
						(name like <cfqueryparam cfsqltype="CF_SQL_VARCHAR" maxlength="255" value="%#left(aTerms[x],255)#%">)
						 <cfif x is not arrayLen(aTerms)>#joiner#</cfif>
					</cfloop>
				<cfelse>
					name like <cfqueryparam cfsqltype="CF_SQL_VARCHAR" maxlength="255" value="%#left(arguments.searchTerms,255)#%">
				</cfif>
			)
		</cfquery>
		
		<cfreturn results>
	</cffunction>
	
	<cffunction name="validThread" access="private" returnType="boolean" output="false"
				hint="Checks a structure to see if it contains all the proper keys/values for a thread.">
		
		<cfargument name="cData" type="struct" required="true">
		<cfset var rList = "name,readonly,active,forumidfk,useridfk,datecreated,sticky">
		<cfset var x = "">
		
		<cfloop index="x" list="#rList#">
			<cfif not structKeyExists(cData,x)>
				<cfreturn false>
			</cfif>
		</cfloop>
		
		<cfreturn true>
		
	</cffunction>
</cfcomponent>