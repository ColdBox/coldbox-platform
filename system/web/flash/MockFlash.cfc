<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	A flash scope that is used for unit testing.
----------------------------------------------------------------------->
<cfcomponent output="false" extends="coldbox.system.web.flash.AbstractFlashScope" hint="A ColdBox unit testing flash scope">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	
	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">
    	<cfargument name="controller" 	type="any" required="true" hint="The ColdBox Controller" colddoc:generic="coldbox.system.web.Controller"/>
		<cfargument name="defaults" 	type="any" required="false" default="#structNew()#" hint="Default flash data packet for the flash RAM object=[scope,properties,inflateToRC,inflateToPRC,autoPurge,autoSave]" colddoc:generic="struct"/>
    	<cfscript>
    		super.init(argumentCollection=arguments);
			
    		instance.mockFlash = structnew();
    		
			return this;
    	</cfscript>
    </cffunction>

<!------------------------------------------- IMPLEMENTED METHODS ------------------------------------------>

	<!--- get/set Mock Flash --->
	<cffunction name="getmockFlash" access="public" returntype="any" output="false" hint="Get the mock flash map">
		<cfreturn instance.mockFlash>
	</cffunction>
	<cffunction name="setmockFlash" access="public" returntype="void" output="false" hint="Override the mock flash map">
		<cfargument name="mockFlash" type="any" required="true">
		<cfset instance.mockFlash = arguments.mockFlash>
	</cffunction>

	<!--- saveFlash --->
	<cffunction name="saveFlash" output="false" access="public" returntype="any" hint="Save the flash storage in preparing to go to the next request">
		<!--- Init The Storage if not Created --->
		<cfif NOT flashExists()>
    		<cfset instance.mockFlash = structNew()>	
		</cfif>
		
		<!--- Now Save the Storage --->
		<cfset instance.mockFlash = getScope()>
		
		<cfreturn this>
	</cffunction>

	<!--- flashExists --->
	<cffunction name="flashExists" output="false" access="public" returntype="boolean" hint="Checks if the flash storage exists and IT HAS DATA to inflate.">
		<cfscript>
    		// Check if storage is set and not empty
			return ( structIsEmpty(instance.mockFlash) );
    	</cfscript>
	</cffunction>

	<!--- getFlash --->
	<cffunction name="getFlash" output="false" access="public" returntype="struct" hint="Get the flash storage structure to inflate it.">
		<!--- Check if Exists, else return empty struct --->
		<cfif flashExists()>
			<cfreturn instance.mockFlash>
		</cfif>
		
		<cfreturn structnew()>
	</cffunction>
	
	<!--- removeFlash --->
    <cffunction name="removeFlash" output="false" access="public" returntype="any" hint="Remove the entire flash storage">
    	<cfset structDelete(instance, "mockFlash")>
		<cfreturn this>
    </cffunction>

</cfcomponent>