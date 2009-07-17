<cfcomponent name="userBean" output="false">

	<!---
	PROPERTIES
	--->
	<cfset variables.instance = StructNew() />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="userBean" output="false">
		<cfargument name="UserID" 		type="string" required="false" default="" />
		<cfargument name="UserName" 	type="string" required="false" default="" />
		<cfargument name="Password" 	type="string" required="false" default="" />
		<cfargument name="Email" 		type="string" required="false" default="" />
		<cfargument name="CreatedOn" 	type="string" required="false" default="" />
		<cfargument name="LastLogin" 	type="string" required="false" default="" />

		<!--- run setters --->
		<cfset setUserID(arguments.UserID) />
		<cfset setUserName(arguments.UserName) />
		<cfset setPassword(arguments.Password) />
		<cfset setEmail(arguments.Email) />
		<cfset setCreatedOn(arguments.CreatedOn) />
		<cfset setLastLogin(arguments.LastLogin) />
		<cfset setVerified(false) />
		<cfreturn this />
 	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="setMemento" access="public" returntype="void" output="false">
		<cfargument name="memento" type="struct" required="yes"/>
		<cfset variables.instance = arguments.memento />
		<cfreturn this />
	</cffunction>
	<cffunction name="getMemento" access="public" returntype="struct" output="false" >
		<cfreturn variables.instance />
	</cffunction>

	<cffunction name="validate" access="public" returntype="array" output="false">
		<cfset var errors = arrayNew(1) />
		<cfset var thisError = structNew() />

		<!--- UserID --->
		<cfif (NOT len(trim(getUserID())))>
			<cfset thisError.field = "UserID" />
			<cfset thisError.type = "required" />
			<cfset thisError.message = "UserID is required" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- UserName --->
		<cfif (NOT len(trim(getUserName())))>
			<cfset thisError.field = "UserName" />
			<cfset thisError.type = "required" />
			<cfset thisError.message = "UserName is required" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- Password --->
		<cfif (NOT len(trim(getPassword())))>
			<cfset thisError.field = "Password" />
			<cfset thisError.type = "required" />
			<cfset thisError.message = "Password is required" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- Email --->
		<cfif (NOT len(trim(getEmail())))>
			<cfset thisError.field = "Email" />
			<cfset thisError.type = "required" />
			<cfset thisError.message = "Email is required" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- CreatedOn --->
		<cfif (NOT len(trim(getCreatedOn())))>
			<cfset thisError.field = "CreatedOn" />
			<cfset thisError.type = "required" />
			<cfset thisError.message = "CreatedOn is required" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<!--- LastLogin --->
		<cfif (NOT len(trim(getLastLogin())))>
			<cfset thisError.field = "LastLogin" />
			<cfset thisError.type = "required" />
			<cfset thisError.message = "LastLogin is required" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif>

		<cfreturn errors />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setUserID" access="public" returntype="void" output="false">
		<cfargument name="UserID" type="string" required="true" />
		<cfset variables.instance.UserID = arguments.UserID />
	</cffunction>
	<cffunction name="getUserID" access="public" returntype="string" output="false">
		<cfreturn variables.instance.UserID />
	</cffunction>

	<cffunction name="setUserName" access="public" returntype="void" output="false">
		<cfargument name="UserName" type="string" required="true" />
		<cfset variables.instance.UserName = arguments.UserName />
	</cffunction>
	<cffunction name="getUserName" access="public" returntype="string" output="false">
		<cfreturn variables.instance.UserName />
	</cffunction>

	<cffunction name="setPassword" access="public" returntype="void" output="false">
		<cfargument name="Password" type="string" required="true" />
		<cfset variables.instance.Password = arguments.Password />
	</cffunction>
	<cffunction name="getPassword" access="public" returntype="string" output="false">
		<cfreturn variables.instance.Password />
	</cffunction>

	<cffunction name="setEmail" access="public" returntype="void" output="false">
		<cfargument name="Email" type="string" required="true" />
		<cfset variables.instance.Email = arguments.Email />
	</cffunction>
	<cffunction name="getEmail" access="public" returntype="string" output="false">
		<cfreturn variables.instance.Email />
	</cffunction>

	<cffunction name="setCreatedOn" access="public" returntype="void" output="false">
		<cfargument name="CreatedOn" type="string" required="true" />
		<cfset variables.instance.CreatedOn = arguments.CreatedOn />
	</cffunction>
	<cffunction name="getCreatedOn" access="public" returntype="string" output="false">
		<cfreturn variables.instance.CreatedOn />
	</cffunction>

	<cffunction name="setLastLogin" access="public" returntype="void" output="false">
		<cfargument name="LastLogin" type="string" required="true" />
		<cfset variables.instance.LastLogin = arguments.LastLogin />
	</cffunction>
	<cffunction name="getLastLogin" access="public" returntype="string" output="false">
		<cfreturn variables.instance.LastLogin />
	</cffunction>

	<cffunction name="setVerified" access="public" returntype="void" output="false">
		<cfargument name="Verified" type="string" required="true" />
		<cfset variables.instance.Verified = arguments.Verified />
	</cffunction>
	<cffunction name="getVerified" access="public" returntype="string" output="false">
		<cfreturn variables.instance.Verified />
	</cffunction>


</cfcomponent>