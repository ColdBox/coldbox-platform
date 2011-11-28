<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	An appender that interfaces with the ColdBox Tracer Panel
	
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="An appender that interfaces with the ColdBox Tracer Panel">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="ColdBoxTracerAppender" hint="Constructor" output="false" >
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
			var severityStyle = "";
			var severity = severityToString(loge.getseverity());
			
			// Severity Styles
			switch(severity){
				case "FATAL" : { severityStyle = "fw_redText"; break;}
				case "ERROR" : { severityStyle = "fw_orangeText"; break;}
				case "WARN"  : { severityStyle = "fw_greenText"; break;}
				case "INFO"  : { severityStyle = "fw_blackText"; break;}
				case "DEBUG" : { severityStyle = "fw_blueText"; break;}
			}
			
			if ( hasCustomLayout() ){
				entry = getCustomLayout().format(loge);
			}
			else{
				entry = "<span class='#severityStyle#'><b>#severity#</b></span> #timeFormat(loge.getTimeStamp(),"hh:MM:SS.l tt")# <b>#loge.getCategory()#</b> <br/> #loge.getMessage()#";
			}
			
			//send to coldBox debugger
			getColdBox().getDebuggerService().pushTracer(entry,loge.getExtraInfo());
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	
	
</cfcomponent>