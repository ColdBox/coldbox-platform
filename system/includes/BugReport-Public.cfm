<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
A public error template that just shows that an exception ocurred.
----------------------------------------------------------------------->
<cfoutput>
<!--- StyleSheets --->
<style type="text/css"><cfinclude template="/coldbox/system/includes/css/cbox-debugger.css.cfm"></style>
<div class="fw_errorDiv">
	<h1>Oopsy! An Exception Was Encountered</h1>

	<div class="fw_errorNotice">
		<!--- CUSTOM SET MESSAGE --->
		<h3>#oException.getExtramessage()#</h3>

		<!--- ERROR TYPE --->
		<cfif oException.getType() neq "">
			<strong>Error Type: </strong> #oException.gettype()# : 
			<cfif oException.geterrorCode() neq "">
				<strong>Error Code:</strong> #oException.getErrorCode()#
			</cfif>
			<br />
		</cfif>

		<!--- ERROR oExceptionS --->
		<cfif isStruct(oException.getExceptionStruct()) >
			<strong>Error Messages:</strong>
			#oException.getmessage()#
		</cfif>
	</div>

	<div style="margin:10px;color:gray">
		<em>* The full robust errors can be seen by switching the error template in your configuration.</em>
	</div>
</div>
</cfoutput>