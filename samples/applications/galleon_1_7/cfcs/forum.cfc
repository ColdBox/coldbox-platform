<!---
	Name         : forum.cfc
	Author       : Raymond Camden 
	Created      : January 26, 2005
	Last Updated : November 5, 2006
	History      : Support dbtype, switched to UUID (rkc 1/26/05)
				   getForums now gets last msg, msg count (rkc 4/6/05)
				   ms access fix in getForums. I love joins (rkc 4/15/05)
   				   New init, use of table prefix (rkc 8/27/05)
				   getForums returns the thread id for newest thread (rkc 9/15/05)
				   Accidently left a hard coded ID in getForums (rkc 9/28/05)
				   getForums, conferenceid is NOT required (rkc 9/29/05)
				   limit search length (rkc 10/30/05)
				   clean up subscription (rkc 11/22/05)
				   show last user for post, other small fixes (rkc 7/12/06)				   
				   Simple size change (rkc 7/27/06)
				   Attachment support (rkc 11/3/06)
				   Reverted description to text field (rkc 11/5/06)				   
	Purpose		 : 
--->
<cfcomponent displayName="Forum" hint="Handles Forums which contain a collection of threads.">

	<cfset variables.dsn = "">
	<cfset variales.dbtype = "">
	<cfset variables.tableprefix = "">
	<cfset variables.utils = createObject("component","utils")>
		
	<cffunction name="init" access="public" returnType="forum" output="false"
				hint="Returns an instance of the CFC initialized with the correct DSN.">
		<cfargument name="settings" type="struct" required="true" hint="Setting">
		
		<cfset variables.dsn = arguments.settings.dsn>
		<cfset variables.dbtype = arguments.settings.dbtype>
		<cfset variables.tableprefix = arguments.settings.tableprefix>

		<cfset variables.thread = createObject("component","thread").init(arguments.settings)>
		<cfreturn this>
		
	</cffunction>

	<cffunction name="addForum" access="remote" returnType="uuid" roles="forumsadmin" output="false"
				hint="Adds a forum.">				
		<cfargument name="forum" type="struct" required="true">
		<cfset var newforum = "">
		<cfset var newid = createUUID()>
		
		<cfif not validForum(arguments.forum)>
			<cfset variables.utils.throw("ForumCFC","Invalid data passed to addForum.")>
		</cfif>
		
		<cfquery name="newforum" datasource="#variables.dsn#">
			insert into #variables.tableprefix#forums(id,name,description,readonly,active,conferenceidfk,attachments)
			values(<cfqueryparam value="#newid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
				   <cfqueryparam value="#arguments.forum.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
				   <cfqueryparam value="#arguments.forum.description#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
				   <cfqueryparam value="#arguments.forum.readonly#" cfsqltype="CF_SQL_BIT">,
				   <cfqueryparam value="#arguments.forum.active#" cfsqltype="CF_SQL_BIT">,
				   <cfqueryparam value="#arguments.forum.conferenceidfk#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
				   <cfqueryparam value="#arguments.forum.attachments#" cfsqltype="CF_SQL_BIT">
				   )
		</cfquery>
		
		<cfreturn newid>
				
	</cffunction>
	
	<cffunction name="deleteForum" access="public" returnType="void" roles="forumsadmin" output="false"
				hint="Deletes a forum along with all of it's children.">
		<cfargument name="id" type="uuid" required="true">
		<cfset var threadKids = "">
				
		<!--- first, delete my children --->
		<cfset threadKids = variables.thread.getThreads(false,arguments.id)>
		<cfloop query="threadKids">
			<cfset variables.thread.deleteThread(threadKids.id)>
		</cfloop>

		<cfquery datasource="#variables.dsn#">
			delete	from #variables.tableprefix#forums
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

		<!--- clean up subscriptions --->
		<cfquery datasource="#variables.dsn#">
			delete	from #variables.tableprefix#subscriptions
			where	forumidfk = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>
	
	<cffunction name="getForum" access="remote" returnType="struct" output="false"
				hint="Returns a struct copy of the forum.">
		<cfargument name="id" type="uuid" required="true">
		<cfset var qGetForum = "">
				
		<cfquery name="qGetForum" datasource="#variables.dsn#">
			select	id, name, description, readonly, active, conferenceidfk, attachments
			from	#variables.tableprefix#forums
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

		<!--- Throw if invalid id passed --->
		<cfif not qGetForum.recordCount>
			<cfset variables.utils.throw("ForumCFC","Invalid ID")>
		</cfif>
		
		<!--- Only a ForumsAdmin can get bActiveOnly=false --->
		<cfif not qGetForum.active and not isUserInRole("forumsadmin")>
			<cfset variables.utils.throw("ForumCFC","Invalid call to getForum")>
		</cfif>
		
		<cfreturn variables.utils.queryToStruct(qGetForum)>
			
	</cffunction>
		
	<cffunction name="getForums" access="remote" returnType="query" output="false"
				hint="Returns a list of forums.">

		<cfargument name="bActiveOnly" type="boolean" required="false" default="true">
		<cfargument name="conferenceid" type="uuid" required="false">
		
		<cfset var qGetForums = "">
		<cfset var getLastUser = "">
		
		<!--- Only a ForumsAdmin can be bActiveOnly=false --->
		<cfif not arguments.bActiveOnly and not isUserInRole("forumsadmin")>
			<cfset variables.utils.throw("ForumCFC","Invalid call to getForums")>
		</cfif>
		
		<cfquery name="qGetForums" datasource="#variables.dsn#">
			select	#variables.tableprefix#forums.id, #variables.tableprefix#forums.name, #variables.tableprefix#forums.description, #variables.tableprefix#forums.readonly, #variables.tableprefix#forums.attachments,
					#variables.tableprefix#forums.active, #variables.tableprefix#forums.conferenceidfk, #variables.tableprefix#conferences.name as conference, 
					max(#variables.tableprefix#messages.posted) as lastpost, count(#variables.tableprefix#messages.id) as messagecount,
					
				<!--- Thanks to Shlomy Gantz --->
				(
					select threadidfk from #variables.tableprefix#messages m where  m.posted = 
				
				(SELECT max(mm.posted)
					as lastpost
					from (#variables.tableprefix#forums f left join
				    #variables.tableprefix#threads t  ON f.id = t.forumidfk) left JOIN #variables.tableprefix#messages mm ON t.id =
					mm.threadidfk  where f.id = #variables.tableprefix#forums.id
					<cfif isDefined("variables.conferenceid")> and #variables.tableprefix#conferences.id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.conferenceid#" maxlength="35"></cfif>
					)
				) 				
				as threadidfk
					
			from	((#variables.tableprefix#forums inner join #variables.tableprefix#conferences on #variables.tableprefix#forums.conferenceidfk = #variables.tableprefix#conferences.id)
					left join #variables.tableprefix#threads on #variables.tableprefix#forums.id = #variables.tableprefix#threads.forumidfk)
					left join #variables.tableprefix#messages on #variables.tableprefix#threads.id = #variables.tableprefix#messages.threadidfk
			where	1=1
			<cfif arguments.bActiveOnly>
			and		#variables.tableprefix#forums.active = 1
			</cfif>
			<cfif isDefined("arguments.conferenceid")>
			and		#variables.tableprefix#forums.conferenceidfk = <cfqueryparam value="#arguments.conferenceid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			</cfif>
			group by #variables.tableprefix#forums.id, #variables.tableprefix#forums.name, #variables.tableprefix#forums.description, #variables.tableprefix#forums.readonly, #variables.tableprefix#forums.attachments,  #variables.tableprefix#forums.active, #variables.tableprefix#forums.conferenceidfk, #variables.tableprefix#conferences.name, #variables.tableprefix#conferences.id
			order by #variables.tableprefix#forums.name
		</cfquery>
		
		<!--- My ugly hack to add useridfk. There must be a better way to do this. --->
		<cfset queryAddColumn(qGetForums, "useridfk", arrayNew(1))>
		<cfloop query="qGetForums">
			<cfif lastpost neq "">
				<cfquery name="getLastUser" datasource="#variables.dsn#">
				select	useridfk
				from	#variables.tableprefix#messages
				where	threadidfk = <cfqueryparam cfsqltype="cf_sql_varchar" value="#threadidfk#" maxlength="35">
				and		posted = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#lastpost#">
				</cfquery>
				<cfset querySetCell(qGetForums, "useridfk", getLastUser.useridfk, currentRow)>
			</cfif>
		</cfloop>
		
		<cfreturn qGetForums>
			
	</cffunction>
	
	<cffunction name="saveForum" access="remote" returnType="void" roles="forumsadmin" output="false"
				hint="Saves an existing forum.">
				
		<cfargument name="id" type="uuid" required="true">
		<cfargument name="forum" type="struct" required="true">
		
		<cfif not validForum(arguments.forum)>
			<cfset variables.utils.throw("ForumCFC","Invalid data passed to saveForum.")>
		</cfif>
		
		<cfquery datasource="#variables.dsn#">
			update	#variables.tableprefix#forums
			set		name = <cfqueryparam value="#arguments.forum.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
					description = <cfqueryparam value="#arguments.forum.description#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
					readonly = <cfqueryparam value="#arguments.forum.readonly#" cfsqltype="CF_SQL_BIT">,
					active = <cfqueryparam value="#arguments.forum.active#" cfsqltype="CF_SQL_BIT">,
					attachments = <cfqueryparam value="#arguments.forum.attachments#" cfsqltype="CF_SQL_BIT">,
					conferenceidfk = <cfqueryparam value="#arguments.forum.conferenceidfk#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>

	<cffunction name="search" access="remote" returnType="query" output="false"
				hint="Allows you to search forums.">
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
			from	#variables.tableprefix#forums
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
	
	<cffunction name="validForum" access="private" returnType="boolean" output="false"
				hint="Checks a structure to see if it contains all the proper keys/values for a forum.">
		
		<cfargument name="cData" type="struct" required="true">
		<cfset var rList = "name,description,readonly,active,conferenceidfk">
		<cfset var x = "">
		
		<cfloop index="x" list="#rList#">
			<cfif not structKeyExists(cData,x)>
				<cfreturn false>
			</cfif>
		</cfloop>
		
		<cfreturn true>
		
	</cffunction>
</cfcomponent>