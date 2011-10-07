<cfcomponent name="formBean" hint="I model a simple form bean" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfset variables.instance = structnew()>
	<cfset variables.instance.fname = "">
	<cfset variables.instance.lname = "">
    <cfset variables.instance.email = "" >
	<cfset variables.instance.initDate = "">

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" output="false" hint="I return a form bean instance" returntype="any">
		<cfscript>
		instance.initDate = now();
		return this;
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getInstance" access="public" returntype="any" output="false">
		<cfreturn variables.instance >
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setInstance" access="public" returntype="void" output="false">
		<cfargument name="instance" type="struct" required="true">
		<cfset variables.instance = arguments.instance>
	</cffunction>
	<!--- ************************************************************* --->
	
	
	<!--- onMissingMethod --->
	<cffunction name="onMissingMethod" output="false" access="public" returntype="any" hint="">
		<!--- ************************************************************* --->
		<cfargument name="missingMethodName" type="string" required="true" default="" hint=""/>
		<cfargument name="missingMethodArguments" type="struct" required="true" default="" hint=""/>
		<!--- ************************************************************* --->
		<cfscript>
			var propertyName = "";
			
			if( left(arguments.missingmethodName,3) eq "set" ){
				propertyName = right(arguments.missingmethodName, len(arguments.missingMethodName)-3);
				variables.instance[propertyName] = arguments.missingMethodArguments["1"];	
			}
		
		</cfscript>		
	</cffunction>
	
</cfcomponent>