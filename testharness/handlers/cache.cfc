<cfcomponent name="cache" 
			 hint="a default handler" 
			 extends="coldbox.system.EventHandler" 
			 output="false"
			 autowire="false">
			 
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