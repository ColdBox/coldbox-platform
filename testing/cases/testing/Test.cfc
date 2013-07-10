<cfcomponent output="false">

	<cfscript>
		variables.reload = false;
		variables.name = "Luis";
		variables.settings = structnew();
		variables.settings["appname"] = "mockFactory";
		variables.settings["appmapping"] = "/mockFactory";
		
		variables.collaborator = createObject("component","coldbox.testing.cases.testing.Collaborator");		
	</cfscript>

	<cffunction name="displayData" access="public" returntype="query" hint="get data and send it back" output="false" >
		<cfreturn variables.collaborator.getDataFromDB()>
	</cffunction>
	
	<!--- Collaborator --->
	<cffunction name="getcollaborator" access="public" output="false" returntype="any" hint="Get collaborator">
		<cfreturn variables.collaborator/>
	</cffunction>
	<cffunction name="setcollaborator" access="public" output="false" returntype="void" hint="Set collaborator">
		<cfargument name="collaborator" type="any" required="true"/>
		<cfset variables.collaborator = arguments.collaborator/>
	</cffunction>

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
	
	<!--- Spy Test --->
	<!--- spyTest --->
	<cffunction name="spyTest" output="false" access="public" returntype="any" hint="Spy test">
		<cfscript>
			/* I do a spy test call */
			if( getData() gt 100 ){
				return 0;
			}
			else{
				return getData();
			}
		</cfscript>
	</cffunction>
	
	<!--- getSetting --->
	<cffunction name="getSetting" output="true" access="public" returntype="string" hint="Get a setting">
		<cfargument name="name" 	type="string" required="true" default="" hint="Name of setting"/>
		<cfargument name="testArg" 	type="string" required="false" hint=""/>
		
		<cfif structKeyExists(variables.settings,arguments.name)>
			<cfreturn variables.settings[arguments.name]>
		<cfelse>
			<cfreturn "NOT FOUND">
		</cfif>		
	</cffunction>
	
</cfcomponent>