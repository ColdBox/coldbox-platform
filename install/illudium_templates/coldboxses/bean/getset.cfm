	<%!---
	ACCESSORS
	---%><cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i">
	<%cffunction name="set#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" access="public" returntype="void" output="false"%>
		<%cfargument name="#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" type="<cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.type eq "uuid">uuid<cfelse>string</cfif>" required="true" /%>
		<%cfset variables.instance.#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# = arguments.#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# /%>
	<%/cffunction%>
	<%cffunction name="get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" access="public" returntype="<cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.type eq "uuid">uuid<cfelse>string</cfif>" output="false"%>
		<%cfreturn variables.instance.#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# /%>
	<%/cffunction%>
</cfloop>