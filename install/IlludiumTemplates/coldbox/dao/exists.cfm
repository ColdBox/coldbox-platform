	<%cffunction name="exists" access="public" output="false" returntype="boolean"%>
		<%cfargument name="#root.bean.xmlAttributes.name#" type="#root.bean.xmlAttributes.path#" required="true" /%>

		<%cfset var qExists = ""%>
		<%cfquery name="qExists" datasource="%variables.dsn%" maxrows="1"%>
			SELECT count(1) as idexists
			FROM	#root.bean.dbTable.xmlAttributes.name#
			WHERE		0=0<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey eq "Yes">#chr(13)#			AND		#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# = <%cfqueryparam value="%arguments.#root.bean.xmlAttributes.name#.get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#()%" CFSQLType="#root.bean.dbtable.xmlChildren[i].xmlAttributes.cfSqlType#" /%></cfif></cfloop>
		<%/cfquery%>

		<%cfif qExists.idexists%>
			<%cfreturn true /%>
		<%cfelse%>
			<%cfreturn false /%>
		<%/cfif%>
	<%/cffunction%>