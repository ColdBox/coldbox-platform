<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
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
		<cfargument name="name" 		required="false" type="string" default="BaseDictionary" hint="The dictionary name">
		<cfargument name="dictionary" 	required="false" type="struct" default="#structnew()#"  hint="The default dictionary [struct]">
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
		<cfargument name="key" required="true" type="string" hint="The key to return">
		<!--- ************************************************************* --->
		<cfscript>
			if ( keyExists(arguments.key) ){
				return structFind( getDictionary(), arguments.key );
			}
			else
				return "";
		</cfscript>
	</cffunction>
	
	<!--- Key Exists --->
	<cffunction name="keyExists" access="public" returntype="boolean" hint="Check if a key exists" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="key" required="true" type="string" hint="The key to return">
		<!--- ************************************************************* --->
		<cfreturn structKeyExists( getDictionary(), arguments.key )>
	</cffunction>
	
	<!--- set a new Key --->
	<cffunction name="setKey" access="public" returntype="void" hint="Set a new key in the dictionary" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="key" 	 required="true" type="string" 	hint="The key to return">
		<cfargument name="value" required="true" type="any" 	hint="The value of the key">
		<!--- ************************************************************* --->
		<cfscript>
			var dictionary = getDictionary();
			dictionary[arguments.key] = arguments.value;
		</cfscript>
	</cffunction>
	
	<!--- Clear a key --->
	<cffunction name="clearKey" access="public" returntype="boolean" hint="Clear a key from the dictionary" output="false" >
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
	<cffunction name="getDictionary" access="public" output="false" returntype="struct" hint="Get Dictionary">
		<cfreturn instance.Dictionary/>
	</cffunction>
	<cffunction name="setDictionary" access="public" output="false" returntype="void" hint="Set Dictionary">
		<cfargument name="Dictionary" type="struct" required="true"/>
		<cfset instance.Dictionary = arguments.Dictionary/>
	</cffunction>
	
	<!--- Dictionary Name --->
	<cffunction name="getname" access="public" output="false" returntype="string" hint="Get dictionary name">
		<cfreturn instance.name/>
	</cffunction>
	<cffunction name="setname" access="public" output="false" returntype="void" hint="Set dictionary name">
		<cfargument name="name" type="string" required="true"/>
		<cfset instance.name = arguments.name/>
	</cffunction>

</cfcomponent>