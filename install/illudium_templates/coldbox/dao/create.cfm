	<%cffunction name="create" access="public" output="false" returntype="boolean"%>
		<%cfargument name="#root.bean.xmlAttributes.name#" type="#root.bean.xmlAttributes.path#" required="true" /%>

		<%cfset var qCreate = "" /%>
		
			<%cfquery name="qCreate" datasource="%variables.dsn%"%>
				INSERT INTO #root.bean.dbtable.xmlAttributes.name#
					(
					<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.identity neq true>#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#<cfif i neq arrayLen(root.bean.dbtable.xmlChildren)>,</cfif>
					</cfif></cfloop>)
				VALUES
					(
					<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.identity neq true><%cfqueryparam value="%arguments.#root.bean.xmlAttributes.name#.get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#()%" CFSQLType="#root.bean.dbtable.xmlChildren[i].xmlAttributes.cfSqlType#" <cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.required neq "Yes"> null="%not len(arguments.#root.bean.xmlAttributes.name#.get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())%"</cfif> /%><cfif i neq arrayLen(root.bean.dbtable.xmlChildren)>,</cfif>
					</cfif></cfloop>)
			<%/cfquery%>
		<%cfreturn true /%>
	<%/cffunction%>