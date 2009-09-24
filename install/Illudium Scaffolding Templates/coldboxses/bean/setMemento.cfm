	<%cffunction name="setMemento" access="public" returntype="#root.bean.xmlAttributes.path#" output="false"%>
		<%cfargument name="memento" type="struct" required="yes"/%>
		<%cfset variables.instance = arguments.memento /%>
		<%cfreturn this /%>
	<%/cffunction%>
	<%cffunction name="getMemento" access="public" returntype="struct" output="false" %>
		<%cfreturn variables.instance /%>
	<%/cffunction%>