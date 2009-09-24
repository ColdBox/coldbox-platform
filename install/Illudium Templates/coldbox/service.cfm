<cfoutput>
<%cfcomponent name="#root.bean.xmlAttributes.name#Service" output="false" cache="true" cachetimeout="30">

	<%cffunction name="init" access="public" output="false" returntype="#root.bean.xmlAttributes.path#Service"%>
		<%cfargument name="#root.bean.xmlAttributes.name#DAO" type="#root.bean.xmlAttributes.path#DAO" required="true" /%>
		<%cfargument name="#root.bean.xmlAttributes.name#Gateway" type="#root.bean.xmlAttributes.path#Gateway" required="true" /%>

		<%cfset variables.#root.bean.xmlAttributes.name#DAO = arguments.#root.bean.xmlAttributes.name#DAO /%>
		<%cfset variables.#root.bean.xmlAttributes.name#Gateway = arguments.#root.bean.xmlAttributes.name#Gateway /%>

		<%cfreturn this/%>
	<%/cffunction%>

	<!-- custom code -->
<%/cfcomponent%>
</cfoutput>