<cfcomponent name="ehBlog" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->
	<cffunction name="onAppStart" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- *Edit this line if you are not using a default blog --->
		<cfset var blogname = getToken(application.applicationName,3,"_")>
		<cfset var lylaFile = "">
		<cfset var majorVersion = "">
		<cfset var minorVersion = "">
		<cfset var cfversion = "">

		<!--- load an init blog --->
		<cfset application.blog = createObject("component","#getSetting("AppMapping")#.org.camden.blog.blog").init(blogname)>
		<!--- Path may be different if admin. --->
		<cfif findNoCase("admin/", cgi.script_name)>
			<!---<cfset theFile = expandPath("../includes/main")> --->
			<cfset lylaFile = "../includes/captcha.xml">
		<cfelse>
			<!---<cfset theFile = expandPath("../includes/main")> --->
			<cfset lylaFile = "./includes/captcha.xml">
		</cfif>
		<!--- MODIFIED TO USE COLDBOX I18N --->
		<cfset getPlugin("i18n").setfwLocale(getSetting("DefaultLocale"))>

		<!--- Use Captcha? --->
		<cfset application.usecaptcha = application.blog.getProperty("usecaptcha")>
		<cfif application.usecaptcha>
			<cfset application.captcha = CreateObject("component","#getSetting("AppMapping")#.org.captcha.captchaService").init(configFile="#lylaFile#") />
			<cfset application.captcha.setup() />
		</cfif>

		<!--- clear cache --->
		<cfmodule template="../tags/scopecache.cfm" scope="application" clearall="true">

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
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		<!--- Encoding --->
		<cfset setEncoding("form","utf-8")>
		<cfset setEncoding("url","utf-8")>

		<!--- Moved here from layout --->
		<!--- Get Additional Title's To Display --->
		<cfset Event.setValue("additionalTitle","")>

		<cfif Event.getValue("mode","") is "cat">
			<cftry>
				<cfset cat = application.blog.getCategory(Event.getValue("catid"))>
				<cfset Event.setValue("additionalTitle",": #cat.categoryname#")>
				<cfcatch></cfcatch>
			</cftry>
		<cfelseif Event.getValue("mode","") is "entry">
			<cftry>
				<cfset entry = application.blog.getEntry(Event.getValue("entry"))>
				<cfset Event.setValue("additionalTitle",": #entry.title#")>
				<cfcatch></cfcatch>
			</cftry>
		</cfif>

		<!--- EXIT HANDLERS: --->
		<cfset rc.xehComments = "ehBlog.dspComments">
		<cfset rc.xehTrackbacks = "ehBlog.dspTrackbacks">

	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspBlog" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehTrackback = "ehBlog.dspTrackback">
		<cfset rc.xehPrint = "ehBlog.dspPrint">
		<cfset rc.xehSend = "ehBlog.dspSend">
		<cfset rc.xehRSS = "ehBlog.dspRss">
		<cfset rc.xehSubscribe = "ehBlog.doSubscribe">

		<!--- Handle URL variables to figure out how we will get betting stuff. --->
		<cfmodule template="../tags/getmode.cfm" r_params="params"/>

		<!--- only cache on home page --->
		<cfset Event.setValue("disabled",false)>
		<cfif Event.getValue("mode") is not "" or len(cgi.query_string) or not structIsEmpty(form)>
			<cfset Event.setValue("disabled",true)>
		</cfif>
		<!--- Try to get the articles. --->
		<cftry>
			<cfset Event.setValue("articles", application.blog.getEntries(params) )>
			<!--- if using alias, switch mode to entry --->
			<cfif Event.getValue("mode") is "alias">
				<cfset Event.setValue("mode","entry")>
				<cfset Event.setValue("entry", Event.getValue("articles.id"))>
			</cfif>
			<cfcatch>
				<cfset Event.setValue("articles", queryNew("id"))>
			</cfcatch>
		</cftry>

		<!--- Set the View To display --->
		<cfset Event.setView("vwIndex")>
		<!--- Cfdoc Check --->
		<cfset fnccfdocument()>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspRss" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var params = structNew()>
		<cfset var rc = Event.getCollection()>
		<cfset var additionalTitle = "">

		<cfif Event.valueExists("mode") and Event.getValue("mode") is "full">
			<cfset Event.setValue("mode","full")>
		<cfelse>
			<cfset Event.setValue("mode","short")>
		</cfif>

		<!--- only allow 1 or 2 --->
		<cfif Event.valueExists("version") and Event.getValue("version") is 1>
			<cfset Event.setValue("version",1)>
		<cfelse>
			<cfset Event.setValue("version",2)>
		</cfif>

		<cfif Event.valueExists("mode2")>
			<cfif Event.getValue("mode2") is "day" and Event.valueExists("day") and Event.valueExists("month") and Event.valueExists("year")>
				<cfset params.byDay = val(Event.getValue("day"))>
				<cfset params.byMonth = val(Event.getValue("month"))>
				<cfset params.byYear = val(Event.getValue("year"))>
			<cfelseif Event.getValue("mode2") is "month" and Event.valueExists("month") and Event.valueExists("year")>
				<cfset params.byMonth = val(Event.getValue("month"))>
				<cfset params.byYear = val(Event.getValue("year"))>
			<cfelseif Event.getValue("mode2") is "cat" and Event.valueExists("catid")>
				<cfset params.byCat = Event.getValue("catid")>
				<cftry>
					<cfset additionalTitle = " - " & application.blog.getCategory(Event.getValue("catid")).categoryname>
					<cfcatch></cfcatch>
				</cftry>
			<cfelseif Event.getValue("mode2") is "entry">
				<cfset params.byEntry = Event.getValue("entry")>
			</cfif>
		</cfif>
		<cfset Event.setValue("params",params)>
		<cfset Event.setView("vwRss",true)>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspTrackback" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var response = '<?xml version="1.0" encoding="utf-8"?><response><error>{code}</error>{message}</response>'>
		<cfset var message = '<message>{error}</message>'>
		<cfset var error = "">
		<cfset var id = "">
		<cfset var entry = "">
		<cfset var blogEntry = "">

		<!--- TBs allowed? --->
		<cfif not application.blog.getProperty("allowtrackbacks")><cfabort></cfif>

		<!--- Kill TB
		This link doesn't authenticate at all, but gives us one click clean up of TBs from email. --->
		<cfif Event.valueExists("kill") and len(trim(Event.getValue("kill")))>
			<cftry>
				<cfset application.blog.deleteTrackback(Event.getValue("kill"))>
				<cfset setNextEvent("ehBlog.dspBlog")>
				<cfcatch>
					<!--- silently fail --->
				</cfcatch>
			</cftry>
		</cfif>

		<cfif cgi.REQUEST_METHOD eq "POST">
			<!--- must have entry id --->
			<cfif not len(cgi.query_string)>
				<cfset error = "Could not find post - please check trackback URL">
			<cfelse>
				<cfset entry = cgi.query_string>
				<cftry>
					<cfset blogEntry = application.blog.getEntry(entry)>
					<!--- must have url --->
					<cfif structKeyExists(form, "url")>
						<cfset id = application.blog.addTrackBack(Event.getValue("title",""), Event.getValue("url",""), Event.getValue("blog_name",""), Event.getValue("excerpt",""), entry)>
						<cfif id is not "">
							<!--- Form a message about the TB --->
							<cfmodule template="../tags/trackbackemail.cfm" trackback="#id#" />
							<cfmodule template="../tags/scopecache.cfm" scope="application" clearall="true">
						</cfif>
					<cfelse>
						<cfset error = "URL not provided">
					</cfif>
					<cfcatch>
						<!--- person TBed a bad entry --->
						<cfset error = "Bad Entry">
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfset error = "TrackBack request not POSTed">
		</cfif>

		<cfif not len(error)>
			<cfset response = replace(response, "{code}", "0")>
			<cfset response = replace(response, "{message}", "")>
		<cfelse>
			<cfset response = replace(response, "{code}", "1")>
			<cfset message = replace(message, "{error}", error)>
			<cfset response = replace(response, "{message}", message)>
		</cfif>

		<!--- Place into Request Collection --->
		<cfset Event.setValue("response", response)>
		<!--- Set View --->
		<cfset Event.setView("vwTrackback")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doSubscribe" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfif Event.valueExists("subscriber_email") and len(trim(Event.getValue("subscriber_email"))) and isEmail(trim(Event.getValue("subscriber_email")))>
			<cfset application.blog.addSubscriber(trim(Event.getValue("subscriber_email")))>
			<!--- set Messagebox --->
			<cfset getPlugin("messagebox").setMessage("info","Thank you for subscribing to my blog")>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("warning","Please review your email entry. Invalid format found: #Event.getValue("subscriber_email")#")>
		</cfif>
		<!--- Set Next Event --->
		<cfset setNextEvent("ehBlog.dspBlog",Event.getValue("query_string",""))>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doUnsubscribe" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfif not Event.valueExists("email")>
			<cfset setNextEvent("ehBlog.dspBlog")>
		</cfif>

		<cfif Event.valueExists("commentID")>
			<!--- Attempt to unsub --->
			<cftry>
				<cfset Event.setValue("result", application.blog.unsubscribeThread(Event.getValue("commentID"), Event.getValue("email")) )>
				<cfcatch>
					<cfset Event.setValue("result",false)>
				</cfcatch>
			</cftry>
		<cfelseif Event.valueExists("token")>
			<!--- Attempt to unsub --->
			<cftry>
				<cfset Event.setValue("result", application.blog.removeSubscriber(Event.getValue("email"), Event.getValue("token")) )>
				<cfcatch>
					<cfset Event.setValue("result",false)>
				</cfcatch>
			</cftry>
		</cfif>
		<cfset Event.setValue("additionalTitle",getResource("unsubscribe"))>
		<!--- Set View --->
		<cfset Event.setView("vwUnsubscribe")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspComments" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var closeme = false>
		<cfset var rc = Event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAddComment = "ehBlog.doAddComment">

		<!--- Get Cookie Values --->
		<cfif not Event.valueExists("addcomment")>
			<cfif isDefined("cookie.blog_name")>
				<cfset Event.setValue("name",cookie.blog_name)>
				<cfset Event.setValue("rememberMe", true)>
			</cfif>
			<cfif isDefined("cookie.blog_email")>
				<cfset Event.setValue("email", cookie.blog_email)>
				<cfset Event.setValue("rememberMe", true)>
			</cfif>
			<!--- RBB 11/02/2005: Added new website check --->
			<cfif isDefined("cookie.blog_website")>
				<cfset Event.setValue("website",cookie.blog_website)>
				<cfset Event.setValue("rememberMe", true)>
			</cfif>
		</cfif>

		<cfif not Event.valueExists("id")>
			<cfset closeMe = true>
		<cfelse>
			<cftry>
				<cfset Event.setValue("entry",application.blog.getEntry(Event.getValue("id")) )>
				<cfset Event.setValue("comments",application.blog.getComments(Event.getValue("id")) )>
				<cfif Event.getValue("entry.allowcomments") is false>
					<cfset closeMe = true>
				</cfif>
				<cfcatch>
					<cfset closeMe = true>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif closeMe>
			<cfoutput>
				<script>
				window.close();
				</script>
			</cfoutput>
			<cfabort>
		</cfif>
		<cfset Event.setValue("additionalTitle",getResource("addcomments"))>
		<!--- Set View --->
		<cfset Event.setView("vwAddcomment")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doAddComment" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var errorStr = "">
		<cfset var entry = "">
		<cfset var email = "">
		<cfset var subject = "">
		<cfset var commentID = 0>

		<cfset Event.setValue("name",trim(Event.getValue("name")))>
		<cfset Event.setValue("email", trim(Event.getValue("email")))>
		<!--- RBB 11/02/2005: Added new website option --->
		<cfset Event.setValue("website",trim(Event.getValue("website")))>
		<cfset Event.setValue("newcomments", trim(Event.getValue("newcomments")))>

		<!--- error checks --->
		<cfif not len(Event.getValue("name"))>
			<cfset errorStr = errorStr & getResource("mustincludename") & "<br>">
		</cfif>
		<cfif not len(Event.getValue("email")) or not isEmail(Event.getValue("email"))>
			<cfset errorStr = errorStr & getResource("mustincludeemail") & "<br>">
		</cfif>
		<cfif len(Event.getValue("website")) and not isURL(Event.getValue("website"))>
			<cfset errorStr = errorStr & getResource("invalidurl") & "<br>">
		</cfif>
		<cfif not len(Event.getValue("newcomments"))>
			<cfset errorStr = errorStr & getResource("mustincludecomments") & "<br>">
		</cfif>

		<!--- captcha validation --->
		<cfif application.useCaptcha>
			<cfif not len(Event.getValue("captchaText"))>
			   <cfset errorStr = errorStr & "Please enter the Captcha text.<br>">
			<cfelseif NOT application.captcha.validateCaptcha(Event.getValue("captchaHash"),Event.getValue("captchaText"))>
			   <cfset errorStr = errorStr & "The captcha text you have entered is incorrect.<br>">
			</cfif>
		</cfif>
		<!--- No error, then add --->
		<cfif not len(errorStr)>
			<!--- Get Entry --->
			<cfset entry = application.blog.getEntry(Event.getValue("id")) >
		    <!--- RBB 11/02/2005: added website to commentID --->
		    <cftry>
				<cfset commentID = application.blog.addComment(Event.getValue("id"),left(Event.getValue("name"),50), left(Event.getValue("email"),50), left(form.website,255), Event.getValue("newcomments"), Event.getValue("subscribe",false))>
				<!--- Form a message about the comment --->
				<cfset subject = getResource("commentaddedtoblog") & ": " & application.blog.getProperty("blogTitle") & " / " & getResource("entry") & ": " & entry.title>
				<cfsavecontent variable="email">
				<cfoutput>
		#getResource("commentaddedtoblogentry")#:	#entry.title#
		#getResource("commentadded")#: 			#getPlugin("i18n").dateLocaleFormat(now())# / #getPlugin("i18n").timeLocaleFormat(now())#
		#getResource("commentmadeby")#:	 		#Event.getValue("name")# (#form.website#)
		URL: #application.blog.makeLink(Event.getValue("id"))#

		#Event.getValue("newcomments")#

		------------------------------------------------------------
		#getResource("unsubscribe")#: %unsubscribe%
		This blog powered by BlogCFC #application.blog.getVersion()#
		Created by Raymond Camden (ray@camdenfamily.com)
				</cfoutput>
				</cfsavecontent>

				<cfset application.blog.notifyEntry(entry.id, trim(email), subject, Event.getValue("email"))>
				<cfcatch>
					<cfif cfcatch.message is not "Comment blocked for spam.">
						<cfrethrow>
					</cfif>
				</cfcatch>

			</cftry>

			<cfmodule template="../tags/scopecache.cfm" scope="application" clearall="true">

			<!--- clear form data --->
			<cfif Event.getValue("rememberMe",false)>
				<cfcookie name="blog_name" value="#trim(htmlEditFormat(Event.getValue("name")))#" expires="never">
				<cfcookie name="blog_email" value="#trim(htmlEditFormat(Event.getValue("email")))#" expires="never">
				<!--- RBB 11/02/2005: Added new website cookie --->
				<cfcookie name="blog_website" value="#trim(htmlEditFormat(Event.getValue("website")))#" expires="never">
			<cfelse>
				<cfcookie name="blog_name" expires="now">
				<cfcookie name="blog_email" expires="now">
			</cfif>
			<!--- reload page and close this up --->
			<cfoutput>
			<script>
			window.opener.location.reload();
			window.close();
			</script>
			</cfoutput>
			<cfabort>
		</cfif>
		<!--- Set the error message --->
		<cfset getPlugin("messagebox").setMessage("error",errorStr)>
		<!--- Go to display --->
		<cfset dspComments(Event)>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeleteComment" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset application.blog.deleteComment(Event.getValue("delete"))>
		<cfset setNextEvent("ehBlog.dspComments")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspTrackbacks" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var params = Structnew()>
		<cfset var rc = Event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAddTrackback ="ehBlog.doAddTrackback">
		<cfif not Event.valueExists("id") or not application.blog.getProperty("allowtrackbacks")>
			<cfabort>
		</cfif>
		<cfif Event.valueExists("delete") and isUserInRole("admin")>
			<cfset application.blog.deleteTrackback(Event.getValue("delete"))>
		</cfif>

		<cfset params.byEntry = Event.getValue("id")>
		<cfset Event.setValue("article",application.blog.getEntries(params))>
		<cfset Event.setValue("additionalTitle","Trackbacks for #Event.getValue("article").title#")>
		<!--- Set View --->
		<cfset Event.setView("vwTrackbacks")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doAddTrackback" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var errorStr = "">
		<cfset var id = "">

		<cfif not len(trim(Event.getValue("blog_name")))>
			<cfset errorStr = errorStr & getResource("mustincludeblogname") & "<br>">
		</cfif>

		<cfif not len(trim(Event.getValue("title")))>
			<cfset errorStr = errorStr & getResource("mustincludeblogtitle") & "<br>">
		</cfif>

		<cfif not len(trim(Event.getValue("excerpt")))>
			<cfset errorStr = errorStr & getResource("mustincludeblogexcerpt") & "<br>">
		</cfif>

		<cfif not len(trim(Event.getValue("url"))) or not isURL(Event.getValue("url"))>
			<cfset errorStr = errorStr & getResource("mustincludeblogentryurl") & "<br>">
		</cfif>

		<cfif not len(errorStr)>
			<cfset id = application.blog.addTrackBack(Event.getValue("title"), Event.getValue("url"), Event.getValue("blog_name"), Event.getValue("excerpt"), Event.getValue("id"))>
			<cfif id is not "">
				<!--- Form a message about the TB --->
				<cfmodule template="../tags/trackbackemail.cfm" trackback="#id#" />
				<cfmodule template="../tags/scopecache.cfm" scope="application" clearall="true">
			</cfif>
			<!--- reload page and close this up --->
			<cfoutput>
			<script>
			window.opener.location.reload();
			window.close();
			</script>
			</cfoutput>
			<cfabort>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("error",errorStr)>
		</cfif>
		<!--- Set NextEvent --->
		<cfset setNextEvent("ehBlog.dspTrackbacks","id=#Event.getValue("id")#")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeleteTrackback" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfif Event.valueExists("delete") and UserInRole("admin")>
			<cfset application.blog.deleteTrackback(Event.getValue("delete"))>
		</cfif>
		<!--- Set NextEvent --->
		<cfset setNextEvent("ehBlog.dspTrackbacks","id=#Event.getValue("id")#")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspPrint" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfif not Event.valueExists("id")>
			<cfset setNextEvent("ehBlog.dspBlog")>
		</cfif>

		<cftry>
			<cfset Event.setValue("entry", application.blog.getEntry(Event.getValue("id")))>
			<cfcatch>
				<cfset setNextEvent("ehBlog.dspBlog")>
			</cfcatch>
		</cftry>
		<!--- Set View --->
		<cfset Event.setView("vwPrint")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspSend" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehTrackback = "ehBlog.dspTrackback">
		<cfset rc.xehPrint = "ehBlog.dspPrint">
		<cfset rc.xehSend = "ehBlog.dspSend">
		<cfset rc.xehRSS = "ehBlog.dspRss">
		<cfset rc.xehSubscribe = "ehBlog.doSubscribe">
		<cfset rc.xehSendEntry = "ehBlog.doSend">

		<cfif not Event.valueExists("id")>
			<cfset setNextEvent("ehBlog.dspHome")>
		<cfelse>
			<cftry>
				<cfset Event.setValue("entry",application.blog.getEntry(Event.getValue("id")))>
				<cfcatch>
					<cfset setNextEvent("ehBlog.dspHome")>
				</cfcatch>
			</cftry>
		</cfif>
		<cfset Event.setValue("showForm", true)>
		<cfset Event.setValue("additionalTitle",getResource("send"))>
		<!--- Set View --->
		<cfset Event.setView("vwSend")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doSend" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var errorStr = "">
		<cfset var entry = application.blog.getEntry(Event.getValue("id"))>

		<cfif not len(trim(Event.getValue("email",""))) or not isEmail(Event.getValue("email",""))>
			<cfset errorStr = errorStr & getResource("mustincludeemail") & "<br />">
		</cfif>
		<cfif not len(trim(Event.getValue("remail",""))) or not isEmail(Event.getValue("remail",""))>
			<cfset errorStr = errorStr & getResource("mustincludereceiveremail") & "<br />">
		</cfif>

		<cfif not len(errorStr)>
			<cfmail to="#Event.getValue("remail")#" from="#Event.getValue("email")#" cc="#application.blog.getProperty("owneremail")#"
					subject="#getResource("blogentryfrom")#: #application.blog.getProperty("blogtitle")#"
					type="html">
				<p>
				The following blog entry was sent to you from: <b>#Event.getValue("email")#</b><br />
				It came from the blog: <b>#application.blog.getProperty("blogtitle")#</b><br />
				The entry is titled: <b>#entry.title#</b><br />
				The entry can be found here: <b><a href="#application.blog.makeLink(entry.id)#">#application.blog.makeLink(entry.id)#</a></b>
				</p>

				<cfif len(Event.getValue("notes"))>
				<p>
				The following notes were included:<br />
				<b>#Event.getValue("notes")#</b>
				</p>
				<p>
				<hr>
				</p>
				</cfif>
				#application.blog.renderEntry(entry.body)#
				<cfif len(entry.morebody)>#application.blog.renderEntry(entry.morebody)#</cfif>
			</cfmail>
			<cfset Event.setValue("showForm", false)>
			<cfset getPlugin("messagebox").setMessage("info",getResource("entrysent"))>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("error",errorStr)>
		</cfif>
		<!--- Display Send --->
		<cfset setNextEvent("ehBlog.dspSend","id=#Event.getValue('id')#")>
	</cffunction>
	<!--- ************************************************************* --->



	<!--- ************************************************************* --->
	<!--- Private Functions --->
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="fnccfdocument" access="private" returntype="void" hint="Check for cfdoctype and change layout">
		<cfscript>
		var Event = controller.getRequestService().getContext();
		if ( Event.getValue("cfdoctype",0) neq 0 )
			Event.setLayout("Layout.Cfdoc");
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>