	<%cffunction name="get#root.bean.xmlAttributes.name#" access="public" output="false" returntype="#root.bean.xmlAttributes.path#"%>
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey eq "Yes"><%cfargument name="#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" type="#root.bean.dbtable.xmlChildren[i].xmlAttributes.type#" required="true" /%>
		</cfif></cfloop>
		<%cfset var #root.bean.xmlAttributes.name# = create#root.bean.xmlAttributes.name#(argumentCollection=arguments) /%>
		<%cfset variables.#root.bean.xmlAttributes.name#DAO.read(#root.bean.xmlAttributes.name#) /%>
		<%cfreturn #root.bean.xmlAttributes.name# /%>
	<%/cffunction%>