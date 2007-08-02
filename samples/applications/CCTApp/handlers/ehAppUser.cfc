<cfcomponent name="ehAppUsers" extends="coldbox.system.eventhandler">
	
	<cffunction name="dspLogin" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection() />
		<cfset Event.setView("appUser/vwLogin") />
	</cffunction>

	<cffunction name="dspForm" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection() />	
		<cfset rc.oAppUser = getPlugin("ioc").getBean("appUserService").getAppUser(appUserId = rc.appUserId).results />
		
		<cfset structDelete(rc,'appUserId') />
		<cfset getPlugin("beanFactory").populateBean(rc.oAppUser) />
		
		<cfset event.setView("appUser/vwForm") />
	</cffunction>
	
	<cffunction name="dspAppUser" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection() />
		<cfset rc.oAppUser = getPlugin("ioc").getBean("appUserService").getAppUser(appUserId = rc.appUserId).results />
		<cfset event.setView("appUser/vwAppUser") />
	</cffunction>
	
	<cffunction name="dspAppUsers" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection() />
		<cfset rc.stAppUsers = getPlugin("ioc").getBean("appUserService").browseRecords(argumentCollection = rc) />
		<cfset event.setView("appUser/vwAppUsers") />
	</cffunction>
	
	<cffunction name="doLogin" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection() />	
		<cfset var validAppUser = getPlugin("ioc").getBean("appUserService").checkCredentials(username = rc.username, password = rc.password) />
		
		<cfif validAppUser.results>
			<cfset getPlugin("ioc").getBean("securityService").logIn(validAppUser.oAppUser) />
			<cfset setNextEvent("ehAppUser.dspAppUsers") />
		<cfelse>		
			<cfset getPlugin('messagebox').setMessage(validAppUser.messageType,validAppUser.message) />
			<cfset Event.setView("appUser/vwLogin") />
		</cfif>			
	</cffunction>
	
	<cffunction name="doLogout" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset getPlugin("ioc").getBean("securityService").logout() />
		<cfset Event.setView("appUser/vwLogin") />
	</cffunction>

	<cffunction name="doUpdate" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection() />
		<cfset var stUpdate = '' />
		<!--- set default --->
		<cfset event.paramValue('isActive',0) />
		
		<cfset stUpdate = getPlugin("ioc").getBean("appUserService").updateAppUser(argumentCollection = rc) />
		
		<!--- load bean with current data --->
		<cfset rc.oAppUser = stUpdate.oAppUser />
			
		<cfif stUpdate.results>
			<cfset getPlugin('messagebox').setMessage('info','Updated Successfully') />
			<cfset setNextEvent("ehAppUser.dspAppUsers")>
		<cfelse>
			<cfset getPlugin('messagebox').setMessage('error',stUpdate.message) />
			<cfset event.setView("appUser/vwForm") />
		</cfif>
	</cffunction>
	
	<cffunction name="doDelete" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = event.getCollection()>
		<cfset rc.oAppUser = getPlugin("ioc").getBean("appUserService").deleteAppUser(appUserId = rc.appUserId) />
		<cfset getPlugin("messagebox").setMessage(rc.oAppUser.messageType, rc.oAppUser.message)>
		<cfset setNextEvent("ehAppUser.dspAppUsers")>
	</cffunction>
</cfcomponent>