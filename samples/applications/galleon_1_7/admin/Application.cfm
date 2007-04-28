<!--- Galleon appnames --->
<cfset appName = "galleonForumsAdmin">
<cfset prefix = getCurrentTemplatePath()>
<cfset prefix = reReplace(prefix, "[^a-zA-Z]","","all")>
<cfset prefix = right(prefix, 64 - len(appName))>
<cfapplication name="#prefix##appName#"
			   clientmanagement="yes"
			   sessionmanagement="yes"
			   setclientcookies="true">