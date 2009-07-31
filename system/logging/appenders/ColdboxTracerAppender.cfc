<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	An appender that interfaces with the ColdBox Tracer Panel
	
Properties:
 - coldbox_app_key : (Optional), the coldbox application key to use, else uses default.
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="An appender that interfaces with the ColdBox Tracer Panel">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="ColdBoxTracerAppender" hint="Constructor" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this appender."/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the appender"/>
		<!--- ************************************************************* --->
		<cfscript>
			// Init supertype
			super.init(argumentCollection=arguments);
			
			//check properties
			if( NOT propertyExists('coldbox_app_key') ){
				setProperty('coldbox_app_key',"");
			}
			
			// Create ColdBox Factory
			instance.coldboxFactory = createObject("component","coldbox.system.ioc.ColdboxFactory").init(getProperty('coldbox_app_key'));
			
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="coldbox.system.logging.LogEvent" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfscript>
			var loge = arguments.logEvent;
			var entry = "";
			var traceSeverity = "information";
			var coldbox = instance.coldboxFactory.getColdBox();
			
			if ( hasCustomLayout() ){
				entry = getCustomLayout().format(loge);
			}
			else{
				entry = "#severityToString(loge.getseverity())# #loge.getCategory()# #loge.getMessage()#";
			}
			
			coldbox.getDebuggerService().pushTracer(entry,loge.getExtraInfo());
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	
</cfcomponent>