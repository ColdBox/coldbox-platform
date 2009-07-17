<cfcomponent name="ehUser" extends="coldbox.system.eventhandler" output="false">
	
	<cffunction name="dspUsers" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection() />
		<cfset rc.users = getPlugin("ioc").getBean("UserManager").getUsers() />
		
		<cfset rc.xehView = 'admin.ehUser.dspUser'>
		<cfset rc.xehEdit = 'admin.ehUser.dspEditUser'>
		<cfset rc.xehDelete = 'admin.ehUser.dspDelUser'>
		
		<cfset Event.setView("user/list")>		
	</cffunction>
	
	<cffunction name="dspEditUser" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection() />
		<!--- No user object in Event Collection? (Will exist after validation) --->
		<cfif not isDefined("rc.user")>
			<cfset rc.user = getPlugin("ioc").getBean("UserManager").getUser( Event.getValue("userId","") ) />
		</cfif>
		<cfset rc.userTypes = getPlugin("ioc").getBean("UserManager").getUserTypes()>
		<!--- EXIT EVENT HANDLERS: --->
		<cfset rc.xehSave = "admin.ehUser.doSaveUser">			
		<cfset rc.xehBack = "admin.ehUser.dspUsers">			

		<cfset Event.setView("user/edit")>		
	</cffunction>
	
	<cffunction name="dspUser" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection() />
		<!--- No user object passed? --->
		<cfif not isDefined("rc.user")>
			<cfset rc.user = getPlugin("ioc").getBean("UserManager").getUser( Event.getValue("userId","") ) />	
		</cfif>
		<!--- EXIT EVENT HANDLERS: --->
		<cfset rc.xehEdit = "admin.ehUser.dspEditUser">			
		<cfset rc.xehBack = "admin.ehUser.dspUsers">			
		<cfset Event.setView("user/view")>		
	</cffunction>
	
	<cffunction name="doSaveUser" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		
		<cfset var isValidationError  = 0>
		<cfset var userType = getPlugin("ioc").getBean("UserManager").getUserType( Event.getValue("userTypeId") )>
		<cfset var newPassword = Event.getValue("newPassword")>
		<cfset var confirmPassword = Event.getValue("confirmPassword")>
		<cfset var rc = Event.getCollection() />
		<cfset rc.user = getPlugin("ioc").getBean("UserManager").getUser( Event.getValue("userId","") ) />	
		
		<!--- PopulateBean --->
		<cfset getPlugin("beanFactory").populateBean(rc.user)>
		<cfset rc.user.setUserType(userType)>
		
		<!--- Password? --->
		<cfif newPassword neq "" and newPassword eq confirmPassword>
			<cfset rc.user.setPassword(newPassword)>
		<cfelseif newPassword neq "" and newPassword neq confirmPassword>
			<cfset getPlugin("messagebox").setMessage("error", "Validation error: Passwords are not equal")>
			<cfset isValidationError  = 1>
		</cfif>
		
		<!--- Validation Error? --->
		<cfif isValidationError>
			<cfset dspEditUser(Event)>
		<cfelse>
			<cfset getPlugin("ioc").getBean("UserManager").saveUser(rc.user)>		
			<cfset setNextEvent("admin.ehUser.dspUsers")>
		</cfif>
		
	</cffunction>
	
	<cffunction name="dspDelUser" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">

		<cfset var rc = Event.getCollection() />
		<cfset rc.user = getPlugin("ioc").getBean("UserManager").getUser( Event.getValue("userId","") ) />	
		<cfset rc.xehDelete = "admin.ehUser.doDelUser">
		<cfset rc.xehBack = "admin.ehUser.dspUsers">
		<cfset Event.setView("user/view")>		
	</cffunction>
	
	<cffunction name="doDelUser" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">

		<cfset var rc = Event.getCollection() />
		<cfset rc.user = getPlugin("ioc").getBean("UserManager").getUser( Event.getValue("userId","") ) />
		<cfset getPlugin("ioc").getBean("UserManager").deleteUser( rc.user ) />

		<cfset setNextEvent("admin.ehUser.dspUsers")>
	</cffunction>
	
	<cffunction name="dspReadByProperty" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">

		<cfset var rc = Event.getCollection() />
		<cfset rc.user = getPlugin("ioc").getBean("UserManager").getUserByUserName( Event.getValue("userName","") ) />	
		<cfset runEvent(Event)>
		
	</cffunction>
	
</cfcomponent>