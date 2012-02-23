<cfcomponent hint="a default handler" output="false">
			 
	<!--- reap --->
	<cffunction name="reap" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="any" required="yes">
		<cfset var rc = event.getCollection()>
		<cfscript>	
			getColdboxOCM().expireAll();
			event.renderData(data="done");
		</cfscript>
	</cffunction>

</cfcomponent>