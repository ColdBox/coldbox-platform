<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="AbstractFlashScope" hint="Constructor">
    	<cfargument name="controller" 	type="any" required="true" hint="The ColdBox Controller" colddoc:generic="coldbox.system.web.Controller"/>
		<cfargument name="defaults" 	type="any" required="false" default="#structNew()#" hint="Default flash data packet for the flash RAM object=[scope,properties,inflateToRC,inflateToPRC,autoPurge,autoSave]" colddoc:generic="struct"/>
    	<cfscript>
			instance = {
    			controller = arguments.controller,
    			defaults   = arguments.defaults
    		};

    		// Defaults checks, just in case
    		if( NOT structKeyExists(instance.defaults,"inflateToRC") ){ instance.defaults.inflateToRC = true; }
    		if( NOT structKeyExists(instance.defaults,"inflateToPRC") ){ instance.defaults.inflateToPRC = false; }
    		if( NOT structKeyExists(instance.defaults,"autoPurge") ){ instance.defaults.autoPurge = true; }

    		// check for properties
    		if( structKeyExists(arguments.defaults, "properties") ){
    			instance.properties = arguments.defaults.properties;
    		}
    		else{
    			instance.properties = {};
    		}
			return this;
    	</cfscript>
    </cffunction>

<!------------------------------------------- OVERRIDE THESE METHODS ------------------------------------------>

	<!--- saveFlash --->
	<cffunction name="saveFlash" output="false" access="public" returntype="any" hint="Save the flash storage in preparing to go to the next request">
	</cffunction>

	<!--- flashExists --->
	<cffunction name="flashExists" output="false" access="public" returntype="boolean" hint="Checks if the flash storage exists and IT HAS DATA to inflate.">
	</cffunction>

	<!--- getFlash --->
	<cffunction name="getFlash" output="false" access="public" returntype="struct" hint="Get the flash storage structure to inflate it.">
	</cffunction>

	<!--- removeFlash --->
    <cffunction name="removeFlash" output="false" access="public" returntype="any" hint="Remove the entire flash storage">
    </cffunction>

<!------------------------------------------- CONCRETE METHODS ------------------------------------------>

	<!--- clearFlash --->
	<cffunction name="clearFlash" output="false" access="public" returntype="any" hint="Clear the flash storage">
		<cfscript>
			var x			= 1;
			var scope 		= "";
			var scopeKeys	= [];
			var scopeKeysLen = 0;

			// Check if flash exists
			if( flashExists() ){
				// Get pointer to flash scope
				scope = getFlash();
				scopeKeys = listToArray( structKeyList( scope ) );
				scopeKeysLen = arrayLen( scopeKeys );
				// iterate over keys and purge
				for(x=1; x lte scopeKeysLen; x++){
					// check if purging and remove
					if( structKeyExists(scope, scopeKeys[x]) AND scope[ scopeKeys[x] ].autoPurge ){
						structDelete(scope, scopeKeys[x]);
					}
				}
				// Destroy if empty
				if( structIsEmpty(scope) ){
					removeFlash();
				}
			}
			return this;
		</cfscript>
	</cffunction>

	<!--- inflateToRC --->
	<cffunction name="inflateFlash" output="false" access="public" returntype="any" hint="Inflate the flash storage into the request collection and request temp storage">
		<cfscript>
			var event 		= getController().getRequestService().getContext();
			var keep 		= false;
			var flash 		= getFlash();
			var x			= 1;
			var scopeKeys	= listToArray( structKeyList( flash ) );
			var scopeKeysLen = arrayLen( scopeKeys );
			var thisKey		= "";

			// Inflate only kept flash variables, other ones are marked for discard.
			for(x=1; x lte scopeKeysLen; x++){
				// check if key exists and inflating
				if( structKeyExists(flash, scopeKeys[x] ) AND flash[ scopeKeys[x] ].keep ){
					thisKey = flash[ scopeKeys[x] ];
					// Keep = true if autoPurge is false, because we need to keep it around.
					if( NOT thisKey.autoPurge ){ keep = true; }
					else{ keep = false; }
					// Save and mark for cleaning if content exists
					if( structKeyExists( thisKey, "content") ){
						// Inflate into RC?
						if( thisKey.inflateToRC ){
							event.setValue(name=scopeKeys[x],value=thisKey.content);
						}
						// Inflate into PRC?
						if( thisKey.inflateToPRC ){
							event.setValue(name=scopeKeys[x],value=thisKey.content,private=true);
						}	
						put(name=scopeKeys[x],
							value=thisKey.content,
							keep=keep,
							autoPurge=thisKey.autoPurge,
							inflateToRC=thisKey.inflateToRC,
							inflateToPRC=thisKey.inflateToPRC);
					}
				}
			}

			// Clear Flash Storage
			clearFlash();

			return this;
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
    <cffunction name="clear" output="false" access="public" returntype="any" hint="Clear the temp flash scope and remove all data">
		<cfset structClear(getScope())>
		<cfreturn this>
    </cffunction>

	<!--- keep --->
    <cffunction name="keep" output="false" access="public" returntype="any" hint="Keep all or a single flash temp variable alive for another relocation.">
    	<cfargument name="keys" type="string" required="false" default="" hint="The keys in the flash ram that you want to mark to be kept until the next relocation"/>
		<cfset statusMarks(arguments.keys,true)>
		<cfset saveFlash()>
		<cfreturn this>
    </cffunction>

	<!--- discard --->
    <cffunction name="discard" output="false" access="public" returntype="any" hint="Mark for discard all or a single flash temp variable for another relocation. You can also remove them if you like.">
    	<cfargument name="keys" type="string" required="false" default="" hint="The keys in the flash ram that you want to be discarded until the next relocation"/>
		<cfset statusMarks(arguments.keys,false)>
		<cfreturn this>
    </cffunction>

	<!--- put --->
    <cffunction name="put" output="false" access="public" returntype="any" hint="Put an object in temp flash scope">
    	<cfargument name="name"  		type="string" 	required="true"  hint="The name of the value"/>
		<cfargument name="value" 		type="any" 		required="true"  hint="The value to store"/>
		<cfargument name="saveNow" 		type="boolean" 	required="false" default="false" hint="Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation"/>
		<cfargument name="keep" 		type="boolean" 	required="false" default="true" hint="Whether to mark the entry to be kept after saving to the flash storage."/>
		<cfargument name="inflateToRC"  type="boolean"  required="false" default="#instance.defaults.inflateToRC#" hint="Whether this flash variable is inflated to the Request Collection or not"/>
		<cfargument name="inflateToPRC" type="boolean"  required="false" default="#instance.defaults.inflateToPRC#" hint="Whether this flash variable is inflated to the Private Request Collection or not"/>
		<cfargument name="autoPurge" 	type="boolean"  required="false" default="#instance.defaults.autoPurge#" hint="Flash memory auto purges variables for you. You can control this purging by saying false to autoPurge."/>
		<cfscript>
			var scope = getScope();
			var entry = structnew();

			// Create Flash Entry
			entry.content 		= arguments.value;
			entry.keep 			= arguments.keep;
			entry.inflateToRC 	= arguments.inflateToRC;
			entry.inflateToPRC 	= arguments.inflateToPRC;
			entry.autoPurge		= arguments.autoPurge;

			// Save entry in temp storage
			scope[arguments.name] = entry;

			// Save to storage
			if( arguments.saveNow ){ saveFlash(); }

			return this;
		</cfscript>
    </cffunction>

	<!--- putAll --->
    <cffunction name="putAll" output="false" access="public" returntype="any" hint="Put a map of name-value pairs into the flash scope">
    	<cfargument name="map" 			type="struct"   required="true" hint="The map of data to flash"/>
		<cfargument name="saveNow"  	type="boolean"  required="false" default="false" hint="Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation"/>
		<cfargument name="keep" 		type="boolean"  required="false" default="true" hint="Whether to mark the entry to be kept after saving to the flash storage."/>
		<cfargument name="inflateToRC"  type="boolean"  required="false" default="#instance.defaults.inflateToRC#" hint="Whether this flash variable is inflated to the Request Collection or not"/>
		<cfargument name="inflateToPRC" type="boolean"  required="false" default="#instance.defaults.inflateToPRC#" hint="Whether this flash variable is inflated to the Private Request Collection or not"/>
		<cfargument name="autoPurge" 	type="boolean"  required="false" default="#instance.defaults.autoPurge#" hint="Flash memory auto purges variables for you. You can control this purging by saying false to autoPurge."/>
		<cfscript>
			var key = "";

			// Save all keys in map
			for( key in arguments.map ){
				// Store value and key to pass
				arguments.name  = key;
				arguments.value = arguments.map[key];
				// place in put
				put(argumentCollection=arguments);
			}

			// Save to Storage
			if( arguments.saveNow ){ saveFlash(); }

			return this;
		</cfscript>
    </cffunction>

	<!--- remove --->
    <cffunction name="remove" output="false" access="public" returntype="any" hint="Remove an object from flash scope">
    	<cfargument name="name"  type="string" required="true" hint="The name of the value"/>
		<cfargument name="saveNow" type="boolean" required="false" default="false" hint="Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation"/>
		<cfscript>
			structDelete(getScope(),arguments.name);
			if( arguments.saveNow ){ saveFlash(); }
			return this;
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
		<cfscript>
			var scope = getScope();

			if( exists(arguments.name) ){
				return scope[arguments.name].content;
			}

			if( structKeyExists(arguments,"default") ){
				return arguments.default;
			}

		</cfscript>
		<cfthrow message="#arguments.name# not found in flash scope. Valid keys are #getKeys()#." type="#getMetadata(this).name#.KeyNotFoundException">
	</cffunction>

	<!--- persist --->
	<cffunction name="persistRC" output="false" access="public" returntype="any" hint="Persist keys from the coldbox request collection in flash scope. If using exclude, then it will try to persist the entire rc but excluding.  Including will only include the keys passed.">
		<cfargument name="include" type="string"  required="false" default="" hint="MUTEX: A list of request collection keys you want to persist"/>
		<cfargument name="exclude" type="string"  required="false" default="" hint="MUTEX: A list of request collection keys you want to exclude from persisting. If sent, then we inspect all rc keys."/>
		<cfargument name="saveNow" type="boolean" required="false" default="false" hint="Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation"/>
		<cfscript>
			var rc = getController().getRequestService().getContext().getCollection();
			var key = "";
			var x=1;
			var thisKey = "";
			var somethingToSave = false;

			// Cleanup
			arguments.include = replace(arguments.include, " ", "", "all");
			arguments.exclude = replace(arguments.exclude, " ", "", "all");

			// Exclude?
			if( len(trim(arguments.exclude)) ){
				for(thisKey in rc){
					// Only persist keys that are not Excluded.
					if( NOT listFindNoCase(arguments.exclude,thisKey) ){
						put(thisKey,rc[thisKey]);
						somethingToSave = true;
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
						somethingToSave = true;
					}
				}
			}

			// Save Now?
			if( arguments.saveNow AND somethingToSave ){ saveFlash(); }

			return this;
		</cfscript>
	</cffunction>

	<!--- getter for the flash data defaults structure --->
	<cffunction name="getDefaults" access="public" output="false" returntype="struct" hint="Get flash scope default data packet">
		<cfreturn instance.defaults/>
	</cffunction>

	<!--- getter for the properties structure --->
	<cffunction name="getProperties" access="public" output="false" returntype="struct" hint="Get flash scope properties">
		<cfreturn instance.properties/>
	</cffunction>

	<!--- setter for the properties structure --->
	<cffunction name="setProperties" access="public" output="false" returntype="any" hint="Set flash scope properties">
		<cfargument name="properties" type="any" required="true" colddoc:generic="struct"/>
		<cfset instance.properties = arguments.properties/>
		<cfreturn this>
	</cffunction>

	<!--- get a property --->
	<cffunction name="getProperty" access="public" returntype="any" hint="Get a flash scope property, throws exception if not found." output="false" >
		<cfargument name="property" required="true" type="any" hint="The key of the property to return.">
		<cfreturn instance.properties[arguments.property]>
	</cffunction>

	<!--- set a property --->
	<cffunction name="setProperty" access="public" returntype="any" hint="Set a flash scope property" output="false" >
		<cfargument name="property" required="true" type="any" 	hint="The property name to set.">
		<cfargument name="value" 	required="true" type="any" 	hint="The value of the property.">
		<cfset instance.properties[arguments.property] = arguments.value>
		<cfreturn this>
	</cffunction>

	<!--- check for a property --->
	<cffunction name="propertyExists" access="public" returntype="boolean" hint="Checks wether a given flash scope property exists or not." output="false" >
		<cfargument name="property" required="true" type="any" hint="The property name">
		<cfreturn structKeyExists(instance.properties,arguments.property)>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- statusMarks --->
    <cffunction name="statusMarks" output="false" access="private" returntype="any" hint="Change the status marks of the temp scope entries">
    	<cfargument name="keys" type="string" required="false" default="" hint="The keys in the flash ram that you want to be discarded or kept until the next relocation"/>
		<cfargument name="keep" type="boolean" required="true" hint="Keep or Discard"/>
    	<cfscript>
			var scope = getScope();
			var targetKeys = structKeyList(scope);
			var x=1;

			// keys passed in?
			if( len(trim(arguments.keys)) ){
				targetKeys = keys;
			}

			// Keep them if they exist
			for(x=1; x lte listLen(targetKeys); x=x+1){
				if( structKeyExists(scope,listGetAt(targetKeys,x)) ){
					scope[listGetAt(targetKeys,x)].keep = arguments.keep;
				}
			}

			return this;
		</cfscript>
    </cffunction>

	<!--- getController --->
    <cffunction name="getController" output="false" access="private" returntype="coldbox.system.web.Controller" hint="Get the controller reference">
    	<cfreturn instance.controller>
    </cffunction>

	<!--- getUtil --->
	<cffunction name="getUtil" output="false" access="private" returntype="coldbox.system.core.util.Util" hint="Get the coldbox utility class">
		<cfreturn createObject("component","coldbox.system.core.util.Util")>
	</cffunction>

</cfcomponent>