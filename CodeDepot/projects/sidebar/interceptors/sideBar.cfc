<!-----------------------------------------------------------------------
Author 	 :	Ernst van der Linden
Date     :	7/31/2008
Description : Intercepts if we need to call the ColdBox SideBar plugin
		
Modification History:
08/08/2008 evdlinden : getRenderedSideBar(), onException()
08/09/2008 evdlinden : postRender appendToBuffer, onException appendToBuffer, xmlParse of sideBar properties
08/10/2008 evdlinden : use properties instead of sideBar structure
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
			
			// Set enabled state on configure
			setProperty('isEnabledOnConfigure',getProperty('isEnabled'));
			
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
			// Calculate and set invisible width
			setProperty( 'invisibleWidth', ( getproperty('width') - getproperty('visibleWidth') ) );
			
			// URL params which are used by the sideBar
			setProperty( 'urlParamNameList', "fwreinit,debugmode,dumpVar,sbIsClearCache,sbClearScope,sbIsClearLog,sbIsEnabled");
			
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<cffunction name="preProcess" access="public" returntype="void" output="true" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<cfset var rc = event.getCollection()>

		<!--- Enable/disable the sidebar? Has been enabled on configure? --->
		<cfif getProperty('isEnabledOnConfigure') AND isBoolean( event.getValue('sbIsEnabled','') )>
			<cfset setProperty('isEnabled',rc.sbIsEnabled)>
		</cfif>

		<!--- Execute SideBar actions? --->
		<cfif getIsRender(arguments.event)>

			<!--- Clear Cache? --->
			<cfif isBoolean( event.getValue('sbIsClearCache','') ) AND event.getValue('sbIsClearCache',false)>
				<cfset getColdboxOCM().expireAll()>
			</cfif>
	
			<!--- Clear Scope? --->
			<cfif isDefined("rc.sbClearScope") AND ListFindNoCase( "session,client", event.getValue('sbClearScope','') )>
				<cfset StructClear( rc.sbClearScope )>
			</cfif>
	
			<!--- Clear Log? --->
			<cfif isBoolean( event.getValue('sbIsClearLog','') ) AND event.getValue('sbIsClearLog',false)>
				<cfset getPlugin("logger").removeLogFile()>
			</cfif>
		
		</cfif>		
		
	</cffunction>

	<cffunction name="postRender" access="public" returntype="void" output="true" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		<!--- Render SideBar? --->
		<cfif getIsRender(arguments.event)>
			<!--- Append rendered sideBar to buffer --->
			<cfset appendToBuffer( getRenderedSideBar(arguments.event) )>
		</cfif>
	</cffunction>

	<cffunction name="onException" access="public" returntype="void" output="true" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		<!--- Render SideBar? --->
		<cfif getIsRender(arguments.event)>
			<!--- Append rendered sideBar to buffer --->
			<cfset appendToBuffer( getRenderedSideBar(arguments.event) )>
		</cfif>
	</cffunction>

<!------------------------------------------- PRIVATE METHDOS ------------------------------------------->
	
	<cffunction name="getRenderedSideBar" access="public" output="true" returntype="string">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<cfset var renderedSideBar = ''>
		<cfset var links = getproperty('links')>
		<cfset var i = 0>
		<cfset var rc = arguments.event.getCollection()>

		<cfset rc.currentURL = getCurrentURL()>
		<!--- Enable link --->
		<cfset rc.enableHref = rc.currentURL & '&sbIsEnabled=0'>
		<!--- Reload framework link --->
		<cfset rc.fwReInitHref = rc.currentURL & '&fwreinit=1'>
		<!--- Enable/disable DebugMode link --->
		<cfset rc.debugModeHref = rc.currentURL & '&debugmode=#( IIF( not getDebugMode(), DE("1"), DE("0") )  )#'>		
		<!--- Clear cache link --->
		<cfset rc.clearCacheHref = rc.currentURL & '&sbIsClearCache=1'>
		<!--- Clear scope link --->
		<cfset rc.clearScopeHref = "location.href='#rc.currentURL#&sbClearScope='+ getElementById('sbClearScope').value;">
		<!--- Clear log link --->
		<cfset rc.clearLogHref = rc.currentURL & '&sbIsClearLog=1'>
		<!--- Cache panel link --->
		<cfset rc.cachePanelHref = "window.open('index.cfm?debugpanel=cache','cache','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=800')">
		<!--- Profiler link --->
		<cfset rc.profilerHref = "window.open('index.cfm?debugpanel=profiler','profilermonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=800')">
		<!--- Dump var link --->
		<cfset rc.dumpvarHref = "location.href='#rc.currentURL#&dumpvar='+ getElementById('sbDumpVar').value;">
		<!--- Search ColdBox Live Docs link --->
		<cfset rc.searchCBLiveDocsHref = "window.open('http://ortus.svnrepository.com/coldbox/trac.cgi/search?q='+ getElementById('sbSearchCBLiveDocs').value + '&wiki=on','CBLiveDocsSearchResults')">
		<!--- Search ColdBox Forums link --->
		<cfset rc.searchCBForumsHref = "window.open('http://groups.google.com/group/coldbox/search?q='+ getElementById('sbSearchCBForums').value + '&qt_g','CBForumsSearchResults')">

		<!--- Render? --->
		<cfif getIsRender(arguments.event)>
			<cfsavecontent variable="renderedSideBar"><cfinclude template="../includes/sideBar/sideBar.cfm"></cfsavecontent>
		</cfif>
		<cfreturn renderedSideBar>	
	</cffunction>
	
	<cffunction name="getIsRender" access="private" returntype="boolean">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
        <cfreturn ( getproperty('isEnabled') AND NOT arguments.event.isProxyRequest() )>
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

	<cffunction name="getCurrentURL" access="private" returntype="string">
		<cfset var noSideBarQueryString = ''>
		<cfset var i = ''>
		
		<!--- Loop all URL params and build query string --->
		<cfloop index="i" list="#StructKeyList(URL)#">
			<!--- Not used by sideBar? --->
			<cfif not ListFindNoCase( getProperty( 'urlParamNameList') ,i)>
				<cfset noSideBarQueryString = ListAppend(noSideBarQueryString,"#LCASE(i)#=#URL[i]#","&")>			
			</cfif>
		</cfloop>		
		<cfreturn "#CGI.SCRIPT_NAME#?#noSideBarQueryString#">
		
	</cffunction>

</cfcomponent>
