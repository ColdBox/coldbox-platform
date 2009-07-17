<cfcomponent output="false">

	<cffunction name="init" access="public" returntype="struct" output="false">
		<cfargument name="transfer" type="any" required="yes">
		<cfargument name="coldBox" type="any" required="yes">
		
		<cfset setTransfer(arguments.transfer)>
		<cfset setColdBox(arguments.coldBox)>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="setTransfer" access="private" returntype="void">
		<cfargument name="transfer" type="any" required="yes">
		<cfset variables.transfer = arguments.transfer>				
	</cffunction>

	<cffunction name="getTransfer" access="public" returntype="any">
		<cfreturn variables.transfer>				
	</cffunction>

	<cffunction name="setColdBox" access="private" returntype="void">
		<cfargument name="coldbox" type="any" required="yes">
		<cfset variables.coldBox = arguments.coldBox>				
	</cffunction>

	<cffunction name="getColdBox" access="public" returntype="any">
		<cfreturn variables.coldBox>				
	</cffunction>

	<cffunction name="getDsn" access="public" returntype="string">
		<cfreturn getColdBox().getSetting('datasources').dsn1.name>				
	</cffunction>

	<cffunction name="getManager" access="package" returntype="any">
		<cfargument name="componentName" type="string">
		<cfset var manager = CreateObject("component",arguments.componentName).init(getTransfer(),getColdBox())>
		<cfreturn manager>				
	</cffunction>
	
	
</cfcomponent>