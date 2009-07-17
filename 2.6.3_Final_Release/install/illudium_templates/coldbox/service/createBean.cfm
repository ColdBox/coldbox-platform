	<%cffunction name="create#root.bean.xmlAttributes.name#" access="public" output="false" returntype="#root.bean.xmlAttributes.path#"%>
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><%cfargument name="#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" type="#root.bean.dbtable.xmlChildren[i].xmlAttributes.type#" required="<cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey eq "Yes">true<cfelse>false</cfif>" /%>
		</cfloop>
		<%cfset var #root.bean.xmlAttributes.name# = createObject("component","#root.bean.xmlAttributes.path#").init(argumentCollection=arguments) /%>
		<%cfreturn #root.bean.xmlAttributes.name# /%>
	<%/cffunction%>