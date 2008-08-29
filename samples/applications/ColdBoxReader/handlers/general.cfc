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
<cfcomponent name="general" extends="coldbox.system.eventhandler" output="false" autowire="true">

	<!--- Dependency Injections --->
	<cfproperty name="userService" type="ioc" scope="instance" />
	<cfproperty name="feedService" type="ioc" scope="instance" />

	<!--- Start Page --->
	<cffunction name="dspStart" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehReader = "general.dspReader">
		
		<!--- Commented Out, because we use Implicit Views: general.dspStart = general/dspStart --->
		<!--- <cfset Event.setView("general/dspStart")> --->
	</cffunction>

	<!--- Reader --->
	<cffunction name="dspReader" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var FeedStruct = structnew()>
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehViewFeed = "feed.dspViewFeed">
		<cfset rc.xehShowTags = "feed.dspAllTags">
		<cfset rc.xehShowInfo = "general.dspInfo">
		<cfset rc.xehAccountActions = "user.dspAccountActions">
		
		<!--- Get Feeds --->
		<cfset FeedStruct = getFeedService().getAllFeeds()>
		<cfset rc.qryFeeds = FeedStruct.qAllFeeds>
		<cfset rc.qryTopFeeds = FeedStruct.qTopFeeds>
		
		<!--- Implicit View --->
		<!--- <cfset Event.setView("vwReader")> --->
	</cffunction>

	<!--- INformative --->
	<cffunction name="dspInfo" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var rc = Event.getCollection()>
		
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehLogin = "user.dspLogin">
		<cfset rc.xehSignup = "user.dspSignUp">
		<cfset rc.xehUpdateProfile = "user.doUpdateProfile">
		
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