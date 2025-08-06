<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
A public error template that just shows that an exception occurred.
----------------------------------------------------------------------->
<cfoutput>
<!--- StyleSheets --->
<style type="text/css"><cfinclude template="/coldbox/system/exceptions/css/cbox-debugger.css.cfm"></style>
<!--- Exception Container --->
<div class="cb-container">
	<h1>
		<!--- Exception Error Code --->
		<cfif oException.geterrorCode() neq "" AND oException.getErrorCode() neq 0>
			#oException.getErrorCode()# :
		</cfif>
		Oopsy! Something went wrong!
	</h1>

	<!--- The error notice --->
	<div class="notice">
		<!--- CUSTOM SET MESSAGE --->
		<cfif oException.getExtraMessage() neq "">
			<h3>#oException.getExtramessage()#</h3>
		</cfif>

		<!--- ERROR TYPE --->
		<cfif oException.getType() neq "">
			<strong>Type: </strong> #oException.gettype()# <br>
		</cfif>

		<!--- ERROR exception struct --->
		<cfif isStruct( oException.getExceptionStruct() ) >
			<strong>Messages:</strong>
			#oException.getMessage()#
		</cfif>
	</div>

	<div style="margin:10px; color:gray">
		<em>* The full robust errors can be seen by switching the <strong>customErrorTemplate</strong> in your configuration file</em>
	</div>
</div>
</cfoutput>
