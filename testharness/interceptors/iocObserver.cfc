<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	An error observer
----------------------------------------------------------------------->
<cfcomponent name="errorObserver"
			 hint="This is a simple error observer"
			 output="false"
			 extends="coldbox.system.interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="Configuration" output="false" >
		<!--- Nothing --->
		
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<cffunction name="afterAspectsLoad" access="public" returntype="void" hint="My very own custom interception point. " output="true" >
		<!--- ************************************************************* --->
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="Metadata of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			var lightwireBeanConfig = CreateObject("component", "coldbox.system.extras.lightwire.BaseConfigObject").init();	
			var defFile = getSetting('ApplicationPath') & "/config/parent.xml.cfm";
			var parentLightwire = 0;
			
			if( getPlugin("ioc").getIOCFramework() eq "lightwire"){
				/* Setup Parent Factory */
				lightwireBeanConfig.parseXMLConfigFile(defFile,getSettingStructure());
				
				/* Create the parent Lightwire factory */
				parentLightwire = createObject("component","coldbox.system.extras.lightwire.LightWire").init(lightwireBeanConfig);
				
				/* set it up */
				getPlugin("ioc").getIOCFactory().setParentFactory(parentLightwire);
			}
		</cfscript>
	</cffunction>


</cfcomponent>