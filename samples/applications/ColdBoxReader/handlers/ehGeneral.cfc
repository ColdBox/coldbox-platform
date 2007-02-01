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
<cfcomponent name="ehGeneral" extends="coldbox.system.eventhandler">

	<cffunction name="onAppStart" access="public" returntype="void" output="false">
		<!--- Instantiate ColdBox Service --->
		<cfset application.IOCEngine = createObject("component","coldspring.beans.DefaultXmlBeanFactory").init(structnew(),getSettingStructure())/>
		<cfset application.IOCEngine.loadBeansFromXmlFile(expandPath(getSetting("IOCDefinitionFile")))/>
	</cffunction>
	
	<cffunction name="onRequestStart" access="public" returntype="void" output="false">
		<!--- Session param --->
		<cfparam name="session.userID" 		default="">
		<cfparam name="session.username" 	default="">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehSearch = "ehFeed.doSearchByTerm">
		<cfif not structKeyExists(session, "oUserBean")>
			<cfset session.oUserBean = application.IOCEngine.getBean("UserService").createUserBean()>
		</cfif>
	</cffunction>

	<cffunction name="onException" access="public" returntype="void" output="false">
		<!--- My own Exception Handler --->
		<!--- Log error --->
		<cfset var exceptionBean = getValue("ExceptionBean")>
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
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehReader = "ehGeneral.dspReader">
		<cfset setView("vwMain")>
	</cffunction>

	<cffunction name="dspReader" access="public" returntype="void" output="false">
		<cfset var obj = application.IOCEngine.getBean("feedService")>
		<cfset var FeedStruct = structnew()>
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehViewFeed = "ehFeed.dspViewFeed">
		<cfset rc.xehShowTags = "ehFeed.dspAllTags">
		<cfset rc.xehShowInfo = "ehGeneral.dspInfo">
		<cfset rc.xehAccountActions = "ehUser.dspAccountActions">
		<!--- Get Feeds --->
		<cfset FeedStruct = obj.getAllFeeds()>
		<cfset rc.qryFeeds = FeedStruct.qAllFeeds>
		<cfset rc.qryTopFeeds = FeedStruct.qTopFeeds>
		<cfset setView("vwReader")>
	</cffunction>

	<cffunction name="dspInfo" access="public" returntype="void" output="false">
		<!--- EXIT HANDLERS: --->
		<cfset rc.xehLogin = "ehUser.dspLogin">
		<cfset rc.xehSignup = "ehUser.dspSignUp">
		<cfset setView("vwInfo")>
	</cffunction>


</cfcomponent>