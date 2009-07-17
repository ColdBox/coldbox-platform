<cfoutput>
<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey eq "Yes"><cfset primaryKey = root.bean.dbTable.xmlChildren[i].xmlAttributes.name></cfif></cfloop>
<%cfcomponent name="#root.bean.xmlAttributes.name#" extends="coldbox.system.eventhandler" output="false"%>
	
	<%cffunction name="init" access="public" returntype="#root.bean.xmlAttributes.name#" output="false"%>
		<%cfargument name="controller" type="any" required="true"%>
		<%cfset super.init(arguments.controller)%>
		<!--- Any constructor code here --->
		
		<%cfreturn this%>
	<%/cffunction%>

	<!-- custom code -->
	
<%/cfcomponent%>
</cfoutput>