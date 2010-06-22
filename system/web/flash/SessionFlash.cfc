<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	An abstract flash scope that can be used to build ColdBox Flash scopes.
	
	This flash scope is smart enought to not create unecessary session variables
	unless data is put in it.  Else, it does not abuse session.
----------------------------------------------------------------------->
<cfcomponent output="false" extends="coldbox.system.web.flash.AbstractFlashScope" hint="A ColdBox session flash scope">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="SessionFlash" hint="Constructor">
    	<cfargument name="controller" type="coldbox.system.web.Controller" required="true" hint="The ColdBox Controller"/>
    	<cfscript>
    		super.init(arguments.controller);
			
			instance.flashKey = "cbox_flash_scope";
			
			return this;
    	</cfscript>
    </cffunction>

<!------------------------------------------- IMPLEMENTED METHODS ------------------------------------------>

	<!--- getFlashKey --->
	<cffunction name="getFlashKey" output="false" access="public" returntype="string" hint="Get the flash key storage used in session scope.">
		<cfreturn instance.flashKey>
	</cffunction>

	<!--- saveFlash --->
	<cffunction name="saveFlash" output="false" access="public" returntype="void" hint="Save the flash storage in preparing to go to the next request">
		<!--- Init The Storage if not Created --->
		<cfif NOT flashExists()>
    		<cflock scope="session" throwontimeout="true" timeout="20">
				<cfif NOT flashExists()>
					<cfset session[getFlashKey()] = structNew()>
				</cfif>
			</cflock>	
		</cfif>
		
		<!--- Now Save the Storage --->
		<cfset session[getFlashKey()] = getScope()>
	</cffunction>

	<!--- flashExists --->
	<cffunction name="flashExists" output="false" access="public" returntype="boolean" hint="Checks if the flash storage exists and IT HAS DATA to inflate.">
		<cfscript>
    		// Check if session is defined first
    		if( NOT isDefined("session") ) { return false; }
			// Check if storage is set and not empty
			return ( structKeyExists(session, getFlashKey()) AND NOT structIsEmpty(session[getFlashKey()]) );
    	</cfscript>
	</cffunction>

	<!--- getFlash --->
	<cffunction name="getFlash" output="false" access="public" returntype="struct" hint="Get the flash storage structure to inflate it.">
		<!--- Check if Exists, else return empty struct --->
		<cfif flashExists()>
			<cfreturn session[getFlashKey()]>
		</cfif>
		
		<cfreturn structnew()>
	</cffunction>
	
	<!--- removeFlash --->
    <cffunction name="removeFlash" output="false" access="public" returntype="void" hint="Remove the entire flash storage">
    	<cfset structDelete(session, getFlashKey())>
    </cffunction>

</cfcomponent>