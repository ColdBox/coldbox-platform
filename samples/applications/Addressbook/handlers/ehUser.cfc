<cfcomponent name="ehUser" extends="coldboxSamples.system.eventhandler">
	<cffunction name="init" access="public" returntype="ehUser">
		<cfargument name="controller" required="yes" hint="The reference to the framework controller">	
		<cfset super.init(arguments.controller)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="dspAccountActions" access="public">
		<cfset setValue("isLoggedIn", session.userID neq "")>
		
		<cfif session.userID neq "">
			<cfset obj = CreateObject("component","#getSetting("AppCFMXMapping")#.components.users")>
			<cfset qry = obj.getUser(session.userID)>
			<cfset setValue("username", qry.username)>
		</cfif>
		
		<cfset setView("vwAccountActions")>
	</cffunction>

	<cffunction name="dspLogin" access="public">
		<cfset setView("vwLogin")>
	</cffunction>
	
	<cffunction name="dspSignUp" access="public">
		<cfset setView("vwSignUp")>
	</cffunction>

	<cffunction name="doCreateAccount" access="public">
		<cfscript>
			var username = getValue("username","");
			var password = getValue("password","");
			var password2 = getValue("password2","");
			var email = getValue("email","");
			
			if ( username eq "" or password eq "" or email eq ""){
				getPlugin("messagebox").setMessage("error", "Please enter all the account information.");
				setNextEvent("ehUser.dspSignup");
			}
			if ( compare(password,password2) neq 0 ){
				getPlugin("messagebox").setMessage("error", "The passwords do not match.");
				setNextEvent("ehUser.dspSignup");
			}			
			try {
				obj = CreateObject("component","#getSetting("AppCFMXMapping")#.components.users");
				newUserID = obj.createUser(username, password, email);
				if(newUserID eq "") throw("An unexpected error ocurred while creating the account.");
				session.userID = newUserID;
				setNextEvent("ehGeneral.dspReader");

			} catch (any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br>" & e.detail);
				setView("vwSignUp");
			}
		</cfscript>
	</cffunction>


	<cffunction name="doLogin" access="public">
		<cfscript>
			var username = getValue("username","");
			var password = getValue("password","");
			
			try {
				obj = CreateObject("component","#getSetting("AppCFMXMapping")#.components.users");
				userID = obj.checkLogin(username, password);
				if(userID eq "") throw("Username/Password not recognized.");
				session.userID = userID;
				setNextEvent("ehGeneral.dspReader");
				
			} catch (any e) {
				getPlugin("messagebox").setMessage("error", e.message);
				setView("vwLogin");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doLogout" access="public">
		<cfset session.userID = "">
		<cfset setNextEvent("ehGeneral.dspReader")>
	</cffunction>

</cfcomponent>