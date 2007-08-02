<cfcomponent displayname="securityService" hint="This is the securityService component" output="false" cache="true" cachetimeout="0">
	
	<cffunction name="init" access="public" output="false" returntype="securityService">
		<cfargument name="oColdbox" 	type="coldbox.system.controller" required="true" />
		<cfargument name="oTransfer" 	type="transfer.com.Transfer" required="true" />
		
		<cfset variables.oColdbox = arguments.oColdbox />
		<cfset variables.oTransfer = arguments.oTransfer />
		
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="logIn" access="public" returntype="void" output="false">
		<cfargument name="oAppUser" type="transfer.com.TransferObject" required="true">
		
		<cfset variables.oColdbox.getPlugin("sessionstorage").setVar('loggedIn',true) />
		<cfset variables.oColdbox.getPlugin("sessionstorage").setVar("appUserId",oAppUser.getAppUserId()) />
	</cffunction>
	
	<cffunction name="logout" access="public" returntype="void" output="false">
		<cfset variables.oColdbox.getPlugin("sessionstorage").setVar('loggedIn',false) />
		<cfset variables.oColdbox.getPlugin("sessionstorage").deleteVar('appUserId') />
	</cffunction>
	
	<cffunction name="isloggedIn" access="public" returntype="boolean" output="false">		
		<cfreturn variables.oColdbox.getPlugin("sessionstorage").getVar('loggedIn') />
	</cffunction>

</cfcomponent>