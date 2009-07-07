<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	A simple CF appender
	
Properties:

- logType : file or application
----------------------------------------------------------------------->
<cfcomponent name="CFAppender" 
			 extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="A simple CF Appender">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="CFAppender" hint="Constructor" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this appender."/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the appender"/>
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
					$throw(message="Invalid logtype choosen #getProperty("logType")#",
						   detail="Valid types are file or application",
						   type="CFAppender.InvalidLogTypeException");
				}
			}
						
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="coldbox.system.logging.LogEvent" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfset var loge = arguments.logEvent>
		
		<cfif getProperty("logType") eq "file">
			<cflog file="#getName()#" 
			  	   type="#severityToString(loge.getSeverity())#"
			  	   text="#loge.getCategory()# #loge.getMessage()# ExtraInfo: #loge.getextraInfoAsString()#">
		<cfelse>
			<cflog log="Application"
				   type="#severityToString(loge.getSeverity())#"
			  	   text="#loge.getCategory()# #loge.getMessage()# ExtraInfo: #loge.getextraInfoAsString()#">
		</cfif>
			   
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	
</cfcomponent>