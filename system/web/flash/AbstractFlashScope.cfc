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
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="AbstractFlashScope" hint="Constructor">
    	<cfargument name="controller" type="coldbox.system.web.Controller" required="true" hint="The ColdBox Controller"/>
    	<cfscript>
    		instance.controller = arguments.controller;
			return this;
    	</cfscript>
    </cffunction>
	
<!------------------------------------------- OVERRIDE THESE METHODS ------------------------------------------>

	<!--- saveFlash --->
	<cffunction name="saveFlash" output="false" access="public" returntype="void" hint="Save the flash storage in preparing to go to the next request">
	</cffunction>

	<!--- flashExists --->
	<cffunction name="flashExists" output="false" access="public" returntype="boolean" hint="Checks if the flash storage exists and IT HAS DATA to inflate.">
	</cffunction>

	<!--- getFlash --->
	<cffunction name="getFlash" output="false" access="public" returntype="struct" hint="Get the flash storage structure to inflate it.">
	</cffunction>
	
	<!--- removeFlash --->
    <cffunction name="removeFlash" output="false" access="public" returntype="void" hint="Remove the entire flash storage">
    </cffunction>

<!------------------------------------------- CONCRETE METHODS ------------------------------------------>

	<!--- clearFlash --->
	<cffunction name="clearFlash" output="false" access="public" returntype="void" hint="Clear the flash storage">
		<cfscript>
			var key 	= "";
			var scope 	= "";
			
			// Check if flash exists
			if( flashExists() ){
				scope = getFlash();
				
				// loop over contents and clear flash items that are marked for autopurging.	
				for(key in scope){
					if( scope[key].autoPurge ){
						structDelete(scope, key);
					}
				}
				
				// Destroy if empty
				if( structIsEmpty(scope) ){
					removeFlash();
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- inflateToRC --->
	<cffunction name="inflateFlash" output="false" access="public" returntype="void" hint="Inflate the flash storage into the request collection and request temp storage">
		<cfscript>
			var event 	= getController().getRequestService().getContext();
			var flash 	= getFlash();
			var key	 	= "";
			var keep 	= false;
			
			// Inflate only kept flash variables, other ones are marked for discard.
			for(key in flash){
				if( flash[key].keep ){
					// Inflate into RC?
					if( flash[key].inflateToRC ){
						event.setValue(name=key,value=flash[key].content);
					}
					// Inflate into PRC?
					if( flash[key].inflateToPRC ){
						event.setValue(name=key,value=flash[key].content,private=true);
					}
					
					// Keep = true if autoPurge is false, because we need to keep it around.
					if( NOT flash[key].autoPurge ){ keep = true; }
					else{ keep = false; }
					
					// Save and mark for cleaning
					put(name=key,
						value=flash[key].content,
						keep=keep,
						autoPurge=flash[key].autoPurge,
						inflateToRC=flash[key].inflateToRC,
						inflateToPRC=flash[key].inflateToPRC);
				}
			}
			
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
	
	<!--- keep --->
    <cffunction name="keep" output="false" access="public" returntype="void" hint="Keep all or a single flash temp variable alive for another relocation.">
    	<cfargument name="keys" type="string" required="false" default="" hint="The keys in the flash ram that you want to mark to be kept until the next relocation"/>
		<cfset statusMarks(arguments.keys,true)>
		<cfset saveFlash()>
    </cffunction>
	
	<!--- discard --->
    <cffunction name="discard" output="false" access="public" returntype="void" hint="Mark for discard all or a single flash temp variable for another relocation. You can also remove them if you like.">
    	<cfargument name="keys" type="string" required="false" default="" hint="The keys in the flash ram that you want to be discarded until the next relocation"/>
		<cfset statusMarks(arguments.keys,false)>
    </cffunction>
	
	<!--- put --->
    <cffunction name="put" output="false" access="public" returntype="void" hint="Put an object in temp flash scope">
    	<cfargument name="name"  		type="string" 	required="true"  hint="The name of the value"/>
		<cfargument name="value" 		type="any" 		required="true"  hint="The value to store"/>
		<cfargument name="saveNow" 		type="boolean" 	required="false" default="false" hint="Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation"/>
		<cfargument name="keep" 		type="boolean" 	required="false" default="true" hint="Whether to mark the entry to be kept after saving to the flash storage."/>
		<cfargument name="inflateToRC"  type="boolean"  required="false" default="true" hint="Whether this flash variable is inflated to the Request Collection or not"/>
		<cfargument name="inflateToPRC" type="boolean"  required="false" default="false" hint="Whether this flash variable is inflated to the Private Request Collection or not"/>
		<cfargument name="autoPurge" 	type="boolean"  required="false" default="true" hint="Flash memory auto purges variables for you. You can control this purging by saying false to autoPurge."/>
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
		</cfscript>
    </cffunction>
	
	<!--- putAll --->
    <cffunction name="putAll" output="false" access="public" returntype="void" hint="Put a map of name-value pairs into the flash scope">
    	<cfargument name="map" 			type="struct"   required="true" hint="The map of data to flash"/>
		<cfargument name="saveNow"  	type="boolean"  required="false" default="false" hint="Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation"/>
		<cfargument name="keep" 		type="boolean"  required="false" default="true" hint="Whether to mark the entry to be kept after saving to the flash storage."/>
		<cfargument name="inflateToRC"  type="boolean"  required="false" default="true" hint="Whether this flash variable is inflated to the Request Collection or not"/>
		<cfargument name="inflateToPRC" type="boolean"  required="false" default="false" hint="Whether this flash variable is inflated to the Private Request Collection or not"/>
		<cfargument name="autoPurge" 	type="boolean"  required="false" default="true" hint="Flash memory auto purges variables for you. You can control this purging by saying false to autoPurge."/>
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
	<cffunction name="persistRC" output="false" access="public" returntype="void" hint="Persist keys from the coldbox request collection in flash scope. If using exclude, then it will try to persist the entire rc but excluding.  Including will only include the keys passed.">
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
		</cfscript>
	</cffunction>
		
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- statusMarks --->
    <cffunction name="statusMarks" output="false" access="private" returntype="void" hint="Change the status marks of the temp scope entries">
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