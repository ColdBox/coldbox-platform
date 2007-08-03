<cfcomponent displayname="appUserService" hint="This is the appUserService component" output="false" cache="true" cachetimeout="15">	
	<cffunction name="init" access="public" output="false" returntype="appUserService">
		<cfargument name="oAppUserGateway" type="any" required="true" />
		<cfargument name="oTransfer" type="any" required="true" />
		
		<cfset variables.oAppUserGateway = arguments.oAppUserGateway />
		<cfset variables.oTransfer = arguments.oTransfer />
		
		<cfreturn this />
	</cffunction>		
	
	<cffunction name="checkCredentials" access="public" returntype="struct" output="false">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfargument name="isActive" type="boolean" required="true" default="true">
		
		<cfset var stReturn = structnew()>
		<cfset stReturn.results = false />
		<cfset stReturn.message = "User Not Validated." />
		<cfset stReturn.messageType = "error" />
		<cfset stReturn.qAppUser = "" />
		
		<cfif not len(arguments.username) or not len(arguments.password)>
			<cfset stReturn.message = "No username or password defined." />
		<cfelse>
			<cfset arguments.password = hash(arguments.password) />
			<cfset stReturn.qAppUser = variables.oTransfer.listByPropertyMap('AppUser.AppUser',arguments) />
			<cfset stReturn.oAppUser = variables.oTransfer.get('AppUser.AppUser',stReturn.qAppUser.appUserId) />
			
			<cfif stReturn.qAppUser.recordCount>
				<cfset stReturn.results = true />
				<cfset stReturn.message = "Valid User" />
				<cfset stReturn.messageType = "info" />
			<cfelse>
				<cfset stReturn.message = "Invalid User Information." />
			</cfif>
		</cfif>
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="browseRecords" access="public" output="No" returntype="struct">
		<cfreturn variables.oAppUserGateway.browseRecords(argumentCollection = arguments) />
	</cffunction>
	
	<cffunction name="getAppUser" access="public" returntype="struct" output="false">
		<cfargument name="appUserId" type="string" required="true" default="">
		
		<cfset var stReturn = structnew()>
		<cfset stReturn.results = variables.oTransfer.new('AppUser.AppUser') />
		<cfset stReturn.message = "Invalid Request." />
		<cfset stReturn.messageType = "error" />
		
		<cfif len(arguments.appUserId) and isValid('UUID',arguments.appUserId)>
			<cfset stReturn.results = variables.oTransfer.get('AppUser.AppUser',arguments.appUserId) />
		</cfif>
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="deleteAppUser" access="public" returntype="struct" output="false">
		<cfargument name="appUserId" type="string" required="true" default="">
		
		<cfset var stReturn = structnew()>
		<cfset stReturn.results = false />
		<cfset stReturn.message = "Invalid Request." />
		<cfset stReturn.messageType = "error" />
		
		<cfif len(arguments.appUserId) and isValid('UUID',arguments.appUserId)>
			<cfset stReturn.results = variables.oTransfer.delete(variables.oTransfer.get('AppUser.AppUser',arguments.appUserId)) />
			<cfset stReturn.results = true />
			<cfset stReturn.message = "Removed Successfully." />
			<cfset stReturn.messageType = "info" />
		</cfif>
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="updateAppUser" access="public" returntype="struct" output="false">
		<cfargument name="updatedOn" type="Date" required="true" default="#now()#" />
		
		<cfset var validateData = '' />
		<cfset var stReturn = structnew()>
		<cfset stReturn.results = false />
		<cfset stReturn.message = "Invalid Request." />
		<cfset stReturn.messageType = "error" />
		
		<cfif len(arguments.appUserId) and isValid('UUID',arguments.appUserId)>
			<!--- load bean with current data and validate --->
			<cfset stReturn.oAppUser = variables.oTransfer.get('AppUser.AppUser',arguments.appUserId) />
			
			<cfset stReturn.oAppUser.populateBean(arguments) />
			<!--- check for change password --->
			<cfif len(arguments.newPassword) and len(arguments.confirmPassword)>
				<cfif arguments.confirmPassword eq arguments.newPassword>
					<cfset stReturn.oAppUser.setPassword(arguments.newPassword) />
				<cfelse>
					<cfset stReturn.message = "Passwords Do Not Match." />
					<cfreturn stReturn />
				</cfif>			
			</cfif>
			
			<cfset validateData = stReturn.oAppUser.validate() />
			
			<cfif validateData.results>
				<!--- save new bean data to db --->
				<cfset variables.oTransfer.save(stReturn.oAppUser) />
				<cfset stReturn.results = true />
				<cfset stReturn.message = "User Updated" />
				<cfset stReturn.messageType = "info" />
			<cfelse>
				<cfset stReturn.message = validateData.longMessage />
			</cfif>
		</cfif>	
		
		<cfreturn stReturn />
	</cffunction>
</cfcomponent>