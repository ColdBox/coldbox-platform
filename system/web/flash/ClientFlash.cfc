<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	An abstract flash scope that can be used to build ColdBox Flash scopes
----------------------------------------------------------------------->
<cfcomponent output="false" extends="coldbox.system.web.flash.AbstractFlashScope" hint="A ColdBox client flash scope">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	
	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="ClientFlash" hint="Constructor">
    	<cfargument name="controller" 	type="any" required="true" hint="The ColdBox Controller" colddoc:generic="coldbox.system.web.Controller"/>
		<cfargument name="defaults" 	type="any" required="false" default="#structNew()#" hint="Default flash data packet for the flash RAM object=[scope,properties,inflateToRC,inflateToPRC,autoPurge,autoSave]" colddoc:generic="struct"/>
    	<cfscript>
    		super.init(argumentCollection=arguments);
			
			// Marshaller
			instance.converter = createObject("component","coldbox.system.core.conversion.ObjectMarshaller").init();
			instance.flashKey = "cbox_flash";
			
			return this;
    	</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- getFlashKey --->
	<cffunction name="getFlashKey" output="false" access="public" returntype="string" hint="Get the flash key storage used in cluster scope.">
		<cfreturn instance.flashKey>
	</cffunction>

	<!--- saveFlash --->
	<cffunction name="saveFlash" output="false" access="public" returntype="any" hint="Save the flash storage in preparing to go to the next request">
		<cfset client[getFlashKey()] = instance.converter.serializeObject( getScope() )>
		<cfreturn this>
	</cffunction>

	<!--- flashExists --->
	<cffunction name="flashExists" output="false" access="public" returntype="boolean" hint="Checks if the flash storage exists and IT HAS DATA to inflate.">
		<cfscript>
    		// Check if session is defined first
    		if( NOT isDefined("client") ) { return false; }
			// Check if storage is set
			return ( structKeyExists(client, getFlashKey()) );
    	</cfscript>
	</cffunction>

	<!--- getFlash --->
	<cffunction name="getFlash" output="false" access="public" returntype="struct" hint="Get the flash storage structure to inflate it.">
		<!--- Check if Exists, else return empty struct --->
		<cfif flashExists()>
			<cfreturn instance.converter.deserializeObject(client[getFlashKey()])>
		</cfif>
		
		<cfreturn structnew()>
	</cffunction>
	
	<!--- removeFlash --->
    <cffunction name="removeFlash" output="false" access="public" returntype="any" hint="Remove the entire flash storage">
    	<cfset structDelete(client,getFlashKey())>
		<cfreturn this>
    </cffunction>

</cfcomponent>