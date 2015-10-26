<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
A public error template that just shows that an exception ocurred.
----------------------------------------------------------------------->
<cfoutput>
<!--- StyleSheets --->
<style type="text/css"><cfinclude template="/coldbox/system/includes/css/cbox-debugger.css.cfm"></style>
<div class="cb-container">
	<h1>
		<cfif oException.geterrorCode() neq "" AND oException.getErrorCode() neq 0>
			#oException.getErrorCode()# :
		</cfif>
		Oopsy! Something went wrong!</h1>

	<div class="notice">
		<cfif oException.getExtraMessage() neq "">
		<!--- CUSTOM SET MESSAGE --->
		<h3>#oException.getExtramessage()#</h3>
		</cfif>

		<!--- ERROR TYPE --->
		<cfif oException.getType() neq "">
			<strong>Type: </strong> #oException.gettype()# <br>
		</cfif>

		<!--- ERROR oExceptionS --->
		<cfif isStruct(oException.getExceptionStruct()) >
			<strong>Messages:</strong>
			#oException.getmessage()#
		</cfif>
	</div>

	<div style="margin:10px; color:gray">
		<em>* The full robust errors can be seen by switching the <strong>coldbox.customErrorTemplate</strong> in your configuration file (/config/ColdBox.cfc) to "/coldbox/system/includes/BugReport.cfm" and reloading the application.</em>
	</div>
</div>
</cfoutput>