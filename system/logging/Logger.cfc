<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This acts as a logbox object with instance variables such as category.
----------------------------------------------------------------------->
<cfcomponent name="Logger" output="false" hint="This acts as a logbox object with instance variables such as category.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		// Injected Dependencies by LogBox
		this.logLevels  = "";
		this.logBox 	= "";
	
		// private instance scope
		instance = structnew();
		instance.category = "";
		instance.levelMin = "";
		instance.levelMax = "";
		instance.appenders = "";			 	
	</cfscript>
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="Logger" hint="Constructor" output="false" >
		<cfargument name="category" type="string"  required="true" hint="The category name to use this logger with"/>
		<cfargument name="levelMin" type="numeric" required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="levelMax" type="numeric" required="false" default="5" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="appenders" type="struct" required="false" default="#structnew()#" hint="A map of appenders for this category"/>
		<cfscript>
			instance.category = arguments.category;
			instance.levelMin = arguments.levelMin;
			instance.levelMax = arguments.levelMax;
			instance.appenders = arguments.appenders;			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- hasAppenders --->
	<cffunction name="hasAppenders" output="false" access="public" returntype="boolean" hint="Checks to see if we have registered any appenders yet">
		<cfreturn NOT getAppenders().isEmpty()>
	</cffunction>

<!------------------------------------------- FACADE Methods ------------------------------------------->
	
	<!--- Get the Appenders --->
	<cffunction name="getappenders" access="public" returntype="struct" output="false" hint="Get the appenders for this logger">
		<cfreturn instance.appenders>
	</cffunction>
	
	<!--- Level Min --->
	<cffunction name="getlevelMin" access="public" returntype="numeric" output="false" hint="Get the level min setting">
		<cfreturn instance.levelMin>
	</cffunction>
	<cffunction name="setLevelMin" access="public" output="false" returntype="void" hint="Set the appender's default levelMin">
		<cfargument name="levelMin" type="numeric" required="true"/>
		<cfscript>
			// Verify level
			if( this.logLevels.isLevelValid(arguments.levelMin) AND
			    arguments.levelMin lte getLevelMax() ){
				instance.levelMin = arguments.levelMin;
			}
			else{
				$throw("Invalid Log Level","The log level #arguments.levelMin# is invalid or greater than the levelMax (#getLevelMax()#). Valid log levels are from 0 to 5","Logger.InvalidLogLevelException");
			}
		</cfscript>
	</cffunction>
	
	<!--- GetSet level Max --->
	<cffunction name="getlevelMax" access="public" returntype="numeric" output="false" hint="Get the level Max setting">
		<cfreturn instance.levelMax>
	</cffunction>
	<cffunction name="setLevelMax" access="public" output="false" returntype="void" hint="Set the appender's default levelMax">
		<cfargument name="levelMax" type="numeric" required="true"/>
		<cfscript>
			// Verify level
			if( this.logLevels.isLevelValid(arguments.levelMax) AND
			    arguments.levelMax gte getLevelMin() ){
				instance.levelMax = arguments.levelMax;
			}
			else{
				$throw("Invalid Log Level","The log level #arguments.levelMax# is invalid or less than the levelMin (#getLevelMin()#). Valid log levels are from 0 to 5","Logger.InvalidLogLevelException");
			}
		</cfscript>
	</cffunction>
	
	<!--- get/set category object. --->
	<cffunction name="getCategory" access="public" returntype="string" output="false" hint="Get the configured category for this logger">
		<cfreturn instance.Category>
	</cffunction>
	<cffunction name="setCategory" access="public" returntype="void" output="false" hint="Set the category for this logger">
		<cfargument name="category" type="string" required="true">
		<cfset instance.category = arguments.category>
	</cffunction>

	<!--- Debug --->
	<cffunction name="debug" access="public" output="false" returntype="void" hint="I log a debug message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category" type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfscript>
			arguments.category = getCategory();
			if( hasAppenders() ){
				arguments.severity = this.logLevels.DEBUG;
				logMessage(argumentCollection=arguments);
			}
			else{
				this.logBox.debug(argumentCollection=arguments);
			}
		</cfscript>
	</cffunction>
	
	<!--- Info --->
	<cffunction name="info" access="public" output="false" returntype="void" hint="I log an information message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfscript>
			arguments.category = getCategory();
			if( hasAppenders() ){
				arguments.severity = this.logLevels.INFO;
				logMessage(argumentCollection=arguments);
			}
			else{
				this.logBox.info(argumentCollection=arguments);
			}
		</cfscript>
	</cffunction>
	
	<!--- Trace --->
	<cffunction name="trace" access="public" output="false" returntype="void" hint="I log a trace message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfscript>
			arguments.category = getCategory();
			if( hasAppenders() ){
				arguments.severity = this.logLevels.TRACE;
				logMessage(argumentCollection=arguments);
			}
			else{
				this.logBox.trace(argumentCollection=arguments);
			}
		</cfscript>
	</cffunction>
	
	<!--- warn --->
	<cffunction name="warn" access="public" output="false" returntype="void" hint="I log a warning message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfscript>
			arguments.category = getCategory();
			if( hasAppenders() ){
				arguments.severity = this.logLevels.WARN;
				logMessage(argumentCollection=arguments);
			}
			else{
				this.logBox.warn(argumentCollection=arguments);
			}
		</cfscript>
	</cffunction>
	
	<!--- Error --->
	<cffunction name="error" access="public" output="false" returntype="void" hint="I log an error message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfscript>
			arguments.category = getCategory();
			if( hasAppenders() ){
				arguments.severity = this.logLevels.ERROR;
				logMessage(argumentCollection=arguments);
			}
			else{
				this.logBox.error(argumentCollection=arguments);
			}
		</cfscript>
	</cffunction>
	
	<!--- Fatal --->
	<cffunction name="fatal" access="public" output="false" returntype="void" hint="I log a fatal message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfscript>
			arguments.category = getCategory();
			if( hasAppenders() ){
				arguments.severity = this.logLevels.fatal;
				logMessage(argumentCollection=arguments);
			}
			else{
				this.logBox.fatal(argumentCollection=arguments);
			}
		</cfscript>
	</cffunction>
	
	<!--- canLog --->
	<cffunction name="canLog" output="false" access="public" returntype="boolean" hint="Checks wether a log can be made on this appender using a passed in level">
		<cfargument name="level" type="numeric" required="true" default="" hint="The level to check"/>
		<cfscript>
			return (arguments.level GTE getLevelMin() AND arguments.level LTE getLevelMax() );
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- logMessage --->
	<cffunction name="logMessage" output="false" access="private" returntype="void" hint="Write an entry into the loggers registered with this LogBox instance.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string"  required="true"   hint="The message to log.">
		<cfargument name="severity"  type="numeric" required="true"   hint="The severity level to log.">
		<cfargument name="extraInfo" type="any"     required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfscript>
			// Loop over loggers
			var appenders = getAppenders();
			var key = "";
			var thisAppender = "";
			var logEvent = "";
			
			// If message empty, just exit
			arguments.message = trim(arguments.message);
			if( NOT len(arguments.message) ){ return; }
			
			// Check if category can log?
			if( canLog(arguments.severity) ){
				// Create Logging Event
				logEvent = createobject("component","coldbox.system.logging.LogEvent").init(argumentCollection=arguments);		
					
				// Delegate Calls
				for(key in appenders){
					// Get Appender
					thisAppender = appenders[key];
					// Log the message in the appender
					thisAppender.logMessage(logEvent);
				}
			}
		</cfscript>	
	</cffunction>
	
	<!--- Throw Facade --->
	<cffunction name="$throw" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
</cfcomponent>