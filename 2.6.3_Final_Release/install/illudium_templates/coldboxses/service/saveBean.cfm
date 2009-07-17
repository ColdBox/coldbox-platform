	<%cffunction name="save#root.bean.xmlAttributes.name#" access="public" output="false" returntype="boolean"%>
		<%cfargument name="#root.bean.xmlAttributes.name#" type="#root.bean.xmlAttributes.path#" required="true" /%>

		<%cfreturn variables.#root.bean.xmlAttributes.name#DAO.save(#root.bean.xmlAttributes.name#) /%>
	<%/cffunction%>