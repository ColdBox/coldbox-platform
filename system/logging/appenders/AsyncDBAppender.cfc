<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
 A simple asynchronous DB appender for MySQL, MSSQL, Oracle, PostgreSQL

Inspiration from Tim Blair <tim@bla.ir> cflogger project.

Properties:
 - dsn : the dsn to use for logging
 - table : the table to store the logs in
 - columnMap : A column map for aliasing columns. (Optional)
 - autocreate : if true, then we will create the table. Defaults to false (Optional)
 - ensureChecks : if true, then we will check the dsn and table existence.  Defaults to true (Optional)
 - textDBType : Defaults to 'text'. This is used on the autocreate features of the appender for the
 				   message and extended info fields.  This is the actual database type.
				   
The columns needed in the table are

 - id : UUID
 - severity : string
 - category : string
 - logdate : timestamp
 - appendername : string
 - message : string
 - extrainfo : string

If you are building a mapper, the map must have the above keys in it.

----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.appenders.DBAppender" 
			 output="false"
			 hint="This is a simple implementation of a appender that is db based.">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="DBAppender" hint="Constructor" output="false" >
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
			// strong reference to super scope if not cf9 and below choke on high load and cfthread
			variables.$super = super;
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="any" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		
		<cfscript>
			var uuid = createobject("java", "java.util.UUID").randomUUID();
			var threadName = "#getname()#_logMessage_#replace(uuid,"-","","all")#";
		</cfscript>
		
		<!--- Are we in a thread already? --->
		<cfif getUtil().inThread()>
			<cfset super.logMessage(arguments.logEvent)>
		<cfelse>
			<!--- Thread this puppy --->
			<cfthread name="#threadName#" logEvent="#arguments.logEvent#">
				<cfset variables.$super.logMessage(attributes.logEvent)>
			</cfthread>
		</cfif>

	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
</cfcomponent>