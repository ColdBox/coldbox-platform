	<%cffunction name="read" access="public" output="false" returntype="void"%>
		<%cfargument name="#root.bean.xmlAttributes.name#" type="#root.bean.xmlAttributes.path#" required="true" /%>

		<%cfset var qRead = "" /%>
		<%cfset var strReturn = structNew() /%>
		
		<%cfquery name="qRead" datasource="%variables.dsn%"%>
			SELECT	<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i">#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#<cfif i neq arrayLen(root.bean.dbtable.xmlChildren)>,</cfif></cfloop>
			FROM		#root.bean.dbTable.xmlAttributes.name#
			WHERE		0=0
			<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey eq "Yes">AND		#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# = <%cfqueryparam value="%arguments.#root.bean.xmlAttributes.name#.get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#()%" CFSQLType="#root.bean.dbtable.xmlChildren[i].xmlAttributes.cfSqlType#" /%></cfif></cfloop>
		<%/cfquery%>
	
		<%cfif qRead.recordCount%>
			<%cfset strReturn = queryRowToStruct(qRead)%>
			<%cfset arguments.#root.bean.xmlAttributes.name#.init(argumentCollection=strReturn)%>
		<%/cfif%>
	<%/cffunction%>