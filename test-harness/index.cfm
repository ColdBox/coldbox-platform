<cfsetting enablecfoutputonly="yes">
<cfsetting showdebugoutput="false">
<!-----------------------------------------------------------------------
Template :  index.cfm
Author 	 :	Luis Majano
Date     :	October 15, 2005
Description :
	This is only a place holder since everything occurs in application.cfc now.
----------------------------------------------------------------------->
<cfdump var="Total Request Time: #numberFormat( getTickCount() - request.fwRequestStart )#ms" output="console">
<cfdump var="WireBox Mappings: #structCount( application.wirebox.getBinder().getMappings() )#" output="console">
<cfsetting enablecfoutputonly="no">