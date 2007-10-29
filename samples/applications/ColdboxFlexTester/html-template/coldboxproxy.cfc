<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This proxy is an inherited coldbox remote proxy used for enabling
	coldbox as a model framework.
	
	What are the methods I can override for my own usage:
	
	process : process a coldbox event
	announceInterception : announce an interception
	getSetting : get a configuration setting from the app or framework
	getColdboxSettings : get the entire framework configuration structure
	getConfigSettings : get the entire application settings structure.
	
----------------------------------------------------------------------->
<cfcomponent name="coldboxproxy" output="false" extends="coldbox.system.extras.ColdboxProxy">

	<!--- You can override this method if you want to intercept before and after. --->
	<cffunction name="process" output="false" access="remote" returntype="any" hint="Process a remote call and return data/objects back.">
		<cfset var results = "">
		
		<!--- Anything before --->
		
		<!--- Call the actual proxy --->
		<cfset results = super.process(argumentCollection=arguments)>
		
		<!--- Anything after --->
		
		<cfreturn results>
	</cffunction>
	
	<!--- Get a setting --->
	<cffunction name="getSetting" hint="I get a setting from the FW Config structures. Use the FWSetting boolean argument to retrieve from the fwSettingsStruct." access="remote" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="name" 	    type="string"   	hint="Name of the setting key to retrieve"  >
		<cfargument name="FWSetting"  	type="boolean" 	 	required="false"  hint="Boolean Flag. If true, it will retrieve from the fwSettingsStruct else from the configStruct. Default is false." default="false">
		<!--- ************************************************************* --->
		<cfscript>
			var cbController = "";
			var setting = "";
			
			//Verify the coldbox app is ok, else throw
			if ( verifyColdBox() ){
				cbController = application.cbController;
			}
			
			//Get Setting else return ""
			if( cbController.settingExists(argumentCollection=arguments) ){
				setting = cbController.getSetting(argumentCollection=arguments);
			}
			
			//Get settings
			return setting;
		</cfscript>
	</cffunction>
	
	<!--- Get ColdBox Settings --->
	<cffunction name="getColdboxSettings" access="remote" returntype="struct" output="false" hint="I retrieve the ColdBox Settings Structure by Reference">
		<cfscript>
			var cbController = "";
			
			//Verify the coldbox app is ok, else throw
			if ( verifyColdBox() ){
				cbController = application.cbController;
			}
			
			//Get settings
			return cbController.getColdboxSettings();
		</cfscript>
	</cffunction>
	
	<!--- Get ColdBox Settings --->
	<cffunction name="getConfigSettings" access="remote" returntype="struct" output="false" hint="I retrieve the Config Settings Structure by Reference">
		<cfscript>
			var cbController = "";
			
			//Verify the coldbox app is ok, else throw
			if ( verifyColdBox() ){
				cbController = application.cbController;
			}
			
			//Get settings
			return cbController.getConfigSettings();
		</cfscript>
	</cffunction>
</cfcomponent>