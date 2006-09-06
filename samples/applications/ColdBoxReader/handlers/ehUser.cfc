<cfcomponent name="ehUser" extends="coldbox.system.eventhandler">

	<cffunction name="init" access="public" returntype="ehUser">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>

	<cffunction name="dspAccountActions" access="public" returntype="void" output="false">
		<cfset var obj = "">
		<cfset var qry = "">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehLogout = "ehUser.doLogout">
		<cfset rc.xehLogin = "ehUser.dspLogin">
		<cfset rc.xehSignup = "ehUser.dspSignUp">
		<cfset rc.xehHome = "ehGeneral.dspReader">
		<cfset rc.xehAddFeed = "ehFeed.dspAddFeed">
		<!--- Set View --->
		<cfset setView("vwAccountActions")>
	</cffunction>

	<cffunction name="dspLogin" access="public" returntype="void" output="false">
		<!--- EXIT HANDLERS: ---->
		<cfset rc.xehLogin = "ehUser.doLogin">
		<cfset setView("vwLogin")>
	</cffunction>

	<cffunction name="dspSignUp" access="public" returntype="void" output="false">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehCreate = "ehUser.doCreateAccount">
		<cfset setView("vwSignUp")>
	</cffunction>

	<cffunction name="doCreateAccount" access="public" returntype="void" output="false">
		<cfscript>
			var username = getValue("username","");
			var password = getValue("password","");
			var password2 = getValue("password2","");
			var email = getValue("email","");
			var obj = "";
			var newUserID = "";

			if ( username eq "" or password eq "" or email eq ""){
				getPlugin("messagebox").setMessage("error", "Please enter all the account information.");
				setNextEvent("ehUser.dspSignup");
			}
			if ( compare(password,password2) neq 0 ){
				getPlugin("messagebox").setMessage("error", "The passwords do not match.");
				setNextEvent("ehUser.dspSignup");
			}
			try {
				obj = CreateObject("component","#getSetting("AppMapping")#.components.users");
				newUserID = obj.createUser(username, password, email);
				if(newUserID eq "") throw("An unexpected error ocurred while creating the account.");
				session.userID = newUserID;
				qry = obj.getUser(session.userID);
				session.username = qry.username;
				session.email = qry.email;
				session.lastLogin = qry.LastLogin;
				session.createdOn = qry.CreatedOn;
				setNextEvent("ehGeneral.dspReader");

			} catch (any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br>" & e.detail);
				dspSignUp();
			}
		</cfscript>
	</cffunction>


	<cffunction name="doLogin" access="public" returntype="void" output="false">
		<cfscript>
			var username = getValue("username","");
			var password = getValue("password","");
			var obj = "";
			var userID = "";
			var qry = "";
			try {
				obj = CreateObject("component","#getSetting("AppMapping")#.components.users");
				userID = obj.checkLogin(username, password);
				if(userID eq "") throw("Username/Password not recognized.");
				session.userID = userID;
				qry = obj.getUser(session.userID);
				session.username = qry.username;
				session.email = qry.email;
				session.lastLogin = qry.LastLogin;
				session.createdOn = qry.CreatedOn;
				getPlugin("messagebox").setMessage("info","Welcome back to the ColdBox Reader #username#!");
				setNextEvent("ehGeneral.dspReader");

			} catch (any e) {
				getPlugin("logger").logError("Error logging in user", e);
				getPlugin("messagebox").setMessage("error", e.message);
				dspLogin();
			}
		</cfscript>
	</cffunction>

	<cffunction name="doLogout" access="public" returntype="void" output="false">
		<cfset session.userID = "">
		<cfset session.username = "">
		<cfset session.email = "">
		<cfset session.LastLogin = "">
		<cfset session.createdOn = "">
		<cfset setNextEvent("ehGeneral.dspReader")>
	</cffunction>

</cfcomponent>