<cfcomponent extends="coldbox.system.EventHandler" output="false">

	<!--- dependencies --->
	<cfproperty name="forgeService" inject="model">

	<!--- index --->
	<cffunction name="index" returntype="void" output="false">
		<cfargument name="Event">
		<cfscript>	
			var rc = event.getCollection();
			
			rc.types = forgeService.getTypes();
			
		</cfscript>
	</cffunction>

</cfcomponent>