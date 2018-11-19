<!---
	To be included in CFC's that require Lucee's shallow duplicate()
	so as not to break the Adobe ColdFusion cfml compiler.
--->
<cffunction name="luceeDuplicate" access="public" returntype="any" output="false">
	<cfargument name="objectToDuplicate" type="any"     required="true"  />
	<cfargument name="full"              type="boolean" required="false" default="true" />

	<cfreturn Duplicate( arguments.objectToDuplicate, arguments.full ) />
</cffunction>