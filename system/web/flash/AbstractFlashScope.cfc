<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	An abstract flash scope that can be used to build ColdBox Flash scopes.

In order to build scopes you must implement the following methods:

- clearFlash() A method that will destroy the flash storage
- saveFlash() A method that will be called before relocating so the storage can be saved
- flashExists() A method that tells ColdBox if the storage exists and if it has content to inflate
- getFlash() A method that returns the flash storage

All these methds can use any of the concrete methods below. The most important one is the getScope() 
method which will most likely be called by the saveFlash() method in order to persist the flashed map.

----------------------------------------------------------------------->
<cfcomponent output="false" hint="An abstract flash scope that can be used to build ColdBox Flash scopes">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="AbstractFlashScope" hint="Constructor">
    	<cfargument name="controller" type="coldbox.system.Controller" required="true" hint="The ColdBox Controller"/>
    	<cfscript>
    		instance.controller = arguments.controller;
			return this;
    	</cfscript>
    </cffunction>
	
<!------------------------------------------- OVERRIDE THESE METHODS ------------------------------------------>

	<!--- clearFlash --->
	<cffunction name="clearFlash" output="false" access="public" returntype="void" hint="Clear the flash storage">
	</cffunction>

	<!--- saveFlash --->
	<cffunction name="saveFlash" output="false" access="public" returntype="void" hint="Save the flash storage in preparing to go to the next request">
	</cffunction>

	<!--- flashExists --->
	<cffunction name="flashExists" output="false" access="public" returntype="boolean" hint="Checks if the flash storage exists and IT HAS DATA to inflate.">
	</cffunction>

	<!--- getFlash --->
	<cffunction name="getFlash" output="false" access="public" returntype="struct" hint="Get the flash storage structure to inflate it.">
	</cffunction>

<!------------------------------------------- CONCRETE METHODS ------------------------------------------>

	<!--- inflateToRC --->
	<cffunction name="inflateFlash" output="false" access="public" returntype="void" hint="Inflate the flash storage into the request collection and request temp storage">
		<cfscript>
			var event = getController().getRequestService().getContext();
			var flash = getFlash();
			
			// Append flash into request collection.
			event.collectionAppend(collection=flash,overwrite=true);
			// Append flash to temp flash request storage
			putAll(flash);
			
			// Clear Flash Storage
			clearFlash();
		</cfscript>
	</cffunction>

	<!--- getScope --->
	<cffunction name="getScope" output="false" access="public" returntype="struct" hint="Get the flash temp request storage used throughout a request until flashed at the end of a request.">
		<cfscript>
			if( NOT structKeyExists(request,"cbox_flash_temp_storage") ){
				request["cbox_flash_temp_storage"] = structnew();
			}
			
			return request["cbox_flash_temp_storage"];
		</cfscript>
	</cffunction>
	
	<!--- getKeys --->
    <cffunction name="getKeys" output="false" access="public" returntype="string" hint="Get a list of all the objects in the temp flash scope">
    	<cfreturn structKeyList(getScope())>
	</cffunction>	

	<!--- clear --->
    <cffunction name="clear" output="false" access="public" returntype="void" hint="Clear the temp flash scope and remove all data">
		<cfset structClear(getScope())>
    </cffunction>
	
	<!--- put --->
    <cffunction name="put" output="false" access="public" returntype="void" hint="Put an object in temp flash scope">
    	<cfargument name="name"  type="string" required="true" hint="The name of the value"/>
		<cfargument name="value" type="any" required="true" default="" hint="The value to store"/>
		<cfargument name="saveNow" type="boolean" required="false" default="false" hint="Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation"/>
		<cfscript>
			var scope = getScope();
			scope[arguments.name] = arguments.value;
			
			if( arguments.saveNow ){ saveFlash(); }
		</cfscript>
    </cffunction>
	
	<!--- putAll --->
    <cffunction name="putAll" output="false" access="public" returntype="void" hint="Put a map of name-value pairs into the flash scope">
    	<cfargument name="map" type="struct" required="true" default="" hint="The map of "/>
		<cfargument name="saveNow" type="boolean" required="false" default="false" hint="Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation"/>
		<cfscript>
			structAppend(getScope(),arguments.map);
			if( arguments.saveNow ){ saveFlash(); }
		</cfscript>
    </cffunction>
	
	<!--- remove --->
    <cffunction name="remove" output="false" access="public" returntype="void" hint="Remove an object from flash scope">
    	<cfargument name="name"  type="string" required="true" hint="The name of the value"/>
		<cfargument name="saveNow" type="boolean" required="false" default="false" hint="Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation"/>
		<cfscript>
			structDelete(getScope(),arguments.name);
			if( arguments.saveNow ){ saveFlash(); }
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
  		<cfargument name="default" type="any"    required="false" hint="The default value if the scope does not have the object"/>
		<cfset var scope = getScope()>
		
		<cfif exists(arguments.name)>
			<cfreturn scope[arguments.name]>
		</cfif>
		
		<cfif structKeyExists(arguments,"default")>
			<cfreturn arguments.default>
		</cfif>
		
		<cfthrow message="#arguments.name# not found in flash scope. Valid keys are #getKeys()#." type="#getMetadata(this).name#.KeyNotFoundException">
	</cffunction>
	
	<!--- persist --->
	<cffunction name="persistRC" output="false" access="public" returntype="void" hint="Persist keys from the coldbox request collection in flash scope. If using exclude, then it will try to persist the entire rc but excluding.  Including will only include the keys passed.">
		<cfargument name="include" type="string"  required="false" default="" hint="MUTEX: A list of request collection keys you want to persist"/>
		<cfargument name="exclude" type="string"  required="false" default="" hint="MUTEX: A list of request collection keys you want to exclude from persisting. If sent, then we inspect all rc keys."/>
		<cfargument name="saveNow" type="boolean" required="false" default="false" hint="Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation"/>
		<cfscript>
			var rc = getController().getRequestService().getContext().getCollection();
			var key = "";
			var x=1;
			var thisKey = "";
			
			// Cleanup
			arguments.include = trim(arguments.include);
			arguments.exclude = trim(arguments.exclude);
			
			// Exclude?
			if( len(trim(arguments.exclude)) ){
				for(thisKey in rc){
					// Only persist keys that are not Excluded.
					if( NOT listFindNoCase(arguments.exclude,thisKey) ){
						put(thisKey,rc[thisKey]);
					}
				}
			}
			
			// Include?
			if( len(trim(arguments.include)) ){
				for(x=1; x lte listLen(arguments.include); x=x+1){
					thisKey = listGetAt(arguments.include,x);
					// Check if key exists in RC
					if( structKeyExists(rc,thisKey) ){
						put(thisKey,rc[thisKey]);
					}
				}
			}	
			
			// Save Now?
			if( arguments.saveNow ){ saveFlash(); }		
		</cfscript>
	</cffunction>
		
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- getController --->
    <cffunction name="getController" output="false" access="private" returntype="coldbox.system.Controller" hint="Get the controller reference">
    	<cfreturn instance.controller>
    </cffunction>
	
	<!--- getUtil --->
	<cffunction name="getUtil" output="false" access="public" returntype="any" hint="Get the coldbox utility class">
		<cfreturn createObject("component","coldbox.system.core.util.Util")>
	</cffunction>

</cfcomponent>