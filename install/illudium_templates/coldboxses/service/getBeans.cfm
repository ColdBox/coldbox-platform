	<%cffunction name="get#root.bean.xmlAttributes.name#s" access="public" output="false" returntype="query"%>
		<%cfargument name="datatype" type="string" required="false" default="query" hint="query or array" %>
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><%cfargument name="#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" type="#root.bean.dbtable.xmlChildren[i].xmlAttributes.type#" required="false" /%>
		</cfloop>
		<%cfif arguments.datatype eq "query"%>
			<%cfreturn variables.#root.bean.xmlAttributes.name#Gateway.getByAttributesQuery(argumentCollection=arguments) /%>
		<%cfelse%>
			<%cfreturn variables.#root.bean.xmlAttributes.name#Gateway.getByAttributes(argumentCollection=arguments) /%>
		<%/cfif%>
	<%/cffunction%>