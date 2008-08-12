<!-----------------------------------------------------------------------
Author 	 :	Ernst van der Linden (evdlinden@gmail.com)
Date     :	7/31/2008
Description : Intercepts if we need to render the ColdBox SideBar
		
Modification History:
08/08/2008 evdlinden : getRenderedSideBar(), onException()
08/09/2008 evdlinden : postRender appendToBuffer, onException appendToBuffer, xmlParse of sideBar properties
08/10/2008 evdlinden : use properties instead of sideBar structure. Enable/disable sideBar through url param sbIsEnabled=1
08/11/2008 evdlinden : implmented afterAspectsLoad. Enable/disable property needs to be set afterConfigurationLoad interceptor points, which is used by the environment interceptor
08/12/2008 evdlinden : getRenderedSideBar, switched from request scope to local var scope. We don't want to show sideBar vars if in debugmode. 
					   isScroll property implemented. Changed xml location (SideBar=ColdBoxSideBar)
----------------------------------------------------------------------->
<cfcomponent name="coldboxSideBar" output="true" extends="coldbox.system.interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		
		<cfscript>
			// Read SideBar XML
			readSideBarXML();
			
			/* Start processing properties */
			
			if( not propertyExists( 'yOffset') or not isNumeric(getproperty('yOffset') ) ){
				setProperty('yOffset', getPropertyDefault('yOffset'));
			}
			if( not propertyExists( 'isScroll') or not isBoolean(getproperty('isScroll') ) ){
				setProperty('isScroll', getPropertyDefault('isScroll'));
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

	<cffunction name="afterAspectsLoad" access="public" returntype="void" output="false">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<cfset var rc = event.getCollection()>

		<!--- Set isEnabled property after environmentControl interception --->
		<cfif not settingExists('ColdBoxSideBar') or not isBoolean( getSetting('ColdBoxSideBar') )>
			<cfset setProperty('isEnabled', getPropertyDefault('isEnabled') )>
		<cfelse>
			<cfset setProperty('isEnabled', getSetting('ColdBoxSideBar') )>
		</cfif>
		
	</cffunction>
	
	<cffunction name="preProcess" access="public" returntype="void" output="false">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<cfset var rc = event.getCollection()>

		<!--- Enable/disable the sidebar through url? Has been enabled in config? --->
		<cfif settingExists('ColdBoxSideBar') AND isBoolean( getSetting('ColdBoxSideBar') ) AND getSetting('ColdBoxSideBar') AND isBoolean( event.getValue('sbIsEnabled','') )>
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
				<cfset StructClear( evaluate(rc.sbClearScope) )>
			</cfif>
	
			<!--- Clear Log? --->
			<cfif isBoolean( event.getValue('sbIsClearLog','') ) AND event.getValue('sbIsClearLog',false)>
				<cfset getPlugin("logger").removeLogFile()>
			</cfif>
		
		</cfif>		
		
	</cffunction>

	<cffunction name="postRender" access="public" returntype="void" output="true">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		<!--- Render SideBar? --->
		<cfif getIsRender(arguments.event)>
			<!--- Append rendered sideBar to buffer --->
			<cfset appendToBuffer( getRenderedSideBar(arguments.event) )>
		</cfif>
	</cffunction>

	<cffunction name="onException" access="public" returntype="void" output="true">
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
		<cfset var i =0>
		<cfset var local = StructNew()>

		<cfset local.links = getproperty('links')>
		<!--- Get current url without sideBar relevant params --->
		<cfset local.currentURL = getCurrentURL()>
		<!--- Enable link --->
		<cfset local.enableHref = local.currentURL & '&sbIsEnabled=0'>
		<!--- Reload framework link --->
		<cfset local.fwReInitHref = local.currentURL & '&fwreinit=1'>
		<!--- Enable/disable DebugMode link --->
		<cfset local.debugModeHref = local.currentURL & '&debugmode=#( IIF( not getDebugMode(), DE("1"), DE("0") )  )#'>		
		<!--- Clear cache link --->
		<cfset local.clearCacheHref = local.currentURL & '&sbIsClearCache=1'>
		<!--- Clear scope link --->
		<cfset local.clearScopeHref = "location.href='#local.currentURL#&sbClearScope='+ getElementById('sbClearScope').value;">
		<!--- Clear log link --->
		<cfset local.clearLogHref = local.currentURL & '&sbIsClearLog=1'>
		<!--- Cache panel link --->
		<cfset local.cachePanelHref = "window.open('index.cfm?debugpanel=cache','cache','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=800')">
		<!--- Profiler link --->
		<cfset local.profilerHref = "window.open('index.cfm?debugpanel=profiler','profilermonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=800')">
		<!--- Dump var link --->
		<cfset local.dumpvarHref = "location.href='#local.currentURL#&dumpvar='+ getElementById('sbDumpVar').value;">
		<!--- ColdBox Live Docs link --->
		<cfset local.CBLiveDocsHref = "http://ortus.svnrepository.com/coldbox/trac.cgi">
		<!--- Search ColdBox Live Docs link --->
		<cfset local.searchCBLiveDocsHref = "window.open('http://ortus.svnrepository.com/coldbox/trac.cgi/search?q='+ getElementById('sbSearchCBLiveDocs').value + '&wiki=on','CBLiveDocsSearchResults')">
		<!--- ColdBox Forums link --->
		<cfset local.CBForumsHref = "http://forums.coldboxframework.com/index.cfm">
		<!--- Search ColdBox Forums link --->
		<cfset local.searchCBForumsHref = "window.open('http://forums.coldboxframework.com/index.cfm?event=ehForums.doSearch&searchterms='+ getElementById('sbSearchCBForums').value + '&searchtype=any','CBForumsSearchResults')">

		<!--- Render? --->
		<cfif getIsRender(arguments.event)>
			<cfsavecontent variable="renderedSideBar"><cfinclude template="../includes/coldboxsideBar/ColdBoxSideBar.cfm"></cfsavecontent>
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
			<cffile action="read" file="#ExpandPath('includes/coldboxsidebar/coldboxSideBar.xml.cfm')#" variable="sideBarXMLDoc">
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
				<cfthrow message="ColdBoxSideBar: xml file default properties read error. Check default ColdBoxSideBar.xml file ." detail="#cfcatch.message#"> 
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
