<cfoutput>
<%cfcomponent displayname="#root.bean.xmlAttributes.name#" output="false"%>
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><%cfproperty name="#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" type="#root.bean.dbtable.xmlChildren[i].xmlAttributes.type#" default="" /%>
		</cfloop>
	<%!---
	PROPERTIES
	---%>
	<%cfset variables.instance = StructNew() /%>

	<%!---
	INITIALIZATION / CONFIGURATION
	---%>
	<%cffunction name="init" access="public" returntype="#root.bean.xmlAttributes.path#" output="false"%>
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><%cfargument name="#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" type="<cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.type eq "uuid">uuid<cfelse>string</cfif>" required="false" <cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.type eq "uuid">default="%createUUID()%"<cfelse>default=""</cfif> /%>
		</cfloop>
		<%!--- run setters ---%>
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><%cfset set#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#(arguments.#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#) /%>
		</cfloop>
		<%cfreturn this /%>
 	<%/cffunction%>

	<%!---
	PUBLIC FUNCTIONS
	---%>
	<!-- custom code -->

<%/cfcomponent%>
</cfoutput>