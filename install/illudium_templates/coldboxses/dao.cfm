<cfoutput>
<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey eq "Yes"><cfset primaryKey = root.bean.dbTable.xmlChildren[i].xmlAttributes.name></cfif></cfloop>
<%cfcomponent displayname="#root.bean.xmlAttributes.name#DAO" hint="table ID column = <cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey eq "Yes">#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#"</cfif></cfloop>%>

	<%cffunction name="init" access="public" output="false" returntype="#root.bean.xmlAttributes.path#DAO"%>
		<%cfargument name="dsn" type="string" required="true"%>
		<%cfset variables.dsn = arguments.dsn%>
		<%cfreturn this%>
	<%/cffunction%>
	
	<!-- custom code -->

<%/cfcomponent%>
</cfoutput>