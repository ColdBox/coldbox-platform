<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This is a logging object that allows for all kinds of logging to occur within its appender
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is a logging object that allows for all kinds of logging to occur within its appenders">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		// The log levels enum as a public property
		this.logLevels  = createObject( "component", "coldbox.system.logging.LogLevels" );

		// private instance scope
		instance 				= structnew();
		instance._hash 			= createObject( 'java','java.lang.System').identityHashCode( this );
		instance.util 			= createObject( "component", "coldbox.system.core.util.Util" );
		instance.rootLogger 	= "";
		instance.category 		= "";
		instance.appenders 		= "";
		instance.lockName 		= instance._hash & "LoggerOperation";
		instance.lockTimeout 	= 20;

		// Logger Logging Level defaults, which is wideeeee open!
		instance.levelMin 		= this.logLevels.FATAL;
		instance.levelMax 		= this.logLevels.DEBUG;
	</cfscript>

	<!--- Init --->
	<cffunction name="init" access="public" returntype="Logger" hint="Create a new logger object." output="false" >
		<cfargument name="category"  required="true" hint="The category name to use this logger with"/>
		<cfargument name="levelMin"  required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN" colddoc:generic="numeric">
		<cfargument name="levelMax"  required="false" default="4" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN" colddoc:generic="numeric">
		<cfargument name="appenders" required="false" default="#structnew()#" hint="A struct of already created appenders for this category, or blank to use the root logger." colddoc:generic="struct"/>
		<cfscript>

			// Save Properties
			instance.category 	= arguments.category;
			instance.appenders 	= arguments.appenders;

			// Set logging levels
			setLevelMin( arguments.levelMin );
			setLevelMax( arguments.levelMax );

			return this;
		</cfscript>
	</cffunction>

	<!--- get/set the root logger --->
	<cffunction name="getRootLogger" access="public" returntype="any" output="false" hint="Get the root logger" colddoc:generic="coldbox.system.logging.Logger">
		<cfreturn instance.RootLogger>
	</cffunction>
	<cffunction name="setRootLogger" access="public" returntype="void" output="false" hint="Set the root logger for this named logger.">
		<cfargument name="RootLogger" required="true" colddoc:generic="coldbox.system.logging.Logger">
		<cfset instance.RootLogger = arguments.RootLogger>
	</cffunction>

<!------------------------------------------- APPENDER METHODS ------------------------------------------->

	<!--- hasAppenders --->
	<cffunction name="hasAppenders" output="false" access="public" returntype="any" hint="Checks to see if we have registered any appenders yet" colddoc:generic="boolean">
		<cflock name="#instance.lockName#" type="readonly" throwontimeout="true" timeout="#instance.lockTimeout#">
			<cfreturn NOT structIsEmpty(instance.appenders)>
		</cflock>
	</cffunction>

	<!--- Get the Appenders --->
	<cffunction name="getAppenders" access="public" returntype="any" output="false" hint="Get all the registered appenders for this logger. " colddoc:generic="struct">
		<cflock name="#instance.lockName#" type="readonly" throwontimeout="true" timeout="#instance.lockTimeout#">
			<cfreturn instance.appenders>
		</cflock>
	</cffunction>

	<!--- getAppender --->
	<cffunction name="getAppender" output="false" access="public" returntype="any" hint="Get a named appender from this logger class. If the appender does not exists, it will throw an exception.">
		<cfargument name="name" required="true" hint="The appender's name"/>

		<cflock name="#instance.lockName#" type="readonly" throwontimeout="true" timeout="#instance.lockTimeout#">
		<cfscript>
			if( structKeyExists(instance.appenders,arguments.name) ){
				return instance.appenders[arguments.name];
			}
			else{
				throw(message="Appender #arguments.name# does not exist.",
					   detail="The appenders registered are #structKeyList(getAppenders())#",
					   type="Logger.AppenderNotFound");
			}
		</cfscript>
		</cflock>
	</cffunction>

	<!--- appenderExists --->
	<cffunction name="appenderExists" output="false" access="public" returntype="any" hint="Checks to see if a specified appender exists by name." colddoc:generic="Boolean">
		<cfargument name="name" required="true" hint="The name of the appender to check if it is registered"/>
		<cflock name="#instance.lockName#" type="readonly" throwontimeout="true" timeout="#instance.lockTimeout#">
			<cfreturn structKeyExists(instance.appenders, arguments.name)>
		</cflock>
	</cffunction>

	<!--- addAppender --->
	<cffunction name="addAppender" output="false" access="public" returntype="void" hint="Add a new appender to the list of appenders for this logger. If the appender already exists, then it will not be added.">
		<cfargument name="newAppender" required="true" default="" hint="The new appender to add to this logger programmatically." colddoc:generic="coldbox.system.logging.AbstractAppender"/>
		<cfscript>
			var name= "";
			//Verify Appender's name
			if( NOT len(arguments.newAppender.getName()) ){
				throw(message="Appender does not have a name, please instantiate the appender with a unique name.",type="Logger.InvalidAppenderNameException");
			}
			// Get name
			name = arguments.newAppender.getName();
		</cfscript>

		<!--- Verify Registration --->
		<cfif NOT appenderExists(name)>
			<cflock name="#instance.lockName#" type="exclusive" throwontimeout="true" timeout="#instance.lockTimeout#">
			<cfscript>
				if( NOT appenderExists(name) ){
					// Store Appender
					instance.appenders[name] = arguments.newAppender;

					// run registration event if not Initialized
					if( NOT arguments.newAppender.isInitialized() ){
						arguments.newAppender.onRegistration();
						arguments.newAppender.setInitialized(true);
					}
				}
			</cfscript>
			</cflock>
		</cfif>
	</cffunction>

	<!--- unRegister --->
	<cffunction name="removeAppender" output="false" access="public" returntype="any" hint="Unregister an appender from this Logger. True if successful or false otherwise." colddoc:generic="Boolean">
		<cfargument name="name" required="true" hint="The name of the appender to unregister"/>
		<cfset var appender = "">
		<cfset var removed = false>

		<cfif appenderExists(arguments.name)>
			<cflock name="#instance.lockName#" type="exclusive" throwontimeout="true" timeout="#instance.lockTimeout#">
			<cfscript>
				if( appenderExists(arguments.name) ){
					// Get Appender
					appender = instance.appenders[arguments.name];
					// Run un-registration event
					appender.onUnRegistration();
					// Now Delete it
					structDelete(instance.appenders,arguments.name);
					// flag deletion.
					removed = true;
				}
			</cfscript>
			</cflock>
		</cfif>

		<cfreturn removed>
	</cffunction>

	<!--- removeAllAppenders --->
	<cffunction name="removeAllAppenders" output="false" access="public" returntype="void" hint="Removes all appenders registered">
		<cfscript>
			var appenderKeys = structKeyList(getAppenders());
			var x=1;

			for( x=1; x lte listLen(appenderKeys); x=x+1){
				removeAppender(listGetAt(appenderKeys,x));
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC METHODS ------------------------------------------->

	<!--- Level Min --->
	<cffunction name="getlevelMin" access="public" returntype="any" output="false" hint="Get the level min setting" colddoc:generic="numeric">
		<cfreturn instance.levelMin>
	</cffunction>
	<cffunction name="setLevelMin" access="public" output="false" returntype="void" hint="Set the appender's default levelMin">
		<cfargument name="levelMin" required="true"/>
		<cfscript>
			// convert to numeric, if passed in string like "INFO"
			if ( ! isNumeric( levelMin ) ) {
				levelMin = this.logLevels.lookupAsInt( levelMin );
			}
			// Verify level
			if( this.logLevels.isLevelValid(arguments.levelMin) AND
			    arguments.levelMin lte getLevelMax() ){
				instance.levelMin = arguments.levelMin;
			}
			else{
				throw("Invalid Log Level","The log level #arguments.levelMin# is invalid or greater than the levelMax (#getLevelMax()#). Valid log levels are from 0 to 5","Logger.InvalidLogLevelException");
			}
		</cfscript>
	</cffunction>

	<!--- GetSet level Max --->
	<cffunction name="getlevelMax" access="public" returntype="any" output="false" hint="Get the level Max setting" colddoc:generic="Boolean">
		<cfreturn instance.levelMax>
	</cffunction>
	<cffunction name="setLevelMax" access="public" output="false" returntype="void" hint="Set the appender's default levelMax">
		<cfargument name="levelMax" required="true"/>
		<cfscript>
			// convert to numeric, if passed in string like "INFO"
			if ( ! isNumeric( levelMax ) ) {
				levelMax = this.logLevels.lookupAsInt( levelMax );
			}
			// Verify level
			if( this.logLevels.isLevelValid(arguments.levelMax) AND
			    arguments.levelMax gte getLevelMin() ){
				instance.levelMax = arguments.levelMax;
			}
			else{
				throw("Invalid Log Level","The log level #arguments.levelMax# is invalid or less than the levelMin (#getLevelMin()#). Valid log levels are from 0 to 5","Logger.InvalidLogLevelException");
			}
		</cfscript>
	</cffunction>

	<!--- get/set category object. --->
	<cffunction name="getCategory" access="public" returntype="any" output="false" hint="Get the configured category for this logger">
		<cfreturn instance.Category>
	</cffunction>
	<cffunction name="setCategory" access="public" returntype="void" output="false" hint="Set the category for this logger">
		<cfargument name="category" required="true">
		<cfset instance.category = arguments.category>
	</cffunction>

<!------------------------------------------- LOGGING METHODS ------------------------------------------>

	<!--- Debug --->
	<cffunction name="debug" access="public" output="false" returntype="void" hint="I log a debug message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 required="true"  hint="The message to log.">
		<cfargument name="extraInfo" required="false" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfscript>
			arguments.severity = this.logLevels.DEBUG;
			logMessage(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Info --->
	<cffunction name="info" access="public" output="false" returntype="void" hint="I log an information message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 required="true"  hint="The message to log.">
		<cfargument name="extraInfo" required="false" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfscript>
			arguments.severity = this.logLevels.INFO;
			logMessage(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- warn --->
	<cffunction name="warn" access="public" output="false" returntype="void" hint="I log a warning message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 required="true"  hint="The message to log.">
		<cfargument name="extraInfo" required="false" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfscript>
			arguments.severity = this.logLevels.WARN;
			logMessage(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Error --->
	<cffunction name="error" access="public" output="false" returntype="void" hint="I log an error message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 required="true"  hint="The message to log.">
		<cfargument name="extraInfo" required="false" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfscript>
			arguments.severity = this.logLevels.ERROR;
			logMessage(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Fatal --->
	<cffunction name="fatal" access="public" output="false" returntype="void" hint="I log a fatal message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 required="true"  hint="The message to log.">
		<cfargument name="extraInfo" required="false" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfscript>
			arguments.severity = this.logLevels.FATAL;
			logMessage(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- logMessage --->
	<cffunction name="logMessage" output="false" access="public" returntype="void" hint="Write an entry into the loggers registered with this LogBox instance.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 required="true"   hint="The message to log.">
		<cfargument name="severity"  required="true"   hint="The severity level to log, if invalid, it will default to INFO" colddoc:generic="numeric">
		<cfargument name="extraInfo" required="false" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfscript>
			var thisAppender = "";
			var target 		 = this;

			// Verify severity, if invalid, default to INFO
			if( NOT this.logLevels.isLevelValid(arguments.severity) ){
				arguments.severity = this.logLevels.INFO;
			}

			// If message empty, just exit
			arguments.message = trim(arguments.message);
			if( NOT len(arguments.message) ){ return; }

			//Is Logging Enabled?
			if( getLevelMin() eq this.logLevels.OFF ){ return; }

			// Can we log on target
			if( canLog( arguments.severity ) ){
				// Create Logging Event
				arguments.category = target.getCategory();
				var logEvent = new coldbox.system.logging.LogEvent( argumentCollection=arguments );

				// Do we have appenders locally? or go to root Logger
				if( NOT hasAppenders() ){
					target = getRootLogger();
				}
				// Get appenders
				var appenders = target.getAppenders();
				// Delegate Calls to appenders
				for( var key in appenders ){
					// Get Appender
					thisAppender = appenders[ key ];
					// Log the message in the appender if the appender allows it
					if( thisAppender.canLog( arguments.severity ) ){

						// check to see if the async property was passed during definition
						if( thisAppender.propertyExists( 'async' ) && thisAppender.getProperty( 'async' ) ) {
							// prepare threading variables.
							var threadName 	= "logMessage_#replace( createUUID(), "-", "", "all" )#";
							// Are we in a thread already?
							if( instance.util.inThread() ) {
								thisAppender.logMessage( logEvent );
							} else {
								// Thread this puppy
								thread action="run" name="#threadName#" logEvent="#logEvent#" thisAppender="#thisAppender#"{
			 						attributes.thisAppender.logMessage( attributes.logEvent );
			 					}
							}
						} else {
							thisAppender.logMessage( logEvent );
						}
					}
				}
			}
		</cfscript>
	</cffunction>

	<!--- canLog --->
	<cffunction name="canLog" output="false" access="public" returntype="any" hint="Checks wether a log can be made on this Logger using a passed in level" colddoc:generic="Boolean">
		<cfargument name="level" required="true" hint="The level to check if it can be logged in this Logger" colddoc:generic="numeric"/>
		<cfscript>
			// If numeric, do a comparison immediately.
			if( isNumeric( arguments.level ) ){
				return ( arguments.level GTE getLevelMin() AND arguments.level LTE getLevelMax() );
			}
			// Else it is a string
			var targetLevel = this.LogLevels.lookupAsInt( arguments.level );
			return ( canLog( targetLevel ) );
		</cfscript>
	</cffunction>

	<!--- canFatal --->
    <cffunction name="canFatal" output="false" access="public" returntype="any" hint="Can log fatal messages" colddoc:generic="Boolean">
    	<cfreturn canLog( this.logLevels.FATAL )>
    </cffunction>

	<!--- canError --->
    <cffunction name="canError" output="false" access="public" returntype="any" hint="Can log error messages" colddoc:generic="Boolean">
    	<cfreturn canLog( this.logLevels.ERROR )>
    </cffunction>

	<!--- canWarn --->
    <cffunction name="canWarn" output="false" access="public" returntype="any" hint="Can log warn messages" colddoc:generic="Boolean">
    	<cfreturn canLog( this.logLevels.WARN )>
    </cffunction>

	<!--- canInfo --->
    <cffunction name="canInfo" output="false" access="public" returntype="any" hint="Can log info messages" colddoc:generic="Boolean">
    	<cfreturn canLog( this.logLevels.INFO )>
    </cffunction>

	<!--- canDebug --->
    <cffunction name="canDebug" output="false" access="public" returntype="any" hint="Can log debug messages" colddoc:generic="Boolean">
    	<cfreturn canLog( this.logLevels.DEBUG )>
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

</cfcomponent>
