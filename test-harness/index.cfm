<cfsetting enablecfoutputonly="yes">
<cfsetting showdebugoutput="false">
<!-----------------------------------------------------------------------
Template :  index.cfm
Author 	 :	Luis Majano
Date     :	October 15, 2005
Description :
	This is only a place holder since everything occurs in application.cfc now.
----------------------------------------------------------------------->
<cfoutput>
	<div>
		Total Request Time: #numberFormat( getTickCount() - request.fwRequestStart )#ms <br>
		WireBox Mappings: #application.wirebox.getBinder().getMappings().len()#
	</div>
</cfoutput>
<cfsetting enablecfoutputonly="no">