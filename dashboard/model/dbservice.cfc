<cfcomponent output="false" displayname="dbservice" hint="I am the Dashboard Service.">

	<!--- Constructor --->
	<cfset variables.instance = structnew()>

	<cffunction name="init" access="public" returntype="dbservice" output="false">
		<cfset instance.settings = CreateObject("component","settings").init()>
		<cfset instance.fwsettings = CreateObject("component","fwsettings").init()>
		<cfreturn this>
	</cffunction>

	<cffunction name="get" access="public" returntype="any" output="false">
		<cfargument name="model" required="true" type="string" >
		<cfreturn instance["#arguments.model#"]>
	</cffunction>

	<cffunction name="sendbugreport" access="public" returntype="void" output="false">
		<cfargument name="requestCollection" required="true" type="any" >
		<cfargument name="fwSettings"		 required="true" type="any">
		<cfargument name="OS" 				 required="true" type="string">
		<!--- Send Bug Report. --->
		<cfset var myBugreport = "">
		<!--- Save the Report --->
		<cfsavecontent variable="mybugreport">
		<cfoutput>
		=========================================================
		BUG DETAILS
		=========================================================
		Date: #dateFormat(now(),"mmmm dd, YYYY")#
		Time: #TimeFormat(now(), "long")#
		From: #arguments.requestCollection.name#
		=========================================================
		BUG REPORT
		=========================================================
		#arguments.requestCollection.bugreport#
		=========================================================
		COLDBOX DETAILS
		=========================================================
		Version:    #arguments.fwSettings.version#
		Codename:   #arguments.fwSettings.codename#
		Suffix:     #arguments.fwSettings.suffix#
		O.S:        #arguments.OS#
		CF Engine:  #server.ColdFusion.ProductName#
		CF Version: #server.ColdFusion.ProductVersion#
		=========================================================
		</cfoutput>
		</cfsavecontent>
		<!--- Send the bug report --->
		<cfmail to="bugs@coldboxframework.com"
				from="#arguments.requestCollection.email#"
				subject="Bug Report">
		#mybugreport#
		</cfmail>
	</cffunction>

</cfcomponent>