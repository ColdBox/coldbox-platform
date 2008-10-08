<!---
	Name         : message.cfc
	Author       : Raymond Camden 
	Created      : January 25, 2005
	Last Updated : November 5, 2006
	History      : Support dbtype, switched to UUID (rkc 1/25/05)
				   Fix use of top in mysql (rkc 2/3/05)
				   getConferences can now get msgcount, lastpost (rkc 4/4/05)
   				   New init, use of table prefix (rkc 8/27/05)
				   query returns threadid of last post. thanks to shlomy! (rkc 9/15/05)
				   limit length of search term (rkc 10/30/05)
				   clean up subscriptions (rkc 11/22/05)
				   show last user for post, other small fixes (rkc 7/12/06)
				   Simple size change (rkc 7/27/06)
				   Note to myself on bug to look into (rkc 11/3/06)
				   Reverted description to text field (rkc 11/5/06) 
	Purpose		 : 
--->
<cfcomponent displayName="Conference" hint="Handles Conferences, the highest level container for Forums.">

	<cfset variables.dsn = "">
	<cfset variables.dbtype = "">
	<cfset variables.tableprefix = "">
	<cfset variables.utils = createObject("component","utils")>
		
	<cffunction name="init" access="public" returnType="conference" output="false"
				hint="Returns an instance of the CFC initialized with the correct DSN.">
		<cfargument name="settings" type="struct" required="true" hint="Setting">
						
		<cfset variables.dsn = arguments.settings.dsn>
		<cfset variables.dbtype = arguments.settings.dbtype>
		<cfset variables.tableprefix = arguments.settings.tableprefix>
		
		<cfset variables.forum = createObject("component","forum").init(arguments.settings)>

		<cfreturn this>
		
	</cffunction>

	<cffunction name="addConference" access="remote" returnType="uuid" roles="forumsadmin" output="false"
				hint="Adds a conference.">
				
		<cfargument name="conference" type="struct" required="true">
		<cfset var newconference = "">
		<cfset var newid = createUUID()>
		
		<cfif not validConference(arguments.conference)>
			<cfset variables.utils.throw("ConferenceCFC","Invalid data passed to addConference.")>
		</cfif>
		
		<cfquery name="newconference" datasource="#variables.dsn#">
			insert into #variables.tableprefix#conferences(id,name,description,active)
			values(<cfqueryparam value="#newid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
				   <cfqueryparam value="#arguments.conference.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
				   <cfqueryparam value="#arguments.conference.description#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
				   <cfqueryparam value="#arguments.conference.active#" cfsqltype="CF_SQL_BIT">
				   )
		</cfquery>
		
		<cfreturn newid>
		
	</cffunction>
	
	<cffunction name="deleteConference" access="public" returnType="void" roles="forumsadmin" output="false"
				hint="Deletes a conference along with all of it's children.">

		<cfargument name="id" type="uuid" required="true">
		<cfset var forumKids = "">
				
		<!--- first, delete my children --->
		<cfset forumKids = variables.forum.getForums(false,arguments.id)>
		<cfloop query="forumKids">
			<cfset variables.forum.deleteForum(forumKids.id)>
		</cfloop>
		
		<cfquery datasource="#variables.dsn#">
			delete	from #variables.tableprefix#conferences
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

		<!--- clean up subscriptions --->
		<cfquery datasource="#variables.dsn#">
			delete	from #variables.tableprefix#subscriptions
			where	conferenceidfk = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>

	<cffunction name="getConference" access="remote" returnType="struct" output="false"
				hint="Returns a struct copy of the conferene.">
		<cfargument name="id" type="uuid" required="true">
		<cfset var qGetConference = "">
				
		<cfquery name="qGetConference" datasource="#variables.dsn#">
			select	id, name, description, active
			from	#variables.tableprefix#conferences
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

		<!--- Throw if invalid id passed --->
		<cfif not qGetConference.recordCount>
			<cfset variables.utils.throw("ConferenceCFC","Invalid ID")>
		</cfif>
		
		<!--- Only a ForumsAdmin can get bActiveOnly=false --->
		<cfif not qGetConference.active and not isUserInRole("forumsadmin")>
			<cfset variables.utils.throw("ConferenceCFC","Invalid call to getConferfence")>
		</cfif>
		
		<cfreturn variables.utils.queryToStruct(qGetConference)>
			
	</cffunction>
		
	<cffunction name="getConferences" access="remote" returnType="query" output="false"
				hint="Returns a list of conferences.">

		<cfargument name="bActiveOnly" type="boolean" required="false" default="true">
		<cfset var qGetConferences = "">
		
		<!--- Only a ForumsAdmin can be bActiveOnly=false --->
		<cfif not arguments.bActiveOnly and not isUserInRole("forumsadmin")>
			<cfset variables.utils.throw("ConferenceCFC","Invalid call to getConferfences")>
		</cfif>
		
		<cfquery name="qGetConferences" datasource="#variables.dsn#">
			select #variables.tableprefix#conferences.id,#variables.tableprefix#conferences.name, #variables.tableprefix#conferences.description, 
			#variables.tableprefix#conferences.active, Count(#variables.tableprefix#messages.id) AS messagecount, max(#variables.tableprefix#messages.posted)
			as lastpost,
			(
			select threadidfk from #variables.tableprefix#messages m where  m.posted = (SELECT max(mm.posted)
			as lastpost
			from ((#variables.tableprefix#conferences c left JOIN #variables.tableprefix#forums f ON c.id = f.conferenceidfk) left
			join #variables.tableprefix#threads t  ON f.id = t.forumidfk) left JOIN #variables.tableprefix#messages mm ON t.id =
			mm.threadidfk  where c.id = #variables.tableprefix#conferences.id )
			) as threadidfk,
(
select useridfk from #variables.tableprefix#messages m where  m.posted = (SELECT
max(mm.posted) as lastpost from ((#variables.tableprefix#conferences c left JOIN
#variables.tableprefix#forums f ON c.id = f.conferenceidfk) left join #variables.tableprefix#threads t  ON
f.id = t.forumidfk) left JOIN #variables.tableprefix#messages mm ON t.id = mm.threadidfk
where c.id = #variables.tableprefix#conferences.id )
) as useridfk
			from ((#variables.tableprefix#conferences left JOIN #variables.tableprefix#forums ON #variables.tableprefix#conferences.id =
			#variables.tableprefix#forums.conferenceidfk) left JOIN #variables.tableprefix#threads ON #variables.tableprefix#forums.id = #variables.tableprefix#threads.forumidfk)
			left JOIN #variables.tableprefix#messages ON #variables.tableprefix#threads.id = #variables.tableprefix#messages.threadidfk
			<cfif arguments.bActiveOnly>
			where	#variables.tableprefix#conferences.active = 1
			</cfif>
			GROUP BY #variables.tableprefix#conferences.id,#variables.tableprefix#conferences.name, #variables.tableprefix#conferences.description,
			#variables.tableprefix#conferences.active
			order by #variables.tableprefix#conferences.name
		</cfquery>
		
		<!---
		TODO: 
		
		I discovered a bug that crops up where 2 messages for the same conf have the same date. Need to ping my man Schlomy
		<cfquery name="qGetConfs" datasource="#variables.dsn#">
				select	#variables.tableprefix#conferences.id,#variables.tableprefix#conferences.name, #variables.tableprefix#conferences.description, 
			   	#variables.tableprefix#conferences.active, count(#variables.tableprefix#messages.id) AS messagecount, max(#variables.tableprefix#messages.posted) as lastpost
			from ((#variables.tableprefix#conferences left JOIN #variables.tableprefix#forums ON #variables.tableprefix#conferences.id =
			#variables.tableprefix#forums.conferenceidfk) left JOIN #variables.tableprefix#threads ON #variables.tableprefix#forums.id = #variables.tableprefix#threads.forumidfk)
			left JOIN #variables.tableprefix#messages ON #variables.tableprefix#threads.id = #variables.tableprefix#messages.threadidfk
			<cfif arguments.bActiveOnly>
			where	#variables.tableprefix#conferences.active = 1
			</cfif>
			GROUP BY #variables.tableprefix#conferences.id,#variables.tableprefix#conferences.name, #variables.tableprefix#conferences.description,
			#variables.tableprefix#conferences.active

			order by #variables.tableprefix#conferences.name
		</cfquery>
		
		<cfset queryAddColumn(qGetConfs, "threadidfk", arrayNew(1))>
		<cfset queryAddColumn(qGetConfs, "useridfk", arrayNew(1))>

		<cfloop query="qGetConfs">
		
			<cfquery name="test" datasource="#variables.dsn#">
			select threadidfk from #variables.tableprefix#messages m where  m.posted = 
			(
				SELECT max(mm.posted) 	as lastpost
				from ((#variables.tableprefix#conferences c left JOIN #variables.tableprefix#forums f ON c.id = f.conferenceidfk) left
				join #variables.tableprefix#threads t  ON f.id = t.forumidfk) left JOIN #variables.tableprefix#messages mm ON t.id =
				mm.threadidfk  where c.id = #variables.tableprefix#conferences.id 
			)
			
			<cfquery name="getForums" datasource="#variables.dsn#">
			select	id
			from	#variables.tableprefix#forums
			where	conferenceidfk = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
			</cfquery>
			
			<cfif getForums.recordCount>

				<cfquery name="q" datasource="#variables.dsn#" >
				select	max(datecreated) as lastpost
				from	#variables.tableprefix#threads
				where	forumidfk in (<cfqueryparam cfsqltype="cf_sql_varchar" value="#valueList(getForums.id)#" list="true">)
				</cfquery>
				
				<cfset querySetCell(qGetConfs, "threadidfk", q.lastpost, currentRow)>
			</cfif>
		</cfloop>
		--->
		
		<cfreturn qGetConferences>
			
	</cffunction>
	
	<cffunction name="getLatestPosts" access="remote" returnType="query" output="false"
				hint="Retrieve the last 20 posts to any threads in forums in this conference.">
		<cfargument name="conferenceid" type="uuid" required="true">
		<cfset var qLatestPosts = "">
		
		<cfquery name="qLatestPosts" datasource="#variables.dsn#">
			select		
				<cfif variables.dbtype is not "mysql">
				top 20 
				</cfif>
						#variables.tableprefix#messages.title, #variables.tableprefix#threads.name as thread, #variables.tableprefix#messages.posted, #variables.tableprefix#users.username, #variables.tableprefix#messages.threadidfk as threadid, #variables.tableprefix#messages.body
			from		#variables.tableprefix#messages, #variables.tableprefix#threads, #variables.tableprefix#users, #variables.tableprefix#forums
			where		#variables.tableprefix#messages.threadidfk = #variables.tableprefix#threads.id
			and			#variables.tableprefix#messages.useridfk = #variables.tableprefix#users.id
			and			#variables.tableprefix#threads.forumidfk = #variables.tableprefix#forums.id
			and			#variables.tableprefix#forums.conferenceidfk = <cfqueryparam value="#arguments.conferenceid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			order by	#variables.tableprefix#messages.posted desc
				<cfif variables.dbtype is "mysql">
				limit 20
				</cfif>
		</cfquery>
		
		<cfreturn qLatestPosts>
	</cffunction>
	
	<cffunction name="saveConference" access="remote" returnType="void" roles="forumsadmin" output="false"
				hint="Saves an existing conference.">
				
		<cfargument name="id" type="uuid" required="true">
		<cfargument name="conference" type="struct" required="true">
		
		<cfif not validConference(arguments.conference)>
			<cfset variables.utils.throw("ConferfenceCFC","Invalid data passed to saveConference.")>
		</cfif>
		
		<cfquery datasource="#variables.dsn#">
			update	#variables.tableprefix#conferences
			set		name = <cfqueryparam value="#arguments.conference.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
					description = <cfqueryparam value="#arguments.conference.description#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
					active = <cfqueryparam value="#arguments.conference.active#" cfsqltype="CF_SQL_BIT">
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>
	
	<cffunction name="search" access="remote" returnType="query" output="false"
				hint="Allows you to search conferences.">
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
			select	id, name, description
			from	#variables.tableprefix#conferences
			where	active = 1
			and (
				<cfif arguments.searchtype is not "phrase">
					<cfloop index="x" from=1 to="#arrayLen(aTerms)#">
						(name like <cfqueryparam cfsqltype="CF_SQL_VARCHAR" maxlength="255" value="%#left(aTerms[x],255)#%"> 
						 or
						 description like '%#aTerms[x]#%')
						 <cfif x is not arrayLen(aTerms)>#joiner#</cfif>
					</cfloop>
				<cfelse>
					name like <cfqueryparam cfsqltype="CF_SQL_VARCHAR" maxlength="255" value="%#left(arguments.searchTerms,255)#%">
					or
					description like '%#arguments.searchTerms#%'
				</cfif>
			)
		</cfquery>
		
		<cfreturn results>
	</cffunction>
	
	<cffunction name="validConference" access="private" returnType="boolean" output="false"
				hint="Checks a structure to see if it contains all the proper keys/values for a conference.">
		
		<cfargument name="cData" type="struct" required="true">
		<cfset var rList = "name,description,active">
		<cfset var x = "">
		
		<cfloop index="x" list="#rList#">
			<cfif not structKeyExists(cData,x)>
				<cfreturn false>
			</cfif>
		</cfloop>
		
		<cfreturn true>
		
	</cffunction>
</cfcomponent>