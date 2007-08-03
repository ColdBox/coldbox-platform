	<%cffunction name="save" access="public" output="false" returntype="boolean" %>
		<%cfargument name="#root.bean.xmlAttributes.name#" type="#root.bean.xmlAttributes.path#" required="true" %>
		
		<%cfset var success = false %>
		<%cfif arguments.#root.bean.xmlAttributes.name#.get#primaryKey#() neq 0%>
			<%cfset success = update(arguments.#root.bean.xmlAttributes.name#) %>
		<%cfelse%>
			<%!--- Comment the following if you would NOT like to generate UUID's ---%>
			<%cfset arguments.#root.bean.xmlAttributes.name#.set#primaryKey#(createUUID())%>
			<%cfset success = create(arguments.#root.bean.xmlAttributes.name#) %>
		<%/cfif%>
		
		<%cfreturn success %>
	<%/cffunction%>