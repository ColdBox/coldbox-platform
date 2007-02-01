<cfcomponent name="ehUser" extends="coldbox.system.eventhandler">

	<cffunction name="dspAccountActions" access="public" returntype="void" output="false">
		<cfset var obj = "">
		<cfset var qry = "">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehLogout = "ehUser.doLogout">
		<cfset rc.xehLogin = "ehUser.dspLogin">
		<cfset rc.xehSignup = "ehUser.dspSignUp">
		<cfset rc.xehHome = "ehGeneral.dspReader">
		<cfset rc.xehAddFeed = "ehFeed.dspAddFeed">
		<cfset rc.xehMyFeeds = "ehFeed.dspMyFeeds">
		
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
			var password2 = getValue("password2","");
			var userService = application.IOCEngine.getBean("userService");
			var userBean = userService.createUserBean();
			
			//Populate Bean From Request Collection.
			getPlugin("beanFactory").populateBean(userBean);
			
			if ( userBean.getUserName() eq "" or userBean.getPassword() eq "" or userBean.getemail() eq ""){
				getPlugin("messagebox").setMessage("warning", "Please enter all the account information in order to create an account.");
				setNextEvent("ehUser.dspSignUp");
			}
			if ( compare(UserBean.getpassword(),password2) neq 0 ){
				getPlugin("messagebox").setMessage("warning", "The passwords do not match.");
				setNextEvent("ehUser.dspSignup");
			}
			try {
				userService.createUser(userBean);
				userBean.setVerified(true);
				//set session object
				session.oUserBean = userBean;
				//relocate
				setNextEvent("ehGeneral.dspReader");

			} catch (any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br>" & e.detail);
				dspSignUp();
			}
		</cfscript>
	</cffunction>

	<cffunction name="doLogin" access="public" returntype="void" output="false">
		<cfscript>
			var userService = application.IOCEngine.getBean("userService");
			var userBean = userService.createUserBean();
			try {
				
				getPlugin("beanFactory").populateBean(userBean);
				userService.checkLogin(userBean);
				if (userBean.getVerified()){
					structDelete(session,"oUserBean");
					session.oUserBean = userBean;
					getPlugin("messagebox").setMessage("info","Welcome back to the ColdBox Reader #userBean.getusername()#!");
					setNextEvent("ehGeneral.dspReader");
				}
				else{
					throw("Username/Password not recognized.");
				}

			} catch (any e) {
				getPlugin("logger").logError("Error logging in user", e);
				getPlugin("messagebox").setMessage("error", e.message);
				dspLogin();
			}
		</cfscript>
	</cffunction>

	<cffunction name="doLogout" access="public" returntype="void" output="false">
		<cfset StructDelete(session,"oUserBean")>
		<cfset setNextEvent("ehGeneral.dspReader")>
	</cffunction>

</cfcomponent>