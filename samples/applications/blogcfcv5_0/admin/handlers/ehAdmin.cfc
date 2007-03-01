<cfcomponent name="ehBlog" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->
	<cffunction name="onAppStart" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var blogname = getToken(application.applicationName,3,"_")>
		<cfset var lylaFile = "">
		<cfset var majorVersion = "">
		<cfset var minorVersion = "">
		<cfset var cfversion = "">

		<!--- load an init blog --->
		<cfset application.blog = createObject("component","#getSetting("ParentMapping")#.org.camden.blog.blog").init(blogname)>
		<!--- Path may be different if admin. --->
		<cfif findNoCase("admin/", cgi.script_name)>
			<cfset theFile = expandPath("../includes/main")>
			<cfset lylaFile = "../includes/captcha.xml">
		<cfelse>
			<cfset theFile = expandPath("./includes/main")>
			<cfset lylaFile = "./includes/captcha.xml">
		</cfif>
		<cfset getPlugin("i18n").setfwLocale(getSetting("DefaultLocale"))>

		<!--- Use Captcha? --->
		<cfset application.usecaptcha = application.blog.getProperty("usecaptcha")>

		<cfif application.usecaptcha>
			<cfset application.captcha = CreateObject("component","#getSetting("ParentMapping")#.org.captcha.captchaService").init(configFile="#lylaFile#") />
			<cfset application.captcha.setup() />
		</cfif>

		<!--- clear cache --->
		<cfmodule template="../../tags/scopecache.cfm" scope="application" clearall="true">

		<cfset majorVersion = listFirst(server.coldfusion.productversion)>
		<cfset minorVersion = listGetAt(server.coldfusion.productversion,2)>
		<cfset cfversion = majorVersion & "." & minorVersion>

		<cfset application.isColdFusionMX7 = server.coldfusion.productname is "ColdFusion Server" and cfversion gte 7>

		<!--- Used in various places --->
		<cfset application.rootURL = application.blog.getProperty("blogURL")>
		<!--- per documentation - rooturl should be http://www.foo.com/something/something/index.cfm --->
		<cfset application.rootURL = reReplace(application.rootURL, "(.*)/index.cfm", "\1")>

		<!--- used for cache purposes is 60 minutes --->
		<cfset application.timeout = 60*60>

		<!--- how many entries? --->
		<cfset application.maxEntries = application.blog.getProperty("maxentries")>

		<!--- TBs allowed? --->
		<cfset application.trackbacksAllowed = application.blog.getProperty("allowtrackbacks")>

		<!--- We are initialized --->
		<cfset application.init = true>

	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="onRequestStart" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- Encoding --->
		<cfset setEncoding("form","utf-8")>
		<cfset setEncoding("url","utf-8")>

		<cflogin>
			<cfif Context.valueExists("username") and Context.valueExists("password") and len(trim(Context.getValue("username"))) and len(trim(Context.getValue("password")))>
				<cfif application.blog.authenticate(left(trim(Context.getValue("username")),50),left(trim(Context.getValue("password")),50))>
					<cfloginuser name="#trim(Context.getValue("username"))#" password="#trim(Context.getValue("password"))#" roles="admin">
					<!---
						  This was added because CF's built in security system has no way to determine if a user is logged on.
						  In the past, I used getAuthUser(), it would return the username if you were logged in, but
						  it also returns a value if you were authenticated at a web server level. (cgi.remote_user)
						  Therefore, the only say way to check for a user logon is with a flag.
					--->
					<cfset session.loggedin = true>
				</cfif>
			</cfif>
		</cflogin>

		<cfif findNoCase("/admin", cgi.script_name) and not isLoggedIn() and not findNoCase("/admin/index.cfm?event=ehAdmin.dspNotify", cgi.script_name)>
			<cfset Context.overrideEvent("ehAdmin.dspLogin")>
		</cfif>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehEntries = "ehAdmin.dspEntries">
		<cfset rc.xehCategories = "ehAdmin.dspCategories">
		<cfset rc.xehComments = "ehAdmin.dspComments">
		<cfset rc.xehSettings = "ehAdmin.dspSettings">
		<cfset rc.xehSubscribers = "ehAdmin.dspSubscribers">
		<cfset rc.xehTrackbacks = "ehAdmin.dspTrackbacks">
		<cfset rc.xehStats = "ehAdmin.dspStats">
		<cfset rc.xehLogout = "ehAdmin.doLogout">		
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doLogout" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfif isLoggedIn()>
			<cfset structDelete(session,"loggedin")>
			<cflogout>
		</cfif>
		<!--- Set the next Event --->
		<cfset setNextEvent("ehAdmin.dspLogin")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspLogin" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var qs = cgi.query_string>
		<cfset Context.setValue("qs",reReplace(qs, "logout=[^&]+", ""))>
		<cfset Context.setValue("title","Logon")>
		<cfset Context.setView("vwLogin")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspHome" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset Context.setValue("title","Home")>
		<cfset Context.setView("vwIndex")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspStats" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<cfset var dsn = application.blog.getProperty("dsn")>
		<cfset var dbtype = application.blog.getProperty("blogdbtype")>
		<cfset var blog = application.blog.getProperty("name")>
		<cfset var thirtyDaysAgo = "">

		<!--- LM: All this should be in a Model call --->
		
		<!--- get a bunch of crap --->
		<cfquery name="rc.getTotalEntries" datasource="#dsn#">
				select	count(id) as totalentries,
						min(posted) as firstentry,
						max(posted) as lastentry
				from	tblblogentries
				where 	tblblogentries.blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">
		</cfquery>

		<cfquery name="rc.getTotalSubscribers" datasource="#dsn#">
			select	count(email) as totalsubscribers
			from	tblblogsubscribers
			where 	tblblogsubscribers.blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">
		</cfquery>
		
		<cfquery name="rc.getTotalViews" datasource="#dsn#">
			select		sum(views) as total
			from		tblblogentries
			where 	tblblogentries.blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">
		</cfquery>
		
		<cfquery name="rc.getTopViews" datasource="#dsn#">
			select		<cfif dbtype is not "mysql">top 10</cfif> id, title, views
			from		tblblogentries
			where 	tblblogentries.blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">
			order by	views desc
			<cfif dbtype is "mysql">limit 10</cfif>
		</cfquery>

		<!--- get last 30 --->
		<cfset thirtyDaysAgo = dateAdd("d", -30, now())>
		<cfquery name="rc.last30" datasource="#dsn#">
			select	count(id) as totalentries
			from	tblblogentries
			where 	tblblogentries.blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">
			and		posted >= <cfqueryparam cfsqltype="cf_sql_date" value="#thirtyDaysAgo#">
		</cfquery>
		
		<cfquery name="rc.getTotalComments" datasource="#dsn#">
			select	count(tblblogcomments.id) as totalcomments
			from	tblblogcomments, tblblogentries
			where	tblblogcomments.entryidfk = tblblogentries.id
			and		tblblogentries.blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">
		</cfquery>

		<!--- RBB: 1/20/2006: get trackbacks --->
		<cfquery name="rc.getTotalTrackbacks" datasource="#dsn#">
			select count(tblblogtrackbacks.id) as totaltrackbacks
			from	tblblogtrackbacks, tblblogentries
			where	tblblogtrackbacks.entryid = tblblogentries.id
			and		tblblogentries.blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">
		</cfquery>
		
		<!--- gets num of entries per category --->
		<cfquery name="rc.getCategoryCount" datasource="#dsn#">
			select	categoryid, categoryname, count(categoryidfk) as total
			from	tblblogcategories, tblblogentriescategories
			where	tblblogentriescategories.categoryidfk = tblblogcategories.categoryid
			and		tblblogcategories.blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">
			group by tblblogcategories.categoryid, tblblogcategories.categoryname
			<cfif dbtype is not "msaccess">
				order by total desc
			<cfelse>
				order by count(categoryidfk) desc
			</cfif>
		</cfquery>
		
		<!--- gets num of comments per entry, top 10 --->
		<cfquery name="rc.topCommentedEntries" datasource="#dsn#">
			select
			<cfif dbtype is not "mysql">top 10</cfif>
			tblblogentries.id, tblblogentries.title, count(tblblogcomments.id) as commentcount
			from			tblblogentries, tblblogcomments
			where			tblblogcomments.entryidfk = tblblogentries.id
			and				tblblogentries.blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">

			group by		tblblogentries.id, tblblogentries.title
			<cfif dbtype is not "msaccess">
				order by	commentcount desc
			<cfelse>
				order by 	count(tblblogcomments.id) desc
			</cfif>
			<cfif dbtype is "mysql">limit 10</cfif>
		</cfquery>
		
		<!--- gets num of comments per category, top 10 --->
		<cfquery name="rc.topCommentedCategories" datasource="#dsn#">
			select
			<cfif dbtype is not "mysql">top 10</cfif>
							tblblogcategories.categoryid,
							tblblogcategories.categoryname,
							count(tblblogcomments.id) as commentcount
			from			tblblogcategories, tblblogcomments, tblblogentriescategories
			where			tblblogcomments.entryidfk = tblblogentriescategories.entryidfk
			and				tblblogentriescategories.categoryidfk = tblblogcategories.categoryid
			and				tblblogcategories.blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">
			group by		tblblogcategories.categoryid, tblblogcategories.categoryname
			<cfif dbtype is not "msaccess">
				order by	commentcount desc
			<cfelse>
				order by	count(tblblogcomments.id) desc
			</cfif>
			<cfif dbtype is "mysql">limit 10</cfif>
		</cfquery>
		
		<!--- RBB 1/20/2006: gets num of trackbacks per entry, top 10 --->
		<cfquery name="rc.topTrackbackedEntries" datasource="#dsn#">
			select
			<cfif dbtype is not "mysql">top 10</cfif>
			tblblogentries.id, tblblogentries.title, count(tblblogtrackbacks.id) as trackbackcount
			from			tblblogentries, tblblogtrackbacks
			where			tblblogtrackbacks.entryid = tblblogentries.id
			and				tblblogentries.blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">

			group by		tblblogentries.id, tblblogentries.title
			<cfif dbtype is not "msaccess">
				order by	trackbackcount desc
			<cfelse>
				order by 	count(tblblogtrackbacks.id) desc
			</cfif>
			<cfif dbtype is "mysql">limit 10</cfif>
		</cfquery>
		
		<cfquery name="rc.topSearchTerms" datasource="#dsn#">
			select
			<cfif dbtype is not "mysql">top 10</cfif>
						searchterm, count(searchterm) as total
			from		tblblogsearchstats
			where		blog = <cfqueryparam cfsqltype="cf_sql_varchar" value="#blog#">
			group by	searchterm
			<cfif dbtype is not "msaccess">
				order by	total desc
			<cfelse>
				order by	count(searchterm) desc
			</cfif>
			<cfif dbtype is "mysql">limit 10</cfif>
		</cfquery>
		
		<cfif rc.getTotalEntries.totalEntries>
			<cfset Context.setValue("dur",dateDiff("d",rc.getTotalEntries.firstEntry, now()))>
		</cfif>

		<cfset Context.setValue("title",getresource("stats"))>
		<!--- Set View --->
		<cfset Context.setView("vwStats")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspEntries" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var params = structNew()>
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehEntry = "ehAdmin.dspEntry">
		<cfset rc.xehDeleteEntries = "ehAdmin.doDeleteEntries">
		
		<!--- Set params --->
		<cfset params.mode = "short">
		<cfif len(trim(Context.getValue("keywords","")))>
			<cfset params.searchTerms = Context.getValue("keywords")>
			<cfset params.dontlogsearch = true>
		</cfif>
		<cfset Context.setValue("entries",application.blog.getEntries(params))>
		<cfset Context.setValue("title","Entries")>
		<cfset Context.setView("vwEntries")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspEntry" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<!--- In coldbox you can use the form, url scopes too. You are open
		to use whatever you want. However, the request collection provides
		a one central repository, that any template, module, include can
		get --->
		<cfset var rc = Context.getCollection()>
		<Cfset var entry = "">
		<cfset var message = "">
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSave = "ehAdmin.doSaveEntry">
		
		<cftry>
			<cfif Context.getValue("id") neq 0>
				<cfset entry = application.blog.getEntry(Context.getValue("id"))>
				<cfif len(entry.morebody)>
					<cfset entry.body = entry.body & "<more/>" & entry.morebody>
				</cfif>			
				<!--- Param Values --->
				<cfset Context.paramValue("title",entry.title)>
				<cfset Context.paramValue("body",entry.body)>
				<cfset Context.paramValue("alias",entry.alias)>	
				<cfset Context.paramValue("posted",entry.posted)>
				<cfset Context.paramValue("allowcomments",entry.allowcomments)>
				<cfset Context.paramValue("oldenclosure",entry.enclosure)>
				<cfset Context.paramValue("oldfilesize", entry.filesize)>
				<cfset Context.paramValue("oldmimetype", entry.mimetype)>
				<cfset Context.paramValue("released", entry.released)>
				
				<!--- handle case where form submitted, cant use cfparam --->
				<cfif not Context.valueExists("save")>
					<cfset rc.categories = structKeyList(entry.categories)>
				</cfif>

			<cfelse>
				<!--- New Entry --->
				<cfif not Context.valueExists("save") and not Context.valueExists("return") and not Context.valueExists("preview")>
					<cfset rc.categories = "">
				</cfif>
				<!--- Param Values --->
				<cfset Context.paramValue("body", "")>
				<cfset Context.paramValue("alias", "")>	
				<cfset Context.paramValue("posted", "#dateAdd("h", application.blog.getProperty("offset"), now())#")>
				<cfset Context.paramValue("allowcomments", "")>
				<cfset Context.paramValue("oldenclosure", "")>
				<cfset Context.paramValue("oldfilesize", "0")>
				<cfset Context.paramValue("oldmimetype", "")>
				<cfset Context.paramValue("released", "true")>
				<cfset Context.paramValue("title","")>
			</cfif>
			<cfcatch>
				<cfset getPlugin("logger").logError("Error in entries", cfcatch)>
				<cfset setNextEvent("ehAdmin.dspEntries")>
			</cfcatch>
		</cftry>
		
		<!---param Values --->
		<cfset Context.paramValue("cboRelatedEntries", "")>
		<cfset Context.paramValue("cboRelatedEntriesCats", "")>
		<cfset Context.paramValue("newcategory", "")>
		
		<!--- Check oldfilesize --->
		<cfif not isNumeric(rc.oldfilesize)>
			<cfset rc.oldfilesize = 0>
		</cfif>
		<!--- check date --->
		<cfif lsIsDate(rc.posted)>
			<cfset rc.posted = createODBCDateTime(rc.posted)>
			<cfset rc.posted = getPlugin("i18n").dateLocaleFormat(rc.posted,"short") & " " & getPlugin("i18n").timeLocaleFormat(rc.posted)>
		</cfif>
		<cfset Context.setValue("allCats",application.blog.getCategories())>
		<cfset Context.setValue("message",message)>
		<cfset Context.setValue("entry",entry)>
		<cfset Context.setView("vwEntry")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doSaveEntry" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var errors = arrayNew(1)>
		<cfset var entry = "">
		<cfset var destination = "">
		<cfset var origbody = "">
		<cfset var strMoreTag = "">
		<cfset var moreStart = "">
		<cfset var moreText = "">
		<cfset var rc = Context.getCollection()>
	
		<!--- Param Values --->
		<cfset Context.paramValue("cboRelatedEntries", "")>
		<cfset Context.paramValue("cboRelatedEntriesCats", "")>
		<cfset Context.paramValue("newcategory", "")>

		<!--- Check for cancel --->
		<cfif Context.valueExists("cancel")>
			<cfset setNextEvent("ehAdmin.dspEntries")>
		</cfif>
	
		<!--- check for delete enclosure --->
		<cfif Context.valueExists("delete_enclosure")>
			<cfif len(rc.oldenclosure) and fileExists(rc.oldenclosure)>
				<cffile action="delete" file="#rc.oldenclosure#">
			</cfif>
			<cfset rc.oldenclosure = "">
			<cfset rc.oldfilesize = "0">
			<cfset rc.oldmimetype = "">
			<!--- We need to set a msg to warn folks that they need to save the entry --->
			<cfif rc.id is not "new">
				<cfset message = getResource("enclosureentrywarning")>
			</cfif>
		</cfif>

		<!---
		Enclosure logic move out to always run. Thinking is that it needs to run on preview.
		--->
		<cfif Context.valueExists("enclosure") and len(trim(rc.enclosure))>
			<cfset destination = expandPath("../enclosures")>
			<!--- first off, potentially make the folder --->
			<cfif not directoryExists(destination)>
				<cfdirectory action="create" directory="#destination#">
			</cfif>

			<cffile action="upload" filefield="enclosure" destination="#destination#" nameconflict="makeunique">
			<cfif cffile.filewassaved>
				<cfset rc.oldenclosure = cffile.serverDirectory & "/" & cffile.serverFile>
				<cfset rc.oldfilesize = cffile.filesize>
				<cfset rc.oldmimetype = cffile.contenttype & "/" & cffile.contentsubtype>
			</cfif>
		</cfif>

		<!--- Save Entry --->
		<cfif Context.valueExists("save")>
			<cfif not len(trim(rc.title))>
				<cfset arrayAppend(errors, getResource("mustincludetitle"))>
			<cfelse>
				<cfset rc.title = trim(rc.title)>
			</cfif>
			<cfif not isDate(rc.posted)>
				<cfset arrayAppend(errors, getResource("invaliddate"))>
			</cfif>
			<cfif not len(trim(rc.body))>
				<cfset arrayAppend(errors, getResource("mustincludebody"))>
				<cfset origbody = "">
			<cfelse>
				<cfset rc.body = trim(rc.body)>
				<cfset origbody = rc.body>

				<!--- Handle potential <more/> --->
				<!--- fix by Andrew --->
				<cfset strMoreTag = "<more/>">
				<cfset moreStart = findNoCase(strMoreTag,rc.body)>
				<cfif moreStart gt 1>
					<cfset moreText = trim(mid(rc.body,(moreStart+len(strMoreTag)),len(rc.body)))>
					<cfset rc.body = trim(left(rc.body,moreStart-1))>
				<cfelseif moreStart is 1>
					<cfset arrayAppend(errors, getResource("mustincludebody"))>
				<cfelse>
					<cfset moreText = "">
				</cfif>
			</cfif>
			<!--- Categories --->
			<cfif (not Context.valueExists("categories") or rc.categories is 0) and not len(trim(rc.newCategory))>
				<cfset arrayAppend(errors, getResource("mustincludecategory"))>
			<cfelse>
				<cfset rc.newCategory = trim(htmlEditFormat(rc.newCategory))>
			</cfif>

			<cfif len(rc.alias)>
				<cfset rc.alias = trim(htmlEditFormat(rc.alias))>
			<cfelse>
				<!--- Auto create the alias --->
				<cfset rc.alias = application.blog.makeTitle(rc.title)>
			</cfif>

			<cfif not arrayLen(errors)>
				<!--- Before we save, modify the posted time by -1 * posted --->
				<cfset rc.posted = dateAdd("h", -1 * application.blog.getProperty("offset"), rc.posted)>
				<cfif Context.getValue("id") neq 0>
					<cfset application.blog.saveEntry(rc.id,rc.title,rc.body,moreText,rc.alias,rc.posted,rc.allowcomments, rc.oldenclosure, rc.oldfilesize, rc.oldmimetype,rc.released,rc.cboRelatedEntries)>
				<cfelse>
					<cfset rc.id = application.blog.addEntry(rc.title,rc.body,moreText,rc.alias,rc.posted,rc.allowcomments, rc.oldenclosure, rc.oldfilesize, rc.oldmimetype,rc.released,rc.cboRelatedEntries)>
				</cfif>
				<!--- remove all old cats that arent passed in --->
				<cfif rc.id is not "new">
					<cfset application.blog.removeCategories(rc.id)>
				</cfif>
				<!--- potentially add new cat --->
				<cfif len(trim(rc.newCategory))>
					<cfset Context.paramValue("categories", "")>
					<cfset rc.categories = listAppend(rc.categories,application.blog.addCategory(rc.newCategory, application.blog.makeTitle(rc.newCategory)))>
				</cfif>
				<cfset application.blog.assignCategories(rc.id,rc.categories)>
				<cfmodule template="../../tags/scopecache.cfm" scope="application" clearall="true">
				<cfset setNextEvent("ehAdmin.dspEntries")>
			<cfelse>
				<!--- restore body, since it loses more body --->
				<cfset rc.body = origbody>
			</cfif>
		</cfif>
		
		<!--- Run internal event to display entry --->
		<cfset dspEntry(Context)>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeleteEntries" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var u = "">
		<cfloop index="u" list="#Context.getValue("mark","")#">
			<cfset application.blog.deleteEntry(u)>
		</cfloop>
		<cfset setNextEvent("ehAdmin.dspEntries")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeleteTrackbacks" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var u = "">
		<cfloop index="u" list="#Context.getValue("mark","")#">
			<cfset application.blog.deleteTrackback(u)>
		</cfloop>
		<cfset setNextEvent("ehAdmin.dspTrackbacks")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspTrackbacks" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehTrackback = "ehAdmin.dspTrackback">
		<cfset rc.xehDeleteTrackbacks = "ehAdmin.doDeleteTrackbacks">
		
		<cfset Context.setValue("tbs", application.blog.getTrackbacks(sortdir="desc"))>
		<cfset Context.setValue("title","Trackbacks")>
		<cfset Context.setView("vwTrackbacks")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeleteCategories" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var u = "">
		<cfloop index="u" list="#Context.getValue("mark","")#">
			<cfset application.blog.deleteCategory(u)>
		</cfloop>
		<cfset setNextEvent("ehAdmin.dspCategories")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspCategories" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehCategory = "ehAdmin.dspCategory">
		<cfset rc.xehDeleteCategory = "ehAdmin.doDeleteCategories">
		
		<cfset Context.setValue("categories", application.blog.getCategories())>
		<cfset Context.setValue("title","Trackbacks")>
		<cfset Context.setView("vwCategories")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspCategory" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSaveCategory = "ehAdmin.doAddCategory">
		<cftry>
			<cfif Context.getValue("id",0) neq 0>
				<cfset Context.setValue("cat",application.blog.getCategory(Context.getValue("id")))>
				<cfset Context.setValue("name",Context.getValue("cat.categoryname"))>
				<cfset Context.setValue("alias",Context.getValue("cat.categoryalias"))>
			</cfif>
			<cfcatch>
				<cfset setNextEvent("ehAdmin.dspCategories")>
			</cfcatch>
		</cftry>

		<cfset Context.setValue("title","Category Editor")>
		<cfset Context.setView("vwCategory")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doAddCategory" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var errors = arrayNew(1)>

		<cfif Context.valueExists("cancel")>
			<cfset setNextEvent("ehAdmin.dspCategories")>
		</cfif>

		<cfif not len(trim(Context.getValue("name")))>
			<cfset arrayAppend(errors, "The name cannot be blank.")>
		</cfif>
		<cfif not len(trim(Context.getValue("alias")))>
			<cfset Context.setValue("alias",application.blog.makeTitle(Context.getValue("name")))>
		<cfelseif reFind("[^[:alnum:] -]", Context.getValue("alias"))>
			<cfset arrayAppend(errors, "Your alias may only contain letters, numbers, spaces, or hyphens.")>
		</cfif>
		<cfif not arrayLen(errors)>
			<cftry>
			<cfif Context.getValue("id") neq 0>
				<cfset application.blog.saveCategory(Context.getValue("id"), left(Context.getValue("name"),50), left(Context.getValue("alias"), 50))>
			<cfelse>
				<cfset application.blog.addCategory(left(Context.getValue("name"),50), left(Context.getValue("alias"),50))>
			</cfif>
			<cfcatch>
				<cfif findNoCase("already exists as a category", cfcatch.message)>
					<cfset arrayAppend(errors, "A category with this name already exists.")>
				<cfelse>
					<cfrethrow>
				</cfif>
			</cfcatch>
			</cftry>

			<cfif not arrayLen(errors)>
				<!--- clear the archive pod cache --->
				<cfmodule template="../../tags/scopecache.cfm" action="clear" scope="application" cachename="pod_archives" />
				<cfset setNextEvent("ehAdmin.dspCategories")>
			</cfif>
		</cfif>
		<cfset Context.setValue("errors",errors)>
		<cfset setNextEvent("ehAdmin.dspCategory","id=#Context.getValue("id")#")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspComments" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehComment = "ehAdmin.dspComment">
		<cfset rc.xehDeleteComment = "ehAdmin.doDeleteComments">
		
		<cfset Context.setValue("comments", application.blog.getComments(sortdir="desc"))>
		<cfset Context.setValue("title","Comments")>
		<cfset Context.setView("vwComments")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeleteComments" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var u = "">
		<cfloop index="u" list="#Context.getValue("mark","")#">
			<cfset application.blog.deleteComment(u)>
		</cfloop>
		<cfset setNextEvent("ehAdmin.dspComments")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspComment" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAddComment = "ehAdmin.doAddComment">
		
		<cftry>
			<cfset Context.setValue("comment", application.blog.getComment(Context.getValue("id")))>
			<cfif Context.getValue("comment.recordCount") is 0>
				<cfset setNextEvent("ehAdmin.dspComments")>
			</cfif>
			<cfcatch>
				<cfset setNextEvent("ehAdmin.dspComments")>
			</cfcatch>
		</cftry>
		<cfset Context.setValue("title","Comment Editor")>
		<cfset Context.setView("vwComment")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doAddComment" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var errors = arrayNew(1)>

		<cfif Context.valueExists("cancel")>
			<cfset setNextEvent("ehAdmin.dspComments")>
		</cfif>

		<cfif not len(trim(Context.getValue("name")))>
			<cfset arrayAppend(errors, "The name cannot be blank.")>
		</cfif>
		<cfif not len(trim(Context.getValue("email"))) or not isEmail(Context.getValue("email"))>
			<cfset arrayAppend(errors, "The email cannot be blank and must be a valid email address.")>
		</cfif>
		<cfif len(Context.getValue("website")) and not isURL(Context.getValue("website"))>
			<cfset arrayAppend(errors, "Website must be a valid URL.")>
		</cfif>
		<cfif not len(trim(Context.getValue("newcomment")))>
			<cfset arrayAppend(errors, "The comment cannot be blank.")>
		</cfif>
		<cfif not arrayLen(errors)>
			<cfset application.blog.saveComment(Context.getValue("id"), left(Context.getValue("name"),50), left(Context.getValue("email"),50), left(Context.getValue("website"),255), Context.getValue("newcomment"), Context.getValue("subscribe",false))>
			<cfset setNextEvent("ehAdmin.dspComments")>
		</cfif>
		<cfset Context.setValue("errors",errors)>
		<cfset setNextEvent("ehAdmin.dspComment","id=#Context.getValue("id")#")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspSubscribers" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDeleteSub = "ehAdmin.doDeleteSubscribers">
		<cfset Context.setValue("subscribers", application.blog.getSubscribers())>
		<cfset Context.setValue("title","Subscribers")>
		<cfset Context.setView("vwSubscribers")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeleteSubscribers" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var u = "">
		<cfloop index="u" list="#Context.getValue("MARK","")#">
			<cfset application.blog.removeSubscriber(u)>
		</cfloop>
		<cfset setNextEvent("ehAdmin.dspSubscribers")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspSettings" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var settings = application.blog.getProperties()>
		<cfset var validDBTypes = application.blog.getValidDBTypes()>
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSaveSettings = "ehAdmin.doSaveSettings">
		<cfloop item="setting" collection="#settings#">
			<cfset Context.paramValue("#setting#", settings[setting])>			
		</cfloop>
		<cfset Context.setValue("settings",settings)>
		<Cfset Context.setValue("validDBTypes",validDBTypes)>
		<cfset Context.setValue("title","Settings")>
		<cfset Context.setView("vwSettings")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doSaveSettings" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<cfset var errors = arrayNew(1)>
		<cfset var keylist = "">
		
		<cfif Context.valueExists("cancel")>
			<cfset setNextEvent("ehAdmin.dspHome")>
		</cfif>

		<cfif not len(trim(Context.getValue("blogtitle")))>
			<cfset arrayAppend(errors, "Your blog must have a title.")>
		</cfif>

		<cfif not len(trim(Context.getValue("blogurl")))>
			<cfset arrayAppend(errors, "Your blog url cannot be blank.")>
		<cfelseif right(Context.getValue("blogurl"), 9) is not "index.cfm">
			<cfset arrayAppend(errors, "The blogurl setting must end with index.cfm.")>
		</cfif>

		<cfif len(trim(Context.getValue("commentsfrom"))) and not isEmail(Context.getValue("commentsfrom"))>
			<cfset arrayAppend(errors, "The commentsfrom setting must be a valid email address.")>
		</cfif>

		<cfif len(trim(Context.getValue("maxentries"))) and not isNumeric(Context.getValue("maxentries"))>
			<cfset arrayAppend(errors, "Max entries must be numeric.")>
		</cfif>

		<cfif len(trim(Context.getValue("offset"))) and not isNumeric(Context.getValue("offset"))>
			<cfset arrayAppend(errors, "Offset must be numeric.")>
		</cfif>

		<cfset Context.setValue("pingurls",toList(Context.getValue("pingurls")))>

		<cfif not len(trim(Context.getValue("dsn")))>
			<cfset arrayAppend(errors, "Your blog must have a dsn.")>
		</cfif>

		<cfif not len(trim(Context.getValue("locale")))>
			<cfset arrayAppend(errors, "Your blog must have a locale.")>
		</cfif>

		<cfset Context.setValue("ipblocklist", toList(Context.getValue("ipblocklist")))>
		<cfset Context.setValue("trackbackspamlist", toList(Context.getValue("trackbackspamlist")))>

		<cfif not arrayLen(errors)>
			<!--- make a list of the keys we will send. --->
			<cfset keylist = "blogtitle,blogdescription,blogkeywords,blogurl,commentsfrom,maxentries,offset,pingurls,dsn,blogdbtype,locale,ipblocklist,allowtrackbacks,trackbackspamlist,mailserver,mailusername,mailpassword,users,usecaptcha">
			<cfloop index="key" list="#keylist#">
				<cfset application.blog.setProperty(key, trim(rc[key]))>
			</cfloop>
			<cfset getPlugin("messagebox").setMessage("info","Settings have been updated successfully.")>
			<cfset setNextEvent("ehAdmin.dspHome","reinit=1")>
		</cfif>
		<cfset Context.setView("vwSettings")>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>