<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	A simple cftracer appender
	
Properties:

----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="A simple cftrace Appender">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="TracerAppender" hint="Constructor" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		required="true" hint="The unique name for this appender."/>
		<cfargument name="properties" 	required="false" default="#structnew()#" hint="A map of configuration properties for the appender"/>
		<cfargument name="layout" 		required="false" default="" hint="The layout class to use in this appender for custom message rendering."/>
		<cfargument name="levelMin"  	required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN"/>
		<cfargument name="levelMax"  	required="false" default="4" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN"/>
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
		<cfargument name="logEvent" type="any" required="true" hint="The logging event"/>
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
				case "WARN"  : { traceSeverity = "warning"; break; }
			}
		</cfscript>
		
		<cftry>
			<cftrace category="#loge.getCategory()#" text="#entry#" type="#traceSeverity#">
			<cfcatch type="any"><!--- Silent as sometimes, the tag fails itself on cf9, boohoo! ---></cfcatch>
		</cftry>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	
</cfcomponent>