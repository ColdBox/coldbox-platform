<!-----------------------------------------------------------------------
Author 	 :	Ernst van der Linden
Date     :	7/31/2008
Description : Intercepts if we need to call the ColdBox SideBar plugin
		
Modification History:

Todo: implement postRender, so we can discard the plugin
----------------------------------------------------------------------->
<cfcomponent name="sideBar" output="false" extends="coldbox.system.interceptor">

	<cffunction name="preRender" access="public" returntype="void" output="true" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<!--- Enable SideBar? Debug mode? SideBar enabled? No proxy Request? --->
		<cfif getSetting('SideBar') AND NOT Event.isProxyRequest()>
			<!--- Call SideBar Plugin --->
			<cfset getPlugin("sideBar","true").setIsRender(true)>
		</cfif>
		
	</cffunction>
			
</cfcomponent>
