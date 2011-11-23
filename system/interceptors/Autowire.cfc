<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Description :
	DEPRECATED, LEFT FOR COMPATIBILITY
	
----------------------------------------------------------------------->
<cfcomponent hint="This is an autowire interceptor DEPRECATED DO NOT USE" output="false" extends="coldbox.system.Interceptor">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- configure --->
	<cffunction name="configure" access="public" returntype="void" output="false" >
		<cfscript>
			var ormSettings = getSetting("orm").injection;
			
			// Prepare Autowire Settings
			
			// Enable Entity Injection
			if(NOT propertyExists("entityInjection") or NOT isBoolean(getProperty("entityInjection"))){
				setProperty("entityInjection",false);
			}
			// Entity Includes
			if(NOT propertyExists("entityInclude") ){
				setProperty("entityInclude",'');
			}
			// Entity Excludes
			if(NOT propertyExists("entityExclude") ){
				setProperty("entityExclude",'');
			}
			
			// setup property compat
			ormSettings.enabled = getProperty("entityInjection");
			ormSettings.include = getProperty("entityInclude");
			ormSettings.exclude = getProperty("entityExclude");
			
		</cfscript>
	</cffunction>

</cfcomponent>