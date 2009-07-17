<cfcomponent name="ehProduct" extends="coldbox.system.eventhandler" output="false">
	
	<cffunction name="dspProducts" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<!--- Set the View To Display, after Logic --->
		<cfset Event.setView("product/vwList")>
	</cffunction>
	
</cfcomponent>