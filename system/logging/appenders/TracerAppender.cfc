<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	A simple cftracer appender
	
Properties:

----------------------------------------------------------------------->
<cfcomponent name="CFAppender" 
			 extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="A simple CF Appender">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="TracerAppender" hint="Constructor" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this appender."/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the appender"/>
		<!--- ************************************************************* --->
		<cfscript>
			// Init supertype
			super.init(argumentCollection=arguments);
			
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
			
			if ( hasCustomLayout() ){
				entry = getCustomLayout().format(loge);
			}
			else{
				entry = "#loge.getMessage()# ExtraInfo: #loge.getextraInfoAsString()#";
			}
			
			// Severity by cftrace
			switch( this.logLevels.lookupCF(loge.getSeverity()) ){
				case "FATAL" : { traceSeverity = "fatal information"; break; }
				case "ERROR" : { traceSeverity = "error"; break; }
				case "WARN" : { traceSeverity = "warning"; break; }
			}
		</cfscript>
		
		<cftrace category="#loge.getCategory()#" text="#entry#" type="#traceSeverity#">	   
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	
</cfcomponent>