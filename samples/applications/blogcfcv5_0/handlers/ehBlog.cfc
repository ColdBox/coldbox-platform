<cfcomponent name="ehBlog" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->
	<cffunction name="onAppStart" access="public" returntype="void" output="false">
		<!--- *Edit this line if you are not using a default blog --->
		<cfset var blogname = getToken(application.applicationName,3,"_")>
		<cfset var lylaFile = "">
		<cfset var majorVersion = "">
		<cfset var minorVersion = "">
		<cfset var cfversion = "">
		
		<!--- load an init blog --->
		<cfset application.blog = createObject("component","org.camden.blog.blog").init(blogname)>
		<!--- Path may be different if admin. --->
		<cfif findNoCase("admin/", cgi.script_name)>
			<!---<cfset theFile = expandPath("../includes/main")> --->
			<cfset lylaFile = "../includes/captcha.xml">
		<cfelse>
			<!---<cfset theFile = expandPath("../includes/main")> --->
			<cfset lylaFile = "./includes/captcha.xml">
		</cfif>
		<!--- MODIFIED TO USE COLDBOX I18N --->
		<cfset application.localeutils = getPlugin("i18n").setfwLocale(getSetting("DefaultLocale"))>

		<!--- Use Captcha? --->
		<cfset application.usecaptcha = application.blog.getProperty("usecaptcha")>
		<cfif application.usecaptcha>
			<cfset application.captcha = CreateObject("component","org.captcha.captchaService").init(configFile="#lylaFile#") />
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
		<!--- Encoding --->
		<cfset setEncoding("form","utf-8")>
		<cfset setEncoding("url","utf-8")>

		<!--- Moved here from layout --->
		<!--- Get Additional Title's To Display --->
		<cfset setValue("additionalTitle","")>
		
		<cfif getValue("mode","") is "cat">
			<cftry>
				<cfset cat = application.blog.getCategory(getValue("catid"))>
				<cfset setValue("additionalTitle",": #cat.categoryname#")>
				<cfcatch></cfcatch>
			</cftry>
		<cfelseif getValue("mode","") is "entry">
			<cftry>
				<cfset entry = application.blog.getEntry(getValue("entry"))>
				<cfset setValue("additionalTitle",": #entry.title#")>
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
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehTrackback = "ehBlog.dspTrackback">
		<cfset rc.xehPrint = "ehBlog.dspPrint">
		<cfset rc.xehSend = "ehBlog.dspSend">
		<cfset rc.xehRSS = "ehBlog.dspRss">
		<cfset rc.xehSubscribe = "ehBlog.doSubscribe">
		
		<!--- Handle URL variables to figure out how we will get betting stuff. --->
		<cfmodule template="../tags/getmode.cfm" r_params="params"/>

		<!--- only cache on home page --->
		<cfset setvalue("disabled",false)>
		<cfif getValue("mode") is not "" or len(cgi.query_string) or not structIsEmpty(form)>
			<cfset setvalue("disabled",true)>
		</cfif>
		<!--- Try to get the articles. --->
		<cftry>
			<cfset setValue("articles", application.blog.getEntries(params) )>
			<!--- if using alias, switch mode to entry --->
			<cfif getValue("mode") is "alias">
				<cfset setValue("mode","entry")>
				<cfset setValue("entry", getValue("articles.id"))>
			</cfif>
			<cfcatch>
				<cfset setValue("articles", queryNew("id"))>
			</cfcatch>
		</cftry>

		<!--- Set the View To display --->
		<cfset setView("vwIndex")>
		<!--- Cfdoc Check --->
		<cfset fnccfdocument()>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspRss" access="public" returntype="void" output="false">
		<cfset var params = structNew()>
		<cfset var additionalTitle = "">

		<cfif valueExists("mode") and getvalue("mode") is "full">
			<cfset setvalue("mode","full")>
		<cfelse>
			<cfset setvalue("mode","short")>
		</cfif>

		<!--- only allow 1 or 2 --->
		<cfif valueExists("version") and getValue("version") is 1>
			<cfset setvalue("version",1)>
		<cfelse>
			<cfset setvalue("version",2)>
		</cfif>

		<cfif valueExists("mode2")>
			<cfif getValue("mode2") is "day" and valueExists("day") and valueExists("month") and valueExists("year")>
				<cfset params.byDay = val(getvalue("day"))>
				<cfset params.byMonth = val(getvalue("month"))>
				<cfset params.byYear = val(getvalue("year"))>
			<cfelseif getValue("mode2") is "month" and valueExists("month") and valueExists("year")>
				<cfset params.byMonth = val(getvalue("month"))>
				<cfset params.byYear = val(getvalue("year"))>
			<cfelseif getValue("mode2") is "cat" and valueExists("catid")>
				<cfset params.byCat = getvalue("catid")>
				<cftry>
					<cfset additionalTitle = " - " & application.blog.getCategory(getvalue("catid")).categoryname>
					<cfcatch></cfcatch>
				</cftry>
			<cfelseif getValue("mode2") is "entry">
				<cfset params.byEntry = getValue("entry")>
			</cfif>
		</cfif>
		<cfset setvalue("params",params)>
		<cfset setView("vwRss",true)>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspTrackback" access="public" returntype="void" output="false">
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
		<cfif valueExists("kill") and len(trim(getValue("kill")))>
			<cftry>
				<cfset application.blog.deleteTrackback(getValue("kill"))>
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
						<cfset id = application.blog.addTrackBack(getvalue("title",""), getvalue("url",""), getvalue("blog_name",""), getvalue("excerpt",""), entry)>
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
		<cfset setValue("response", response)>
		<!--- Set View --->
		<cfset setView("vwTrackback")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doSubscribe" access="public" returntype="void" output="false">
		<cfif valueExists("subscriber_email") and len(trim(getValue("subscriber_email"))) and isEmail(trim(getValue("subscriber_email")))>
			<cfset application.blog.addSubscriber(trim(getValue("subscriber_email")))>
			<!--- set Messagebox --->
			<cfset getPlugin("messagebox").setMessage("info","Thank you for subscribing to my blog")>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("warning","Please review your email entry. Invalid format found: #getvalue("subscriber_email")#")>
		</cfif>
		<!--- Set Next Event --->
		<cfset setNextEvent("ehBlog.dspBlog",getValue("query_string",""))>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doUnsubscribe" access="public" returntype="void" output="false">
		<cfif not valueExists("email")>
			<cfset setNextEvent("ehBlog.dspBlog")>
		</cfif>

		<cfif valueExists("commentID")>
			<!--- Attempt to unsub --->
			<cftry>
				<cfset setValue("result", application.blog.unsubscribeThread(getValue("commentID"), getValue("email")) )>
				<cfcatch>
					<cfset setValue("result",false)>
				</cfcatch>
			</cftry>
		<cfelseif valueExists("token")>
			<!--- Attempt to unsub --->
			<cftry>
				<cfset setValue("result", application.blog.removeSubscriber(getValue("email"), getValue("token")) )>
				<cfcatch>
					<cfset setValue("result",false)>
				</cfcatch>
			</cftry>
		</cfif>
		<cfset setValue("additionalTitle",getResource("unsubscribe"))>
		<!--- Set View --->
		<cfset setView("vwUnsubscribe")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspComments" access="public" returntype="void" output="false">
		<cfset var closeme = false>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAddComment = "ehBlog.doAddComment">
		
		<!--- Get Cookie Values --->
		<cfif not valueExists("addcomment")>
			<cfif isDefined("cookie.blog_name")>
				<cfset setValue("name",cookie.blog_name)>
				<cfset setValue("rememberMe", true)>
			</cfif>
			<cfif isDefined("cookie.blog_email")>
				<cfset setValue("email", cookie.blog_email)>
				<cfset setValue("rememberMe", true)>
			</cfif>
			<!--- RBB 11/02/2005: Added new website check --->
			<cfif isDefined("cookie.blog_website")>
				<cfset setValue("website",cookie.blog_website)>
				<cfset setValue("rememberMe", true)>
			</cfif>
		</cfif>

		<cfif not valueExists("id")>
			<cfset closeMe = true>
		<cfelse>
			<cftry>
				<cfset setValue("entry",application.blog.getEntry(getValue("id")) )>
				<cfset setValue("comments",application.blog.getComments(getValue("id")) )>
				<cfif getValue("entry.allowcomments") is false>
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
		<cfset setvalue("additionalTitle",getResource("addcomments"))>
		<!--- Set View --->
		<cfset setView("vwAddcomment")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doAddComment" access="public" returntype="void" output="false">
		<cfset var errorStr = "">
		<cfset var entry = "">
		<cfset var email = "">
		<cfset var subject = "">
		<cfset var commentID = 0>
		
		<cfset setvalue("name",trim(getValue("name")))>
		<cfset setvalue("email", trim(getValue("email")))>
		<!--- RBB 11/02/2005: Added new website option --->
		<cfset setvalue("website",trim(getValue("website")))>
		<cfset setvalue("newcomments", trim(getValue("newcomments")))>
		
		<!--- error checks --->
		<cfif not len(getValue("name"))>
			<cfset errorStr = errorStr & getResource("mustincludename") & "<br>">
		</cfif>
		<cfif not len(getValue("email")) or not isEmail(getValue("email"))>
			<cfset errorStr = errorStr & getResource("mustincludeemail") & "<br>">
		</cfif>
		<cfif len(getValue("website")) and not isURL(getValue("website"))>
			<cfset errorStr = errorStr & getResource("invalidurl") & "<br>">
		</cfif>
		<cfif not len(getValue("newcomments"))>
			<cfset errorStr = errorStr & getResource("mustincludecomments") & "<br>">
		</cfif>
		
		<!--- captcha validation --->
		<cfif application.useCaptcha>
			<cfif not len(getvalue("captchaText"))>
			   <cfset errorStr = errorStr & "Please enter the Captcha text.<br>">
			<cfelseif NOT application.captcha.validateCaptcha(getvalue("captchaHash"),getvalue("captchaText"))>
			   <cfset errorStr = errorStr & "The captcha text you have entered is incorrect.<br>">
			</cfif>
		</cfif>
		<!--- No error, then add --->
		<cfif not len(errorStr)>
			<!--- Get Entry --->
			<cfset entry = application.blog.getEntry(getValue("id")) >
		    <!--- RBB 11/02/2005: added website to commentID --->
		    <cftry>
				<cfset commentID = application.blog.addComment(getValue("id"),left(getValue("name"),50), left(getValue("email"),50), left(form.website,255), getValue("newcomments"), getValue("subscribe",false))>
				<!--- Form a message about the comment --->
				<cfset subject = getResource("commentaddedtoblog") & ": " & application.blog.getProperty("blogTitle") & " / " & getResource("entry") & ": " & entry.title>
				<cfsavecontent variable="email">
				<cfoutput>
		#getResource("commentaddedtoblogentry")#:	#entry.title#
		#getResource("commentadded")#: 			#application.localeUtils.dateLocaleFormat(now())# / #application.localeUtils.timeLocaleFormat(now())#
		#getResource("commentmadeby")#:	 		#getValue("name")# (#getValue("email")# / #form.website#)
		URL: #application.blog.makeLink(getValue("id"))#

		#getValue("newcomments")#

		------------------------------------------------------------
		#getResource("unsubscribe")#: %unsubscribe%
		This blog powered by BlogCFC #application.blog.getVersion()#
		Created by Raymond Camden (ray@camdenfamily.com)
				</cfoutput>
				</cfsavecontent>

				<cfset application.blog.notifyEntry(entry.id, trim(email), subject, getValue("email"))>
				<cfcatch>
					<cfif cfcatch.message is not "Comment blocked for spam.">
						<cfrethrow>
					</cfif>
				</cfcatch>

			</cftry>

			<cfmodule template="../tags/scopecache.cfm" scope="application" clearall="true">

			<!--- clear form data --->
			<cfif getValue("rememberMe",false)>
				<cfcookie name="blog_name" value="#trim(htmlEditFormat(getValue("name")))#" expires="never">
				<cfcookie name="blog_email" value="#trim(htmlEditFormat(getValue("email")))#" expires="never">
				<!--- RBB 11/02/2005: Added new website cookie --->
				<cfcookie name="blog_website" value="#trim(htmlEditFormat(getvalue("website")))#" expires="never">
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
		<cfset dspComments()>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeleteComment" access="public" returntype="void" output="false">
		<cfset application.blog.deleteComment(getValue("delete"))>
		<cfset setNextEvent("ehBlog.dspComments")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspTrackbacks" access="public" returntype="void" output="false">
		<cfset var params = Structnew()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehAddTrackback ="ehBlog.doAddTrackback">
		<cfif not valueExists("id") or not application.blog.getProperty("allowtrackbacks")>
			<cfabort>
		</cfif>
		<cfif valueExists("delete") and isUserInRole("admin")>
			<cfset application.blog.deleteTrackback(getvalue("delete"))>
		</cfif>

		<cfset params.byEntry = getvalue("id")>
		<cfset setValue("article",application.blog.getEntries(params))>
		<cfset setValue("additionalTitle","Trackbacks for #getValue("article").title#")>
		<!--- Set View --->
		<cfset setView("vwTrackbacks")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doAddTrackback" access="public" returntype="void" output="false">
		<cfset var errorStr = "">
		<cfset var id = "">
		
		<cfif not len(trim(getValue("blog_name")))>
			<cfset errorStr = errorStr & getResource("mustincludeblogname") & "<br>">
		</cfif>

		<cfif not len(trim(getValue("title")))>
			<cfset errorStr = errorStr & getResource("mustincludeblogtitle") & "<br>">
		</cfif>

		<cfif not len(trim(getValue("excerpt")))>
			<cfset errorStr = errorStr & getResource("mustincludeblogexcerpt") & "<br>">
		</cfif>

		<cfif not len(trim(getValue("url"))) or not isURL(getValue("url"))>
			<cfset errorStr = errorStr & getResource("mustincludeblogentryurl") & "<br>">
		</cfif>

		<cfif not len(errorStr)>
			<cfset id = application.blog.addTrackBack(getValue("title"), getValue("url"), getValue("blog_name"), getValue("excerpt"), getValue("id"))>
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
		<cfset setNextEvent("ehBlog.dspTrackbacks","id=#getvalue("id")#")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doDeleteTrackback" access="public" returntype="void" output="false">
		<cfif valueExists("delete") and UserInRole("admin")>
			<cfset application.blog.deleteTrackback(getValue("delete"))>
		</cfif>
		<!--- Set NextEvent --->
		<cfset setNextEvent("ehBlog.dspTrackbacks","id=#getvalue("id")#")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspPrint" access="public" returntype="void" output="false">
		<cfif not valueExists("id")>
			<cfset setNextEvent("ehBlog.dspBlog")>
		</cfif>

		<cftry>
			<cfset setValue("entry", application.blog.getEntry(getValue("id")))>
			<cfcatch>
				<cfset setNextEvent("ehBlog.dspBlog")>
			</cfcatch>
		</cftry>
		<!--- Set View --->
		<cfset setView("vwPrint")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspSend" access="public" returntype="void" output="false">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehTrackback = "ehBlog.dspTrackback">
		<cfset rc.xehPrint = "ehBlog.dspPrint">
		<cfset rc.xehSend = "ehBlog.dspSend">
		<cfset rc.xehRSS = "ehBlog.dspRss">
		<cfset rc.xehSubscribe = "ehBlog.doSubscribe">
		<cfset rc.xehSendEntry = "ehBlog.doSend">

		<cfif not valueExists("id")>
			<cfset setNextEvent("ehBlog.dspHome")>
		<cfelse>
			<cftry>
				<cfset setValue("entry",application.blog.getEntry(getvalue("id")))>
				<cfcatch>
					<cfset setNextEvent("ehBlog.dspHome")>
				</cfcatch>
			</cftry>
		</cfif>
		<cfset setValue("showForm", true)>
		<cfset setValue("additionalTitle",getResource("send"))>
		<!--- Set View --->
		<cfset setView("vwSend")>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="doSend" access="public" returntype="void" output="false">
		<cfset var errorStr = "">
		<cfset var entry = application.blog.getEntry(getvalue("id"))>

		<cfif not len(trim(getvalue("email",""))) or not isEmail(getvalue("email",""))>
			<cfset errorStr = errorStr & getResource("mustincludeemail") & "<br />">
		</cfif>
		<cfif not len(trim(getvalue("remail",""))) or not isEmail(getvalue("remail",""))>
			<cfset errorStr = errorStr & getResource("mustincludereceiveremail") & "<br />">
		</cfif>

		<cfif not len(errorStr)>
			<cfmail to="#getvalue("remail")#" from="#getvalue("email")#" cc="#application.blog.getProperty("owneremail")#"
					subject="#getResource("blogentryfrom")#: #application.blog.getProperty("blogtitle")#"
					type="html">
				<p>
				The following blog entry was sent to you from: <b>#getvalue("email")#</b><br />
				It came from the blog: <b>#application.blog.getProperty("blogtitle")#</b><br />
				The entry is titled: <b>#entry.title#</b><br />
				The entry can be found here: <b><a href="#application.blog.makeLink(entry.id)#">#application.blog.makeLink(entry.id)#</a></b>
				</p>

				<cfif len(getvalue("notes"))>
				<p>
				The following notes were included:<br />
				<b>#getvalue("notes")#</b>
				</p>
				<p>
				<hr>
				</p>
				</cfif>
				#application.blog.renderEntry(entry.body)#
				<cfif len(entry.morebody)>#application.blog.renderEntry(entry.morebody)#</cfif>
			</cfmail>
			<cfset setValue("showForm", false)>
			<cfset getPlugin("messagebox").setMessage("info",getResource("entrysent"))>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("error",errorStr)>
		</cfif>
		<!--- Display Send --->
		<cfset setNextEvent("ehBlog.dspSend","id=#rc.id#")>
	</cffunction>
	<!--- ************************************************************* --->



	<!--- ************************************************************* --->
	<!--- Private Functions --->
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="fnccfdocument" access="private" returntype="void" hint="Check for cfdoctype and change layout">
		<cfscript>
		if ( getValue("cfdoctype",0) neq 0 )
			setLayout("Layout.Cfdoc");
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>