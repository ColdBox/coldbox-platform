<!-----------------------------------------------------------------------
Template :  Application.cfm 
Author 	 :	Luis Majano
Date     :	January 22, 2006
Description : 			
	This is a protection Application cfm for the config file.
----------------------------------------------------------------------->
<cfif listlast(cgi.script_name, "/") is "config.xml.cfm" or listlast(cgi.script_name, "/") is "coldbox.xml.cfm">
	<cfabort>
</cfif>
