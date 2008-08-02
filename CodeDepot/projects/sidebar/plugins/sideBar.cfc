<!-----------------------------------------------------------------------
Author 	 :	Ernst van der Linden
Date     :	7/31/2008
Description : Shows the ColdBox Sidebar
		
Modification History:

----------------------------------------------------------------------->
<cfcomponent name="sideBar" hint="I am the ColdBox SideBar" extends="coldbox.system.plugin" output="false">
  
    <cffunction name="init" access="public" returntype="sideBar" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
  		super.Init(arguments.controller);
  		setpluginName("SideBar");
  		setpluginVersion("0.1");
  		setpluginDescription("Shows the ColdBox Sidebar");
  		
  		//Return instance
  		return this;
		</cfscript>
	</cffunction>
    
	<cffunction name="getSideBarData" access="private" returntype="struct">
		<cfset var event = controller.getRequestService().getContext()>
		<cfset var sideBarData = StructNew()>
		
		<!--- No SideBar data available? --->
		<cfif not isSideBarData()>

			<cfset sideBarData.isRender = false>
			<!--- Put in request collection --->
			<cfset request.sideBarData = sideBarData>
			
		</cfif>		
		
		<cfreturn request.sideBarData>
	</cffunction>

	<cffunction name="isSideBarData" access="private" returntype="boolean">
		<cfset var event = controller.getRequestService().getContext()>
        <cfreturn isDefined("request.sideBarData")>
	</cffunction>
	
	<cffunction name="render" access="public" returntype="string">
		<!--- Render? --->
		<cfif isRender()>
			<cfreturn renderView('sideBar')>
		<cfelse>
			<cfreturn "">	
		</cfif>
	</cffunction>
    
	<cffunction name="setIsRender" access="public" returntype="void">
		<cfargument name="isRender" type="boolean" required="true">
		<cfset getSideBarData().isRender = arguments.isRender>
	</cffunction>

	<cffunction name="isRender" access="public" returntype="boolean">
        <cfreturn getSideBarData().isRender>
	</cffunction>
		
</cfcomponent>