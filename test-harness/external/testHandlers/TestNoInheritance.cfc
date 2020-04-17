<!-----------------------------------------------------------------------Author 	 :	Luis MajanoDate     :	September 25, 2005Description :	General handler for my hello application. Please remember to alter	your extends base component using the Coldfusion Mapping.	example:		Mapping: fwsample		Argument Type: fwsample.system.EventHandlerModification History:Sep/25/2005 - Luis Majano	-Created the template.-----------------------------------------------------------------------><cfcomponent output="false">
	<cffunction name="dspExternal" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext"><cfscript>
		var rc = Event.getCollection();
		Event.setView( "vwExternalHandler" );
		</cfscript>
	</cffunction>
</cfcomponent>
