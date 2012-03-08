<cfcomponent output="false" hint="A normal ColdBox event handler">

	<!--- index --->
    <cffunction name="index" output="false" hint="Index">
    	<cfargument name="event">
    	
    	<cfset event.setView("home/index")>
    </cffunction>

</cfcomponent>