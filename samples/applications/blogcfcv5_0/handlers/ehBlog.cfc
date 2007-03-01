<cfcomponent name="ehBlog" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->
	<cffunction name="onAppStart" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
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
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- Encoding --->
		<cfset setEncoding("form","utf-8")>
		<cfset setEncoding("url","utf-8")>

		<!--- Moved here from layout --->
		<!--- Get Additional Title's To Display --->
		<cfset Context.setValue("additionalTitle","")>

		<cfif Context.getValue("mode","") is "cat">
			<cftry>
				<cfset cat = application.blog.getCategory(Context.getValue("catid"))>
				<cfset Context.setValue("additionalTitle",": #cat.categoryname#")>
				<cfcatch></cfcatch>
			</cftry>
		<cfelseif Context.getValue("mode","") is "entry">
			<cftry>
				<cfset entry = application.blog.getEntry(Context.getValue("entry"))>
				<cfset Context.setValue("additionalTitle",": #entry.title#")>
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
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehTrackback = "ehBlog.dspTrackback">
		<cfset rc.xehPrint = "ehBlog.dspPrint">
		<cfset rc.xehSend = "ehBlog.dspSend">
		<cfset rc.xehRSS = "ehBlog.dspRss">
		<cfset rc.xehSubscribe = "ehBlog.doSubscribe">

		<!--- Handle URL variables to figure out how we will get betting stuff. --->
		<cfmodule template="../tags/getmode.cfm" r_params="params"/>

		<!--- only cache on home page --->
		<cfset Context.setValue("disabled",false)>
		<cfif Context.getValue("mode") is not "" or len(cgi.query_string) or not structIsEmpty(form)>
			<cfset Context.setValue("disabled",true)>
		</cfif>
		<!--- Try to get the articles. --->
		<cftry>
			<cfset Context.setValue("articles", application.blog.getEntries(params) )>
			<!--- if using alias, switch mode to entry --->
			<cfif Context.getValue("mode") is "alias">
				<cfset Context.setValue("mode","entry")>
				<cfset Context.setValue("entry", Context.getValue("articles.id"))>
			</cfif>
			<cfcatch>
				<cfset Context.setValue("articles", queryNew("id"))>
			</cfcatch>
		</cftry>

		<!--- Set the View To display --->
		<cfset Context.setView("vwIndex")>
		<!--- Cfdoc Check --->
		<cfset fnccfdocument()>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspRss" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var params = structNew()>
		<cfset var rc = Context.getCollection()>
		<cfset var additionalTitle = "">

		<cfif Context.valueExists("mode") and Context.getValue("mode") is "full">
			<cfset Context.setValue("mode","full")>
		<cfelse>
			<cfset Context.setValue("mode","short")>
		</cfif>

		<!--- only allow 1 or 2 --->
		<cfif Context.valueExists("version") and Context.getValue("version") is 1>
			<cfset Context.setValue("version",1)>
		<cfelse>
			<cfset Context.setValue("version",2)>
		</cfif>

		<cfif Context.valueExists("mode2")>
			<cfif Context.getValue("mode2") is "day" and Context.valueExists("day") and Context.valueExists("month") and Context.valueExists("year")>
				<cfset params.byDay = val(Context.getValue("day"))>
				<cfset params.byMonth = val(Context.getValue("month"))>
				<cfset params.byYear = val(Context.getValue("year"))>
			<cfelseif Context.getValue("mode2") is "month" and Context.valueExists("month") and Context.valueExists("year")>
				<cfset params.byMonth = val(Context.getValue("month"))>
				<cfset params.byYear = val(Context.getValue("year"))>
			<cfelseif Context.getValue("mode2") is "cat" and Context.valueExists("catid")>
				<cfset params.byCat = Context.getValue("catid")>
				<cftry>
					<cfset additionalTitle = " - " & application.blog.getCategory(Context.getValue("catid")).categoryname>
					<cfcatch></cfcatch>
				</cftry>
			<cfelseif Context.getValue("mode2") is "entry">
				<cfset params.byEntry = Context.getValue("entry")>
			</cfif>
		</cfif>
		<cfset Context.setValue("params",params)>
		<cfset Context.setView("vwRss",true)>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspTrackback" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
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
		<cfif Context.valueExists("kill") and len(trim(Context.getValue("kill")))>
			<cftry>
				<cfset application.blog.deleteTrackback(Context.getValue("kill"))>
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
						<cfset id = application.blog.addTrackBack(Context.getValue("title",""), Context.getValue("url",""), Context.getValue("blog_name",""), Context.getValue("excerpt",""), entry)>
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
		<cfset Context.setValue("response", response)>
		<!--- Set View --->
		<cfset Context.setView("vwTrackback")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doSubscribe" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfif Context.valueExists("subscriber_email") and len(trim(Context.getValue("subscriber_email"))) and isEmail(trim(Context.getValue("subscriber_email")))>
			<cfset application.blog.addSubscriber(trim(Context.getValue("subscriber_email")))>
			<!--- set Messagebox --->
			<cfset getPlugin("messagebox").setMessage("info","Thank you for subscribing to my blog")>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("warning","Please review your email entry. Invalid format found: #Context.getValue("subscriber_email")#")>
		</cfif>
		<!--- Set Next Event --->
		<cfset setNextEvent("ehBlog.dspBlog",Context.getValue("query_string",""))>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doUnsubscribe" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfif not Context.valueExists("email")>
			<cfset setNextEvent("ehBlog.dspBlog")>
		</cfif>

		<cfif Context.valueExists("commentID")>
			<!--- Attempt to unsub --->
			<cftry>
				<cfset Context.setValue("result", application.blog.unsubscribeThread(Context.getValue("commentID"), Context.getValue("email")) )>
				<cfcatch>
					<cfset Context.setValue("result",false)>
				</cfcatch>
			</cftry>
		<cfelseif Context.valueExists("token")>
			<!--- Attempt to unsub --->
			<cftry>
				<cfset Context.setValue("result", application.blog.removeSubscriber(Context.getValue("email"), Context.getValue("token")) )>
				<cfcatch>
					<cfset Context.setValue("result",false)>
				</cfcatch>
			</cftry>
		</cfif>
		<cfset Context.setValue("additionalTitle",getResource("unsubscribe"))>
		<!--- Set View --->
		<cfset Context.setView("vwUnsubscribe")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspComments" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var closeme = false>
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAddComment = "ehBlog.doAddComment">

		<!--- Get Cookie Values --->
		<cfif not Context.valueExists("addcomment")>
			<cfif isDefined("cookie.blog_name")>
				<cfset Context.setValue("name",cookie.blog_name)>
				<cfset Context.setValue("rememberMe", true)>
			</cfif>
			<cfif isDefined("cookie.blog_email")>
				<cfset Context.setValue("email", cookie.blog_email)>
				<cfset Context.setValue("rememberMe", true)>
			</cfif>
			<!--- RBB 11/02/2005: Added new website check --->
			<cfif isDefined("cookie.blog_website")>
				<cfset Context.setValue("website",cookie.blog_website)>
				<cfset Context.setValue("rememberMe", true)>
			</cfif>
		</cfif>

		<cfif not Context.valueExists("id")>
			<cfset closeMe = true>
		<cfelse>
			<cftry>
				<cfset Context.setValue("entry",application.blog.getEntry(Context.getValue("id")) )>
				<cfset Context.setValue("comments",application.blog.getComments(Context.getValue("id")) )>
				<cfif Context.getValue("entry.allowcomments") is false>
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
		<cfset Context.setValue("additionalTitle",getResource("addcomments"))>
		<!--- Set View --->
		<cfset Context.setView("vwAddcomment")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doAddComment" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var errorStr = "">
		<cfset var entry = "">
		<cfset var email = "">
		<cfset var subject = "">
		<cfset var commentID = 0>

		<cfset Context.setValue("name",trim(Context.getValue("name")))>
		<cfset Context.setValue("email", trim(Context.getValue("email")))>
		<!--- RBB 11/02/2005: Added new website option --->
		<cfset Context.setValue("website",trim(Context.getValue("website")))>
		<cfset Context.setValue("newcomments", trim(Context.getValue("newcomments")))>

		<!--- error checks --->
		<cfif not len(Context.getValue("name"))>
			<cfset errorStr = errorStr & getResource("mustincludename") & "<br>">
		</cfif>
		<cfif not len(Context.getValue("email")) or not isEmail(Context.getValue("email"))>
			<cfset errorStr = errorStr & getResource("mustincludeemail") & "<br>">
		</cfif>
		<cfif len(Context.getValue("website")) and not isURL(Context.getValue("website"))>
			<cfset errorStr = errorStr & getResource("invalidurl") & "<br>">
		</cfif>
		<cfif not len(Context.getValue("newcomments"))>
			<cfset errorStr = errorStr & getResource("mustincludecomments") & "<br>">
		</cfif>

		<!--- captcha validation --->
		<cfif application.useCaptcha>
			<cfif not len(Context.getValue("captchaText"))>
			   <cfset errorStr = errorStr & "Please enter the Captcha text.<br>">
			<cfelseif NOT application.captcha.validateCaptcha(Context.getValue("captchaHash"),Context.getValue("captchaText"))>
			   <cfset errorStr = errorStr & "The captcha text you have entered is incorrect.<br>">
			</cfif>
		</cfif>
		<!--- No error, then add --->
		<cfif not len(errorStr)>
			<!--- Get Entry --->
			<cfset entry = application.blog.getEntry(Context.getValue("id")) >
		    <!--- RBB 11/02/2005: added website to commentID --->
		    <cftry>
				<cfset commentID = application.blog.addComment(Context.getValue("id"),left(Context.getValue("name"),50), left(Context.getValue("email"),50), left(form.website,255), Context.getValue("newcomments"), Context.getValue("subscribe",false))>
				<!--- Form a message about the comment --->
				<cfset subject = getResource("commentaddedtoblog") & ": " & application.blog.getProperty("blogTitle") & " / " & getResource("entry") & ": " & entry.title>
				<cfsavecontent variable="email">
				<cfoutput>
		#getResource("commentaddedtoblogentry")#:	#entry.title#
		#getResource("commentadded")#: 			#getPlugin("i18n").dateLocaleFormat(now())# / #getPlugin("i18n").timeLocaleFormat(now())#
		#getResource("commentmadeby")#:	 		#Context.getValue("name")# (#form.website#)
		URL: #application.blog.makeLink(Context.getValue("id"))#

		#Context.getValue("newcomments")#

		------------------------------------------------------------
		#getResource("unsubscribe")#: %unsubscribe%
		This blog powered by BlogCFC #application.blog.getVersion()#
		Created by Raymond Camden (ray@camdenfamily.com)
				</cfoutput>
				</cfsavecontent>

				<cfset application.blog.notifyEntry(entry.id, trim(email), subject, Context.getValue("email"))>
				<cfcatch>
					<cfif cfcatch.message is not "Comment blocked for spam.">
						<cfrethrow>
					</cfif>
				</cfcatch>

			</cftry>

			<cfmodule template="../tags/scopecache.cfm" scope="application" clearall="true">

			<!--- clear form data --->
			<cfif Context.getValue("rememberMe",false)>
				<cfcookie name="blog_name" value="#trim(htmlEditFormat(Context.getValue("name")))#" expires="never">
				<cfcookie name="blog_email" value="#trim(htmlEditFormat(Context.getValue("email")))#" expires="never">
				<!--- RBB 11/02/2005: Added new website cookie --->
				<cfcookie name="blog_website" value="#trim(htmlEditFormat(Context.getValue("website")))#" expires="never">
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
		<cfset dspComments(Context)>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeleteComment" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset application.blog.deleteComment(Context.getValue("delete"))>
		<cfset setNextEvent("ehBlog.dspComments")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspTrackbacks" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var params = Structnew()>
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAddTrackback ="ehBlog.doAddTrackback">
		<cfif not Context.valueExists("id") or not application.blog.getProperty("allowtrackbacks")>
			<cfabort>
		</cfif>
		<cfif Context.valueExists("delete") and isUserInRole("admin")>
			<cfset application.blog.deleteTrackback(Context.getValue("delete"))>
		</cfif>

		<cfset params.byEntry = Context.getValue("id")>
		<cfset Context.setValue("article",application.blog.getEntries(params))>
		<cfset Context.setValue("additionalTitle","Trackbacks for #Context.getValue("article").title#")>
		<!--- Set View --->
		<cfset Context.setView("vwTrackbacks")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doAddTrackback" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var errorStr = "">
		<cfset var id = "">

		<cfif not len(trim(Context.getValue("blog_name")))>
			<cfset errorStr = errorStr & getResource("mustincludeblogname") & "<br>">
		</cfif>

		<cfif not len(trim(Context.getValue("title")))>
			<cfset errorStr = errorStr & getResource("mustincludeblogtitle") & "<br>">
		</cfif>

		<cfif not len(trim(Context.getValue("excerpt")))>
			<cfset errorStr = errorStr & getResource("mustincludeblogexcerpt") & "<br>">
		</cfif>

		<cfif not len(trim(Context.getValue("url"))) or not isURL(Context.getValue("url"))>
			<cfset errorStr = errorStr & getResource("mustincludeblogentryurl") & "<br>">
		</cfif>

		<cfif not len(errorStr)>
			<cfset id = application.blog.addTrackBack(Context.getValue("title"), Context.getValue("url"), Context.getValue("blog_name"), Context.getValue("excerpt"), Context.getValue("id"))>
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
		<cfset setNextEvent("ehBlog.dspTrackbacks","id=#Context.getValue("id")#")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeleteTrackback" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfif Context.valueExists("delete") and UserInRole("admin")>
			<cfset application.blog.deleteTrackback(Context.getValue("delete"))>
		</cfif>
		<!--- Set NextEvent --->
		<cfset setNextEvent("ehBlog.dspTrackbacks","id=#Context.getValue("id")#")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspPrint" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfif not Context.valueExists("id")>
			<cfset setNextEvent("ehBlog.dspBlog")>
		</cfif>

		<cftry>
			<cfset Context.setValue("entry", application.blog.getEntry(Context.getValue("id")))>
			<cfcatch>
				<cfset setNextEvent("ehBlog.dspBlog")>
			</cfcatch>
		</cftry>
		<!--- Set View --->
		<cfset Context.setView("vwPrint")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspSend" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehTrackback = "ehBlog.dspTrackback">
		<cfset rc.xehPrint = "ehBlog.dspPrint">
		<cfset rc.xehSend = "ehBlog.dspSend">
		<cfset rc.xehRSS = "ehBlog.dspRss">
		<cfset rc.xehSubscribe = "ehBlog.doSubscribe">
		<cfset rc.xehSendEntry = "ehBlog.doSend">

		<cfif not Context.valueExists("id")>
			<cfset setNextEvent("ehBlog.dspHome")>
		<cfelse>
			<cftry>
				<cfset Context.setValue("entry",application.blog.getEntry(Context.getValue("id")))>
				<cfcatch>
					<cfset setNextEvent("ehBlog.dspHome")>
				</cfcatch>
			</cftry>
		</cfif>
		<cfset Context.setValue("showForm", true)>
		<cfset Context.setValue("additionalTitle",getResource("send"))>
		<!--- Set View --->
		<cfset Context.setView("vwSend")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doSend" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var errorStr = "">
		<cfset var entry = application.blog.getEntry(Context.getValue("id"))>

		<cfif not len(trim(Context.getValue("email",""))) or not isEmail(Context.getValue("email",""))>
			<cfset errorStr = errorStr & getResource("mustincludeemail") & "<br />">
		</cfif>
		<cfif not len(trim(Context.getValue("remail",""))) or not isEmail(Context.getValue("remail",""))>
			<cfset errorStr = errorStr & getResource("mustincludereceiveremail") & "<br />">
		</cfif>

		<cfif not len(errorStr)>
			<cfmail to="#Context.getValue("remail")#" from="#Context.getValue("email")#" cc="#application.blog.getProperty("owneremail")#"
					subject="#getResource("blogentryfrom")#: #application.blog.getProperty("blogtitle")#"
					type="html">
				<p>
				The following blog entry was sent to you from: <b>#Context.getValue("email")#</b><br />
				It came from the blog: <b>#application.blog.getProperty("blogtitle")#</b><br />
				The entry is titled: <b>#entry.title#</b><br />
				The entry can be found here: <b><a href="#application.blog.makeLink(entry.id)#">#application.blog.makeLink(entry.id)#</a></b>
				</p>

				<cfif len(Context.getValue("notes"))>
				<p>
				The following notes were included:<br />
				<b>#Context.getValue("notes")#</b>
				</p>
				<p>
				<hr>
				</p>
				</cfif>
				#application.blog.renderEntry(entry.body)#
				<cfif len(entry.morebody)>#application.blog.renderEntry(entry.morebody)#</cfif>
			</cfmail>
			<cfset Context.setValue("showForm", false)>
			<cfset getPlugin("messagebox").setMessage("info",getResource("entrysent"))>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("error",errorStr)>
		</cfif>
		<!--- Display Send --->
		<cfset setNextEvent("ehBlog.dspSend","id=#Context.getValue('id')#")>
	</cffunction>
	<!--- ************************************************************* --->



	<!--- ************************************************************* --->
	<!--- Private Functions --->
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="fnccfdocument" access="private" returntype="void" hint="Check for cfdoctype and change layout">
		<cfscript>
		var Context = controller.getRequestService().getContext();
		if ( Context.getValue("cfdoctype",0) neq 0 )
			Context.setLayout("Layout.Cfdoc");
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>