<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Serialize and deserialize JSON data into native ColdFusion objects
http://www.epiphantastic.com/cfjson/

Authors: Jehiah Czebotar (jehiah@gmail.com)
         Thomas Messier  (thomas@epiphantastic.com)
Version: 1.9 February 20, 2008

Modifications:
	- Contributed by Ernst van der Linden (evdlinden@gmail.com) ]
	- Sana Ullah (adjusted the compatibility with coldbox plugins).
	- Luis Majano (adaptations & best practices)
----------------------------------------------------------------------->
<cfcomponent name="JSON"
			 hint="JSON Plugin is used to serialize and deserialize JSON data to/from native ColdFusion objects."
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="JSON" output="false">
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.Controller">
		<cfscript>
			super.Init(arguments.controller);
			
			setpluginName("JSON");
			setpluginVersion("1.9");
			setpluginDescription("JSON Plugin is used to serialize and deserialize JSON data to/from native ColdFusion objects");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			
			instance.json = createObject("component","coldbox.system.core.util.conversion.JSON").init();
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Decode from JSON to CF --->
	<cffunction name="decode" access="public" returntype="any" output="no" hint="Converts data from JSON to CF format">
		<!--- ************************************************************* --->
		<cfargument name="data" type="string" required="Yes" hint="JSON Packet" />
		<!--- ************************************************************* --->
		<cfset instance.json.decode(argumentCollection=arguments)>
	</cffunction>
	
	<!--- CONVERTS DATA FROM CF TO JSON FORMAT --->
	<cffunction name="encode" access="public" returntype="string" output="No" hint="Converts data from CF to JSON format">
		<!--- ************************************************************* --->
		<cfargument name="data" 			type="any" 		required="Yes" hint="The CF structure" />
		<cfargument name="queryFormat" 		type="string" 	required="No" default="query" hint="query or array" />
		<cfargument name="queryKeyCase" 	type="string" 	required="No" default="lower" hint="lower or upper"/>
		<cfargument name="stringNumbers" 	type="boolean" 	required="No" default="false" >
		<cfargument name="formatDates" 		type="boolean" 	required="No" default="false" >
		<cfargument name="columnListFormat" type="string" 	required="No" default="string" hint="string or array" >
		<cfargument name="keyCase"			type="string" 	required="No" default="lower"  hint="lower or upper"/>
		<!--- ************************************************************* --->
		<cfset instance.json.encode(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Validate a JSON document --->
	<cffunction name="validate" access="remote" output="yes" returntype="boolean" hint="I validate a JSON document against a JSON schema">
		<!--- ************************************************************* --->
		<cfargument name="doc" 			type="string" 	required="No" />
		<cfargument name="schema"	 	type="string" 	required="No" />
		<cfargument name="errorVar" 	type="string" 	required="No" default="JSONSchemaErrors" />
		<cfargument name="stopOnError" 	type="boolean" 	required="No" default=true />
		<!--- These arguments are for internal use only --->
		<cfargument name="_doc" 		type="any" 		required="No" />
		<cfargument name="_schema" 		type="any" 		required="No" />
		<cfargument name="_item" 		type="string" 	required="No" default="root" />
    	<!--- ************************************************************* --->
		<cfset instance.json.validate(argumentCollection=arguments)>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	
</cfcomponent>