<!---
	Name         : blog
	Author       : Raymond Camden 
	Created      : February 10, 2003
	Last Updated : June 1, 2006
	History      : Reset history for version 5.0
				 : Related Entries support by Charlie Griefer and Jeff Coughlin
				 : Pete Freitag pointed out two security holes in getComments and getTrackbacks (rkc 5/18/06)
				 : Use rwhaun pointed out the AJAX related stuff for Related Entries didn't filter by blogname (rkc 6/2/06)
	Purpose		 : Blog CFC
--->
<cfcomponent displayName="Blog" output="false" hint="BlogCFC by Raymond Camden">

	<!--- Load utils immidiately. --->
	<cfset variables.utils = createObject("component", "utils")>		

	<!--- Require 6.1 or higher --->
	<cfset majorVersion = listFirst(server.coldfusion.productversion)>
	<cfset minorVersion = listGetAt(server.coldfusion.productversion,2)>
	<cfset cfversion = majorVersion & "." & minorVersion>
	<cfif (server.coldfusion.productname is "ColdFusion Server" and cfversion lte 6)
		  or 
		  (server.coldfusion.productname is "BlueDragon" and cfversion lte 6.1)>
		<cfset utils.throw("Blog must be run under ColdFusion 6.1, BlueDragon 6.2, or higher.")>
	</cfif>

	<!--- Valid database types --->
	<cfset validDBTypes = "MSACCESS,MYSQL,MSSQL">

	<!--- current version --->
	<cfset version = "5.004">
	
	<!--- cfg file --->
	<cfset variables.cfgFile = "#getDirectoryFromPath(GetCurrentTemplatePath())#/blog.ini.cfm">
	
	<cffunction name="init" access="remote" returnType="blog" output="false"
				hint="Initialize the blog engine">
		<cfargument name="name" type="string" required="false" default="default" hint="Blog name, defaults to default in blog.ini">
		<cfargument name="instanceData" type="struct" required="false" hint="Allows you to specify BlogCFC info at runtime.">
				
		<cfif isDefined("arguments.instanceData")>
			<cfset instance = duplicate(arguments.instanceData)>
		<cfelse>
			<cfif not listFindNoCase(structKeyList(getProfileSections(variables.cfgFile)),name)>
				<cfset utils.throw("#arguments.name# isn't registered as a valid blog.")>
			</cfif>
			<cfset instance = structNew()>
			<cfset instance.dsn = utils.configParam(variables.cfgFile,arguments.name,"dsn")>	
			<cfset instance.ownerEmail = utils.configParam(variables.cfgFile, arguments.name, "owneremail")>
			<cfset instance.blogURL = utils.configParam(variables.cfgFile, arguments.name, "blogURL")>
			<cfset instance.blogTitle = utils.configParam(variables.cfgFile, arguments.name, "blogTitle")>
			<cfset instance.blogDescription = utils.configParam(variables.cfgFile, arguments.name, "blogDescription")>
			<cfset instance.blogDBType = utils.configParam(variables.cfgFile, arguments.name, "blogDBType")>
			<cfset instance.locale = utils.configParam(variables.cfgFile, arguments.name, "locale")>
			<cfset instance.users = utils.configParam(variables.cfgFile,arguments.name,"users")>
			<cfset instance.commentsFrom = utils.configParam(variables.cfgFile,arguments.name,"commentsFrom")>
			<cfset instance.mailServer = utils.configParam(variables.cfgFile,arguments.name,"mailserver")>
			<cfset instance.mailusername = utils.configParam(variables.cfgFile,arguments.name,"mailusername")>
			<cfset instance.mailpassword = utils.configParam(variables.cfgFile,arguments.name,"mailpassword")>
			<cfset instance.pingurls = utils.configParam(variables.cfgFile,arguments.name,"pingurls")>
			<cfset instance.offset = utils.configParam(variables.cfgFile, arguments.name, "offset")>
			<cfset instance.allowtrackbacks = utils.configParam(variables.cfgFile, arguments.name, "allowtrackbacks")>
			<cfset instance.trackbackspamlist = utils.configParam(variables.cfgFile, arguments.name, "trackbackspamlist")>
			<cfset instance.blogkeywords = utils.configParam(variables.cfgFile, arguments.name, "blogkeywords")>
			<cfset instance.ipblocklist = utils.configParam(variables.cfgFile, arguments.name, "ipblocklist")>
			<cfset instance.maxentries = utils.configParam(variables.cfgFile, arguments.name, "maxentries")>
			<cfset instance.usecaptcha = utils.configParam(variables.cfgFile, arguments.name, "usecaptcha")>
		</cfif>
				
		<!--- Name the blog --->
		<cfset instance.name = arguments.name>
				
		<!--- Only real validation we do on instance data. --->						
		<cfif not isValidDBType(instance.blogDBType)>
			<cfset utils.throw("#instance.blogDBType# is not a supported value (#getValidDBTypes()#)")>
		</cfif>

		<!--- get a copy of ping --->
		<cfset variables.ping = createObject("component", "ping")>
		
		<cfreturn this>
		
	</cffunction>

	<cffunction name="addCategory" access="remote" returnType="uuid" roles="admin" output="false"
				hint="Adds a category.">
		<cfargument name="name" type="string" required="true">	
		<cfargument name="alias" type="string" required="true">	
		
		<cfset var checkC = "">
		<cfset var id = createUUID()>
		
		<cflock name="blogcfc.addCategory" type="exclusive" timeout=30>
		
			<cfif categoryExists(name="#arguments.name#")>
				<cfset utils.throw("#arguments.name# already exists as a category.")>
			</cfif>
			
			<cfquery datasource="#instance.dsn#">
				insert into tblblogcategories(categoryid,categoryname,categoryalias,blog)
				values(
					<cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
					<cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">,
					<cfqueryparam value="#arguments.alias#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">,
					<cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">)
			</cfquery>
						
		</cflock>
		
		<cfreturn id>
	</cffunction>
	
	<cffunction name="addComment" access="remote" returnType="uuid" output="false"
				hint="Adds a comment.">
		<cfargument name="entryid" type="uuid" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="email" type="string" required="true">
		<!--- RBB 11/02/2005:  Added website argument --->
		<cfargument name="website" type="string" required="true">
		<cfargument name="comments" type="string" required="true">
		<cfargument name="subscribe" type="boolean" required="true">
		
		<cfset var newID = createUUID()>
		<cfset var entry = "">
		<cfset var spam = "">
		
		<cfset arguments.comments = htmleditformat(arguments.comments)>
		<cfset arguments.name = left(htmlEditFormat(arguments.name),50)>
		<cfset arguments.email = left(htmlEditFormat(arguments.email),50)>
		<!--- RBB 11/02/2005:  Added website element --->
		<cfset arguments.website = left(htmlEditFormat(arguments.website),255)>
				
		<cfif not entryExists(arguments.entryid)>
			<cfset utils.throw("#arguments.entryid# is not a valid entry.")>
		</cfif>
		
		<!--- get the entry so we can check for allowcomments --->
		<cfset entry = getEntry(arguments.entryid)>
		<cfif not entry.allowcomments>
			<cfset utils.throw("#arguments.entryid# does not allow for comments.")>
		</cfif>
		
		<!--- check spam and IPs --->
		<cfloop index="spam" list="#instance.trackbackspamlist#">
			<cfif findNoCase(spam, arguments.comments) or 
				  findNoCase(spam, arguments.name) or
				  findNoCase(spam, arguments.website) or
				  findNoCase(spam, arguments.email)>
				<cfset utils.throw("Comment blocked for spam.")>
			</cfif>
		</cfloop>
		<cfif len(cgi.http_referer) and listFind(instance.ipblocklist, cgi.http_referer)>
			<cfset utils.throw("Comment blocked for spam.")>
		</cfif>
		
		<cfquery datasource="#instance.dsn#">
		<!--- RBB 11/02/2005:  Added website element --->
		insert into tblblogcomments(id,entryidfk,name,email,website,comment,posted,subscribe)
		values(<cfqueryparam value="#newID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
			   <cfqueryparam value="#arguments.entryid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
			   <cfqueryparam value="#arguments.name#" maxlength="50">,
			   <cfqueryparam value="#arguments.email#" maxlength="50">,
				 <!--- RBB 11/02/2005:  Added website element --->
         <cfqueryparam value="#arguments.website#" maxlength="255">,
			   <cfqueryparam value="#arguments.comments#" cfsqltype="CF_SQL_LONGVARCHAR">,
			   <cfqueryparam value="#blogNow()#" cfsqltype="CF_SQL_TIMESTAMP">,
			   <cfif instance.blogDBType is "MSSQL" or instance.blogDBType is "MSACCESS">
				   <cfqueryparam value="#arguments.subscribe#" cfsqltype="CF_SQL_BIT">
			   <cfelse>
   			   		<!--- convert yes/no to 1 or 0 --->
			   		<cfif arguments.subscribe>
			   			<cfset arguments.subscribe = 1>
			   		<cfelse>
			   			<cfset arguments.subscribe = 0>
			   		</cfif>
				   <cfqueryparam value="#arguments.subscribe#" cfsqltype="CF_SQL_TINYINT">
			   </cfif>		   
			   )
		</cfquery>
		
		<!--- If subscribe is no, auto set older posts in thread by this author to no --->
		<cfif not arguments.subscribe>

			<cfquery datasource="#instance.dsn#">
			update	tblblogcomments
			set		subscribe = 0
			where	entryidfk = <cfqueryparam value="#arguments.entryid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			and		email = <cfqueryparam value="#arguments.email#" maxlength="100">
			</cfquery>

		</cfif>
		
		<cfreturn newID>
	</cffunction>
	
	<cffunction name="addEntry" access="remote" returnType="uuid" roles="admin" output="true"
				hint="Adds an entry.">
		<cfargument name="title" type="string" required="true">
		<cfargument name="body" type="string" required="true">
		<cfargument name="morebody" type="string" required="false" default="">
		<cfargument name="alias" type="string" required="false" default="">
		<cfargument name="posted" type="date" required="false" default="#blogNow()#">
		<cfargument name="allowcomments" type="boolean" required="false" default="true">
		<cfargument name="enclosure" type="string" required="false" default="">
		<cfargument name="filesize" type="numeric" required="false" default="0">
		<cfargument name="mimetype" type="string" required="false" default="">
		<cfargument name="released" type="boolean" required="false" default="true">
		<cfargument name="relatedEntries" type="string" required="true" default="">

		<cfset var id = createUUID()>
		<cfset var theURL = "">
				
		<cfquery datasource="#instance.dsn#">
			insert into tblblogentries(id,title,body,posted
				<cfif len(arguments.morebody)>,morebody</cfif>
				<cfif len(arguments.alias)>,alias</cfif>
				,username,blog,allowcomments,enclosure,filesize,mimetype,released,views,mailed)
			values(
				<cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
				<cfqueryparam value="#arguments.title#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">,
				<cfqueryparam value="#arguments.body#" cfsqltype="CF_SQL_LONGVARCHAR">,
				<cfqueryparam value="#arguments.posted#" cfsqltype="CF_SQL_TIMESTAMP">
				<cfif len(arguments.morebody)>
					,<cfqueryparam value="#arguments.morebody#" cfsqltype="CF_SQL_LONGVARCHAR">
				</cfif>
				<cfif len(arguments.alias)>
					,<cfqueryparam value="#arguments.alias#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
				</cfif>
				,<cfqueryparam value="#getAuthUser()#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">,
				<cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">,
			    <cfif instance.blogDBType is not "MYSQL">
					<cfqueryparam value="#arguments.allowcomments#" cfsqltype="CF_SQL_BIT">
			   <cfelse>
   			   		<!--- convert yes/no to 1 or 0 --->
			   		<cfif arguments.allowcomments>
			   			<cfset arguments.allowcomments = 1>
			   		<cfelse>
			   			<cfset arguments.allowcomments = 0>
			   		</cfif>
					<cfqueryparam value="#arguments.allowcomments#" cfsqltype="CF_SQL_TINYINT">
			   </cfif>		   
   				,<cfqueryparam value="#arguments.enclosure#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">
   				,<cfqueryparam value="#arguments.filesize#" cfsqltype="CF_SQL_NUMERIC">
   				,<cfqueryparam value="#arguments.mimetype#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">
   				,<cfif instance.blogDBType is not "MYSQL">
					<cfqueryparam value="#arguments.released#" cfsqltype="CF_SQL_BIT">
			   <cfelse>
   			   		<!--- convert yes/no to 1 or 0 --->
			   		<cfif arguments.released>
			   			<cfset arguments.released = 1>
			   		<cfelse>
			   			<cfset arguments.released = 0>
			   		</cfif>
					<cfqueryparam value="#arguments.released#" cfsqltype="CF_SQL_TINYINT">
			   </cfif>		   
				,0
				,<cfif instance.blogDBType is not "MYSQL">
					<cfqueryparam value="false" cfsqltype="CF_SQL_BIT">
			   <cfelse>
					<cfqueryparam value="0" cfsqltype="CF_SQL_TINYINT">
			   </cfif>		   
				)
		</cfquery>

		<cfif len(trim(arguments.relatedEntries)) GT 0>
			<cfset saveRelatedEntries(id, arguments.relatedEntries) />
		</cfif> 		
		
		<!---
			  Only mail if released = true, and posted not in the future
		--->
		<cfif arguments.released and dateCompare(dateAdd("h", instance.offset,arguments.posted), blogNow()) lte 0>

			<cfset mailEntry(id)>
			
		</cfif>
		
		<cfif arguments.released>
		
			<cfif dateCompare(dateAdd("h", instance.offset,arguments.posted), blogNow()) is 1>
				<!--- Handle delayed posting --->
				<cfset theURL = getRootURL()>
				<cfset theURL = theURL & "admin/notify.cfm?id=#id#">
				<cfschedule action="update" task="BlogCFC Notifier #id#" operation="HTTPRequest" 
							startDate="#arguments.posted#" startTime="#arguments.posted#" url="#theURL#" interval="once">	
			<cfelse>
				<cfset variables.ping.pingAggregators(instance.pingurls, instance.blogtitle, instance.blogurl)>
			</cfif>

		</cfif>		
		
		
		<cfreturn id>
		
	</cffunction>

	<cffunction name="addSubscriber" access="remote" returnType="void" output="false"
				hint="Adds a subscriber to the blog.">
		<cfargument name="email" type="string" required="true">
		<cfset var token = createUUID()>
		<cfset var getMe = "">
		
		<!--- First, lets see if this guy is already subscribed. --->
		<cfquery name="getMe" datasource="#instance.dsn#">
		select	email
		from	tblblogsubscribers
		where	email = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar" maxlength="50">
		and		blog = <cfqueryparam value="#instance.name#" cfsqltype="cf_sql_varchar" maxlength="50">
		</cfquery>
		
		<cfif getMe.recordCount is 0>
			<cfquery datasource="#instance.dsn#">
			insert into tblblogsubscribers(email,
			token,
			blog)
			values(<cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar" maxlength="50">,
			<cfqueryparam value="#token#" cfsqltype="cf_sql_varchar" maxlength="35">,
			<cfqueryparam value="#instance.name#" cfsqltype="cf_sql_varchar" maxlength="50">)
			</cfquery>
		</cfif>
		
	</cffunction>

	<cffunction name="addTrackBack" returnType="string" access="public" output="false"
				hint="Adds a trackback entry for a blog post.">
		<cfargument name="title" type="string" required="true" hint="The title of the remote blog entry.">
		<cfargument name="url" type="string" required="true" hint="The url of the remote blog entry.">
		<cfargument name="blogName" type="string" required="true" hint="The name of the remote blog.">
		<cfargument name="excerpt" type="string" required="true" hint="The excerpt from the remote blog entry.">
		<cfargument name="id" type="string" required="true" hint="The id of the local blog entry.">

		<cfset var checkTrackBack = "">
		<cfset var newID = createUUID()>
		<cfset var spam = "">
		
		<cfset arguments.title = left(htmlEditFormat(arguments.title),255)>
		<cfset arguments.blogName = left(htmlEditFormat(arguments.blogName),255)>
		<cfset arguments.blogurl = left(arguments.url,255)>
		
		<cfset arguments.excerpt = htmlEditFormat(arguments.excerpt)>
		
		<!--- look for spam in title, blogname, and except --->
		<cfloop index="spam" list="#instance.trackbackspamlist#">
			<cfif findNoCase(spam, arguments.title) or 
				  findNoCase(spam, arguments.blogName) or
				  findNoCase(spam, arguments.excerpt) or
				  findNoCase(spam, arguments.url)>
				<!--- silently fail --->
				<cfreturn "">
			</cfif>
		</cfloop>

		<cfif len(cgi.http_referer) and listFind(instance.ipblocklist, cgi.http_referer)>
			<cfset "">
		</cfif>
		
		<!---
		New security. Do not allow 2 TBs with same name+title+url. In theory you could beat this
		by adding random chars to a postURL. It would be more secure to just check Name+Title, 
		but I'm starting with this for now.
		--->		
		<cfquery name="checkTrackBack" datasource="#instance.dsn#">
			select	id
			from	tblblogtrackbacks
			where	blogName = <cfqueryparam value="#arguments.blogName#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">
			and		title = <cfqueryparam value="#arguments.title#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">
			and		postURL = <cfqueryparam value="#arguments.url#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">
		</cfquery>
		
		<cfif not checkTrackBack.recordcount>
			<cfquery datasource="#instance.dsn#">
				insert	into tblblogtrackbacks (id, title, posturl, blogname, excerpt, created, entryid, blog)
						values (
						<cfqueryparam value="#newID#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#arguments.title#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
						<cfqueryparam value="#arguments.url#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
						<cfqueryparam value="#arguments.blogName#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
						<cfqueryparam value="#arguments.excerpt#" cfsqltype="CF_SQL_LONGVARCHAR">,
						<cfqueryparam value="#now()#" cfsqltype="CF_SQL_TIMESTAMP">,
						<cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR">
						)
			</cfquery>
		<cfelse>
			<cfreturn "">
		</cfif>
		
		<cfreturn newID>
	</cffunction>
		
	<cffunction name="assignCategory" access="remote" returnType="void" roles="admin" output="false"
				hint="Assigns entry ID to category X">
		<cfargument name="entryid" type="uuid" required="true">
		<cfargument name="categoryid" type="uuid" required="true">
		<cfset var checkEC = "">
						
		<cfquery name="checkEC" datasource="#instance.dsn#">
			select	categoryidfk
			from	tblblogentriescategories
			where	categoryidfk = <cfqueryparam value="#arguments.categoryid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			and		entryidfk = <cfqueryparam value="#arguments.entryid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

		<cfif entryExists(arguments.entryid) and categoryExists(id=arguments.categoryID) and not checkEC.recordCount>
			<cfquery datasource="#instance.dsn#">
				insert into tblblogentriescategories(categoryidfk,entryidfk)
				values(<cfqueryparam value="#arguments.categoryid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,<cfqueryparam value="#arguments.entryid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">)
			</cfquery>
		</cfif>
		
	</cffunction>

	<cffunction name="assignCategories" access="remote" returnType="void" roles="admin" output="false"
				hint="Assigns entry ID to multiple categories">
		<cfargument name="entryid" type="uuid" required="true">
		<cfargument name="categoryids" type="string" required="true">

		<cfset var i=0>
		
		<!--- Loop through categories --->
		<cfloop index="i" from="1" to="#listLen(arguments.categoryids)#">
			<cfset assignCategory(arguments.entryid,listGetAt(categoryids,i))>
		</cfloop>
	
	</cffunction>	
	
	<cffunction name="authenticate" access="public" returnType="boolean" output="false">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		
		<cfset var q = "">
		
		<cfquery name="q" datasource="#instance.dsn#">
			select 	username
			from	tblusers
			where	username = <cfqueryparam value="#arguments.username#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
			and		password = <cfqueryparam value="#arguments.password#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
			<!--- check for restricted users --->
			<cfif instance.users is not "">
			and		username in (<cfqueryparam value="#instance.users#" cfsqltype="CF_SQL_VARCHAR" list="Yes">)
			</cfif>
		</cfquery>
		
		<cfreturn q.recordCount is 1>
	
	</cffunction>

	<cffunction name="blogNow" access="private" returntype="date" output="false"
				hint="Returns now() with the offset.">
		<cfreturn dateAdd("h", instance.offset, now())>
	</cffunction>
	
	<cffunction name="categoryExists" access="private" returnType="boolean" output="false"
				hint="Returns true or false if an entry exists.">
		<cfargument name="id" type="uuid" required="false">
		<cfargument name="name" type="string" required="false">
		<cfset var checkC = "">

		<!--- must pass either ID or name, but not obth --->
		<cfif (not isDefined("arguments.id") and not isDefined("arguments.name")) or (isDefined("arguments.id") and isDefined("arguments.name"))>
			<cfset utils.throw("categoryExists method must be passed id or name, but not both.")>
		</cfif>
		
		<cfquery name="checkC" datasource="#instance.dsn#">
			select	categoryid
			from	tblblogcategories
			where	
				<cfif isDefined("arguments.id")>
				categoryid = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
				</cfif>
				<cfif isDefined("arguments.name")>
				categoryname = <cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
				</cfif>
				and blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
				
		</cfquery>
	
		<cfreturn checkC.recordCount gte 1>
			
	</cffunction>
	
	
	<cffunction name="deleteCategory" access="remote" returnType="void" roles="admin" output="false"
				hint="Deletes a category.">
		<cfargument name="id" type="uuid" required="true">

		<cfquery datasource="#instance.dsn#">
			delete from tblblogentriescategories
			where categoryidfk = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
		<cfquery datasource="#instance.dsn#">
			delete from tblblogcategories
			where categoryid = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

	</cffunction>

	<cffunction name="deleteComment" access="remote" returnType="void" roles="admin" output="false"
				hint="Deletes a comment.">
		<cfargument name="id" type="uuid" required="true">
		
		<cfquery datasource="#instance.dsn#">
			delete from tblblogcomments
			where id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>
	
	<cffunction name="deleteEntry" access="remote" returnType="void" roles="admin" output="false"
				hint="Deletes an entry, plus all comments.">
		<cfargument name="id" type="uuid" required="true">
		
		<cfif entryExists(arguments.id)>
			<cfquery datasource="#instance.dsn#">
				delete from tblblogentries
				where id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
				and	  blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
			</cfquery>
			
			<cfquery datasource="#instance.dsn#">	
				delete from tblblogcomments
				where entryidfk = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			</cfquery>
			
			<cfquery datasource="#instance.dsn#">	
				delete from tblblogentriescategories
				where entryidfk = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			</cfquery>

		</cfif>
				
	</cffunction>

	<cffunction name="deleteTrackback" access="remote" returnType="void" roles="" output="false"
				hint="Deletes a TB.">
		<cfargument name="id" type="uuid" required="true">
		
		<cfquery datasource="#instance.dsn#">
			delete from tblblogtrackbacks
			where id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>
	
	<cffunction name="entryExists" access="private" returnType="boolean" output="false"
				hint="Returns true or false if an entry exists.">
		<cfargument name="id" type="uuid" required="true">		
		
		<cfquery name="getIt" datasource="#instance.dsn#">
			select		tblblogentries.id
			from		tblblogentries
			where		tblblogentries.id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			and			tblblogentries.blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
			<cfif not isUserInRole("admin")>
			and			posted < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
			and			released = 1
			</cfif>
		</cfquery>

		<cfreturn getIt.recordCount gte 1>
		
	</cffunction>

	
	<cffunction name="generateRSS" access="remote" returnType="string" output="false"
				hint="Attempts to generate RSS 1.0">
		<cfargument name="mode" type="string" required="false" default="short" hint="If mode=short, show EXCERPT chars of entries. Otherwise, show all.">
		<cfargument name="excerpt" type="numeric" required="false" default="250" hint="If mode=short, this how many chars to show.">
		<cfargument name="params" type="struct" required="false" default="#structNew()#" hint="Passed to getEntries. Note, maxEntries can't be bigger than 15.">
		<cfargument name="version" type="numeric" required="false" default="2" hint="RSS verison, Options are 1 or 2">		
		<cfargument name="additionalTitle" type="string" required="false" default="" hint="Adds a title to the end of your blog title. Used mainly by the cat view.">
		
		<cfset var articles = "">
		<cfset var z = getTimeZoneInfo()>
		<cfset var header = "">
		<cfset var channel = "">
		<cfset var items = "">
		<cfset var dateStr = "">
		<cfset var rssStr = "">
		<cfset var utcPrefix = "">
		<cfset var rootURL = "">
		<cfset var cat = "">
		
		<!--- Right now, we force this in. Useful to limit throughput of RSS feed. I may remove this later. --->
		<cfif (structKeyExists(arguments.params,"maxEntries") and arguments.params.maxEntries gt 15) or not structKeyExists(arguments.params,"maxEntries")>
			<cfset arguments.params.maxEntries = 15>
		</cfif>
		
		<cfset articles = getEntries(arguments.params)>
		
		<cfif arguments.version is 1>
	
			<cfsavecontent variable="header">
			<cfoutput>
			<?xml version="1.0" encoding="utf-8"?>
			
			<rdf:RDF 
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns##"
				xmlns:dc="http://purl.org/dc/elements/1.1/"
				xmlns="http://purl.org/rss/1.0/"
			>
			</cfoutput>
			</cfsavecontent>
	
			<cfsavecontent variable="channel">
			<cfoutput>
			<channel rdf:about="#xmlFormat(instance.blogURL)#">
			<title>#xmlFormat(instance.blogTitle)##arguments.additionalTitle#</title>
			<description>#xmlFormat(instance.blogDescription)#</description>
			<link>#xmlFormat(instance.blogURL)#</link>
		
			<items>
				<rdf:Seq>
					<cfloop query="articles">
					<rdf:li rdf:resource="#xmlFormat(makeLink(id))#" />
					</cfloop>
				</rdf:Seq>
			</items>
			
			</channel>
			</cfoutput>
			</cfsavecontent>
	
			<cfif not find("-", z.utcHourOffset)>
				<cfset utcPrefix = "-">
			<cfelse>
				<cfset z.utcHourOffset = right(z.utcHourOffset, len(z.utcHourOffset) -1 )>
				<cfset utcPrefix = "+">
			</cfif>
			
			<cfsavecontent variable="items">
			<cfloop query="articles">
			<cfset dateStr = dateFormat(posted,"yyyy-mm-dd")>
			<cfset dateStr = dateStr & "T" & timeFormat(posted,"HH:mm:ss") & utcPrefix & numberFormat(z.utcHourOffset,"00") & ":00">
			<cfoutput>
		  	<item rdf:about="#xmlFormat(makeLink(id))#">
			<title>#xmlFormat(title)#</title>
			<description><cfif arguments.mode is "short" and len(REReplaceNoCase(body,"<[^>]*>","","ALL")) gte arguments.excerpt>#xmlFormat(left(REReplaceNoCase(body,"<[^>]*>","","ALL"),arguments.excerpt))#...<cfelse>#xmlFormat(body)#</cfif><cfif len(morebody)> [More]</cfif></description>
			<link>#xmlFormat(makeLink(id))#</link>
			<dc:date>#dateStr#</dc:date>
			<dc:subject>#xmlFormat(categoryNames)#</dc:subject>
			</item>
			</cfoutput>
		 	</cfloop>
			</cfsavecontent>
	
			<cfset rssStr = trim(header & channel & items & "</rdf:RDF>")>
	
		<cfelseif arguments.version eq "2">
		
			<cfset rootURL = reReplace(instance.blogURL, "(.*)/index.cfm", "\1")>

			<cfsavecontent variable="header">
			<cfoutput>
			<?xml version="1.0" encoding="utf-8"?>
			
			<rss version="2.0">
			<channel>
			<title>#xmlFormat(instance.blogTitle)##arguments.additionalTitle#</title>
			<link>#xmlFormat(instance.blogURL)#</link>
			<description>#xmlFormat(instance.blogDescription)#</description>
			<language>#replace(lcase(instance.locale),'_','-','one')#</language>
			<pubDate>#dateFormat(blogNow(),"ddd, dd mmm yyyy") & " " & timeFormat(blogNow(),"HH:mm:ss") & " -" & numberFormat(z.utcHourOffset,"00") & "00"#</pubDate>
			<lastBuildDate>{LAST_BUILD_DATE}</lastBuildDate>
			<generator>BlogCFC</generator>
			<docs>http://blogs.law.harvard.edu/tech/rss</docs>
			<managingEditor>#xmlFormat(instance.owneremail)#</managingEditor>
			<webMaster>#xmlFormat(instance.owneremail)#</webMaster>
			</cfoutput>
			</cfsavecontent>
		
			<cfsavecontent variable="items">
			<cfloop query="articles">
			<cfset dateStr = dateFormat(posted,"ddd, dd mmm yyyy") & " " & timeFormat(posted,"HH:mm:ss") & " -" & numberFormat(z.utcHourOffset,"00") & "00">
			<cfoutput>
			<item>
				<title>#xmlFormat(title)#</title>
				<link>#xmlFormat(makeLink(id))#</link>
				<description>
				<!--- Regex operation removes HTML code from blog body output --->
				<cfif arguments.mode is "short" and len(REReplaceNoCase(body,"<[^>]*>","","ALL")) gte arguments.excerpt>
				#xmlFormat(left(REReplace(body,"<[^>]*>","","All"),arguments.excerpt))#...
				<cfelse>#xmlFormat(body)#</cfif>
				<cfif len(morebody)> [More]</cfif>
				</description>
				<cfloop index="cat" list="#categoryNames#">
				<category>#xmlFormat(cat)#</category>
				</cfloop>
				<pubDate>#dateStr#</pubDate>
				<guid>#xmlFormat(makeLink(id))#</guid>
				<cfif len(enclosure)>
				<enclosure url="#xmlFormat("#rootURL#/enclosures/#getFileFromPath(enclosure)#")#" length="#filesize#" type="#mimetype#"/>
				</cfif>
			</item>
			</cfoutput>
		 	</cfloop>
			</cfsavecontent>
		
			<cfset header = replace(header,'{LAST_BUILD_DATE}','#dateFormat(articles.posted[1],"ddd, dd mmm yyyy") & " " & timeFormat(articles.posted[1],"HH:mm:ss") & " -" & numberFormat(z.utcHourOffset,"00") & "00"#','one')>
			<cfset rssStr = trim(header & items & "</channel></rss>")>
		
		</cfif>
							
		<cfreturn rssStr>
		
	</cffunction>
	
	<cffunction name="getActiveDays" returnType="string" output="false" hint="Returns a list of days with Entries.">
		<cfargument name="year" type="numeric" required="true">
		<cfargument name="month" type="numeric" required="true">
		
		<cfset var dtMonth = createDateTime(arguments.year,arguments.month,1,0,0,0)>
		<cfset var dtEndOfMonth = createDateTime(arguments.year,arguments.month,daysInMonth(dtMonth),23,59,59)>
		<cfset var days = "">
		<cfset var posted = "">		

		<cfif instance.blogDBType is "MSSQL">
			<cfset posted = "dateAdd(hh, #instance.offset#, tblblogentries.posted)">
		<cfelseif instance.blogDBType is "MSACCESS">
			<cfset posted = "dateAdd('h', #instance.offset#, tblblogentries.posted)">
		<cfelseif instance.blogDBType is "MYSQL">
			<cfset posted = "date_add(posted, interval #instance.offset# hour)">
		</cfif>				
		
		<cfquery datasource="#instance.dsn#" name="days">
			select distinct 
				<cfif instance.blogDBType is "MSSQL">
					datepart(dd, #preserveSingleQuotes(posted)#) 
				<cfelseif instance.blogDBType is "MYSQL">
					extract(day from #preserveSingleQuotes(posted)#)
				<cfelseif instance.blogDBType is "MSACCESS">
					datepart('d', #preserveSingleQuotes(posted)#)
				</cfif> as posted_day
			from tblblogentries
			where 
				#preserveSingleQuotes(posted)# >= <cfqueryparam value="#dtMonth#" cfsqltype="CF_SQL_TIMESTAMP">
				and 
				#preserveSingleQuotes(posted)# <= <cfqueryparam value="#dtEndOfMonth#" cfsqltype="CF_SQL_TIMESTAMP">
				and blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
				and	#preserveSingleQuotes(posted)# < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#blogNow()#">
				and	released = 1
		</cfquery>

		<cfreturn valueList(days.posted_day)>

	</cffunction>
	
	<cffunction name="getCategories" access="remote" returnType="query" output="false">
		<cfset var getC = "">
		<cfset var getTotal = "">
		
		<!---
		Update on May 10, 2006
		So I wanted to update the code to handle cats with 0 entries. This proved difficult.
		My friend Tai sent code that he said would work on both mssql and mysql,
		but it only worked on mssql for me.
		
		So for now I'm going to use the "nice" method for mssql, and the "hack" method
		for the others. The hack method will be slower, but it should not be terrible.
		--->
		
		<cfif instance.blogDBType is "mssql">

			<cfquery name="getC" datasource="#instance.dsn#">
				select	tblblogcategories.categoryid, tblblogcategories.categoryname, tblblogcategories.categoryalias, count(tblblogentriescategories.entryidfk) as entryCount
				from	(tblblogcategories
				left outer join
				tblblogentriescategories ON tblblogcategories.categoryid = tblblogentriescategories.categoryidfk)
				left join tblblogentries on tblblogentriescategories.entryidfk = tblblogentries.id
				where	tblblogcategories.blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
				<!--- Don't allow future posts unless logged in. --->
				<cfif not isUserInRole("admin")>
					<cfif instance.blogDBType is "mssql">
						and isNull(tblblogentries.posted, '1/1/1900') < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#blogNow()#">
					 	and isNull(tblblogentries.released, 1) = 1 
	 				<cfelseif instance.blogDBType is "mysql">
						and ifNull(tblblogentries.posted, '1/1/1900') < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#blogNow()#">
					 	and ifNull(tblblogentries.released, 1) = 1 
					</cfif>
				</cfif>
				group by tblblogcategories.categoryid, tblblogcategories.categoryname, tblblogcategories.categoryalias
				order by tblblogcategories.categoryname
			</cfquery>

		<cfelse>
		
			<cfquery name="getC" datasource="#instance.dsn#">
			select	tblblogcategories.categoryid, tblblogcategories.categoryname, tblblogcategories.categoryalias
			from	tblblogcategories
			where	tblblogcategories.blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
			order by tblblogcategories.categoryname
			</cfquery>

			<cfset queryAddColumn(getC, "entrycount", arrayNew(1))>
			
			<cfloop query="getC">
				<cfquery name="getTotal" datasource="#instance.dsn#">
				select	count(entryidfk) as total
				from	tblblogentriescategories
				where	categoryidfk = <cfqueryparam value="#categoryid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
				</cfquery>
				<cfif getTotal.recordCount>
					<cfset querySetCell(getC, "entrycount", getTotal.total, currentRow)>
				<cfelse>
					<cfset querySetCell(getC, "entrycount", 0, currentRow)>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn getC>
	</cffunction>
	
	<cffunction name="getCategoriesForEntry" access="remote" returnType="query" output="false">
		<cfargument name="id" type="uuid" required="true">
		<cfset var getC = "">
		
		<cfif not entryExists(arguments.id)>
			<cfset utils.throw("#arguments.id# does not exist.")>
		</cfif>
		
		<cfquery name="getC" datasource="#variables.dsn#">
			select	tblblogcategories.categoryID, tblblogcategories.categoryname
			from	tblblogcategories, tblblogentriescategories
			where	tblblogcategories.categoryID = tblblogentriescategories.categoryidfk
			and		tblblogentriescategories.entryidfk = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		<cfreturn getC>

	</cffunction>

	<cffunction name="getCategory" access="remote" returnType="query" output="false">
		<cfargument name="id" type="uuid" required="true">
		<cfset var getC = "">
		
		<cfif not categoryExists(id="#arguments.id#")>
			<cfset utils.throw("#arguments.id# is not a valid category.")>
		</cfif>
		
		<cfquery name="getC" datasource="#instance.dsn#">
			select	categoryname, categoryalias
			from	tblblogcategories
			where	categoryid = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			and		blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
		</cfquery>
		
		<cfreturn getC>
		
	</cffunction>

	<cffunction name="getCategoryByAlias" access="remote" returnType="string" output="false">
		<cfargument name="alias" type="string" required="true">
		<cfset var getC = "">
				
		<cfquery name="getC" datasource="#instance.dsn#">
			select	categoryid
			from	tblblogcategories
			where	categoryalias = <cfqueryparam value="#arguments.alias#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
			and		blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
		</cfquery>
		
		<cfreturn getC.categoryid>
		
	</cffunction>

	<!--- This method originally written for parseses, but is not used. Keeping it around though. --->
	<cffunction name="getCategoryByName" access="remote" returnType="string" output="false">
		<cfargument name="name" type="string" required="true">
		<cfset var getC = "">
				
		<cfquery name="getC" datasource="#instance.dsn#">
			select	categoryid
			from	tblblogcategories
			where	categoryname = <cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
			and		blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
		</cfquery>
		
		<cfreturn getC.categoryid>
		
	</cffunction>

	<cffunction name="getComment" access="remote" returnType="query" output="false"
				hint="Gets a comment.">
		<cfargument name="id" type="uuid" required="true">
		<cfset var getC = "">
		
		<cfquery name="getC" datasource="#instance.dsn#">
			select		id, name, email, website, comment, posted, subscribe
			from		tblblogcomments
			where		id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
		<cfreturn getC>

	</cffunction>
	
	<cffunction name="getComments" access="remote" returnType="query" output="false"
				hint="Gets comments for an entry.">
		<cfargument name="id" type="uuid" required="false">
		<cfargument name="sortdir" type="string" required="false" default="asc">

		<cfset var getC = "">
		
		<cfif structKeyExists(arguments, "id") and not entryExists(arguments.id)>
			<cfset utils.throw("#arguments.id# does not exist.")>
		</cfif>
		
		<cfif arguments.sortDir is not "asc" and arguments.sortDir is not "desc">
			<cfset arguments.sortDir = "asc">
		</cfif>
		
		<!--- RBB 11/02/2005: Added website to query --->
		<cfquery name="getC" datasource="#instance.dsn#">
			select		tblblogcomments.id, tblblogcomments.name, tblblogcomments.email, tblblogcomments.website, 
						tblblogcomments.comment, tblblogcomments.posted, tblblogcomments.subscribe
			from		tblblogcomments, tblblogentries
			where		tblblogcomments.entryidfk = tblblogentries.id
			<cfif structKeyExists(arguments, "id")>
			and			tblblogcomments.entryidfk = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			</cfif>
			and			tblblogentries.blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
			order by	tblblogcomments.posted #arguments.sortdir#
		</cfquery>
		
		<cfreturn getC>
		
	</cffunction>
	
	<cffunction name="getEntry" access="remote" returnType="struct" output="false"
				hint="Returns one particular entry.">
		<cfargument name="id" type="uuid" required="true">
		<cfset var getIt = "">
		<cfset var s = structNew()>
		<cfset var col = "">
		<cfset var getCategories = "">
		
		<cfif not entryExists(arguments.id)>
			<cfset utils.throw("#arguments.id# does not exist.")>
		</cfif>
	
		<cfquery name="getIt" datasource="#instance.dsn#">
			select		tblblogentries.id, tblblogentries.title, 
						<!--- Handle offset --->
						<cfif instance.blogDBType is "MSACCESS">
						dateAdd('h', #instance.offset#, tblblogentries.posted) as posted, 
						<cfelseif instance.blogDBType is "MSSQL">
						dateAdd(hh, #instance.offset#, tblblogentries.posted) as posted, 
						<cfelse>
						date_add(posted, interval #instance.offset# hour) as posted, 
						</cfif>
						tblblogentries.body, 
						tblblogentries.morebody, tblblogentries.alias, tblusers.name, tblblogentries.allowcomments,
						tblblogentries.enclosure, tblblogentries.filesize, tblblogentries.mimetype, tblblogentries.released, tblblogentries.mailed
			from		tblblogentries, tblusers
			where		tblblogentries.id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			and			tblblogentries.blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
			and			tblblogentries.username = tblusers.username
		</cfquery>

		<cfquery name="getCategories" datasource="#instance.dsn#">
			select	categoryid,categoryname
			from	tblblogcategories, tblblogentriescategories
			where	tblblogentriescategories.entryidfk = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			and		tblblogentriescategories.categoryidfk = tblblogcategories.categoryid
		</cfquery>
				
		<cfloop index="col" list="#getIt.columnList#">
			<cfset s[col] = getIt[col][1]>
		</cfloop>

		<cfset s.categories = structNew()>
		<cfloop query="getCategories">
			<cfset s.categories[categoryid] = categoryname>
		</cfloop>
		
		<!--- Handle view --->
		<cfquery datasource="#instance.dsn#">
		update	tblblogentries
		set		views = views + 1
		where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
		<cfreturn s>
		
	</cffunction>
	
	<cffunction name="getEntries" access="remote" returnType="query" output="false"
				hint="Returns entries. Allows for a params structure to configure what entries are returned.">
		<cfargument name="params" type="struct" required="false" default="#structNew()#">
		<cfset var getEm = "">
		<cfset var getComments = "">
		<cfset var getCategories = "">
		<cfset var getTrackbacks = "">
		<cfset var validOrderBy = "posted,title">
		<cfset var validOrderByDir = "asc,desc">
		<cfset var validMode = "short,full">
		<cfset var pos = "">
		<cfset var id = "">
		
		<!--- By default, order the results by posted col --->
		<cfif not structKeyExists(arguments.params,"orderBy") or not listFindNoCase(validOrderBy,arguments.params.orderBy)>
			<cfset arguments.params.orderBy = "posted">
		</cfif>
		<!--- By default, order the results direction desc --->
		<cfif not structKeyExists(arguments.params,"orderByDir") or not listFindNoCase(validOrderBy,arguments.params.orderByDir)>
			<cfset arguments.params.orderByDir = "desc">
		</cfif>
		<!--- If lastXDays is passed, verify X is int between 1 and 365 --->
		<cfif structKeyExists(arguments.params,"lastXDays")>
			<cfif not val(arguments.params.lastXDays) or val(arguments.params.lastXDays) lt 1 or val(arguments.params.lastXDays) gt 365>
				<cfset structDelete(arguments.params,"lastXDays")>
			<cfelse>
				<cfset arguments.params.lastXDays = val(arguments.params.lastXDays)>
			</cfif>
		</cfif>
		<!--- If byDay is passed, verify X is int between 1 and 31 --->
		<cfif structKeyExists(arguments.params,"byDay")>
			<cfif not val(arguments.params.byDay) or val(arguments.params.byDay) lt 1 or val(arguments.params.byDay) gt 31>
				<cfset structDelete(arguments.params,"byDay")>
			<cfelse>
				<cfset arguments.params.byDay = val(arguments.params.byDay)>
			</cfif>
		</cfif>
		<!--- If byMonth is passed, verify X is int between 1 and 12 --->
		<cfif structKeyExists(arguments.params,"byMonth")>
			<cfif not val(arguments.params.byMonth) or val(arguments.params.byMonth) lt 1 or val(arguments.params.byMonth) gt 12>
				<cfset structDelete(arguments.params,"byMonth")>
			<cfelse>
				<cfset arguments.params.byMonth = val(arguments.params.byMonth)>
			</cfif>
		</cfif>
		<!--- If byYear is passed, verify X is int  --->
		<cfif structKeyExists(arguments.params,"byYear")>
			<cfif not val(arguments.params.byYear)>
				<cfset structDelete(arguments.params,"byYear")>
			<cfelse>
				<cfset arguments.params.byYear = val(arguments.params.byYear)>
			</cfif>
		</cfif>
		<!--- If byTitle is passed, verify we have a length  --->
		<cfif structKeyExists(arguments.params,"byTitle")>
			<cfif not len(trim(arguments.params.byTitle))>
				<cfset structDelete(arguments.params,"byTitle")>
			<cfelse>
				<cfset arguments.params.byTitle = trim(arguments.params.byTitle)>
			</cfif>
		</cfif>

		<!--- By default, get body, commentCount and categories as well, requires additional lookup --->
		<cfif not structKeyExists(arguments.params,"mode") or not listFindNoCase(validMode,arguments.params.mode)>
			<cfset arguments.params.mode = "full">
		</cfif>
		<!--- handle searching --->
		<cfif structKeyExists(arguments.params,"searchTerms") and not len(trim(arguments.params.searchTerms))>
			<cfset structDelete(arguments.params,"searchTerms")>
		</cfif>
		<!--- Limit number returned. Thanks to Rob Brooks-Bilson --->
		<cfif structKeyExists(arguments.params,"maxEntries") and not val(arguments.params.maxEntries)>
			<cfset structDelete(arguments.params,"maxEntries")>
		</cfif>
		
		<cfquery name="getEm" datasource="#instance.dsn#">
			select		
				<cfif structKeyExists(arguments.params,"maxEntries") and 
					  instance.blogDBType is not "MYSQL">
					top #arguments.params.maxEntries#
				</cfif> 
					tblblogentries.id, tblblogentries.title, 
					tblblogentries.alias, 
					<!--- Handle offset --->
					<cfif instance.blogDBType is "MSACCESS">
						dateAdd('h', #instance.offset#, tblblogentries.posted) as posted, 
					<cfelseif instance.blogDBType is "MSSQL">
						dateAdd(hh, #instance.offset#, tblblogentries.posted) as posted, 
					<cfelse>
					date_add(posted, interval #instance.offset# hour) as posted, 
					</cfif>
					tblusers.name, tblblogentries.allowcomments,
					tblblogentries.enclosure, tblblogentries.filesize, tblblogentries.mimetype, tblblogentries.released, tblblogentries.views
				<cfif arguments.params.mode is "full">, tblblogentries.body, tblblogentries.morebody</cfif>
			from	tblblogentries, tblusers
			<cfif structKeyExists(arguments.params,"byCat")>,tblblogentriescategories</cfif>
			
			where		1=1
			
						and blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
						and tblblogentries.username = tblusers.username
			<cfif structKeyExists(arguments.params,"lastXDays")>
				and tblblogentries.posted >= <cfqueryparam value="#dateAdd("d",-1*arguments.params.lastXDays,blogNow())#" cfsqltype="CF_SQL_DATE">
			</cfif>
			
			<cfif structKeyExists(arguments.params,"byDay")>
				<cfif instance.blogDBType is "MSSQL">
					and day(dateAdd(hh, #instance.offset#, tblblogentries.posted)) 
				<cfelseif  instance.blogDBType is "MSACCESS">
					and day(dateAdd('h', #instance.offset#, tblblogentries.posted)) 
				<cfelseif instance.blogDBType is "MYSQL">
					and dayOfMonth(date_add(posted, interval #instance.offset# hour))
				</cfif>
				= <cfqueryparam value="#arguments.params.byDay#" cfsqltype="CF_SQL_NUMERIC">
			</cfif>
			
			<cfif structKeyExists(arguments.params,"byMonth")>
				<cfif instance.blogDBType is "MSSQL">
					and month(dateAdd(hh, #instance.offset#, tblblogentries.posted)) = <cfqueryparam value="#arguments.params.byMonth#" cfsqltype="CF_SQL_NUMERIC">
				<cfelseif instance.blogDBType is "MSACCESS">
					and month(dateAdd('h', #instance.offset#, tblblogentries.posted)) = <cfqueryparam value="#arguments.params.byMonth#" cfsqltype="CF_SQL_NUMERIC">
				<cfelseif instance.blogDBType is "MYSQL">
					and month(date_add(posted, interval #instance.offset# hour)) = <cfqueryparam value="#arguments.params.byMonth#" cfsqltype="CF_SQL_NUMERIC">
				</cfif>
			</cfif>
			
			<cfif structKeyExists(arguments.params,"byYear")>
				<cfif instance.blogDBType is "MSSQL">
					and year(dateAdd(hh, #instance.offset#, tblblogentries.posted)) = <cfqueryparam value="#arguments.params.byYear#" cfsqltype="CF_SQL_NUMERIC">
				<cfelseif instance.blogDBType is "MSACCESS">
					and year(dateAdd('h', #instance.offset#, tblblogentries.posted)) = <cfqueryparam value="#arguments.params.byYear#" cfsqltype="CF_SQL_NUMERIC">
				<cfelseif instance.blogDBType is "MYSQL">
					and year(date_add(posted, interval #instance.offset# hour)) = <cfqueryparam value="#arguments.params.byYear#" cfsqltype="CF_SQL_NUMERIC">
				</cfif>					
			</cfif>

			<cfif structKeyExists(arguments.params,"byTitle")>
				and tblblogentries.title = <cfqueryparam value="#arguments.params.byTitle#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			</cfif>
			
			<cfif structKeyExists(arguments.params,"byCat")>
				and tblblogentriescategories.entryidfk = tblblogentries.id
				and tblblogentriescategories.categoryidfk = <cfqueryparam value="#arguments.params.byCat#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			</cfif>
			
			<cfif structKeyExists(arguments.params,"searchTerms")>
				<cfif not structKeyExists(arguments.params, "dontlogsearch")>
					<cfset logSearch(arguments.params.searchTerms)>
				</cfif>
				and (tblblogentries.title like '%#arguments.params.searchTerms#%' OR tblblogentries.body like '%#arguments.params.searchTerms#%' or tblblogentries.morebody like '%#arguments.params.searchTerms#%')
			</cfif>
			
			<cfif structKeyExists(arguments.params,"byEntry")>
				and tblblogentries.id = <cfqueryparam value="#arguments.params.byEntry#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			</cfif>
			
			<cfif structKeyExists(arguments.params,"byAlias")>
				and tblblogentries.alias = <cfqueryparam value="#arguments.params.byAlias#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			</cfif>

			<!--- Don't allow future posts unless logged in. --->
			<cfif not isUserInRole("admin")>
			and			posted < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
			and			released = 1
			</cfif>
			
			order by 	tblblogentries.#arguments.params.orderBy# #arguments.params.orderByDir#
			<cfif structKeyExists(arguments.params,"maxEntries") and instance.blogDBType is "MYSQL">limit #arguments.params.maxEntries#</cfif>
		</cfquery>
		
		<cfif arguments.params.mode is "full" and getEm.recordCount>
			<cfset queryAddColumn(getEm,"commentCount",arrayNew(1))>
			<cfquery name="getComments" datasource="#instance.dsn#">
				select count(id) as commentCount, entryidfk
				from 	tblblogcomments
				where	entryidfk in (<cfqueryparam value="#valueList(getEm.id)#" cfsqltype="CF_SQL_VARCHAR" list="Yes">)
				group by entryidfk
			</cfquery>
			<cfif getComments.recordCount>
				<!--- for each row, need to find in getEm --->
				<cfloop query="getComments">
					<cfset pos = listFindNoCase(valueList(getEm.id),entryidfk)>
					<cfif pos>
						<cfset querySetCell(getEm,"commentCount",commentCount,pos)>
					</cfif>
				</cfloop>
			</cfif>
			<cfset queryAddColumn(getEm,"categoryids",arrayNew(1))>
			<cfset queryAddColumn(getEm,"categorynames",arrayNew(1))>
			<cfloop query="getEm">
				<cfquery name="getCategories" datasource="#instance.dsn#">
					select	categoryid,categoryname
					from	tblblogcategories, tblblogentriescategories
					where	tblblogentriescategories.entryidfk = <cfqueryparam value="#getEm.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
					and		tblblogentriescategories.categoryidfk = tblblogcategories.categoryid
				</cfquery>
				<cfset querySetCell(getEm,"categoryids",valueList(getCategories.categoryID),currentRow)>
				<cfset querySetCell(getEm,"categorynames",valueList(getCategories.categoryname),currentRow)>
			</cfloop>
			
			<cfset queryAddColumn(getEm,"trackbackCount",arrayNew(1))>
			<cfquery name="getTrackbacks" datasource="#instance.dsn#">
				select count(id) as trackbackCount, entryid
				from 	tblblogtrackbacks
				where	entryid in (<cfqueryparam value="#valueList(getEm.id)#" cfsqltype="CF_SQL_VARCHAR" list="Yes">)
				group by entryid
			</cfquery>
			<cfif getTrackbacks.recordCount>
				<!--- for each row, need to find in getEm --->
				<cfloop query="getTrackbacks">
					<cfset pos = listFindNoCase(valueList(getEm.id),entryid)>
					<cfif pos>
						<cfset querySetCell(getEm,"trackbackCount",trackbackCount,pos)>
					</cfif>
				</cfloop>
			</cfif>
			
		</cfif>
		
		
		<cfreturn getEm>
		
	</cffunction>

	<cffunction name="getProperties" access="remote" returnType="struct" output="false">
		<cfreturn duplicate(instance)>
	</cffunction>
	
	<cffunction name="getProperty" access="remote" returnType="any" output="false">
		<cfargument name="property" type="string" required="true">
		
		<cfif not structKeyExists(instance,arguments.property)>
			<cfset utils.throw("#arguments.property# is not a valid property.")>
		</cfif>
		
		<cfreturn instance[arguments.property]>
		
	</cffunction>

	<cffunction name="getRecentComments" access="remote" returnType="query" output="false"
                hint="Returns the last N comments.">
        <cfargument name="maxEntries" type="numeric" required="false" default="10">
        <cfset var getRecentComments = "">
       
		<cfquery datasource="#instance.dsn#" name="getRecentComments">
		select <cfif instance.blogDBType is not "MYSQL">
                    top #arguments.maxEntries#
                </cfif>
		e.id as entryID,
		e.title,
		c.id,
		c.entryidfk,
		c.name,
		c.comment,
		<!--- Handle offset --->
		<cfif instance.blogDBType is "MSACCESS">
		    dateAdd('h', #instance.offset#, c.posted) as posted
		<cfelseif instance.blogDBType is "MSSQL">
		    dateAdd(hh, #instance.offset#, c.posted) as posted
		<cfelse>
		    date_add(c.posted, interval #instance.offset# hour) as posted
		</cfif>
		from tblblogcomments c
		inner join tblblogentries e on c.entryidfk = e.id
		where	 blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
		order by c.posted desc
		<cfif instance.blogDBType is "MYSQL">limit #arguments.maxEntries#</cfif>
		</cfquery>
        <cfreturn getRecentComments>
		
    </cffunction> 

	<!--- TODO: Take a look at this, something seems wrong. --->
	<cffunction name="getRelatedBlogEntries" access="remote" returntype="query" output="true" hint="returns related entries">
	    <cfargument name="entryId" type="uuid" required="true" />
	    <cfargument name="bDislayBackwardRelations" type="boolean" hint="Displays related entries that set from another entry" default="true" />
	    <cfargument name="bDislayFutureLinks" type="boolean" hint="Displays related entries that occur after the posted date of THIS entry" default="true" />
	
	    <cfset var qEntries = "" />

		<!--- BEGIN : added categoryID to related blog entry query : cjg : 31 december 2005 --->
		<!--- <cfset var qRelatedEntries = queryNew("id,title,posted,alias") />	--->
		<cfset var qRelatedEntries = queryNew("id,title,posted,alias,categoryName") />
		<!--- END : added categoryID to related blog entry query : cjg : 31 december 2005 --->
		
	    <cfset var qThisEntry = "" />
	    <cfset var getRelatedIds = "" />
	
	    <cfquery name="qThisEntry" datasource="#instance.dsn#">
	      select posted
	      from tblblogentries
	      where id = <cfqueryparam value="#arguments.entryId#" cfsqltype="CF_SQL_VARCHAR" maxlength="35" />
	    </cfquery>
	    <cfquery name="getRelatedIds" datasource="#instance.dsn#">
	      select distinct relatedid
	      from tblblogentriesrelated
	      where entryid = <cfqueryparam value="#arguments.entryId#" cfsqltype="CF_SQL_VARCHAR" maxlength="35" />
	      
	      <cfif bDislayBackwardRelations>
	      union
	      
	      select distinct entryid as relatedid
	      from tblblogentriesrelated
	      where relatedid = <cfqueryparam value="#arguments.entryId#" cfsqltype="CF_SQL_VARCHAR" maxlength="35" />
	      </cfif>
	    </cfquery>
	    <cfloop query="getRelatedIds">
		  <cfquery name="getThisRelatedEntry" datasource="#instance.dsn#">
			select
				tblblogentries.id,
				tblblogentries.title,
				tblblogentries.posted,
				tblblogentries.alias,
				tblblogcategories.categoryname
			from
				(tblblogcategories 
				inner join tblblogentriescategories on 
					tblblogcategories.categoryid = tblblogentriescategories.categoryidfk)
				inner join tblblogentries on 
					tblblogentriescategories.entryidfk = tblblogentries.id
	        where tblblogentries.id = <cfqueryparam value="#getrelatedids.relatedid#" cfsqltype="cf_sql_varchar" maxlength="35" />
	        and   tblblogentries.blog = <cfqueryparam value="#instance.name#" cfsqltype="cf_sql_varchar" maxlength="255">
	        <cfif bdislayfuturelinks is false>
				and tblblogentries.posted <= #createodbcdatetime(qthisentry.posted)#
	        </cfif>
			<!--- END : added categoryName to query : cjg : 31 december 2005 --->
	      </cfquery>
		  
	      <cfif getThisRelatedEntry.recordCount>
	        <cfset queryAddRow(qRelatedEntries, 1) />
	        <cfset querySetCell(qRelatedEntries, "id", getThisRelatedEntry.id) />
	        <cfset querySetCell(qRelatedEntries, "title", getThisRelatedEntry.title) />
	        <cfset querySetCell(qRelatedEntries, "posted", getThisRelatedEntry.posted) />
	        <cfset querySetCell(qRelatedEntries, "alias", getThisRelatedEntry.alias) />
			<!--- BEGIN : added categoryName to query : cjg : 31 december 2005 --->
			<cfset querySetCell(qRelatedEntries, "categoryName", getThisRelatedEntry.categoryName) />
			<!--- END : added categoryName to query : cjg : 31 december 2005 --->
	      </cfif>
	    </cfloop>
	    <cfif qRelatedEntries.recordCount>
	      <!--- Order By --->
	      <cfquery name="qRelatedEntries" dbtype="query">
	        select *
	        from qrelatedentries
	        order by posted desc
	      </cfquery>
	    </cfif>
	
		<cfreturn qRelatedEntries />
	</cffunction>
	<!--- END : get related entries method : cjg  --->

	<cffunction name="getRelatedEntriesSelects" access="remote" returntype="query" output="false">
		<cfset var getRelatedP = "" />
		
		<cfquery name="getRelatedP" datasource="#instance.dsn#">
			select 
				tblblogcategories.categoryname, 
				tblblogentries.id, 
				tblblogentries.title, 
				tblblogentries.posted
			from 
				tblblogentries inner join 
					(tblblogcategories inner join tblblogentriescategories on tblblogcategories.categoryid = tblblogentriescategories.categoryidfk) on 
						tblblogentries.id = tblblogentriescategories.entryidfk

			where tblblogcategories.blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">						
			order by
				tblblogcategories.categoryname, 
				tblblogentries.posted,
				tblblogentries.title
		</cfquery>
		
		<cfreturn getRelatedP />
	</cffunction>

	<cffunction name="getRootURL" access="public" returnType="string" output="false"
				hint="Simple helper function to get root url.">
		
		<cfset var theURL = replace(instance.blogurl, "index.cfm", "")>
		<cfreturn theURL>

	</cffunction>
		
	<cffunction name="getSubscribers" access="public" returnType="query" output="false"
				hint="Returns all people subscribed to the blog.">
		<cfset var getPeople = "">
		
		<cfquery name="getPeople" datasource="#instance.dsn#">
		select		email, token
		from		tblblogsubscribers
		where		blog = <cfqueryparam value="#instance.name#" cfsqltype="cf_sql_varchar" maxlength="50">
		order by	email asc
		</cfquery>
		
		<cfreturn getPeople>
	</cffunction>

	<cffunction name="getTrackBack" returnType="struct" access="remote" output="false"
				hint="Returns one trackback entry.">
		<cfargument name="id" type="string" required="true" hint="The id of the trackback.">
		<cfset var trackback = "">
		<cfset var result = structNew()>
				
		<cfquery name="trackback" datasource="#instance.dsn#">
			select		id, title, posturl, excerpt, created, entryid, blogname
			from		tblblogtrackbacks
			where		id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfif trackback.recordcount>
			<cfset result.id = trackback.id>
			<cfset result.title = trackback.title>
			<cfset result.posturl = trackback.posturl>
			<cfset result.excerpt = trackback.excerpt>
			<cfset result.created = trackback.created>
			<cfset result.entryid = trackback.entryid>
			<cfset result.blogname = trackback.blogname>
		</cfif>
		
		<cfreturn result>
		
	</cffunction>

	<cffunction name="getTrackBacks" returnType="query" access="remote" output="false"
				hint="Returns trackback entries for a blog post.">
		<cfargument name="id" type="string" required="false" hint="The id of the blog entry.">
		<cfargument name="sortdir" type="string" required="false" default="asc">
	
		<cfset var trackbacks = "">

		<cfif arguments.sortDir is not "asc" and arguments.sortDir is not "desc">
			<cfset arguments.sortDir = "asc">
		</cfif>
		
		<cfquery name="trackbacks" datasource="#instance.dsn#">
			select		id, title, posturl, excerpt, created, blogname
			from		tblblogtrackbacks
			where		blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">
			<cfif structKeyExists(arguments, "id")>
			and		entryid = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			order by	created #arguments.sortdir#
		</cfquery>

		<cfreturn trackbacks>
		
	</cffunction>
	
	<cffunction name="getValidDBTypes" access="public" returnType="string" output="false"
				hint="Returns the valid database types.">
		<cfreturn variables.validDBTypes>
	</cffunction>

	<cffunction name="getVersion" access="remote" returnType="string" output="false"
				hint="Returns the version of the blog.">
		<cfreturn variables.version>
	</cffunction>
	
	<cffunction name="isValidDBType" access="private" returnType="boolean" output="false"
				hint="Checks to see if a db type is valid for the blog.">
		<cfargument name="dbtype" type="string" required="true">
		
		<cfreturn listFindNoCase(getValidDBTypes(), arguments.dbType) gte 1>
		
	</cffunction>

	<cffunction name="logSearch" access="private" returnType="void" output="false"
				hint="Logs the search.">
		<cfargument name="searchterm" type="string" required="true">
		
		<cfquery datasource="#instance.dsn#">
		insert into tblblogsearchstats(searchterm, searched, blog)
		values(
			<cfqueryparam value="#arguments.searchterm#" cfsqltype="cf_sql_varchar" maxlength="255">,
			<cfqueryparam value="#blogNow()#" cfsqltype="cf_sql_timestamp">,
			<cfqueryparam value="#instance.name#" cfsqltype="cf_sql_varchar" maxlength="50">
		)
		</cfquery>
		
	</cffunction>

	<cffunction name="mailEntry" access="public" returnType="void" output="false"
				hint="Handles email for the blog.">
		<cfargument name="entryid" type="uuid" required="true">
		<cfset var entry = getEntry(arguments.entryid)>
		<cfset var subscribers = getSubscribers()>
		<cfset var theMessage = "">
		<cfset var mailBody = "">

		<cfloop query="subscribers">
		
			<cfsavecontent variable="theMessage">
			<cfoutput>
<h2>#entry.title#</h2>
<b>URL:</b> <a href="#makeLink(entry.id)#">#makeLink(entry.id)#</a><br />			

#renderEntry(entry.body,false,entry.enclosure)#<cfif len(entry.morebody)> 
<a href="#makeLink(entry.id)#">[Continued at Blog]</a></cfif>
				
<p>
You are receiving this email because you have subscribed to this blog.<br />
To unsubscribe, please go to this URL:
<a href="#getRootURL()#index.cfm?event=ehBlog.doUnsubscribe&email=#email#&token=#token#">#getRootURL()#index.cfm?event=ehBlog.doUnsubscribe&email=#email#&token=#token#</a>
</p>
			</cfoutput>
			</cfsavecontent>
			
			<cfif instance.mailserver is "">
				<cfmail to="#email#" from="#instance.owneremail#" subject="#instance.blogtitle# / #entry.title#" type="html">#theMessage#</cfmail>
			<cfelse>
				<cfmail to="#email#" from="#instance.owneremail#" subject="#instance.blogtitle# / #entry.title#"
						server="#instance.mailserver#" username="#instance.mailusername#" password="#instance.mailpassword#" type="html">#theMessage#</cfmail>
			</cfif>
		</cfloop>
			
		<!--- 
			update the record to mark it mailed.
			note: it is possible that an entry will never be marked mailed if your blog has
			no subscribers. I don't think this is an issue though.
		--->
		<cfquery datasource="#instance.dsn#">
		update tblblogentries
		set		mailed = 
				<cfif instance.blogDBType is not "MYSQL">
					<cfqueryparam value="true" cfsqltype="CF_SQL_BIT">
			   <cfelse>
  						<cfqueryparam value="1" cfsqltype="CF_SQL_TINYINT">
			   </cfif>		   
		where	id = <cfqueryparam value="#arguments.entryid#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		
	</cffunction>
	
	<cffunction name="makeCategoryLink" access="public" returnType="string" output="false"
				hint="Generates links for a category.">
		<cfargument name="catid" type="uuid" required="true">
		<cfset var q = "">
		
		<cfquery name="q" datasource="#instance.dsn#">
		select	categoryalias
		from	tblblogcategories
		where	categoryid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.catid#" maxlength="35">
		</cfquery>

		<cfif q.categoryalias is not "">
			<cfreturn "#instance.blogURL#/#q.categoryalias#">
		<cfelse>
			<cfreturn "#instance.blogURL#?mode=cat&catid=#arguments.catid#">
		</cfif>

	</cffunction>
	
	<cffunction name="makeLink" access="public" returnType="string" output="false"
				hint="Generates links for an entry.">
		<cfargument name="entryid" type="uuid" required="true">
		<cfset var q = "">
		<cfset var realdate = "">
		
		<cfquery name="q" datasource="#instance.dsn#">
		select	posted, alias
		from	tblblogentries
		where	id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entryid#" maxlength="35">
		</cfquery>
		
		<cfif q.alias is not "">
			<cfset realdate = dateAdd("h", instance.offset, q.posted)>
			<cfreturn "#instance.blogURL#/#year(realdate)#/#month(realdate)#/#day(realdate)#/#q.alias#">
		<cfelse>
			<cfreturn "#instance.blogURL#?mode=entry&entry=#arguments.entryid#">
		</cfif>
	</cffunction>

	<cffunction name="makeTitle" access="public" returnType="string" output="false"
				hint="Formats the title.">
		<cfargument name="title" type="string" required="true">
		
		<!--- Remove non alphanumeric but keep spaces. --->
		<cfset arguments.title = reReplace(arguments.title,"[^[:alnum:] ]","","all")>
		<!--- change spaces to - --->
		<cfset arguments.title = replace(arguments.title," ","-","all")>
		
		<cfreturn arguments.title>
	</cffunction>
	
	<cffunction name="notifyEntry" access="public" returnType="void" output="false"
				hint="Sends a message to everyone in an entry.">
		<cfargument name="entryid" type="uuid" required="true">
		<cfargument name="message" type="string" required="true">
		<cfargument name="subject" type="string" required="true">
		<cfargument name="from" type="string" required="true">
		
		<cfset var emailAddresses = structNew()>
		<cfset var folks = "">
		<cfset var folk = "">
		<cfset var comments = "">
		<cfset var address = "">
		<cfset var ulink = "">
		<cfset var theMessage = "">
		
		<!--- is it a valid entry? --->
		<cfif not entryExists(arguments.entryid)>
			<cfset utils.throw("#entryid# isn't a valid entry.")>
		</cfif>
		
		<!--- First, get everyone in the thread --->
		<cfset comments = getComments(arguments.entryid)>

		<cfloop query="comments">
			<cfif isBoolean(subscribe) and subscribe and not structKeyExists(emailAddresses, email)>
				<!--- We store the id of the comment, this is used in unsub  notices --->
				<cfset emailAddresses[email] = id>
			</cfif>
		</cfloop>
		
		<!--- Send email to admin --->
		<cfset emailAddresses[instance.ownerEmail] = "">
		
		<!--- Don't send email to from --->
		<cfset structDelete(emailAddresses, arguments.from)>
		
		<cfif not structIsEmpty(emailAddresses)>
			<!--- 
				Determine if we have a commentsFrom property. If so, it overrides this setting.
			--->
			<cfif getProperty("commentsFrom") neq "">
				<cfset arguments.from = getProperty("commentsFrom")>
			</cfif>

			<cfloop item="address" collection="#emailAddresses#">
				<!--- determine if msg has an unsub token, if so, prepare the link --->
				<!--- 
					Note, right now, the email sent to the admin will have a blank 
					commentID. Since the admin can't unsub anyway I don't think it
					is a huge deal.
				--->
				<cfif findNoCase("%unsubscribe%", arguments.message)>
					<cfif address is not instance.ownerEmail>
						<cfset ulink = getRootURL() & "unsubscribe.cfm" & 
						"?commentID=#emailAddresses[address]#&email=#address#">
					<cfelse>
						<cfset ulink = "Not available for owner.">
					</cfif>
					<cfset theMessage = replaceNoCase(arguments.message, "%unsubscribe%", ulink, "all")>
				<cfelse>
					<cfset theMessage = arguments.message>
				</cfif>
								
				<!--- switch depending on server --->
				<cfif instance.mailserver is "">
					<cfmail to="#address#" from="#arguments.from#" subject="#arguments.subject#">#theMessage#</cfmail>
				<cfelse>
					<cfmail to="#address#" from="#arguments.from#" subject="#arguments.subject#"
							server="#instance.mailserver#" username="#instance.mailusername#" password="#instance.mailpassword#">#theMessage#</cfmail>
				</cfif>
			</cfloop>
		</cfif>
		
	</cffunction>

	<cffunction name="removeCategory" access="remote" returnType="void" roles="admin" output="false"
				hint="remove entry ID from category X">
		<cfargument name="entryid" type="uuid" required="true">
		<cfargument name="categoryid" type="uuid" required="true">
		
		<cfquery datasource="#instance.dsn#">
			delete from tblblogentriescategories
			where categoryidfk = <cfqueryparam value="#arguments.categoryid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			and entryidfk = <cfqueryparam value="#arguments.entryid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>

	<cffunction name="removeCategories" access="remote" returnType="void" roles="admin" output="false"
				hint="Remove all categories from an entry.">
		<cfargument name="entryid" type="uuid" required="true">

		<cfquery datasource="#instance.dsn#">
			delete from tblblogentriescategories
			where	entryidfk = <cfqueryparam value="#arguments.entryid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
	</cffunction>

	<cffunction name="removeSubscriber" access="remote" returnType="boolean" output="false"
				hint="Removes a subscriber user.">
		<cfargument name="email" type="string" required="true">
		<cfargument name="token" type="uuid" required="false">
		<cfset var getMe = "">
		
		<cfif not isUserInRole("admin") and not structKeyExists(arguments,"token")>
			<cfset utils.throw("Unauthorized removal.")>
		</cfif>
		
		<!--- First, lets see if this guy is already subscribed. --->
		<cfquery name="getMe" datasource="#instance.dsn#">
		select	email
		from	tblblogsubscribers
		where	email = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar" maxlength="50">
		<cfif structKeyExists(arguments, "token")>
		and		token = <cfqueryparam value="#arguments.token#" cfsqltype="cf_sql_varchar" maxlength="35">
		</cfif>
		</cfquery>
		
		<cfif getMe.recordCount is 1>
			<cfquery datasource="#instance.dsn#">
			delete	from tblblogsubscribers
			where	email = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar" maxlength="50">
			<cfif structKeyExists(arguments, "token")>
			and		token = <cfqueryparam value="#arguments.token#" cfsqltype="cf_sql_varchar" maxlength="35">
			</cfif>
			and		blog = <cfqueryparam value="#instance.name#" cfsqltype="cf_sql_varchar" maxlength="50">
			</cfquery>

			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>

	</cffunction>

	<cffunction name="renderEntry" access="public" returnType="string" output="false"
				hint="Handles rendering the blog entry.">
		<cfargument name="string" type="string" required="true">
		<cfargument name="printformat" type="boolean" required="false" default="false">
		<cfargument name="enclosure" type="string" required="false" default="">
		<cfset var counter = "">
		<cfset var codeblock = "">
		<cfset var codeportion = "">
		<cfset var result = "">
		<cfset var newbody = "">
		<cfset var style = "">
		<cfset var imgURL = "">
		<cfset var rootURL = "">
			
		<!--- Check for code blocks --->
		<cfif findNoCase("<code>",arguments.string) and findNoCase("</code>",arguments.string)>
			<cfset counter = findNoCase("<code>",arguments.string)>
			<cfloop condition="counter gte 1">
                <cfset codeblock = reFindNoCase("(?s)(.*)(<code>)(.*)(</code>)(.*)",arguments.string,1,1)> 
				<cfif arrayLen(codeblock.len) gte 6>
                    <cfset codeportion = mid(arguments.string, codeblock.pos[4], codeblock.len[4])>
                    <cfif len(trim(codeportion))>
						<cfif arguments.printformat>
							<cfset style = "codePrint">
						<cfelse>
							<cfset style = "code">
						</cfif>	
						<cfset result = variables.utils.coloredcode(codeportion, style)>
					<cfelse>
						<cfset result = "">
					</cfif>
					<cfset newbody = mid(arguments.string, 1, codeblock.len[2]) & result & mid(arguments.string,codeblock.pos[6],codeblock.len[6])>
	
                    <cfset arguments.string = newbody>
					<cfset counter = findNoCase("<code>",arguments.string,counter)>
				<cfelse>
					<!--- bad crap, maybe <code> and no ender, or maybe </code><code> --->
					<cfset counter = 0>
				</cfif>
			</cfloop>
		</cfif>

		<!--- New enclosure support. If enclose if a jpg, png, or gif, put it on top, aligned left. --->
		<cfif len(arguments.enclosure) and listFindNoCase("gif,jpg,png", listLast(arguments.enclosure, "."))>
			<cfset rootURL = replace(instance.blogURL, "index.cfm", "")>
			<cfset imgURL = "#rootURL#enclosures/#urlEncodedFormat(getFileFromPath(enclosure))#">
			<cfset arguments.string = "<div class=""autoImage""><img src=""#imgURL#""></div>" & arguments.string>
		</cfif>
		
		<cfreturn paragraphFormat(arguments.string)>
	</cffunction>
	
	<cffunction name="saveCategory" access="remote" returnType="void" roles="admin" output="false"
				hint="Saves an category.">
		<cfargument name="id" type="uuid" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="alias" type="string" required="true">
		<cfset var oldName = getCategory(arguments.id).categoryname>
		
		<cflock name="blogcfc.addCategory" type="exclusive" timeout=30>
		
			<!--- new name? --->
			<cfif oldName neq arguments.name>
				<cfif categoryExists(name="#arguments.name#")>
					<cfset utils.throw("#arguments.name# already exists as a category.")>
				</cfif>
			</cfif>
	
			<cfquery datasource="#instance.dsn#">
			update	tblblogcategories
			set		categoryname = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar" maxlength="50">,
					categoryalias = <cfqueryparam value="#arguments.alias#" cfsqltype="cf_sql_varchar" maxlength="50">
			where	categoryid = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar" maxlength="35">
			</cfquery>

		</cflock>
				
	</cffunction>
	
	<cffunction name="saveComment" access="remote" returnType="uuid" output="false"
				hint="Saves a comment.">
		<cfargument name="commentid" type="uuid" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="email" type="string" required="true">
		<cfargument name="website" type="string" required="true">
		<cfargument name="comments" type="string" required="true">
		<cfargument name="subscribe" type="boolean" required="true">
				
		<cfset arguments.comments = htmleditformat(arguments.comments)>
		<cfset arguments.name = left(htmlEditFormat(arguments.name),50)>
		<cfset arguments.email = left(htmlEditFormat(arguments.email),50)>
		<cfset arguments.website = left(htmlEditFormat(arguments.website),255)>
						
		
		<cfquery datasource="#instance.dsn#">
		update tblblogcomments
		set name = <cfqueryparam value="#arguments.name#" maxlength="50">,
		email = <cfqueryparam value="#arguments.email#" maxlength="50">,
		website = <cfqueryparam value="#arguments.website#" maxlength="255">,
		comment = <cfqueryparam value="#arguments.comments#" cfsqltype="CF_SQL_LONGVARCHAR">,
		subscribe = 
			   <cfif instance.blogDBType is "MSSQL" or instance.blogDBType is "MSACCESS">
				   <cfqueryparam value="#arguments.subscribe#" cfsqltype="CF_SQL_BIT">
			   <cfelse>
   			   		<!--- convert yes/no to 1 or 0 --->
			   		<cfif arguments.subscribe>
			   			<cfset arguments.subscribe = 1>
			   		<cfelse>
			   			<cfset arguments.subscribe = 0>
			   		</cfif>
				   <cfqueryparam value="#arguments.subscribe#" cfsqltype="CF_SQL_TINYINT">
			   </cfif>		   

		where	id = <cfqueryparam value="#arguments.commentid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
				
		<cfreturn arguments.commentid>
	</cffunction>
	
	<cffunction name="saveEntry" access="remote" returnType="void" roles="admin" output="false"
				hint="Saves an entry.">
		<cfargument name="id" type="uuid" required="true">
		<cfargument name="title" type="string" required="true">
		<cfargument name="body" type="string" required="true">
		<cfargument name="morebody" type="string" required="false" default="">
		<cfargument name="alias" type="string" required="false" default="">
		<!--- I use "any" so I can default to a blank string --->		
		<cfargument name="posted" type="any" required="false" default="">	
		<cfargument name="allowcomments" type="boolean" required="false" default="true">	
		<cfargument name="enclosure" type="string" required="false" default="">	
		<cfargument name="filesize" type="numeric" required="false" default="0">
		<cfargument name="mimetype" type="string" required="false" default="">
		<cfargument name="released" type="boolean" required="false" default="true">
		<cfargument name="relatedPPosts" type="string" required="true" default="" />
		
		<cfif not entryExists(arguments.id)>
			<cfset utils.throw("#arguments.id# does not exist as an entry.")>
		</cfif>

		<cfquery datasource="#instance.dsn#">
			update tblblogentries
			set		title = <cfqueryparam value="#arguments.title#" cfsqltype="CF_SQL_CHAR" maxlength="100">,
					body = <cfqueryparam value="#arguments.body#" cfsqltype="CF_SQL_LONGVARCHAR">
					<cfif len(arguments.morebody)>
						,morebody = <cfqueryparam value="#arguments.morebody#" cfsqltype="CF_SQL_LONGVARCHAR">
					<!--- ME - 04/27/2005 - fix this to overwrite more/ on edit --->
				    <cfelse>
     					,morebody = <cfqueryparam null="yes" cfsqltype="CF_SQL_LONGVARCHAR">
					</cfif>
					<cfif len(arguments.alias)>
						,alias = <cfqueryparam value="#arguments.alias#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
					</cfif>
					<cfif len(arguments.posted) and isDate(arguments.posted)>
						,posted = <cfqueryparam value="#arguments.posted#" cfsqltype="CF_SQL_TIMESTAMP">
					</cfif>
					,username = <cfqueryparam value="#getAuthUser()#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
				    <cfif instance.blogDBType is not "MYSQL">
					,allowcomments = <cfqueryparam value="#arguments.allowcomments#" cfsqltype="CF_SQL_BIT">
			   		<cfelse>
				   		<!--- convert yes/no to 1 or 0 --->
				   		<cfif arguments.allowcomments>
				   			<cfset arguments.allowcomments = 1>
				   		<cfelse>
				   			<cfset arguments.allowcomments = 0>
				   		</cfif>
						,allowcomments = <cfqueryparam value="#arguments.allowcomments#" cfsqltype="CF_SQL_TINYINT">	
			   		</cfif>		   
			   		,enclosure = <cfqueryparam value="#arguments.enclosure#" cfsqltype="CF_SQL_CHAR" maxlength="255">
	  				,filesize = <cfqueryparam value="#arguments.filesize#" cfsqltype="CF_SQL_NUMERIC">
   					,mimetype = <cfqueryparam value="#arguments.mimetype#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">
   					<cfif instance.blogDBType is not "MYSQL">
					,released = <cfqueryparam value="#arguments.released#" cfsqltype="CF_SQL_BIT">
			   		<cfelse>
				   		<!--- convert yes/no to 1 or 0 --->
				   		<cfif arguments.released>
				   			<cfset arguments.released = 1>
				   		<cfelse>
				   			<cfset arguments.released = 0>
				   		</cfif>
						,released = <cfqueryparam value="#arguments.released#" cfsqltype="CF_SQL_TINYINT">	
			   		</cfif>		   

			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			and		blog = <cfqueryparam value="#instance.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
		</cfquery>

		<cfif len(trim(arguments.relatedpposts)) GT 0>
			<cfset saveRelatedEntries(arguments.ID, arguments.relatedpposts) />
		</cfif>
		
	</cffunction>

	<cffunction name="saveRelatedEntries" access="public" returntype="void" roles="admin" output="false"
		hint="I add/update related blog entries">
		<cfargument name="ID" type="UUID" required="true" />
		<cfargument name="relatedpposts" type="string" required="true" />
		
		<cfset var ppost = "" />
		
		<cfquery datasource="#instance.dsn#">
			delete from 
				tblblogentriesrelated 
			where 
				entryid = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
		<cfloop list="#arguments.relatedpposts#" index="ppost">
			<cfquery datasource="#instance.dsn#">
				insert into
					tblblogentriesrelated(
						entryid,
						relatedid
					) values (
						<cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
						<cfqueryparam value="#ppost#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
					)
			</cfquery>
		</cfloop>
		
	</cffunction>

	<cffunction name="setProperty" access="public" returnType="void" output="false" roles="admin">
		<cfargument name="property" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		
		<cfset setProfileString(variables.cfgFile, instance.name, arguments.property, arguments.value)>
		<cfset instance[arguments.property] = arguments.value>
		
	</cffunction>
	
	<cffunction name="unsubscribeThread" access="public" returnType="boolean" output="false"
				hint="Removes a user from a thread.">
		<cfargument name="commentID" type="UUID" required="true">
		<cfargument name="email" type="string" required="true">
		<cfset var verifySubscribe = "">
		
		<!--- First ensure that the commentID equals the email --->
		<cfquery name="verifySubscribe" datasource="#instance.dsn#">
			select	entryidfk
			from	tblblogcomments
			where	id = <cfqueryparam value="#arguments.commentID#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
			and		email = <cfqueryparam value="#arguments.email#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
		</cfquery>
		
		<!--- If we have a result, then set subscribe=0 for this user for ALL comments in the thread --->
		<cfif verifySubscribe.recordCount>
		
			<cfquery datasource="#instance.dsn#">
				update	tblblogcomments
				set		subscribe = 0
				where	entryidfk = <cfqueryparam value="#verifySubscribe.entryidfk#" 
									cfsqltype="CF_SQL_VARCHAR" maxlength="35">
				and		email = <cfqueryparam value="#arguments.email#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">
			</cfquery>
			
			<cfreturn true>
		</cfif>
		
		<cfreturn false>
	</cffunction>
			
</cfcomponent>
