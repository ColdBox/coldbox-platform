<cfcomponent extends="coldbox.system.EventHandler" output="false">

	<!--- dependencies --->
	<cfproperty name="forgeService" inject="model">

	<!--- preHandler --->
	<cffunction name="preHandler" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="any" required="yes">
		<cfscript>	
			event.setLayout("main");
		</cfscript>
	</cffunction>

	<!--- index --->
	<cffunction name="index" returntype="void" output="false">
		<cfargument name="Event">
		<cfscript>	
			var rc = event.getCollection();
			
			//rc.types   = forgeService.getTypes();
			rc.popular = forgeService.getEntries(orderBy=forgeService.POPULAR);
			
		</cfscript>
	</cffunction>

</cfcomponent>