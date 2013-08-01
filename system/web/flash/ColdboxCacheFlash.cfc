<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	An abstract flash scope that can be used to build ColdBox Flash scopes.
	
	This flash scope uses the coldbox cache
----------------------------------------------------------------------->
<cfcomponent output="false" extends="coldbox.system.web.flash.AbstractFlashScope" hint="A ColdBox cache flash scope">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	
	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="ColdboxCacheFlash" hint="Constructor">
    	<cfargument name="controller" 	type="any" required="true" hint="The ColdBox Controller" colddoc:generic="coldbox.system.web.Controller"/>
		<cfargument name="defaults" 	type="any" required="false" default="#structNew()#" hint="Default flash data packet for the flash RAM object=[scope,properties,inflateToRC,inflateToPRC,autoPurge,autoSave]" colddoc:generic="struct"/>
    	<cfscript>
    		var cacheName = "default";
			
			super.init(argumentCollection=arguments);
			
    		// get the cacheName from the custom settings: left for compatibility
			if( arguments.controller.settingExists("flashRAM_cacheName") ){
				cacheName = arguments.controller.getSetting("flashRAM_cacheName");
			}
			// check via properties
			if( propertyExists("cacheName") ){
				cacheName = getProperty("cacheName");
			}			
			
			// Setup the cache
			instance.cache = arguments.controller.getColdboxOCM(cacheName);
			
			// Check jsession id First
			if( isDefined("session") and structKeyExists(session,"sessionid") ){
				instance.flashKey = "cbox_flash_" & session.sessionid;
			}
			// Check normal cfid and cftoken in cookie
			else if( structKeyExists(cookie,"CFID") AND structKeyExists(cookie,"CFTOKEN") ){
				instance.flashKey = "cbox_flash_" & hash(cookie.cfid & cookie.cftoken);
			}
			else{
				getUtil().throwit(message="Cannot find a jsessionid, or cfid/cftoken in the cookie scope. Please verify",type="ColdboxCacheFlash.CFIDException");
			}
			
			return this;
    	</cfscript>
    </cffunction>

<!------------------------------------------- IMPLEMENTED METHDOS ------------------------------------------>

	<!--- getFlashKey --->
	<cffunction name="getFlashKey" output="false" access="public" returntype="string" hint="Get the flash key storage used in cluster scope.">
		<cfreturn instance.flashKey>
	</cffunction>

	<!--- saveFlash --->
	<cffunction name="saveFlash" output="false" access="public" returntype="any" hint="Save the flash storage in preparing to go to the next request">
		<!--- Now Save the Storage --->
		<cfset instance.cache.set(getFlashKey(),getScope(),2)>
		<cfreturn this>
	</cffunction>

	<!--- flashExists --->
	<cffunction name="flashExists" output="false" access="public" returntype="boolean" hint="Checks if the flash storage exists and IT HAS DATA to inflate.">
		<cfreturn instance.cache.lookup(getFlashKey())>
	</cffunction>

	<!--- getFlash --->
	<cffunction name="getFlash" output="false" access="public" returntype="struct" hint="Get the flash storage structure to inflate it.">
		<!--- Check if Exists, else return empty struct --->
		<cfif flashExists()>
			<cfreturn instance.cache.get(getFlashKey())>
		</cfif>
		
		<cfreturn structnew()>
	</cffunction>
	
	<!--- removeFlash --->
    <cffunction name="removeFlash" output="false" access="public" returntype="any" hint="Remove the entire flash storage">
    	<cfset instance.cache.clear(getFlashKey())>
		<cfreturn this>
    </cffunction>

</cfcomponent>