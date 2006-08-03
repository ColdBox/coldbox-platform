<!---
	Name         : user.cfc
	Author       : Raymond Camden 
	Created      : January 25, 2005
	Last Updated : October 6, 2005
	History      : Switched to UUID (rkc 1/25/05)
				   Added subscribe (rkc 7/24/05)
				   Added unsubscribe, modified code for adduser/saveuser (rkc 7/29/05)
				   Fixed bugs relating to last changes (rkc 8/3/05)
				   New init, use of prefix (rkc 8/27/05)
				   subscribe method didn't restrict to one user (rkc 10/6/05)
	Purpose		 : 
--->
<cfcomponent displayName="User" hint="Handles all user/security issues for the application.">

	<cfset variables.dsn = "">
	<cfset variables.dbtype = "">
	<cfset variables.tableprefix = "">

	<cfset variables.utils = createObject("component","utils")>

	<cffunction name="init" access="public" returnType="user" output="false"
				hint="Returns an instance of the CFC initialized with the correct DSN.">
		<cfargument name="settings" type="struct" required="true" hint="Setting">
		
		<cfset variables.dsn = arguments.settings.dsn>
		<cfset variables.dbtype = arguments.settings.dbtype>
		<cfset variables.tableprefix = arguments.settings.tableprefix>

		<cfreturn this>
		
	</cffunction>

	<cffunction name="addUser" access="public" returnType="void" output="false"
				hint="Attempts to create a new user.">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfargument name="emailaddress" type="string" required="true">
		<cfargument name="groups" type="string" required="false">
		
		<cfset var checkuser = "">
		<cfset var insuser = "">
		
		<cflock name="user.cfc" type="exclusive" timeout="30">
			<cfquery name="checkuser" datasource="#variables.dsn#">
				select	id
				from	#variables.tableprefix#users
				where	username = <cfqueryparam value="#arguments.username#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			</cfquery>
			
			<cfif checkuser.recordCount>
				<cfset variables.utils.throw("User CFC","User already exists")>
			<cfelse>
				<cfquery name="insuser" datasource="#variables.dsn#">
				insert into #variables.tableprefix#users(id,username,password,emailaddress,datecreated)
				values(<cfqueryparam value="#createUUID()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
				<cfqueryparam value="#arguments.username#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">,
				<cfqueryparam value="#arguments.password#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">,
				<cfqueryparam value="#arguments.emailaddress#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
				<cfqueryparam value="#now()#" cfsqltype="CF_SQL_TIMESTAMP">
				)
				</cfquery>
				<cfif isDefined("arguments.groups") and len(arguments.groups)>
					<cfset assignGroups(arguments.username,arguments.groups)>
				</cfif>
			</cfif>
			
		</cflock>
	</cffunction>

	<cffunction name="assignGroups" access="private" returnType="void" output="false"
				hint="Assigns a user to groups.">
		<cfargument name="username" type="string" required="true">
		<cfargument name="groups" type="string" required="true">
		<cfset var uid = getUserId(arguments.username)>
		<cfset var gid = "">
		<cfset var group = "">
				
		<cfloop index="group" list="#arguments.groups#">
			<cfset gid = getGroupID(group)>
			<cfquery datasource="#variables.dsn#">
				insert into #variables.tableprefix#users_groups(useridfk,groupidfk)
				values(<cfqueryparam value="#uid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,<cfqueryparam value="#gid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">)
			</cfquery>
		</cfloop>
		
	</cffunction>
		
	<cffunction name="authenticate" access="public" returnType="boolean" output="false"
				hint="Returns true or false if the user authenticates.">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfset var qAuth = "">
		
		<cfquery name="qAuth" datasource="#variables.dsn#">
			select	id
			from	#variables.tableprefix#users
			where	username = <cfqueryparam value="#arguments.username#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			and		password = <cfqueryparam value="#arguments.password#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
		</cfquery>
			
		<cfreturn qAuth.recordCount gt 0>
			
	</cffunction>

	<cffunction name="deleteUser" access="public" returnType="void" output="false"
				hint="Deletes a user.">
		<cfargument name="username" type="string" required="true">
		<cfset var uid = getUserId(arguments.username)>

		<cflock name="user.cfc" type="exclusive" timeout="30">

		<cfquery datasource="#variables.dsn#">
			delete	from #variables.tableprefix#users_groups
			where	useridfk = <cfqueryparam value="#uid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
			
		<cfquery datasource="#variables.dsn#">
			delete	from #variables.tableprefix#users
			where	id = <cfqueryparam value="#uid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

		<cfquery datasource="#variables.dsn#">
			delete	from #variables.tableprefix#subscriptions
			where	useridfk = <cfqueryparam value="#uid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

		</cflock>
						
	</cffunction>
	
	<cffunction name="getGroupID" access="public" returnType="uuid" output="false"
				hint="Returns a group id.">
		<cfargument name="group" type="string" required="true">
		<cfset var qGetGroup = "">
		
		<cfquery name="qGetGroup" datasource="#variables.dsn#">
			select	id
			from	#variables.tableprefix#groups
			where
			<cfif variables.dbtype is not "mysql">
			[group]
			<cfelse>
			#variables.tableprefix#groups.group
			</cfif>
			 = <cfqueryparam value="#arguments.group#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
		</cfquery>
		
		<cfif qGetGroup.recordCount>
			<cfreturn qGetGroup.id>
		<cfelse>
			<cfset variables.utils.throw("UserCFC","Invalid Group [#arguments.group#]")>
		</cfif>
				
	</cffunction>

	<cffunction name="getGroups" access="public" returnType="query" output="false"
				hint="Returns a query of all the known groups.">
		<cfset var qGetGroups = "">

		<cfquery name="qGetGroups" datasource="#variables.dsn#">
			select	id, 
			<cfif variables.dbtype is not "mysql">
			[group]
			<cfelse>
			#variables.tableprefix#groups.group
			</cfif>
			from	#variables.tableprefix#groups
		</cfquery>
		
		<cfreturn qGetGroups>
		
	</cffunction>
	
	<cffunction name="getGroupsForUser" access="public" returnType="string" output="false"
				hint="Returns a list of groups for a user.">
		<cfargument name="username" type="string" required="true">
		<cfset var qGetGroups = "">
		
		<cfquery name="qGetGroups" datasource="#variables.dsn#">
			<cfif variables.dbtype is not "mysql">
				select	#variables.tableprefix#groups.[group]
			<cfelse>
				select #variables.tableprefix#groups.group
			</cfif>
			from	#variables.tableprefix#users, #variables.tableprefix#groups, #variables.tableprefix#users_groups
			where	#variables.tableprefix#users_groups.useridfk = #variables.tableprefix#users.id
			and		#variables.tableprefix#users_groups.groupidfk = #variables.tableprefix#groups.id
			and		#variables.tableprefix#users.username = <cfqueryparam value="#arguments.username#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
		</cfquery>
		
		<cfreturn valueList(qGetGroups.group)>
			
	</cffunction>


	<cffunction name="getSubscriptions" access="public" returnType="query" output="false"
				hint="Gets subscriptions for a user.">
		<cfargument name="username" type="string" required="true">
		<cfset var uid = getUserId(arguments.username)>
		<cfset var q = "">
		
		<cfquery name="q" datasource="#variables.dsn#">
			select	id, threadidfk, forumidfk, conferenceidfk
			from	#variables.tableprefix#subscriptions
			where	useridfk = <cfqueryparam value="#uid#" cfsqltype="cf_sql_varchar" maxlength="35">
		</cfquery>
		
		<cfreturn q>
	</cffunction>
	
	<cffunction name="getUser" access="public" returnType="struct" output="false"
				hint="Returns a user.">
		<cfargument name="username" type="string" required="true">
		<cfset var qGetUser = "">
		<cfset var user = structNew()>
		
		<cfquery name="qGetUser" datasource="#variables.dsn#">		
		select #variables.tableprefix#users.id, #variables.tableprefix#users.username, #variables.tableprefix#users.password, #variables.tableprefix#users.emailaddress, #variables.tableprefix#users.datecreated, count(#variables.tableprefix#messages.id) as postcount
		from #variables.tableprefix#users
		left join  #variables.tableprefix#messages
		on  #variables.tableprefix#users.id = #variables.tableprefix#messages.useridfk
		where username = <cfqueryparam value="#arguments.username#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
		group by #variables.tableprefix#users.id, #variables.tableprefix#users.username, #variables.tableprefix#users.password, #variables.tableprefix#users.emailaddress, #variables.tableprefix#users.datecreated
		</cfquery>
		
		<cfset user = variables.utils.queryToStruct(qGetUser)>
		<cfset user.groups = getGroupsForUser(arguments.username)>
		
		<cfreturn user>
			
	</cffunction>

	<cffunction name="getUserID" access="public" returnType="uuid" output="false"
				hint="Returns a user id.">
		<cfargument name="username" type="string" required="true">
		<cfset var qGetUser = "">
		
		<cfquery name="qGetUser" datasource="#variables.dsn#">
			select	id
			from	#variables.tableprefix#users
			where	username = <cfqueryparam value="#arguments.username#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
		</cfquery>
		
		<cfif qGetUser.recordCount>
			<cfreturn qGetUser.id>
		<cfelse>
			<cfset variables.utils.throw("UserCFC","Invalid Username")>
		</cfif>
				
	</cffunction>

	<cffunction name="getUsers" access="public" returnType="query" output="false"
				hint="Returns all the users.">
		<cfset var qGetUsers = "">
		
		<cfquery name="qGetUsers" datasource="#variables.dsn#">
		select #variables.tableprefix#users.id, #variables.tableprefix#users.username, #variables.tableprefix#users.password, #variables.tableprefix#users.emailaddress, #variables.tableprefix#users.datecreated, count(#variables.tableprefix#messages.id) as postcount
		from #variables.tableprefix#users
		left join  #variables.tableprefix#messages
		on  #variables.tableprefix#users.id = #variables.tableprefix#messages.useridfk
		group by #variables.tableprefix#users.id, #variables.tableprefix#users.username, #variables.tableprefix#users.password, #variables.tableprefix#users.emailaddress, #variables.tableprefix#users.datecreated
		</cfquery>
		
		<cfreturn qGetUsers>
			
	</cffunction>

	<cffunction name="removeGroups" access="private" returnType="void" output="false"
				hint="Removes all groups from a user.">
		<cfargument name="username" type="string" required="true">
		
		<cfset var uid = getUserId(arguments.username)>
				
		<cfquery datasource="#variables.dsn#">
			delete from #variables.tableprefix#users_groups
			where useridfk = <cfqueryparam value="#uid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>
	
	<cffunction name="saveUser" access="public" returnType="void" output="false"
				hint="Attempts to save a user.">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfargument name="emailaddress" type="string" required="true">
		<cfargument name="datecreated" type="date" required="true">
		<cfargument name="groups" type="string" required="false">

		<cfset var uid = getUserId(arguments.username)>
								
		<cfquery datasource="#variables.dsn#">
			update	#variables.tableprefix#users
			set		emailaddress = <cfqueryparam value="#arguments.emailaddress#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
					password = <cfqueryparam value="#arguments.password#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">,
					datecreated = <cfqueryparam value="#arguments.datecreated#" cfsqltype="CF_SQL_TIMESTAMP">
			where	username = <cfqueryparam value="#arguments.username#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
		</cfquery>
			
		<!--- remove groups --->
		<cfset removeGroups(arguments.username)>
		
		<!--- assign groups --->
		<cfset assignGroups(arguments.username,arguments.groups)>
		
	</cffunction>

	<cffunction name="subscribe" access="public" returnType="void" output="false"
				hint="Subscribes a user to Galleon.">
		<cfargument name="username" type="string" required="true">
		<cfargument name="mode" type="string" required="true">
		<cfargument name="id" type="uuid" required="true">
		<cfset var uid = getUserId(arguments.username)>
		<cfset var check = "">
		
		<cfif not listFindNoCase("conference,forum,thread", arguments.mode)>
			<cfset variables.utils.throw("UserCFC","Invalid Mode")>
		</cfif>
		
		<cfquery name="check" datasource="#variables.dsn#">
		select	useridfk
		from	#variables.tableprefix#subscriptions
		where	
				<cfif arguments.mode is "conference">
				conferenceidfk = 
				<cfelseif arguments.mode is "forum">
				forumidfk = 
				<cfelseif arguments.mode is "thread">
				threadidfk = 
				</cfif>
				<cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar" maxlength="35">
		and		useridfk = <cfqueryparam value="#uid#" cfsqltype="cf_sql_varchar" maxlength="35">				
		</cfquery>
		
		<cfif check.recordCount is 0>
			<cfquery datasource="#variables.dsn#">
			insert into #variables.tableprefix#subscriptions(id,useridfk, 
				<cfif arguments.mode is "conference">
				conferenceidfk
				<cfelseif arguments.mode is "forum">
				forumidfk
				<cfelseif arguments.mode is "thread">
				threadidfk 
				</cfif>)
			values(<cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar" maxlength="35">,
			<cfqueryparam value="#uid#" cfsqltype="cf_sql_varchar" maxlength="35">,
			<cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar" maxlength="35">)
			</cfquery>
		</cfif>
				
	</cffunction>		

	<cffunction name="unsubscribe" access="public" returnType="void" output="false"
				hint="Unsubscribes a user from Galleon data.">
		<cfargument name="username" type="string" required="true">
		<cfargument name="id" type="uuid" required="true">
		<cfset var uid = getUserId(arguments.username)>
				
		<cfquery datasource="#variables.dsn#">
		delete	from	#variables.tableprefix#subscriptions
		where	id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar" maxlength="35">
		and		useridfk = <cfqueryparam value="#uid#" cfsqltype="cf_sql_varchar" maxlength="35">				
		</cfquery>		
				
	</cffunction>		

</cfcomponent>