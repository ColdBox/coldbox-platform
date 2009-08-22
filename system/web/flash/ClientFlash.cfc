<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	An abstract flash scope that can be used to build ColdBox Flash scopes
----------------------------------------------------------------------->
<cfcomponent output="false" extends="coldbox.system.web.flash.AbstractFlashScope" hint="A ColdBox client flash scope">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="ClientFlash" hint="Constructor">
    	<cfargument name="controller" type="coldbox.system.Controller" required="true" hint="The ColdBox Controller"/>
    	<cfscript>
    		super.init(arguments.controller);
			
			// Marshaller
			instance.converter = createObject("component","coldbox.system.core.util.conversion.ObjectMarshaller").init();
			instance.flashKey = "cbox_flash";
			
			return this;
    	</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- clear --->
    <cffunction name="clear" output="false" access="public" returntype="void" hint="Clear the flash scope and remove all data">
    	<cfscript>
    		if( isStorageAttached() ){
				serializeToScope(structnew());
			}
    	</cfscript>
    </cffunction>
	
	<!--- put --->
    <cffunction name="put" output="false" access="public" returntype="void" hint="Put an object in flash scope">
    	<cfargument name="name"  type="string" required="true" hint="The name of the value"/>
		<cfargument name="value" type="any" required="true" default="" hint="The value to store"/>
		<cfscript>
			var scope = getScope();
			// save and serialize again
			scope[arguments.name] = arguments.value;
			serializeToScope(scope);
		</cfscript>
    </cffunction>
	
	<!--- putAll --->
    <cffunction name="putAll" output="false" access="public" returntype="void" hint="Put a map of name-value pairs into the flash scope overriding if possible.">
    	<cfargument name="map" type="struct" required="true" default="" hint="The map of "/>
   		<cfscript>
			var scope = getScope();
			
			structAppend(scope, arguments.map);
			serializeToScope(scope);
			
		</cfscript>
    </cffunction>
	
	<!--- remove --->
    <cffunction name="remove" output="false" access="public" returntype="boolean" hint="Remove an object from flash scope">
    	<cfargument name="name"  type="string" required="true" hint="The name of the value"/>
    	<cfscript>
			var results = false;
			var scope = getScope();
			
			if( isStorageAttached() ){
				results = structDelete(scope,arguments.name,true);
				if( results ){
					serializeToScope(scope);
				}
			}
			
			return results;
		</cfscript>
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
    	<cfset structKeyList(getScope())>
    </cffunction>

	<!--- getFlashKey --->
    <cffunction name="getFlashKey" output="false" access="public" returntype="string" hint="Get the flash key">
    	<cfreturn instance.flashKey>
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- serializeScope --->
    <cffunction name="serializeToScope" output="false" access="private" returntype="void" hint="Serialize and save the scope">
    	<cfargument name="scope" type="struct" required="true" hint="The struct to serialize into the client flash scope"/>
		<cfset client[getFlashKey()] = instance.converter.serializeObject(arguments.scope)>
    </cffunction>

	<!--- ensureStorage --->
    <cffunction name="ensureStorage" output="false" access="private" returntype="struct" hint="Makes sure the storage is created else create and return it.">
    	<!--- If not created, then create Storage --->
		<cfif NOT isStorageAttached()>
    		<cfset serializeToScope(structnew())>
		</cfif>
		
		<!--- Deserialize Scope --->
		<cfreturn instance.converter.deserializeObject(client[getFlashKey()])>
    </cffunction>

	<!--- isStorageAttached --->
    <cffunction name="isStorageAttached" output="false" access="private" returntype="boolean" hint="Checks if the storage in the session scope is attached, else returns false">
    	<cfreturn structKeyExists(client,getFlashKey())>
    </cffunction>

</cfcomponent>