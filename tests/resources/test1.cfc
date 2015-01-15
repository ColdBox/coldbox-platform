<cfcomponent output="false" extends="base1">
	
	<cffunction name="t1" returntype="void">
		<cfset var myVal = "ColdBox Great Toolkit" />
	</cffunction>

	<cffunction name="aPrivateMethod" returntype="boolean" access="private">
		<cfreturn true/>
	</cffunction>

	<cffunction name="anException" returntype="boolean" access="private">
		<cfthrow type="AnException" message="An Exception">
	</cffunction>
	
</cfcomponent>
