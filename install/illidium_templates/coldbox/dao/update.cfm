	<%cffunction name="update" access="public" output="false" returntype="boolean"%>
		<%cfargument name="#root.bean.xmlAttributes.name#" type="#root.bean.xmlAttributes.path#" required="true" /%>

		<%cfset var qUpdate = "" /%>
		<%cftry%>
			<%cfquery name="qUpdate" datasource="%variables.dsn%"%>
				UPDATE	#root.bean.dbTable.xmlAttributes.name#
				SET		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey neq true and root.bean.dbtable.xmlChildren[i].xmlAttributes.identity neq "Yes">#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# = <%cfqueryparam value="%arguments.#root.bean.xmlAttributes.name#.get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#()%" CFSQLType="#root.bean.dbtable.xmlChildren[i].xmlAttributes.cfSqlType#"<cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.required neq "Yes"> null="%not len(arguments.#root.bean.xmlAttributes.name#.get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())%"</cfif> /%><cfif i neq arrayLen(root.bean.dbtable.xmlChildren)>,</cfif>
							</cfif></cfloop>
				WHERE		0=0<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey eq "Yes">#chr(13)#				AND		#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# = <%cfqueryparam value="%arguments.#root.bean.xmlAttributes.name#.get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#()%" CFSQLType="#root.bean.dbtable.xmlChildren[i].xmlAttributes.cfSqlType#" /%></cfif></cfloop>
			<%/cfquery%>
			<%cfcatch type="database"%>
				<%cfreturn false /%>
			<%/cfcatch%>
		<%/cftry%>
		<%cfreturn true /%>
	<%/cffunction%>