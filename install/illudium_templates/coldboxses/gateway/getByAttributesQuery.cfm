	<%cffunction name="getByAttributesQuery" access="public" output="false" returntype="query"%>
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><%cfargument name="#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" type="#root.bean.dbtable.xmlChildren[i].xmlAttributes.type#" required="false" /%>
		</cfloop><%cfargument name="orderby" type="string" required="false" /%>
		
		<%cfset var qList = "" /%>		
		<%cfquery name="qList" datasource="%variables.dsn%"%>
			SELECT	<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i">#chr(13)#				#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#<cfif i neq arrayLen(root.bean.dbtable.xmlChildren)>,</cfif></cfloop>
			FROM	#root.bean.dbtable.xmlAttributes.name#
			WHERE		0=0<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i">#chr(13)#		<%cfif structKeyExists(arguments,"#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#") and len(arguments.#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#)%>
			AND	#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# = <%cfqueryparam value="%arguments.#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#%" CFSQLType="#root.bean.dbtable.xmlChildren[i].xmlAttributes.cfSqlType#" /%>
		<%/cfif%></cfloop>
		<%cfif structKeyExists(arguments, "orderby") and len(arguments.orderBy)%>
			ORDER BY %arguments.orderby%
		<%/cfif%>
		<%/cfquery%>
		
		<%cfreturn qList /%>
	<%/cffunction%>