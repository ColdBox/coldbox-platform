<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	An abstract flash scope that can be used to build ColdBox Flash scopes.

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
	
<!------------------------------------------- CONCRETE METHODS ------------------------------------------>

	<!--- persist --->
	<cffunction name="persistRC" output="false" access="public" returntype="void" hint="Persist keys from the coldbox request collection in flash scope. If using exclude, then it will try to persist the entire rc but excluding.  Including will only include the keys passed.">
		<cfargument name="include" type="string"  required="false" default="" hint="MUTEX: A list of request collection keys you want to persist"/>
		<cfargument name="exclude" type="string"  required="false" default="" hint="MUTEX: A list of request collection keys you want to exclude from persisting. If sent, then we inspect all rc keys."/>
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
		</cfscript>
	</cffunction>
	

<!------------------------------------------- ABSTRACT METHODS ------------------------------------------>

	<!--- clear --->
    <cffunction name="clear" output="false" access="public" returntype="void" hint="Clear the flash scope and remove all data">
    </cffunction>
	
	<!--- put --->
    <cffunction name="put" output="false" access="public" returntype="void" hint="Put an object in flash scope">
    	<cfargument name="name"  type="string" required="true" hint="The name of the value"/>
		<cfargument name="value" type="any" required="true" default="" hint="The value to store"/>
    </cffunction>
	
	<!--- putAll --->
    <cffunction name="putAll" output="false" access="public" returntype="void" hint="Put a map of name-value pairs into the flash scope">
    	<cfargument name="map" type="struct" required="true" default="" hint="The map of "/>
    </cffunction>
	
	<!--- remove --->
    <cffunction name="remove" output="false" access="public" returntype="void" hint="Remove an object from flash scope">
    	<cfargument name="name"  type="string" required="true" hint="The name of the value"/>
    </cffunction>
	
	<!--- exists --->
    <cffunction name="exists" output="false" access="public" returntype="boolean" hint="Check if an object exists in flash scope">
    	<cfargument name="name"  type="string" required="true" hint="The name of the value"/>
    </cffunction>

	<!--- size --->
    <cffunction name="size" output="false" access="public" returntype="numeric" hint="Get the size of the items in flash scope">
    </cffunction>
	
	<!--- isEmpty --->
    <cffunction name="isEmpty" output="false" access="public" returntype="boolean" hint="Check if the flash scope is empty or not">
    </cffunction>
	
	<!--- get --->
    <cffunction name="get" output="false" access="public" returntype="any" hint="Get an object from flash scope">
    	<cfargument name="name"    type="string" required="true" hint="The name of the value"/>
  		<cfargument name="default" type="any"    required="false" hint="The default value if the scope does not have the object"/>
	</cffunction>
	
	<!--- getKeys --->
    <cffunction name="getKeys" output="false" access="public" returntype="string" hint="Get a list of all the objects in the flash scope">
    </cffunction>	
	
	<!--- getScope --->
    <cffunction name="getScope" output="false" access="public" returntype="struct" hint="Get a reference to the entire flash scope, usually a struct.">
    </cffunction>
		
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- getController --->
    <cffunction name="getController" output="false" access="private" returntype="coldbox.system.Controller" hint="Get the controller reference">
    	<cfreturn instance.controller>
    </cffunction>

</cfcomponent>