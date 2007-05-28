<cfsetting enablecfoutputonly="yes">
<!-----------------------------------------------------------------------
Template :  index.cfm 
Author 	 :	Luis Majano
Date     :	September 15, 2005
Description : 			
	This is the index file of your application. This template just needs
	a cfinclude to the frameworks coldbox file. You do not need to modify
	this file.
----------------------------------------------------------------------->
<!--- Use the override variable below to load a specific coldbox config file.
This is very useful in multi-tiered environments or just plain o'l fun

Note: Uses a relative path, it will be expanded by ColdBox, unless
it is already expanded. In other words, relative or absolute path.

<cfset COLDBOX_CONFIG_FILE="">
--->
<cfinclude template="/coldbox/system/coldbox.cfm">
<cfsetting enablecfoutputonly="no">
