<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Ernst van der Linden ( evdlinden@gmail.com | http://evdlinden.behindthe.net )
Date     :	7/31/2008
Description : Intercepts if we need to render the ColdBox SideBar
		
Modification History:
08/08/2008 evdlinden : getRenderedSideBar(), onException()
08/09/2008 evdlinden : postRender appendToBuffer, onException appendToBuffer, xmlParse of sideBar properties
08/10/2008 evdlinden : use properties instead of sideBar structure. Enable/disable sideBar through url param sbIsEnabled=1
08/11/2008 evdlinden : implmented afterAspectsLoad. Enable/disable property needs to be set afterConfigurationLoad interceptor points, which is used by the environment interceptor
08/12/2008 evdlinden : getRenderedSideBar, switched from request scope to local var scope. We don't want to show sideBar vars if in debugmode. 
					   isScroll property implemented. Changed xml location (SideBar=ColdBoxSideBar)
10/13/2008 evdlinden : added waitTimeBeforeOpen property					   
----------------------------------------------------------------------->
<cfcomponent name="coldboxSideBar" output="false" extends="coldbox.system.interceptor" hint="The ColdBox Developer Side Bar">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Configure Method --->
	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		
		<cfscript>
			// Read SideBar XML
			readSideBarXML();
			
			/* Default Is Enabled */
			setProperty('isEnabled', false );
			
			/* Check for an app base Path */
			if( not propertyExists('baseAppPath') ){
				/* Else Default to cgi.script_name */
				setProperty('baseAppPath','#CGI.SCRIPT_NAME#');
			}
			
			// Set css default path
			setPropertyDefault('cssPath','#getProperty("baseAppPath")#?sbContent=css');
			// Set image default path
			setPropertyDefault('imagePath','#getProperty("baseAppPath")#?sbContent=img');
			
			// Set js path
			setProperty( 'jsPath', '#getProperty("baseAppPath")#?sbContent=js' );
						
			// URL params which are used by the sideBar
			setProperty( 'urlParamNameList', "fwreinit,debugmode,dumpVar,sbIsClearCache,sbClearScope,sbIsClearLog,sbIsEnabled");
			
			/* Start processing properties */
			
			if( not propertyExists( 'yOffset') or not isNumeric(getproperty('yOffset') ) ){
				setProperty('yOffset', getPropertyDefault('yOffset'));
			}
			if( not propertyExists( 'slideSpeed') or not isNumeric(getproperty('slideSpeed') ) ){
				setProperty('slideSpeed', getPropertyDefault('slideSpeed'));
			}
			if( not propertyExists( 'waitTimeBeforeOpen') or not isNumeric(getproperty('waitTimeBeforeOpen') ) ){
				setProperty('waitTimeBeforeOpen', getPropertyDefault('waitTimeBeforeOpen'));
			}
			if( not propertyExists( 'waitTimeBeforeClose') or not isNumeric(getproperty('waitTimeBeforeClose') ) ){
				setProperty('waitTimeBeforeClose', getPropertyDefault('waitTimeBeforeClose'));
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
			if( not propertyExists('imageVAlign') or not ListFindNoCase('top,middle,bottom', getproperty('imageVAlign') ) ){
				setProperty( 'imageVAlign', getPropertyDefault('imageVAlign') );
			}
			if( not propertyExists('cssPath') or not REFindNoCase("[A-Z]",getproperty('cssPath')) ){
				setProperty( 'cssPath', getPropertyDefault('cssPath') );
			}
			// Calculate and set invisible width
			setProperty( 'invisibleWidth', ( getproperty('width') - getproperty('visibleWidth') ) );
			
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<!--- afterAspectsLoad --->
	<cffunction name="afterAspectsLoad" access="public" returntype="void" output="false">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<!--- Set isEnabled property after environmentControl interception --->
		<cfif not settingExists('ColdBoxSideBar') or not isBoolean( getSetting('ColdBoxSideBar') )>
			<cfset setProperty('isEnabled', getPropertyDefault('isEnabled') )>
		<cfelse>
			<cfset setProperty('isEnabled', getSetting('ColdBoxSideBar') )>
		</cfif>
		
	</cffunction>
	
	<!--- preProcess --->
	<cffunction name="preProcess" access="public" returntype="void" output="false">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<cfset var rc = event.getCollection()>
		<cfset var contentType = ''>
		<cfset var filePath = ''>
		
		<!--- Enable/disable the sidebar through url? Has been enabled in config? --->
		<cfif settingExists('ColdBoxSideBar') AND isBoolean( getSetting('ColdBoxSideBar') ) AND getSetting('ColdBoxSideBar') AND isBoolean( event.getValue('sbIsEnabled','') )>
			<cfset setProperty('isEnabled',rc.sbIsEnabled)>
		</cfif>

		<!--- Execute SideBar actions? --->
		<cfif getIsRender(arguments.event)>
			
			<!--- Get Content(js,css,img) of SideBar?  --->
			<cfif ListFindNoCase("css,js,img",event.getValue('sbContent',''))>
				<!--- Get binary content --->
				<cfswitch expression="#rc.sbContent#">
					<cfcase value="css">
						<cfset contentType = 'text/css'>
						<cfset filePath = ExpandPath( getPropertyDefault('includesDirectory') & '_ColdBoxSideBar.css')>
					</cfcase>
					<cfcase value="js">
						<cfset contentType = 'text/js'>
						<cfset filePath = ExpandPath( getPropertyDefault('includesDirectory') & '_ColdBoxSideBar.js')>
					</cfcase>
					<cfcase value="img">
						<cfset contentType = 'image/png'>
						<cfset filePath = ExpandPath( getPropertyDefault('includesDirectory') & 'ColdBoxSideBar.png')>
					</cfcase>
					<cfdefaultcase>
						<cfabort>
					</cfdefaultcase>
				</cfswitch>
				<!--- Output binary file content  --->
				<cfcontent type="#contentType#" variable="#getFileContent(filePath,true)#">
				<cfabort>
			</cfif>
		
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

	<!--- postRender --->
	<cffunction name="postRender" access="public" returntype="void" output="false">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		<!--- Render SideBar? --->
		<cfif isStruct(event.getRenderData()) and structisEmpty(event.getRenderData())>
			<!--- Render SideBar? --->
			<cfif getIsRender(arguments.event)>
				<!--- Append rendered sideBar to buffer --->
				<cfset appendToBuffer( getRenderedSideBar(arguments.event) )>
			</cfif>
		</cfif>
	</cffunction>

	<!--- onException --->
	<cffunction name="onException" access="public" returntype="void" output="false">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		<!--- Render SideBar? --->
		<cfif getIsRender(arguments.event) >
			<!--- Append rendered sideBar to buffer --->
			<cfset appendToBuffer( getRenderedSideBar(arguments.event) )>
		</cfif>
	</cffunction>

<!------------------------------------------- PRIVATE METHDOS ------------------------------------------->
	
	<!--- getRenderedSideBar --->
	<cffunction name="getRenderedSideBar" access="public" output="false" returntype="string" hint="Render our beautiful sidebar">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<cfset var renderedSideBar = ''>
		<cfset var i =0>
		<cfset var refLocal = StructNew()>

		<cfset refLocal.links = getproperty('links')>
		<!--- Get current url without sideBar relevant params --->
		<cfset refLocal.currentURL = getCurrentURL()>
		<!--- Enable link --->
		<cfset refLocal.enableHref = refLocal.currentURL & '&sbIsEnabled=0'>
		<!--- Reload framework link --->
		<cfset refLocal.fwReInitHref = refLocal.currentURL & '&fwreinit=1'>
		<!--- Enable/disable DebugMode link --->
		<cfset refLocal.debugModeHref = refLocal.currentURL & '&debugmode=#( IIF( not getDebugMode(), DE("1"), DE("0") )  )#'>		
		<!--- Clear cache link --->
		<cfset refLocal.clearCacheHref = refLocal.currentURL & '&sbIsClearCache=1'>
		<!--- Clear scope link --->
		<cfset refLocal.clearScopeHref = "location.href='#refLocal.currentURL#&sbClearScope='+ getElementById('sbClearScope').value;">
		<!--- Clear log link --->
		<cfset refLocal.clearLogHref = refLocal.currentURL & '&sbIsClearLog=1'>
		<!--- Cache panel link --->
		<cfset refLocal.cachePanelHref = "window.open('index.cfm?debugpanel=cache','cache','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=800')">
		<!--- Profiler link --->
		<cfset refLocal.profilerHref = "window.open('index.cfm?debugpanel=profiler','profilermonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=800')">
		<!--- Dump var link --->
		<cfset refLocal.dumpvarHref = "location.href='#refLocal.currentURL#&dumpvar='+ getElementById('sbDumpVar').value;">
		<!--- ColdBox Live Docs link --->
		<cfset refLocal.CBLiveDocsHref = "http://ortus.svnrepository.com/coldbox/trac.cgi">
		<!--- Search ColdBox Live Docs link --->
		<cfset refLocal.searchCBLiveDocsHref = "window.open('http://ortus.svnrepository.com/coldbox/trac.cgi/search?q='+ getElementById('sbSearchCBLiveDocs').value + '&wiki=on','CBLiveDocsSearchResults')">
		<!--- ColdBox Forums link --->
		<cfset refLocal.CBForumsHref = "http://forums.coldboxframework.com/index.cfm">
		<!--- Search ColdBox Forums link --->
		<cfset refLocal.searchCBForumsHref = "window.open('http://forums.coldboxframework.com/index.cfm?event=ehForums.doSearch&searchterms='+ getElementById('sbSearchCBForums').value + '&searchtype=any','CBForumsSearchResults')">

		<!--- Render? --->
		<cfif getIsRender(arguments.event)>
			<cfsavecontent variable="renderedSideBar"><cfinclude template="../includes/coldboxsidebar/ColdBoxSideBar.cfm"></cfsavecontent>
		</cfif>
		<cfreturn renderedSideBar>	
	</cffunction>
	
	<!--- Get is render --->
	<cffunction name="getIsRender" access="private" returntype="boolean" output="false" hint="Checks if we can render the sidebar">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
        <cfreturn ( getproperty('isEnabled') AND NOT arguments.event.isProxyRequest() )>
	</cffunction>
	
	<!--- SetPropertyDefault --->
	<cffunction name="setPropertyDefault" access="private" returntype="void" output="false" hint="Insert a property">
		<cfargument name="propertyName"  required="true" type="string">
		<cfargument name="propertyValue" required="true" type="any">
		<cfset StructInsert(getSideBarDefaults(), arguments.propertyName, arguments.propertyValue, true)>       
	</cffunction>

	<!--- getPropertyDefault --->
	<cffunction name="getPropertyDefault" access="private" returntype="any" output="false" hint="Get a property default">
		<cfargument name="propertyName" required="true" type="string">
		<cfreturn StructFind(getSideBarDefaults(), arguments.propertyName)>   
	</cffunction>
	
	<!--- getSideBarDefaults --->
	<cffunction name="getSideBarDefaults" access="private" returntype="struct" output="false" hint="Get the side bar defaults, lazy loaded">
		<!--- SideBarDefaults exists ? --->
		<cfif not propertyExists('sideBarDefaults')>
			<cfset setProperty('sideBarDefaults',StructNew())>
		</cfif>	
		<cfreturn getproperty('sideBarDefaults')>       
	</cffunction>
		
	<!--- Read the sidebar XML --->
	<cffunction name="readSideBarXML" access="private" returntype="void" output="false" hint="Read the sidebar xml configuration file">
		<cfset var i = 0>
		<cfset var k = 0>
		<cfset var sideBarXMLDoc = ''>
		<cfset var sideBarXML = ''>
		<cfset var properties = ''>
		<cfset var property = StructNew()>
		
 		<cftry>
			<!--- Read SideBar XML --->
			<cffile action="read" file="#ExpandPath('/coldbox/system/config/ColdBoxSideBar.xml')#" variable="sideBarXMLDoc">
			<!--- Parse XML --->
			<cfset sideBarXML = XmlParse(sideBarXMLDoc)>
			<!--- Set xml properties array --->
			<cfset properties = sideBarXML['Sidebar']['Properties']['Property']>
		
			<!--- Loop properties --->
			 <cfloop index="i" from="1" to="#ArrayLen(properties)#">
				 <!--- Property has properties? --->
				 <cfif properties[i].xmlAttributes['name'] EQ "links">
					<!--- Decode JSON --->
					<cfset property.value = getPlugin('json').decode( properties[i].xmlText )>
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

	<!--- Get the Current URL --->
	<cffunction name="getCurrentURL" access="private" returntype="string" output="false">
		<cfset var noSideBarQueryString = ''>
		<cfset var i = ''>
		
		<!--- Loop all URL params and build query string --->
		<cfloop index="i" list="#StructKeyList(URL)#">
			<!--- Not used by sideBar? --->
			<cfif not ListFindNoCase( getProperty( 'urlParamNameList') ,i)>
				<cfset noSideBarQueryString = ListAppend(noSideBarQueryString,"#LCASE(i)#=#URL[i]#","&")>			
			</cfif>
		</cfloop>		
		<cfreturn "#getProperty('baseAppPath')#?#noSideBarQueryString#">		
	</cffunction>

	<!--- getFileContent --->
	<cffunction name="getFileContent" access="private" returntype="any" output="false" hint="Read a file for its binary or content.">
		<cfargument name="filePath" type="string" required="true">
		<cfargument name="isBinary" type="boolean" default="false" required="false">
		
		<cfset var fileContent = ''>
		<cfset var readType = 'read'>
		
		<!--- Binary read? --->
		<cfif arguments.isBinary>
			<cfset readType = 'readbinary'>
		</cfif>
		
		<!--- Absolute filePath? --->
		
		<!--- read the file binary data --->
		<cffile action="#readType#" file="#arguments.filePath#" variable="fileContent">

		<cfreturn fileContent>				
	</cffunction>

</cfcomponent>
