<cfcomponent name="ehUser" extends="coldbox.system.eventhandler">

	<cffunction name="dspAccountActions" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
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
		<cfset Context.setView("vwAccountActions")>
	</cffunction>

	<cffunction name="dspLogin" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: ---->
		<cfset rc.xehLogin = "ehUser.doLogin">
		<cfset Context.setView("vwLogin")>
	</cffunction>

	<cffunction name="dspSignUp" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset var rc = Context.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehCreate = "ehUser.doCreateAccount">
		<cfset Context.setView("vwSignUp")>
	</cffunction>

	<cffunction name="doCreateAccount" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfscript>
			var password2 = Context.getValue("password2","");
			var userService = getPlugin("ioc").getBean("userService");
			var userBean = userService.createUserBean();
			var rc = Context.getCollection();
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
				userService.saveUser(userBean);
				userBean.setVerified(true);
				//set session object
				session.oUserBean = userBean;
				//relocate
				setNextEvent("ehGeneral.dspReader");

			} catch (any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br>" & e.detail);
				dspSignUp(requestContext);
			}
		</cfscript>
	</cffunction>

	<cffunction name="doLogin" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfscript>
			var userService = getPlugin("ioc").getBean("userService");
			var userBean = userService.createUserBean();
			var rc = Context.getCollection();
			
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
				dspLogin(requestContext);
			}
		</cfscript>
	</cffunction>

	<cffunction name="doLogout" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfset StructDelete(session,"oUserBean")>
		<cfset setNextEvent("ehGeneral.dspReader")>
	</cffunction>


	<cffunction name="doNewPassword" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfscript>
			var username = Context.getValue("username","");
			var newPassword = "";
			var userService = getPlugin("ioc").getBean("userService");
			var userBean = userService.createUserBean();
			
			if ( username eq "" ){
				getPlugin("messagebox").setMessage("warning", "Please enter a username to retrieve a new password.");
			}
			else{
				try {
					//Set the username
					userBean.setUsername(username);
					//Try to get Info
					userService.getUserByUsername(userBean);
					//Verify user
					if ( userBean.getUserID() neq "" ){
						userService.generateNewPassword(userBean, getSetting("MailUsername"), getMailSettings());
						getPlugin("messagebox").setMessage("info", "A new password has been generated and sent to your email on file. Please log in and change your password.");
					}
					else{
						getPlugin("messagebox").setMessage("error", "The username you entered does not exist.");
					}
				} catch (any e) {
					getPlugin("messagebox").setMessage("error", e.message & "<br>" & e.detail);
				}
			}
			setNextEvent("ehUser.dspLogin");
			return;
		</cfscript>	
	</cffunction>
	
	<cffunction name="doUpdateProfile" access="public" returntype="void" output="false">
		<cfargument name="Context" type="coldbox.system.beans.requestContext">
		<cfscript>
			var password = Context.getValue("password","");
			var confirmpassword = Context.getValue("confirmpassword","");
			var email = Context.getValue("email","");
			var userService = getPlugin("ioc").getBean("userService");
			var userBean = userService.createUserBean();
			
			getPlugin("beanFactory").populateBean(userBean);
			
			if ( email eq "" ){
				getPlugin("messagebox").setMessage("warning", "Please enter an email address to update.");
			}
						
			if ( compare(password,confirmpassword) neq 0 ){
				getPlugin("messagebox").setMessage("warning", "The passwords do not match. Please try again.");
			}
			try {
				userBean.setUserID(session.oUserBean.getUserID());
				userService.saveUser(userBean);
				getPlugin("messagebox").setMessage("info", "Your profile has been updated successfully.");

			} catch (any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br>" & e.detail);
			}
			setNextEvent("ehGeneral.dspInfo");
		</cfscript>
	</cffunction>
	
	
</cfcomponent>