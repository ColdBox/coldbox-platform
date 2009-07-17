	<%cffunction name="testdoSave" access="public" returntype="void" output="false"%>
		<%cfscript%>
		//Get references
		var event = "";
		
		//Place any variables on the form or URL scope to test the handler.
		//FORM.name = "luis"
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i">
		<cfset element = root.bean.dbtable.xmlChildren[i].xmlAttributes>
		<cfif primaryKey neq element.name>
		<cfif element.type eq "numeric">
		form.#element.name# = '';
		<cfelseif element.type eq "Boolean">
		form.#element.name# = true;
		<cfelseif element.type eq "Date">
		form.#element.name# = dateformat(now(),"medium");
		<cfelse>
		form.#element.name# = 'UNIT TEST';
		</cfif>
		</cfif>
		</cfloop>
		
		event = execute("#root.bean.xmlAttributes.name#.doSave");
			
		//Do your asserts below
				
		<%/cfscript%>
	<%/cffunction%>