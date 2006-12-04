<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :

	The galleon port.

----------------------------------------------------------------------->
<cfcomponent name="ehUsers" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->
	
	<cffunction name="dspLogin" access="public" returntype="void" output="false">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehDoLogin = "ehUsers.doLogin">
		<cfset rc.xehRegister = "ehUsers.doRegister">
		<cfset rc.xehPasswordReminder = "ehUsers.doPasswordReminder">
		<!--- Set Title and Templatename --->
		<cfset setValue("title","#application.settings.title#")>
		<cfset setValue("templatename","main")>
		<!--- Set the View To Display, after Logic --->
		<cfset setView("vwLogin")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doLogin" access="public" returntype="void" output="false">
		<cfset var mygroups = "">
		<!--- handle security --->
		<cflogin>
			<cfif application.user.authenticate(trim(getValue("username")), trim(getValue("password")))>
				<!--- good logon, grab their groups --->
				<cfset mygroups = application.user.getGroupsForUser(trim(getValue("username")))>
				<cfset session.user = application.user.getUser(trim(getValue("username")))>
				<cfloginuser name="#trim(getValue("username"))#" password="#trim(getValue("password"))#" roles="#mygroups#">
			<cfelse>
				<cfif application.settings.requireconfirmation>
					<cfset getPlugin("messagebox").setMessage("error","Either your username and password did not match or you have not completed your email confirmation.")>
				<cfelse>
					<cfset getPlugin("messagebox").setMessage("error","Your username and password did not work.")>
				</cfif>
				<cfset setNextEvent("ehUsers.dspLogin","failedLogon=true&ref=#getValue("ref")#")>
			</cfif>
		</cflogin>
		<!--- SuccessFull Login --->
		<cfif request.udf.isLoggedOn()>
			<cfif getvalue("ref") neq "">
				<cflocation url="#getValue("ref")#" addToken="false">
			<cfelse>
				<cfset setNextEvent("ehForums.dspHome")>
			</cfif>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doLogout" access="public" returntype="void" output="false">
		<!--- handle security --->
		<cflogout>
		<cfset structDelete(session, "user")>
		<cfset setNextEvent("ehForums.dspHome","loggedout=true")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doRegister" access="public" returntype="void" output="false">
		<cfset var errors = "">
		<cfset var mygroups = "">
		
		<!--- Check for Validation --->
		<cfif not len(trim(getValue("username_new"))) or not request.udf.isValidUsername(getValue("username_new"))>
			<cfset errors = errors & "You must enter a username. Only letters and numbers are allowed.<br>">
		</cfif>

		<cfif not len(trim(getValue("emailaddress"))) or not request.udf.isEmail(getValue("emailaddress"))>
			<cfset errors = errors & "You must enter a valid email address.<br>">
		</cfif>

		<cfif not valueExists("password_new") or not len(trim(getValue("password_new"))) or getValue("password_new") neq getValue("password_new2")>
			<cfset errors = errors & "You must enter a valid password that matches the confirmation.<br>">
		</cfif>

		<cfif not len(errors)>
			<cftry>
				<cfset application.user.addUser(trim(getValue("username_new")),trim(getValue("password_new")),trim(getValue("emailaddress")),"forumsmember")>
				<cfset mygroups = application.user.getGroupsForUser(trim(getValue("username_new")))>
				
				<!--- Only login if no confirmation needed --->
				<cfif not application.settings.requireconfirmation>
					<cflogin>
						<cfset session.user = application.user.getUser(trim(getValue("username_new")))>
						<cfloginuser name="#trim(getValue("username_new"))#" password="#trim(form.password_new)#" roles="#mygroups#">
					</cflogin>

					<cfif getValue("ref") neq "">
						<cflocation url="#getValue("ref")#" addToken="false">
					<cfelse>
						<cfset setNextEvent("ehForums.dspHome")>
					</cfif>
				<cfelse>
					<cfset setNextEvent("ehUsers.dspLogin","showRequireConfirmation=true")>
				</cfif>
				
				<cfcatch type="user cfc">
					<cfif findNoCase("User already exists",cfcatch.message)>
						<cfset errors = errors & "This username already exists.<br>">
					</cfif>
				</cfcatch>
				
				<cfcatch type="any">
					<cfset errors = "General DB error. #cfcatch.detail# #cfcatch.message#">
					<cfset getPlugin("logger").logError("General DB Errors creating Registration", cfcatch )>
				</cfcatch>
			</cftry>
		</cfif>
		<!--- Errors Occurred --->
		<cfset getPlugin("messagebox").setMessage("error",errors)>
		<!--- Set Next Events --->
		<cfset setNextEvent("ehUsers.dspLogin","failedRegistration=true")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doPasswordReminder" access="public" returntype="void" output="false">
		<!--- Do Your Logic Here to prepare a view --->
		<cfset var data = application.user.getUser(trim(getValue("username_lookup")))>
		<cfif data.emailaddress is not "">
			<cfmail to="#data.emailaddress#" from="#application.settings.fromAddress#" subject="Galleon Password Reminder">
			This is a password reminder from the Galleon Forums at #application.settings.rooturl#.
			Your password is: #data.password#
			</cfmail>
			<cfset getPlugin("messagebox").setMessage("info", "A reminder has been sent to your email address.")>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("error", "Sorry, but your username could not be found in our system.")>
		</cfif>

		<!--- Set the View To Display, after Logic --->
		<cfset setNextEvent("ehUsers.dspLogin","passreminder=true")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doConfirmUser" access="public" returntype="void" output="false">
		<!--- Exit Handlers --->
		<cfset rc.xehLogin = "ehUsers.dspLogin">
		<!--- run confirmation --->
		<cfset rc.result = application.user.confirm(getvalue("u",""))>
		<!--- Set Title and Templatename --->
		<cfset setValue("title","#application.settings.title# Registration Confirmation")>
		<cfset setValue("templatename","main")>
		<cfset setView("vwConfirm")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="dspProfile" access="public" returntype="void" output="false">
		<cfset var thisPage = cgi.script_name & "?" & cgi.query_string>
		<cfset var subMode = "">
		<cfset var subID = "">
		<cfset var thread = "">
		<cfset var name = "">
		<cfset var forum = "">
		<cfset var conference = "">
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSaveProfile = "ehUsers.doSaveProfile">
		<cfset rc.xehRemoveSub = "ehUsers.doRemoveSub">
		<cfset rc.xehForums = "ehForums.dspForums">
		<cfset rc.xehThreads = "ehForums.dspThreads">
		<cfset rc.xehMessages = "ehForums.dspMessages">
		
		<!--- Check if Logged On --->
		<cfif not request.udf.isLoggedOn()>
			<cfset setNextEvent("ehUsers.dspLogin","ref=#urlEncodedFormat(thisPage)#")>
		</cfif>

		<!--- attempt to subscribe --->
		<cfif valueExists("s")>
			<cftry>
				<cfif valueExists("threadid")>
					<cfset subMode = "thread">
					<cfset subID = getValue("threadID")>
					<cfset thread = application.thread.getThread(subID)>
					<cfset name = thread.name>
				<cfelseif valueExists("forumid")>
					<cfset subMode = "forum">
					<cfset subID = getValue("forumid")>
					<cfset forum = application.forum.getForum(subID)>
					<cfset name = forum.name>
				<cfelseif valueExists("conferenceid")>
					<cfset subMode = "conference">
					<cfset subID = getValue("conferenceid")>
					<cfset conference = application.conference.getConference(subid)>
					<cfset name = conference.name>
				</cfif>
				<cfcatch>
					<cfset setNextEvent("ehForums.dspHome")>
				</cfcatch>
			</cftry>
			<cfif subMode neq "">
				<cfset application.user.subscribe(getAuthUser(), subMode, subID)>
				<cfset setValue("confirm","subscribe") >
				<cfset getPlugin("messagebox").setMessage("info","You have been subscribed to the #submode#: <b>#name#</b>")>
			</cfif>
		</cfif>

		<cfset setValue("user", application.user.getUser(getAuthUser()) )>
		<cfset setValue("subs", application.user.getSubscriptions(getAuthUser()) )>

		<!--- Set Title and Templatename --->
		<cfset setValue("title","#application.settings.title# : Profile")>
		<cfset setValue("templatename","main")>
		<!--- Set the View To Display, after Logic --->
		<cfset setView("vwProfile")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doSaveProfile" access="public" returntype="void" output="false">
		<!--- Get User Info --->
		<cfset var user = application.user.getUser(getAuthUser())>
		<cfset var errors = "">
		<!--- Validate --->
		<cfif not len(trim(getValue("emailaddress"))) or not request.udf.isEmail(getValue("emailaddress"))>
			<cfset errors = errors & "You must enter a valid email address.<br>">
		<cfelse>
			<cfset user.emailaddress = trim(htmlEditFormat(getValue("emailaddress")))>
		</cfif>

		<cfif len(trim(getValue("password_new"))) and getValue("password_new") neq getValue("password_confirm")>
			<cfset errors = errors & "To change your password, your confirmation password must match.<br>">
		</cfif>
		<!--- Save if no Errors --->
		<cfif not len(errors)>
			<cfif len(trim(getValue("password_new")))>
				<cfset user.password = getValue("password_new")>
			</cfif>
			<cfset application.user.saveUser(username=getAuthUser(),password=user.password,emailaddress=user.emailaddress,datecreated=user.datecreated,groups=application.user.getGroupsForUser(getAuthUser()),signature=rc.signature,confirmed=true)>
			<cfset getPlugin("messagebox").setMessage("info","Your profile has been updated.")>
		<cfelse>
			<cfset getPlugin("messagebox").setMessage("warning",errors)>
		</cfif>
		<!--- Redirect --->
		<cfset setNextEvent("ehUsers.dspProfile","confirm=profile")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doRemoveSub" access="public" returntype="void" output="false">
		<cftry>
			<cfset application.user.unsubscribe(getAuthUser(), getValue("removeSub"))>
			<cfset getPlugin("messagebox").setMessage("info","You have been Unsubscribed successfully.")>
			<cfcatch>
				<!--- silently fail --->
				<cfset getPlugin("logger").logError("Error Unsubscribing",cfcatch, rc)>
			</cfcatch>
		</cftry>

		<!--- Redirect --->
		<cfset setNextEvent("ehUsers.dspProfile","confirm=subscribe")>
	</cffunction>

	<!--- ************************************************************* --->
	
</cfcomponent>