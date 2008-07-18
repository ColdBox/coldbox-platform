<!-----------------------------------------------------------------------
Author 	 :	Oscar Arevalo
Date     :	February 13, 2006
Description :
	General handler for my ColdboxReader application.

Modification History:
feb/13/2006 - Oscar Arevalo
	-Created the template.
aug/20/2006 - Luis Majano
	- Modified for 1.1.0
----------------------------------------------------------------------->
<cfcomponent name="ehGeneral" extends="coldbox.system.eventhandler" output="false" autowire="true">

	<!--- Dependency Injections --->
	<cfproperty name="userService" type="ioc" scope="instance" />
	<cfproperty name="feedService" type="ioc" scope="instance" />

	<!--- On Request Start Method --->
	<cffunction name="onRequestStart" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSearch = "ehFeed.doSearchByTerm">
		
		<cfif not structKeyExists(session, "oUserBean")>
			<cfset session.oUserBean = getUserService().createUserBean()>
		</cfif>
		
	</cffunction>

	<!--- On Exceptions --->
	<cffunction name="onException" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var exceptionBean = Event.getValue("ExceptionBean")>
		
		<!--- Do per Type Validations, example here --->
		<cfif exceptionBean.getType eq "Framework.plugins.settings.EventSyntaxInvalidException">
			<cfset getPlugin("messagebox").setMessage("warning", "No page found with that syntax.")>
			<!--- Relocate to default event --->
			<cfset setNextEvent()>
		<cfelse>
			<cfset getPlugin("logger").logErrorWithBean(exceptionBean)>
		</cfif>
	</cffunction>

	<!--- Start Page --->
	<cffunction name="dspStart" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehReader = "ehGeneral.dspReader">
		
		<cfset Event.setView("vwMain")>
	</cffunction>

	<!--- Reader --->
	<cffunction name="dspReader" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var FeedStruct = structnew()>
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehViewFeed = "ehFeed.dspViewFeed">
		<cfset rc.xehShowTags = "ehFeed.dspAllTags">
		<cfset rc.xehShowInfo = "ehGeneral.dspInfo">
		<cfset rc.xehAccountActions = "ehUser.dspAccountActions">
		
		<!--- Get Feeds --->
		<cfset FeedStruct = getFeedService().getAllFeeds()>
		<cfset rc.qryFeeds = FeedStruct.qAllFeeds>
		<cfset rc.qryTopFeeds = FeedStruct.qTopFeeds>
		
		<cfset Event.setView("vwReader")>
	</cffunction>

	<!--- INformative --->
	<cffunction name="dspInfo" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehLogin = "ehUser.dspLogin">
		<cfset rc.xehSignup = "ehUser.dspSignUp">
		<cfset rc.xehUpdateProfile = "ehUser.doUpdateProfile">
		
		<cfset Event.setView("vwInfo")>
	</cffunction>

<!------------------------------------------ DEPENDENCIES -------------------------------------->
	
	<!--- Get User Service --->
	<cffunction name="getuserService" access="private" output="false" returntype="any" hint="Get userService">
		<cfreturn instance.userService/>
	</cffunction>		
	<!--- feedService --->
	<cffunction name="getfeedService" access="private" output="false" returntype="any" hint="Get feedService">
		<cfreturn instance.feedService/>
	</cffunction>	
	
</cfcomponent>