	<%cffunction name="getByAttributes" access="public" output="false" returntype="array"%>
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><%cfargument name="#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" type="#root.bean.dbtable.xmlChildren[i].xmlAttributes.type#" required="false" /%>
		</cfloop><%cfargument name="orderby" type="string" required="false" /%>
		
		<%cfset var qList = getByAttributesQuery(argumentCollection=arguments) /%>		
		<%cfset var arrObjects = arrayNew(1) /%>
		<%cfset var tmpObj = "" /%>
		<%cfset var i = 0 /%>
		<%cfloop from="1" to="%qList.recordCount%" index="i"%>
			<%cfset tmpObj = createObject("component","#root.bean.xmlAttributes.path#").init(argumentCollection=queryRowToStruct(qList,i)) /%>
			<%cfset arrayAppend(arrObjects,tmpObj) /%>
		<%/cfloop%>
				
		<%cfreturn arrObjects /%>
	<%/cffunction%>