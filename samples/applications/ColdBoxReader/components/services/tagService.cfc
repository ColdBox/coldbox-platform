<cfcomponent name="tags" extends="baseservice">
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="tagDAO" required="true" type="any">
		<cfargument name="ModelbasePath" required="true" type="string">
		<!--- ******************************************************************************** --->
		<cfset instance = structnew()>
		<cfset instance.tagDAO = arguments.tagDAO>
		<cfset instance.modelBasePath = arguments.ModelBasePath>
		<cfreturn this />
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="getTags" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="feedID" type="string" required="false" default="">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		
		<cfif len(trim(arguments.feedID)) eq 0>
			<cfset qry = instance.tagDAO.getAll()>
		<cfelse>
			<cfset qry = instance.tagDAO.getByID(arguments.feedID)>
		</cfif>
		
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="addFeedTags" access="public" returntype="void">
		<!--- ******************************************************************************** --->
		<cfargument name="feedID" type="string" required="yes">
		<cfargument name="tags" type="string" required="yes">
		<cfargument name="userID" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfset var aTags = "">
		<cfset var newID = "">
		<cfset arguments.tags = Replace(arguments.tags," ",",","ALL")>
		<cfset aTags = ListToArray(arguments.tags)>
		
		<cfloop from="1" to="#ArrayLen(aTags)#" index="i">
			<cfset arguments.newID = CreateUUID()>
			<cfset arguments.TagName = aTags[i]>
			<cfset instance.tagDAO.create(arguments)>	
		</cfloop>
	</cffunction>
	
	<!--- ******************************************************************************** --->

</cfcomponent>