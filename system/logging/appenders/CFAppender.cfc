<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	A simple CF Logger
	
Properties:

- logType : file or application
----------------------------------------------------------------------->
<cfcomponent name="CFLogger" 
			 extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="A simple CF Logger">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="CFLogger" hint="Constructor called by a Concrete Logger" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this logger."/>
		<cfargument name="levelMin" 	type="numeric" required="false" default="0" hint="The default log level for this logger, by default it is 0. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="levelMax" 	type="numeric" required="false" default="5" hint="The default log level for this logger, by default it is 5. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the logger"/>
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
						   type="CFLogger.InvalidLogTypeException");
				}
			}
						
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the logger.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string"   required="true"   hint="The message to log.">
		<cfargument name="severity"  type="numeric"  required="true"   hint="The severity level to log.">
		<cfargument name="extraInfo" type="any"      required="no" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		
		<cfif getProperty("logType") eq "file">
			<cflog file="#getName()#" 
			  	   type="#this.logLevels.lookup(arguments.severity)#"
			  	   text="#arguments.message#">
		<cfelse>
			<cflog log="Application"
				   type="#this.logLevels.lookup(arguments.severity)#"
			  	   text="#arguments.message#">
		</cfif>
			   
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	
</cfcomponent>