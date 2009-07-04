<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	A simple ConsoleAppender
	
Properties:
- none
----------------------------------------------------------------------->
<cfcomponent name="ConsoleAppender" 
			 extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="A simple Console Appender">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="ConsoleAppender" hint="Constructor" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this appender."/>
		<cfargument name="levelMin" 	type="numeric" required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="levelMax" 	type="numeric" required="false" default="5" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the appender"/>
		<!--- ************************************************************* --->
		<cfscript>
			// Init supertype
			super.init(argumentCollection=arguments);
			
			instance.out = createObject("java","java.lang.System").out;
						
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="coldbox.system.logging.LogEvent" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfscript>
			var extra = "";
			var loge = arguments.logEvent;
			
			try{
				extra = loge.extraInfo.toString();
			}
			catch(Any e){
				$log("ERROR","Extrainfo toString() failed on #getName()# appender. #e.message# #e.detail#");
			}
			
			// Log message
			instance.out.println("#severityToString(loge.getseverity())# #loge.getCategory()# #loge.getmessage()# #chr(13)# #extra#");
		</cfscript>			   
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	
</cfcomponent>