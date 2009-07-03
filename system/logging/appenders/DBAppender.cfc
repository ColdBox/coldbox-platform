<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
 A simple DB logger for MySQL, MSSQL, Oracle, PostgreSQL

Inspiration from Tim Blair <tim@bla.ir> cflogger project.

Properties:
 - dsn : the dsn to use for logging
 - table : the table to store the logs in
 - columnMap : A column map for aliasing columns. (Optional)
 - autocreate : if true, then we will create the table. Defaults to false (Optional)
	
The columns needed in the table are

 - id : UUID
 - severity : string
 - category : string
 - logdate : timestamp
 - loggername : string
 - message : string

If you are building a mapper, the map must have the above keys in it.

----------------------------------------------------------------------->
<cfcomponent name="DBLogger" 
			 extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="This is a simple implementation of a logger that is db based.">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="DBLogger" hint="Constructor called by a Concrete Logger" output="false" >
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
			if( NOT propertyExists('dsn') ){ 
				$throw(message="No dsn property defined",type="DBLogger.InvalidProperty"); 
			}
			if( NOT propertyExists('table') ){ 
				$throw(message="No table property defined",type="DBLogger.InvalidProperty"); 
			}
			if( NOT propertyExists('autoCreate') OR NOT isBoolean(getProperty('autoCreate')) ){ 
				setProperty('autoCreate',false); 
			}
			if( NOT propertyExists('defaultCategory') ){
				setProperty("defaultCategory",arguments.name);
			}
			if( propertyExists("columnMap") ){
				checkColumnMap();
			}
			
			// columns
			instance.columns = "id,severity,category,logdate,loggername,message";
						
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- onRegistration --->
	<cffunction name="onRegistration" output="false" access="public" returntype="void" hint="Runs on registration">
		<cfscript>
			// DSN Check
			ensureDSN();			
			// Table Checks
			ensureTable();
		</cfscript>
	</cffunction>
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the logger.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string"   required="true"   hint="The message to log.">
		<cfargument name="severity"  type="numeric"  required="true"   hint="The severity level to log.">
		<cfargument name="extraInfo" type="any"      required="no" default="" hint="Extra information to send to the loggers.">
		<!--- ************************************************************* --->
		<cfscript>
			var type = "cf_sql_tinyint";
			var category = getProperty("defaultCategory");
			var cmap = "";
			var cols = "";
			
			// Check Category Sent?
			if ( isStruct(arguments.extraInfo) and structKeyExists(arguments.extraInfo,"Category") ){
				category = arguments.extraInfo.category;
			}
			// Column Maps
			if( propertyExists('columnMap') ){
				cmap = getProperty('columnMap');
				cols = "#cmap.id#,#cmap.severity#,#cmap.category#,#cmap.logdate#,#cmap.loggername#,#cmap.message#";
			}
			else{
				cols = instance.columns;
			}
		</cfscript>
		
		<!--- write the log message to the DB --->
		<cfquery datasource="#getProperty("dsn")#">
			INSERT INTO #getProperty('table')# (#cols#) VALUES (
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#createUUID()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#this.logLevels.lookup(arguments.severity)#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#category#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(getName(),100)#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.message#">
			)
		</cfquery>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- ensureDSN --->
	<cffunction name="ensureDSN" output="false" access="private" returntype="void" hint="Verify the datasource">
		<cfscript>
			var datasources = CreateObject("java", "coldfusion.server.ServiceFactory").datasourceservice.getDatasources();
			
			if( NOT structKeyExists(datasources, getProperty('dsn')) ){
				$throw(message="The dsn #getProperty("dsn")# does not exist. Please create it before using this DBLogger",type="DBLogger.DSNException");
			}			
		</cfscript>
	</cffunction>
	
	<!--- ensureTable --->
	<cffunction name="ensureTable" output="false" access="private" returntype="void" hint="Verify or create the logging table">
		<cfset var dsn = getProperty("dsn")>
		<cfset var qTables = 0>
		<cfset var tableFound = false>
		<cfset var qCreate = "">
		<cfset var cols = instance.columns>
		<!--- Get Tables on this DSN --->
		<cfdbinfo datasource="#dsn#" name="qTables" type="tables" />

		<cfdump var="#qTables#">
		<!--- Verify it exists --->
		<cfloop query="qTables">
			<cfif qTables.table_name eq getProperty("table")>
				<cfset tableFound = true>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<!--- AutoCreate Table? --->
		<cfif NOT tableFound and getProperty('autoCreate')>
			<!--- Try to Create Table  --->
			<cfquery name="qCreate" datasource="#dsn#">
				CREATE TABLE #getProperty('table')# (
					#listgetAt(cols,1)# VARCHAR(36) NOT NULL,
					#listgetAt(cols,2)# VARCHAR(10) NOT NULL,
					#listgetAt(cols,3)# VARCHAR(100) NOT NULL,
					#listgetAt(cols,4)# DATETIME NOT NULL,
					#listgetAt(cols,5)# VARCHAR(100) NOT NULL,
					#listgetAt(cols,6)# TEXT,
					PRIMARY KEY (id)
				)
			</cfquery>
		<cfelseif NOT tableFound and NOT getProperty('autoCreate')>
			<!--- Throw Error --->
			<cfthrow message="Table #getProperty('table')# was not found in the defined datasource: #dsn#. Please create the appropriate logging table."
					 detail="The autocreate property for this logger is set to false."
					 type="DBLogger.TableNotFoundException">
		</cfif>
	</cffunction>
	
	<!--- checkColumnMap --->
	<cffunction name="checkColumnMap" output="false" access="private" returntype="void" hint="Check a column map definition">
		<cfscript>
			var map = getProperty('columnMap');
			
			for(key in map){
				if( NOT listFindNoCase(instance.columns,key) ){
					$throw(message="Invalid column map key: #key#",detail="The available keys are #instance.columns#",type="DBLogger.InvalidColumnMapException");
				}
			}
		</cfscript>
	</cffunction>
	
</cfcomponent>