<!-----------------------------------------------------------------------
Author 	 :	Ernst van der Linden
Date     :	7/31/2008
Description : Intercepts if we need to call the ColdBox SideBar plugin
		
Modification History:

Todo: implement postRender, so we can discard the plugin
----------------------------------------------------------------------->
<cfcomponent name="sideBar" output="true" extends="coldbox.system.interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<cfscript>
			/* Start processing properties */
			if( not propertyExists('isEnabled') or not isBoolean(getproperty('isEnabled')) ){
				setProperty('isEnabled',true);
			}
			if( not propertyExists('yOffset') or not isNumeric(getproperty('yOffset')) ){
				setProperty('yOffset',100);
			}
			if( not propertyExists('links') or not isArray(getproperty('links')) ){
				setProperty('links',ArrayNew(1));
			}
			if( not propertyExists('width') or not isNumeric(getproperty('width')) ){
				setProperty('width',200);
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<cffunction name="preProcess" access="public" returntype="void" output="true" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">

		<!--- Enable SideBar? Debug mode? SideBar enabled? No proxy Request? --->
		<cfif getproperty('isEnabled') AND NOT Event.isProxyRequest()>
			<cfset setIsRender(true)>
		</cfif>

	</cffunction>

	<cffunction name="onException" access="public" returntype="void" output="true" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">

		<!--- Enable SideBar? Debug mode? SideBar enabled? No proxy Request? --->
		<cfif getproperty('isEnabled') AND NOT Event.isProxyRequest()>
			<cfset setIsRender(true)>
		</cfif>

	</cffunction>

<!------------------------------------------- PRIVATE METHDOS ------------------------------------------->

	<cffunction name="getSideBarData" access="private" returntype="struct">
		<cfset var sideBarData = StructNew()>
		
		<!--- No SideBar data available? --->
		<cfif not getIsSideBarData()>

			<cfset sideBarData.isRender = false>
			<!--- Put in request collection --->
			<cfset request.sideBarData = sideBarData>
			
		</cfif>		
		
		<cfreturn request.sideBarData>
	</cffunction>

	<cffunction name="getIsSideBarData" access="private" returntype="boolean">
        <cfreturn isDefined("request.sideBarData")>
	</cffunction>
	
	<cffunction name="render" access="public" output="true" returntype="string">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<cfset var renderedSideBar = ''>
		<cfset var i = 0>
		<!--- SideBar dimension settings --->
		<cfset var sideBar = StructNew()>
		<cfset sideBar.links = getproperty('links')>
		<cfset sideBar.yOffset = getproperty('yOffset')>
		<cfset sideBar.width = getproperty('width')>
		<cfset sideBar.visibleWidth = 30>
		<cfset sideBar.invisibleWidth = sideBar.width - sideBar.visibleWidth>
		
		
		<!--- Render? --->
		<cfif getIsRender()>
			<cfsavecontent variable="renderedSideBar"><cfinclude template="../includes/sideBar/sideBar.cfm"></cfsavecontent>
		</cfif>
		<cfreturn renderedSideBar>	
	</cffunction>
    
	<cffunction name="setIsRender" access="private" returntype="void">
		<cfargument name="isRender" type="boolean" required="true">
		<cfset getSideBarData().isRender = arguments.isRender>
	</cffunction>

	<cffunction name="getIsRender" access="private" returntype="boolean">
        <cfreturn getSideBarData().isRender>
	</cffunction>
		
</cfcomponent>
