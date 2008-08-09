<!-----------------------------------------------------------------------
Author 	 :	Ernst van der Linden
Date     :	7/31/2008
Description : Intercepts if we need to call the ColdBox SideBar plugin
		
Modification History:
08/08/2008 evdlinden : getRenderedSideBar(), onException()
08/09/2008 evdlinden : postRender appendToBuffer, onException appendToBuffer, xmlParse of sideBar properties
----------------------------------------------------------------------->
<cfcomponent name="sideBar" output="true" extends="coldbox.system.interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		
		<cfscript>
			// Read SideBar XML
			readSideBarXML();
			
			/* Start processing properties */
			if( not propertyExists( 'isEnabled') or not isBoolean(getproperty('isEnabled') ) ){
				setProperty('isEnabled', getPropertyDefault('isEnabled') );
			}
			if( not propertyExists( 'yOffset') or not isNumeric(getproperty('yOffset') ) ){
				setProperty('yOffset', getPropertyDefault('yOffset'));
			}
			if( not propertyExists( 'links') or not isArray(getproperty('links') ) ){
				setProperty('links', getPropertyDefault('links') );
			}
			if( not propertyExists('width') or not isNumeric(getproperty('width')) ){
				setProperty('width', getPropertyDefault('width') );
			}
			if( not propertyExists('visibleWidth') or not isNumeric(getproperty('visibleWidth')) ){
				setProperty( 'visibleWidth', getPropertyDefault('visibleWidth') );
			}
			if( not propertyExists('imagePath') or not REFindNoCase("[A-Z]",getproperty('imagePath')) ){
				setProperty( 'imagePath', getPropertyDefault('imagePath') );
			}
			if( not propertyExists('cssPath') or not REFindNoCase("[A-Z]",getproperty('cssPath')) ){
				setProperty( 'cssPath', getPropertyDefault('cssPath') );
			}
			if( not propertyExists('imageVAlign') or not ListFindNoCase('top,middle,bottom', getproperty('imageVAlign') ) ){
				setProperty( 'imageVAlign', getPropertyDefault('imageVAlign') );
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<cffunction name="postRender" access="public" returntype="void" output="true" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		<!--- Append rendered sideBar to buffer --->
		<cfset appendToBuffer(getRenderedSideBar(arguments.event))>
	</cffunction>

	<cffunction name="onException" access="public" returntype="void" output="true" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		<!--- Append rendered sideBar to buffer --->
		<cfset appendToBuffer(getRenderedSideBar(arguments.event))>
	</cffunction>

<!------------------------------------------- PRIVATE METHDOS ------------------------------------------->
	
	<cffunction name="getRenderedSideBar" access="public" output="true" returntype="string">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<cfset var renderedSideBar = ''>
		<cfset var i = 0>
		<!--- SideBar Settings --->
		<cfset var sideBar = StructNew()>
		<cfset sideBar.links = getproperty('links')>
		<cfset sideBar.yOffset = getproperty('yOffset')>
		<cfset sideBar.width = getproperty('width')>
		<cfset sideBar.visibleWidth = getproperty('visibleWidth')>
		<cfset sideBar.invisibleWidth = sideBar.width - sideBar.visibleWidth>
		<cfset sideBar.imagePath = getproperty('imagePath')>
		<cfset sideBar.imageVAlign = getproperty('imageVAlign')>
		<cfset sideBar.cssPath = getproperty('cssPath')>
		
		<!--- Render? --->
		<cfif getIsRender(arguments.event)>
			<cfsavecontent variable="renderedSideBar"><cfinclude template="../includes/sideBar/sideBar.cfm"></cfsavecontent>
		</cfif>
		<cfreturn renderedSideBar>	
	</cffunction>

	<cffunction name="getIsRender" access="private" returntype="boolean">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
        <cfreturn (getproperty('isEnabled') AND NOT arguments.event.isProxyRequest())>
	</cffunction>
		
	<cffunction name="setPropertyDefault" access="private" returntype="void">
		<cfargument name="propertyName" required="true" type="string">
		<cfargument name="propertyValue" required="true" type="any">
		<cfset StructInsert(getSideBarDefaults(), arguments.propertyName, arguments.propertyValue)>       
	</cffunction>

	<cffunction name="getPropertyDefault" access="private" returntype="any">
		<cfargument name="propertyName" required="true" type="string">
		<cfreturn StructFind(getSideBarDefaults(), arguments.propertyName)>   
	</cffunction>
	
	<cffunction name="getSideBarDefaults" access="private" returntype="struct">
		<!--- SideBarDefaults exists ? --->
		<cfif not propertyExists('sideBarDefaults')>
			<cfset setProperty('sideBarDefaults',StructNew())>
		</cfif>	
		<cfreturn getproperty('sideBarDefaults')>       
	</cffunction>
		
	<cffunction name="readSideBarXML" access="private" returntype="void">
		<cfset var i = 0>
		<cfset var k = 0>
		<cfset var sideBarXMLDoc = ''>
		<cfset var sideBarXML = ''>
		<cfset var properties = ''>
		<cfset var property = StructNew()>
		
 		<cftry>
			<!--- Read SideBar XML --->
			<cffile action="read" file="#ExpandPath('includes/sidebar/sideBar.xml.cfm')#" variable="sideBarXMLDoc">
			<!--- Parse XML --->
			<cfset sideBarXML = XmlParse(sideBarXMLDoc)>
			<!--- Set xml properties array --->
			<cfset properties = sideBarXML['Sidebar']['Properties']['Property']>
		
			<!--- Loop properties --->
			 <cfloop index="i" from="1" to="#ArrayLen(properties)#">
				 <!--- Property has properties? --->
				 <cfif properties[i].xmlAttributes['name'] EQ "links">
					<!--- Decode JSON --->
					<cfset property.value = getPlugin('JSON').decode( properties[i].xmlText )>
				<cfelse>
					<cfset property.value = properties[i].xmlText>
				</cfif>
				<cfset setPropertyDefault(properties[i].xmlAttributes['name'],property.value)>
			</cfloop>
			
			<cfcatch type="any">
				<cfthrow message="SideBar: xml file default properties read error. Check default SideBar.xml file ." detail="#cfcatch.message#"> 
			</cfcatch>
		</cftry>	
	</cffunction>		
</cfcomponent>
