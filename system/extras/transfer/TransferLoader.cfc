<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Template : TransferConfigFactory.cfc
Author 	 : Luis Majano
Date     : 7/23/2008
Description :
	
	This interceptor is used to create transfer and load it
	
---------------------------------------------------------------------->
<cfcomponent name="TransferLoader"
			 hint="Creates Transfer and caches it within ColdBox" 
			 output="false"
			 extends="coldbox.system.interceptor">

<!---------------------------------------- CONSTRUCTOR --------------------------------------------------->
	
	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<cfscript>
			var beanInjectorProperties = structnew();
			/* Default BeanInjector Properties */
			beanInjectorProperties.useSetterInjection = true;
			beanInjectorProperties.debugMode = false;
			
			/* Property Checks */
			if( not propertyExists('datasourceAlias') ){
				$throw("No datasource name passed","Please pass in the name of the datasource to use");
			}
			if( not propertyExists('configPath') ){
				$throw("No configpath passed","Please pass in the location of the configPath file");
			}
			if( not propertyExists('definitionPath') ){
				$throw("No definitionPath passed","Please pass in the location of the definitionPath");
			}
			/* Optional Cache Key Vars */
			if( not propertyExists('TransferFactoryCacheKey') ){
				setProperty('TransferFactoryCacheKey',"TransferFactory");
			}
			if( not propertyExists('TransferCacheKey') ){
				setProperty('TransferCacheKey',"Transfer");
			}
			if( not propertyExists('TransactionCacheKey') ){
				setProperty('TransactionCacheKey','TransferTransaction');
			}
			/* Optional Transfer Factory Path */
			if( not propertyExists('TransferFactoryClassPath') ){
				setProperty('TransferFactoryClassPath',"transfer.TransferFactory");
			}
			if( not propertyExists('TransferConfigurationClassPath') ){
				setProperty('TransferConfigurationClassPath',"transfer.com.config.Configuration");
			}		
			/* TDO */
			if( not propertyExists('LoadBeanInjector') or not isBoolean(getProperty("LoadBeanInjector")) ){
				setProperty("LoadBeanInjector",false);
			}	
			if( not propertyExists('BeanInjectorProperties') ){
				setProperty("BeanInjectorProperties",structnew());
			}	
			/* Setup Bean Injector Properties From JSON Packet */
			if( isStruct(getProperty("BeanInjectorProperties")) ){
				structAppend(beanInjectorProperties,getProperty("BeanInjectorProperties"));
				setProperty("BeanInjectorProperties",BeanInjectorProperties);
			}
		</cfscript>
	</cffunction>


<!---------------------------------------- PUBLIC --------------------------------------------------->
	
	<cffunction name="afterConfigurationLoad" output="false" access="public" returntype="void" hint="Load Transfer after configuration has loaded">
		<!--- *********************************************************************** --->
		<cfargument name="event" 	required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<!--- *********************************************************************** --->
		<cfscript>
			/* Create Transfer Factory */
			var configFactory = createObject("component","coldbox.system.extras.transfer.TransferConfigFactory").init();
			/* Create Configuration Object */
			var configuration = configFactory.getTransferConfig(configPath=getProperty('configPath'),
																definitionPath=getProperty('definitionPath'),
																dsnBean=getDatasource(getProperty("datasourceAlias")),
																configClassPath=getProperty('TransferConfigurationClassPath'));
																
			var TransferFactory = createObject("component",getProperty('TransferFactoryClassPath')).init(configuration=configuration);
			var BeanInjectorProperties = getProperty("BeanInjectorProperties");
			var TDO = 0;
			var Transfer = TransferFactory.getTransfer();
			var TDOArgs = getProperty("BeanInjectorProperties");
			
			/* TDO Observer */
			if( getProperty("LoadBeanInjector") ){
				/* Setup Arguments */
				TDOArgs.transfer = Transfer;
				TDOArgs.ColdBoxBeanFactory = getPlugin("beanFactory");
				/* Create TDO */
				TDO = CreateObject("component","coldbox.system.extras.transfer.TDOBeanInjectorObserver").init(argumentCollection=TDOArgs);
			}
			
			/* Transfer is loaded, now cache it */
			getColdboxOCM().set(getProperty('TransferFactoryCacheKey'),TransferFactory,0);
			getColdboxOCM().set(getProperty('TransferCacheKey'), Transfer,0);
			getColdboxOCM().set(getProperty('TransactionCacheKey'), TransferFactory.getTransaction(),0);
						
		</cfscript>
	</cffunction>
	
	
</cfcomponent>