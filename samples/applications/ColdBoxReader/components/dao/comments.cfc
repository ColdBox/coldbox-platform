<cfcomponent name="comments" extends="basedao" output="false">
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="dsnBean" required="true" type="coldbox.system.beans.datasourceBean">
		<!--- ******************************************************************************** --->
		<cfset super.init(arguments.dsnBean)>
		<cfset setTablename("coldboxreader_feed_comments")>
		<cfset setIDFieldName("FeedID")>
		<cfset setFieldNameList("*")>
		<cfset setDefaultSortBy("CreatedOn")>
		<cfset setDefaultSort("DESC")>
		<cfreturn this />
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
</cfcomponent>