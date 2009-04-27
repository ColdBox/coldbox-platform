<cfcomponent output="false">

	<cfscript>
		variables.reload = false;
		variables.name = "Luis";
		variables.settings = structnew();
		variables.settings["appname"] = "mockFactory";
		variables.settings["appmapping"] = "/mockFactory";		
	</cfscript>

	<!--- getData --->
	<cffunction name="getData" output="false" access="public" returntype="any" hint="">
		<cfreturn 5>
	</cffunction>
	
	<cffunction name="getreload" access="public" returntype="boolean" output="false">
		<cfreturn variables.reload>
	</cffunction>
	
	<!--- getName --->
	<cffunction name="getFullName" output="false" access="public" returntype="string" hint="Get Full Name">
		<cfreturn getName()>
	</cffunction>
	<cffunction name="getName" output="false" access="private" returntype="string" hint="Get Name">
		<cfreturn variables.name>
	</cffunction>
	
	<!--- getSetting --->
	<cffunction name="getSetting" output="false" access="public" returntype="string" hint="Get a setting">
		<cfargument name="name" type="string" required="true" default="" hint="Name of setting"/>
		<cfif structKeyExists(variables.settings,arguments.name)>
			<cfreturn variables.settings[arguments.name]>
		<cfelse>
			<cfreturn "NOT FOUND">
		</cfif>		
	</cffunction>
	
</cfcomponent>