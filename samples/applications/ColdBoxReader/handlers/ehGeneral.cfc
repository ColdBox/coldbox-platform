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

	<cffunction name="onRequestStart" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSearch = "ehFeed.doSearchByTerm">
		<cfif not structKeyExists(session, "oUserBean")>
			<cfset session.oUserBean = getUserService().createUserBean()>
		</cfif>
	</cffunction>

	<cffunction name="onException" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- My own Exception Handler --->
		<!--- Log error --->
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

	<cffunction name="dspStart" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehReader = "ehGeneral.dspReader">
		<cfset Event.setView("vwMain")>
	</cffunction>

	<cffunction name="dspReader" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var obj = getFeedService()>
		<cfset var FeedStruct = structnew()>
		<cfset var rc = Event.getCollection()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehViewFeed = "ehFeed.dspViewFeed">
		<cfset rc.xehShowTags = "ehFeed.dspAllTags">
		<cfset rc.xehShowInfo = "ehGeneral.dspInfo">
		<cfset rc.xehAccountActions = "ehUser.dspAccountActions">
		<!--- Get Feeds --->
		<cfset FeedStruct = obj.getAllFeeds()>
		<cfset rc.qryFeeds = FeedStruct.qAllFeeds>
		<cfset rc.qryTopFeeds = FeedStruct.qTopFeeds>
		<cfset Event.setView("vwReader")>
	</cffunction>

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
	<cffunction name="setuserService" access="private" output="false" returntype="void" hint="Set userService">
		<cfargument name="userService" type="any" required="true"/>
		<cfset instance.userService = arguments.userService/>
	</cffunction>
	
	<!--- feedService --->
	<cffunction name="getfeedService" access="private" output="false" returntype="any" hint="Get feedService">
		<cfreturn instance.feedService/>
	</cffunction>	
	<cffunction name="setfeedService" access="private" output="false" returntype="void" hint="Set feedService">
		<cfargument name="feedService" type="any" required="true"/>
		<cfset instance.feedService = arguments.feedService/>
	</cffunction>
	
</cfcomponent>