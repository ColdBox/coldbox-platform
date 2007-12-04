	<%!---
	DUMP
	---%>
	<%cffunction name="dump" access="public" output="true" return="void"%>
		<%cfargument name="abort" type="boolean" default="false" /%>
		<%cfdump var="%variables.instance%" /%>
		<%cfif arguments.abort%>
			<%cfabort /%>
		<%/cfif%>
	<%/cffunction%>