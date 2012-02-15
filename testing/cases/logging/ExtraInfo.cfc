<cfcomponent>

	<!--- getData --->
    <cffunction name="getData" output="false" access="public" returntype="any" hint="">
    	<cfreturn {name="luis", age="33", awesome=true, nums=[1,2,3,4]}>
    </cffunction>


	<!--- $toString --->
    <cffunction name="$toString" output="false" access="public" returntype="any" hint="">
    	<cfreturn serializeJSON(getData())>
    </cffunction>


</cfcomponent>