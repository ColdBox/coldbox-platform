<cfcomponent displayname="BaseService" output="false">
	
	<cffunction name="init" returntype="BaseService" output="false">
		<cfargument name="dsn"	type="string" required="true">
		<cfargument name="ColdboxFactory" type="coldbox.system.extras.ColdboxFactory" required="true">
		
		<cfset variables.ColdboxFactory = arguments.ColdboxFactory />
		<cfset variables.dsn            =  arguments.dsn />
		
		<cfreturn this />
	</cffunction>
	
</cfcomponent>
