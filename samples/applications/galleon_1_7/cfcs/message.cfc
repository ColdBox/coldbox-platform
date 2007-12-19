<!---
	Name         : message.cfc
	Author       : Raymond Camden 
	Created      : October 21, 2004
	Last Updated : December 8, 2006
	History      : We now check sendonpost to see if we notify admin on posts (rkc 10/21/04)
				   The email sent to admins now cotain forum/conference name. (rkc 2/11/05)
				   Was calling util.throw, not utils (rkc 3/31/05)
				   We needed settings, so now I just pass them all in. (rkc 7/14/05)
				   Subscriptions are different now (rkc 7/29/05)
				   New init, tableprefix (rkc 8/27/05)
				   getmessages returns forum+conference (rkc 9/9/05)
				   limit search string (rkc 10/30/05)
				   make title in subjects dynamic, fix SaveMessage for moderators (rkc 7/12/06)
				   Simple size change + new email support (rkc 7/27/06)
				   Render moved in here - attachment support (rkc 11/3/06)
				   Swaped render around (rkc 11/6/06)
				   Don't send email twice to admin, slight email tweaks (rkc 11/9/06)
				   Fix up the deletion of attachments (rkc 11/16/06)
				   Slight change to emails sent out - send the username as well (rkc 12/5/6)
				   Support for [img] (rkc 12/8/06)
	Purpose		 : 
--->
<cfcomponent displayName="Message" hint="Handles Messages.">

	<cfset variables.dsn = "">
	<cfset variables.dbtype = "">
	<cfset variables.tableprefix = "">

	<cfset variables.utils = createObject("component","utils")>
		
	<cffunction name="init" access="public" returnType="message" output="false"
				hint="Returns an instance of the CFC initialized with the correct DSN.">
		<cfargument name="settings" type="struct" required="true" hint="Setting">

		<cfset variables.dsn = arguments.settings.dsn>
		<cfset variables.dbtype = arguments.settings.dbtype>
		<cfset variables.tableprefix = arguments.settings.tableprefix>
		<cfset variables.attachmentdir = arguments.settings.attachmentdir>
		
		<cfset variables.thread = createObject("component","thread").init(arguments.settings)>
		<cfset variables.forum = createObject("component","forum").init(arguments.settings)>
		<cfset variables.conference = createObject("component","conference").init(arguments.settings)>
		<cfset variables.user = createObject("component","user").init(arguments.settings)>
		<cfset variables.utils = createObject("component","utils")>
		
		<cfset variables.settings = arguments.settings>
		
		<cfreturn this>
		
	</cffunction>

	<cffunction name="addMessage" access="remote" returnType="uuid" output="false"
				hint="Adds a message, and potentially a new thread.">
		
		<cfargument name="message" type="struct" required="true">
		<cfargument name="forumid" type="uuid" required="true">
		<cfargument name="username" type="string" required="false" default="#getAuthUser()#">
		<cfargument name="threadid" type="uuid" required="false">
		<cfset var badForum = false>
		<cfset var forum = "">
		<cfset var badThread = false>
		<cfset var tmpThread = "">
		<cfset var tmpConference = "">
		<cfset var newmessage = "">
		<cfset var getInterestedFolks = "">
		<cfset var thread = "">
		<cfset var newid = createUUID()>
		<cfset var notifiedList = "">
		
		<!--- First see if we can add a message. Because roles= doesn't allow for OR, we use a UDF --->
		<cfif not variables.utils.isUserInAnyRole2("forumsadmin,forumsmoderator,forumsmember")>
			<cfset variables.utils.throw("Message CFC","Unauthorized execution of addMessage.")>
		</cfif>

		<!--- Another security check - if arguments.username neq getAuthUser, throw --->
		<cfif arguments.username neq getAuthUser() and not isUserInRole("forumsadmin")>
			<cfset variables.utils.throw("Message CFC","Unauthorized execution of addMessage.")>
		</cfif>
				
		<cfif not validmessage(arguments.message)>
			<cfset variables.utils.throw("Message CFC","Invalid data passed to addMessage.")>
		</cfif>
		
		<!--- is the forum readonly, or non existent? --->
		<cftry>
			<cfset forum = variables.forum.getForum(arguments.forumid)>
			<cfif forum.readonly and not isUserInRole("forumsadmin")>
				<cfset badForum = true>
			<cfelse>
				<cfset tmpConference = variables.conference.getConference(forum.conferenceidfk)>
			</cfif>
			<cfcatch type="forumcfc">
				<!--- don't really care which it is - it is bad --->
				<cfset badForum = true>
			</cfcatch>
		</cftry>
		
		<cfif badForum>
			<cfset variables.utils.throw("MessageCFC","Invalid or Protected Forum")>
		</cfif>
		
		<!--- is the thread readonly, or nonexistent? --->
		<cfif isDefined("arguments.threadid")>
			<cftry>
				<cfset tmpThread = variables.thread.getThread(arguments.threadid)>
				<cfif tmpThread.readonly and not isUserInRole("forumsadmin")>
					<cfset badThread = true>
				</cfif>
				<cfcatch type="threadcfc">
					<!--- don't really care which it is - it is bad --->
					<cfset badThread = true>
				</cfcatch>
			</cftry>
			
			<cfif badThread>
				<cfset variables.utils.throw("MessageCFC","Invalid or Protected Thread")>
			</cfif>		
		<cfelse>
			<!--- We need to create a new thread --->
			<cfset tmpThread = structNew()>
			<cfset tmpThread.name = message.title>
			<cfset tmpThread.readonly = false>
			<cfset tmpThread.active = true>
			<cfset tmpThread.forumidfk = arguments.forumid>
			<cfset tmpThread.useridfk = variables.user.getUserID(arguments.username)>
			<cfset tmpThread.dateCreated = now()>
			<cfset tmpThread.sticky = false>
			<cfset arguments.threadid = variables.thread.addThread(tmpThread)>
		</cfif>
					
		<cfquery name="newmessage" datasource="#variables.dsn#">
			insert into #variables.tableprefix#messages(id,title,body,useridfk,threadidfk,posted,attachment,filename)
			values(<cfqueryparam value="#newid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
				   <cfqueryparam value="#arguments.message.title#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
				   <cfqueryparam value="#arguments.message.body#" cfsqltype="CF_SQL_LONGVARCHAR">,
				   <cfqueryparam value="#variables.user.getUserID(arguments.username)#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
				   <cfqueryparam value="#arguments.threadid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
				   <cfqueryparam value="#now()#" cfsqltype="CF_SQL_TIMESTAMP">,
				   <cfqueryparam value="#arguments.message.attachment#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
   				   <cfqueryparam value="#arguments.message.filename#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">				   
				   )
		</cfquery>

		<!--- get everyone in the thread who wants posts --->
		<cfset notifiedList = notifySubscribers(arguments.threadid, tmpThread.name, arguments.forumid, variables.user.getUserID(arguments.username),arguments.message.body)>
		
		<cfif structKeyExists(variables.settings,"sendonpost") and len(variables.settings.sendonpost) and not listFindNoCase(notifiedList, variables.settings.sendOnPost)>
			<cfmail to="#variables.settings.sendonpost#" from="#variables.settings.fromAddress#" 
					subject="#variables.settings.title# Notification: Post to #tmpThread.name#">
Title:		#arguments.message.title#
Thread: 	#tmpThread.name#
Forum:		#forum.name#
Conference:	#tmpConference.name#
User:		#arguments.username#

#wrap(arguments.message.body,80)#
			
#variables.settings.rootURL#index.cfm?event=ehMessages.dspMessages&threadid=#arguments.threadid#
			</cfmail>

		</cfif>
		
		<cfreturn newid>
				
	</cffunction>
	
	<cffunction name="deleteMessage" access="public" returnType="void" output="false"
				hint="Deletes a message.">

		<cfargument name="id" type="uuid" required="true">
		<cfset var q = "">
		
		<!--- First see if we can delete a message. Because roles= doesn't allow for OR, we use a UDF --->
		<cfif not variables.utils.isUserInAnyRole2("forumsadmin,forumsmoderator")>
			<cfset variables.utils.throw("Message CFC","Unauthorized execution of deleteMessage.")>
		</cfif>

		<cfquery name="q" datasource="#variables.dsn#">
			select	filename
			from 	#variables.tableprefix#messages
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

		<cfquery datasource="#variables.dsn#">
			delete	from #variables.tableprefix#messages
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
		<cfif len(q.filename) and fileExists("#variables.attachmentdir#/#q.filename#")>
			<cffile action="delete" file="#variables.attachmentdir#/#q.filename#">
		</cfif>
		
	</cffunction>
	
	<cffunction name="getMessage" access="remote" returnType="struct" output="false"
				hint="Returns a struct copy of the message.">
		<cfargument name="id" type="uuid" required="true">
		<cfset var qGetMessage = "">
				
		<cfquery name="qGetMessage" datasource="#variables.dsn#">
			select	id, title, body, posted, useridfk, threadidfk, attachment, filename
			from	#variables.tableprefix#messages
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

		<!--- Throw if invalid id passed --->
		<cfif not qGetMessage.recordCount>
			<cfset variables.utils.throw("MessageCFC","Invalid ID")>
		</cfif>
				
		<cfreturn variables.utils.queryToStruct(qGetMessage)>
			
	</cffunction>
		
	<cffunction name="getMessages" access="remote" returnType="query" output="false"
				hint="Returns a list of messages.">

		<cfargument name="threadid" type="uuid" required="false">
		
		<cfset var qGetMessages = "">
				
		<cfquery name="qGetMessages" datasource="#variables.dsn#">
		select	#variables.tableprefix#messages.id, #variables.tableprefix#messages.title, #variables.tableprefix#messages.body, #variables.tableprefix#messages.attachment, #variables.tableprefix#messages.filename, 
				#variables.tableprefix#messages.posted, #variables.tableprefix#messages.threadidfk, #variables.tableprefix#messages.useridfk, 
				#variables.tableprefix#threads.name as threadname, #variables.tableprefix#users.username,
				#variables.tableprefix#forums.name as forumname, #variables.tableprefix#conferences.name as conferencename
				
		from 	(((#variables.tableprefix#messages left join #variables.tableprefix#threads on #variables.tableprefix#messages.threadidfk = #variables.tableprefix#threads.id)
					left join #variables.tableprefix#forums on #variables.tableprefix#threads.forumidfk = #variables.tableprefix#forums.id)
					left join #variables.tableprefix#conferences on #variables.tableprefix#forums.conferenceidfk = #variables.tableprefix#conferences.id)
					left join #variables.tableprefix#users on #variables.tableprefix#messages.useridfk = #variables.tableprefix#users.id


		<cfif isDefined("arguments.threadid")>
			where		#variables.tableprefix#messages.threadidfk = <cfqueryparam value="#arguments.threadid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfif>
		order by	posted asc
		</cfquery>
		
		<cfreturn qGetMessages>
			
	</cffunction>
	
	<cffunction name="notifySubscribers" access="private" returnType="string" output="false"
				hint="Emails subscribers about a new post.">
		<cfargument name="threadid" type="uuid" required="true">
		<cfargument name="threadname" type="string" required="true">
		<cfargument name="forumid" type="uuid" required="true">
		<cfargument name="userid" type="uuid" required="true">
		<cfargument name="body" type="string" required="true">
		<cfset var forum = variables.forum.getForum(arguments.forumid)>
		<cfset var conference = variables.conference.getConference(forum.conferenceidfk)>
		<cfset var subscribers = "">
		
		<cfset var username = variables.user.getUser(variables.user.getUsernameFromId(arguments.userid)).username>
		
		<!--- 
			  In order to get our subscribers, we need to get the forum and conference for the thread.
			  Then - anyone who is subscribed to ANY of those guys will get notified, unless the person 
			  is #userid#, the originator of the post.
		--->
		<cfquery name="subscribers" datasource="#variables.dsn#">
		select	distinct #variables.tableprefix#subscriptions.useridfk, #variables.tableprefix#users.emailaddress
		from	#variables.tableprefix#subscriptions, #variables.tableprefix#users
		where	(#variables.tableprefix#subscriptions.threadidfk = <cfqueryparam value="#arguments.threadid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		or		#variables.tableprefix#subscriptions.forumidfk = <cfqueryparam value="#arguments.forumid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		or		#variables.tableprefix#subscriptions.conferenceidfk = <cfqueryparam value="#conference.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">)
		and		#variables.tableprefix#subscriptions.useridfk <> <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		and		#variables.tableprefix#subscriptions.useridfk = #variables.tableprefix#users.id
		</cfquery>
		
		<cfif subscribers.recordCount>
			<cfmail query="subscribers" subject="#variables.settings.title# Notification: Post to #arguments.threadname#" from="#variables.settings.fromAddress#" to="#emailaddress#">
A post has been made to a thread, forum, or conference that you are subscribed to.
You can change your subscription preferences by updating your profile.
You can visit the thread here:

#variables.settings.rootURL#index.cfm?event=ehMessages.dspMessages&threadid=#arguments.threadid#

Conference: #conference.name#
Forum:      #forum.name#
Thread:     #arguments.threadname#
User:       #username#
<cfif variables.settings.fullemails>
Message:
#wrap(arguments.body,80)#
</cfif>


			</cfmail>

		</cfif>
		
		<cfreturn valueList(subscribers.emailaddress)>
	</cffunction>
	
	<cffunction name="render" access="public" returnType="string" roles="" output="false"
				hint="This is used to render messages. Handles all string manipulations.">
		<cfargument name="message" type="string" required="true">
		<cfset var counter = "">
		<cfset var codeblock = "">
		<cfset var codeportion = "">
		<cfset var style = "code">
		<cfset var result = "">
		<cfset var newbody = "">
		<cfset var codeBlocks = arrayNew(1)>
		<cfset var imgBlocks = arrayNew(1)>
		<cfset var imgblock = "">
		<cfset var imgportion = "">
		
		<!--- Add Code Support --->
		<cfif findNoCase("[code]",arguments.message) and findNoCase("[/code]",arguments.message)>
			<cfset counter = findNoCase("[code]",arguments.message)>
			<cfloop condition="counter gte 1">
                <cfset codeblock = reFindNoCase("(?s)(.*)(\[code\])(.*)(\[/code\])(.*)",arguments.message,1,1)> 
				<cfif arrayLen(codeblock.len) gte 6>
                    <cfset codeportion = mid(arguments.message, codeblock.pos[4], codeblock.len[4])>
                    <cfif len(trim(codeportion))>
						<cfset result = variables.utils.coloredcode(codeportion, style)>
					<cfelse>
						<cfset result = "">
					</cfif>
					
					<cfset arrayAppend(codeBlocks,result)>
					<cfset newbody = mid(arguments.message, 1, codeblock.len[2]) & "****CODEBLOCK:#arrayLen(codeBlocks)#:KCOLBEDOC****" & mid(arguments.message,codeblock.pos[6],codeblock.len[6])>
                    <cfset arguments.message = newbody>
					<cfset counter = findNoCase("[code]",arguments.message,counter)>
				<cfelse>
					<!--- bad crap, maybe <code> and no ender, or maybe </code><code> --->
					<cfset counter = 0>
				</cfif>
			</cfloop>
		</cfif>

		<cfif findNoCase("[img]",arguments.message) and findNoCase("[/img]",arguments.message)>
			<cfset counter = findNoCase("[img]",arguments.message)>
			<cfloop condition="counter gte 1">
                <cfset imgblock = reFindNoCase("(?s)(.*)(\[img\])(.*)(\[/img\])(.*)",arguments.message,1,1)> 
				<cfif arrayLen(imgblock.len) gte 6>
                    <cfset imgportion = mid(arguments.message, imgblock.pos[4], imgblock.len[4])>
                    <cfif len(trim(imgportion))>
						<cfset result = "<img src=""#imgportion#"">">
					<cfelse>
						<cfset result = "">
					</cfif>
					
					<cfset arrayAppend(imgBlocks,result)>
					<cfset newbody = mid(arguments.message, 1, imgblock.len[2]) & "****IMGBLOCK:#arrayLen(imgBlocks)#:KCOLBGMI****" & mid(arguments.message,imgblock.pos[6],imgblock.len[6])>
                    <cfset arguments.message = newbody>
					<cfset counter = findNoCase("[img]",arguments.message,counter)>
				<cfelse>
					<!--- bad crap, maybe <code> and no ender, or maybe </code><code> --->
					<cfset counter = 0>
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- now htmlecode --->
		<cfset arguments.message = htmlEditFormat(arguments.message)>

		<!--- turn on URLs --->
		<cfset arguments.message = variables.utils.activeURL(arguments.message)>

		<!--- now put those blocks back in --->
		<cfloop index="counter" from="1" to="#arrayLen(codeBlocks)#">
			<cfset arguments.message = replace(arguments.message,"****CODEBLOCK:#counter#:KCOLBEDOC****", codeBlocks[counter])>
		</cfloop>
		<cfloop index="counter" from="1" to="#arrayLen(imgBlocks)#">
			<cfset arguments.message = replace(arguments.message,"****IMGBLOCK:#counter#:KCOLBGMI****", imgBlocks[counter])>
		</cfloop>
		
		<!--- add Ps --->
		<cfset arguments.message = variables.utils.paragraphFormat2(arguments.message)>
		
		<cfreturn arguments.message>
	</cffunction>

	<cffunction name="renderHelp" access="public" returnType="string" roles="" output="false"
				hint="This is used to return help for message editing.">
		<cfset var msg = "">
		
		<cfsavecontent variable="msg">
All URLs will be automatically linked. No HTML is allowed in your message.<br />
You may include code in your message like so: [code]...[/code].<br />
You may include an image in your message like so: [img]url[/img].<br />
		</cfsavecontent>
		
		<cfreturn msg>	
	</cffunction>
		
	<cffunction name="saveMessage" access="remote" returnType="void" roles="" output="false"
				hint="Saves an existing message.">
				
		<cfargument name="id" type="uuid" required="true">
		<cfargument name="message" type="struct" required="true">

		<cfif not variables.utils.isUserInAnyRole2("forumsadmin,forumsmoderator")>
			<cfset variables.utils.throw("Message CFC","Unauthorized execution of saveMessage.")>
		</cfif>
		
		<cfif not validMessage(arguments.message)>
			<cfset variables.utils.throw("Message CFC","Invalid data passed to saveMessage.")>
		</cfif>
		
		<cfquery datasource="#variables.dsn#">
			update	#variables.tableprefix#messages
			set		title = <cfqueryparam value="#arguments.message.title#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
					body = <cfqueryparam value="#arguments.message.body#" cfsqltype="CF_SQL_LONGVARCHAR">,
					threadidfk = <cfqueryparam value="#arguments.message.threadidfk#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
					useridfk = <cfqueryparam value="#arguments.message.useridfk#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
					posted = <cfqueryparam value="#arguments.message.posted#" cfsqltype="CF_SQL_TIMESTAMP">,
					attachment = <cfqueryparam value="#arguments.message.attachment#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">,
					filename = <cfqueryparam value="#arguments.message.filename#" cfsqltype="CF_SQL_VARCHAR" maxlength="255">
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>

	<cffunction name="search" access="remote" returnType="query" output="false"
				hint="Allows you to search messages.">
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
			select	id, title, threadidfk 
			from	#variables.tableprefix#messages
			where	1 = 1
			and (
				<cfif arguments.searchtype is not "phrase">
					<cfloop index="x" from=1 to="#arrayLen(aTerms)#">
						(title like <cfqueryparam cfsqltype="CF_SQL_VARCHAR" maxlength="255" value="%#left(aTerms[x],255)#%">
						or
						 body like '%#aTerms[x]#%'
						)
						 <cfif x is not arrayLen(aTerms)>#joiner#</cfif>
					</cfloop>
				<cfelse>
					title like <cfqueryparam cfsqltype="CF_SQL_VARCHAR" maxlength="255" value="%#left(arguments.searchTerms,255)#%">
					or
					body like '%#arguments.searchTerms#%'
				</cfif>
			)
		</cfquery>
		
		<cfreturn results>
	</cffunction>
	
	<cffunction name="validMessage" access="private" returnType="boolean" output="false"
				hint="Checks a structure to see if it contains all the proper keys/values for a forum.">
		
		<cfargument name="cData" type="struct" required="true">
		<cfset var rList = "title,body">
		<cfset var x = "">
		
		<cfloop index="x" list="#rList#">
			<cfif not structKeyExists(cData,x)>
				<cfreturn false>
			</cfif>
		</cfloop>
		
		<cfreturn true>
		
	</cffunction>
</cfcomponent>