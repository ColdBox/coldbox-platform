<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	A simple CF appender
	
Properties:

- logType : file or application
- fileName : The log file name to use, else uses the appender's name
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="A simple CF Appender">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="CFAppender" hint="Constructor" output="false" >
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
			
			// Verify properties
			if( NOT propertyExists('logType') ){
				setProperty("logType","file");
			}
			else{
				// Check types
				if( NOT reFindNoCase("^(file|application)$", getProperty("logType")) ){
					throw(message="Invalid logtype choosen #getProperty("logType")#",
						   detail="Valid types are file or application",
						   type="CFAppender.InvalidLogTypeException");
				}
			}
			if( NOT propertyExists("fileName") ){
				setProperty("fileName", getName());
			}
						
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="any" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfset var loge = arguments.logEvent>
		<cfset var entry = "">
		
		<cfif hasCustomLayout()>
			<cfset entry = getCustomLayout().format(loge)>
		<cfelse>
			<cfset entry = "#loge.getCategory()# #loge.getMessage()# ExtraInfo: #loge.getextraInfoAsString()#">
		</cfif>
		
		<cfif getProperty("logType") eq "file">
			<cflog file="#getProperty('fileName')#" 
			  	   type="#this.logLevels.lookupCF(loge.getSeverity())#"
			  	   text="#entry#">
		<cfelse>
			<cflog log="Application"
				   type="#this.logLevels.lookupCF(loge.getSeverity())#"
			  	   text="#entry#">
		</cfif>
			   
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	
</cfcomponent>