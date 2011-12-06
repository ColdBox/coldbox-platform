<cfcomponent name="CategoryDAO">

	<cffunction name="init" output="false" returntype="any">
		<cfargument name="dsn" type="string" required="true"/>
		<cfset instance.dsn = arguments.dsn>
		<cfreturn THIS>
	</cffunction>
	
	<cffunction name="getdsn" access="public" returntype="string" output="false">
    	<cfreturn instance.dsn>
    </cffunction>
    <cffunction name="setdsn" access="public" returntype="void" output="false">
    	<cfargument name="dsn" type="string" required="true">
    	<cfset instance.dsn = arguments.dsn>
    </cffunction>   

</cfcomponent>