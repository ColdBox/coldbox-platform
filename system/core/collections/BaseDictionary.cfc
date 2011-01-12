<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/31/2007
Description :
	This is a base lookup dictionary
----------------------------------------------------------------------->
<cfcomponent name="BaseDictionary" hint="This is a base lookup dictionary" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="BaseDictionary" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="name" 		required="false" type="any" default="BaseDictionary" hint="The dictionary name">
		<cfargument name="dictionary" 	required="false" type="any" default="#structnew()#"  hint="The default dictionary [struct]">
		<!--- ************************************************************* --->
		<cfscript>
			//Set PRoperties
			setDictionary(arguments.dictionary);
			setName(arguments.name);
			//return instance.
			return this;
		</cfscript>
	</cffunction>


<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get Key --->
	<cffunction name="getKey" access="public" returntype="any" hint="Get a dictionary key, else return a blank" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="key" required="true" type="any" hint="The key to return">
		<!--- ************************************************************* --->
		<cfscript>
			if ( keyExists(arguments.key) ){
				return structFind( getDictionary(), arguments.key );
			}
			return "";
		</cfscript>
	</cffunction>
	
	<!--- Key Exists --->
	<cffunction name="keyExists" access="public" returntype="any" hint="Check if a key exists: Boolean" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="key" required="true" type="any" hint="The key to return">
		<!--- ************************************************************* --->
		<cfreturn structKeyExists( getDictionary(), arguments.key )>
	</cffunction>
	
	<!--- set a new Key --->
	<cffunction name="setKey" access="public" returntype="void" hint="Set a new key in the dictionary" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="key" 	 required="true" type="any" 	hint="The key to return">
		<cfargument name="value" required="true" type="any" 	hint="The value of the key">
		<!--- ************************************************************* --->
		<cfscript>
			var dictionary = getDictionary();
			dictionary[arguments.key] = arguments.value;
		</cfscript>
	</cffunction>
	
	<!--- Clear a key --->
	<cffunction name="clearKey" access="public" returntype="any" hint="Clear a key from the dictionary, returns true or false if removed" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="key" required="true" type="string" hint="The key to remove">
		<!--- ************************************************************* --->
		<cfreturn structDelete( getDictionary(), arguments.key )>
	</cffunction>
	
	<!--- Clear All --->
	<cffunction name="clearAll" access="public" returntype="void" hint="Clear all the keys" output="false" >
		<cfscript>
			structClear(getDictionary());
		</cfscript>
	</cffunction>

<!------------------------------------------- ACCESSOR/MUTATORS ------------------------------------------->

	<!--- Dictionary --->
	<cffunction name="getDictionary" access="public" output="false" returntype="any" hint="Get Dictionary as struct">
		<cfreturn instance.Dictionary/>
	</cffunction>
	<cffunction name="setDictionary" access="public" output="false" returntype="void" hint="Set Dictionary">
		<cfargument name="dictionary" type="any" required="true"/>
		<cfset instance.dictionary = arguments.dictionary/>
	</cffunction>
	
	<!--- Dictionary Name --->
	<cffunction name="getName" access="public" output="false" returntype="any" hint="Get dictionary name">
		<cfreturn instance.name/>
	</cffunction>
	<cffunction name="setName" access="public" output="false" returntype="void" hint="Set dictionary name">
		<cfargument name="name" type="any" required="true"/>
		<cfset instance.name = arguments.name/>
	</cffunction>

</cfcomponent>