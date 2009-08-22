<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
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
    	<cfargument name="controller" type="coldbox.system.Controller" required="true" hint="The ColdBox Controller"/>
    	<cfscript>
    		super.init(arguments.controller);
			
			instance.flashKey = "cbox_flash";
			
			return this;
    	</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- clear --->
    <cffunction name="clear" output="false" access="public" returntype="void" hint="Clear the flash scope and remove all data">
    	<cfset structClear(getScope())>
    </cffunction>
	
	<!--- put --->
    <cffunction name="put" output="false" access="public" returntype="void" hint="Put an object in flash scope">
    	<cfargument name="name"  type="string" required="true" hint="The name of the value"/>
		<cfargument name="value" type="any" required="true" default="" hint="The value to store"/>
		<cfset var scope = ensureStorage()>
		<cfset scope[arguments.name] = arguments.value>
    </cffunction>
	
	<!--- putAll --->
    <cffunction name="putAll" output="false" access="public" returntype="void" hint="Put a map of name-value pairs into the flash scope overriding if possible.">
    	<cfargument name="map" type="struct" required="true" default="" hint="The map of "/>
		<cfset structAppend(ensureStorage(),arguments.map)>
    </cffunction>
	
	<!--- remove --->
    <cffunction name="remove" output="false" access="public" returntype="boolean" hint="Remove an object from flash scope">
    	<cfargument name="name"  type="string" required="true" hint="The name of the value"/>
    	<cfreturn structDelete(getScope(),arguments.name,true)>
	</cffunction>
	
	<!--- exists --->
    <cffunction name="exists" output="false" access="public" returntype="boolean" hint="Check if an object exists in flash scope">
    	<cfargument name="name"  type="string" required="true" hint="The name of the value"/>
    	<cfreturn structKeyExists(getScope(),arguments.name)>
	</cffunction>

	<!--- size --->
    <cffunction name="size" output="false" access="public" returntype="numeric" hint="Get the size of the items in flash scope">
    	<cfreturn structCount(getScope())>
    </cffunction>
	
	<!--- isEmpty --->
    <cffunction name="isEmpty" output="false" access="public" returntype="boolean" hint="Check if the flash scope is empty or not">
    	<cfreturn structIsEmpty(getScope())>
    </cffunction>
	
	<!--- get --->
    <cffunction name="get" output="false" access="public" returntype="any" hint="Get an object from flash scope">
    	<cfargument name="name"    type="string" required="true" hint="The name of the value"/>
  		<cfargument name="default" type="any"    required="false" default="NOT_FOUND" hint="The default value if the scope does not have the object"/>
		<cfscript>
			var scope = getScope();
			
			if( structKeyExists(scope,arguments.name) ){
				return scope[arguments.name];
			}
			
			return arguments.default;
		</cfscript>
	</cffunction>
	
	<!--- getScope --->
    <cffunction name="getScope" output="false" access="public" returntype="struct" hint="Get all the name-value pairs in the flash scope">
    	<cfif NOT isStorageAttached()>
    		<cfreturn structnew()>
		</cfif>
		<cfreturn ensureStorage()>
    </cffunction>
	
	<!--- getKeys --->
    <cffunction name="getKeys" output="false" access="public" returntype="string" hint="Get a list of all the objects in the flash scope">
    	<cfreturn structKeyList(getScope())>
    </cffunction>

	<!--- getFlashKey --->
    <cffunction name="getFlashKey" output="false" access="public" returntype="string" hint="Get the flash key">
    	<cfreturn instance.flashKey>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- ensureStorage --->
    <cffunction name="ensureStorage" output="false" access="private" returntype="struct" hint="Makes sure the storage is created else create and return it.">
    	<cfif NOT isStorageAttached()>
    		<cflock scope="Session" throwontimeout="true" timeout="20">
				<cfif NOT isStorageAttached()>
					<cfset session[getFlashKey()] = structNew()>
				</cfif>
			</cflock>	
		</cfif>
		<cfreturn session[getFlashKey()]>
    </cffunction>

	<!--- isStorageAttached --->
    <cffunction name="isStorageAttached" output="false" access="private" returntype="boolean" hint="Checks if the storage in the session scope is attached, else returns false">
    	<cfscript>
    		// Check if session is defined first
    		if( NOT isDefined("session") ) { return false; }
			// Check if storage is set
			return structKeyExists(session, getFlashKey());
    	</cfscript>
    </cffunction>

</cfcomponent>