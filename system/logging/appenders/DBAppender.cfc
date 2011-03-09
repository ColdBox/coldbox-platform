<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
 A simple DB appender for MySQL, MSSQL, Oracle, PostgreSQL

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
<cfcomponent extends="coldbox.system.logging.AbstractAppender" 
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
			
			// valid columns
			instance.columns = "id,severity,category,logdate,appendername,message,extrainfo";
			// UUID generator
			instance.uuid = createobject("java", "java.util.UUID");
			
			// Verify properties
			if( NOT propertyExists('dsn') ){ 
				$throw(message="No dsn property defined",type="DBAppender.InvalidProperty"); 
			}
			if( NOT propertyExists('table') ){ 
				$throw(message="No table property defined",type="DBAppender.InvalidProperty"); 
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
			if( NOT propertyExists("ensureChecks") ){
				setProperty("ensureChecks",true);
			}
			if( NOT propertyExists("textDBType") ){
				setProperty("textDBType","text");
			}
			
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- onRegistration --->
	<cffunction name="onRegistration" output="false" access="public" returntype="void" hint="Runs on registration">
		<cfscript>
			if( getProperty("ensureChecks") ){
				// Table Checks
				ensureTable();
			}
		</cfscript>
	</cffunction>
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="any" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfscript>
			var type = "cf_sql_tinyint";
			var category = getProperty("defaultCategory");
			var cmap = "";
			var cols = "";
			var loge = arguments.logEvent;
			var message = loge.getMessage();
			
			// Check Category Sent?
			if( NOT loge.getCategory() eq "" ){
				category = loge.getCategory();
			}
			
			// Column Maps
			if( propertyExists('columnMap') ){
				cmap = getProperty('columnMap');
				cols = "#cmap.id#,#cmap.severity#,#cmap.category#,#cmap.logdate#,#cmap.appendername#,#cmap.message#,#cmap.extrainfo#";
			}
			else{
				cols = instance.columns;
			}
		</cfscript>
		
		<!--- write the log message to the DB --->
		<cfquery datasource="#getProperty("dsn")#">
			INSERT INTO #getProperty('table')# (#cols#) VALUES (
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#instance.uuid.randomUUID().toString()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#severityToString(loge.getseverity())#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#category#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#loge.getTimestamp()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(getName(),100)#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#loge.getMessage()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#loge.getExtraInfoAsString()#">
			)
		</cfquery>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- ensureTable --->
	<cffunction name="ensureTable" output="false" access="private" returntype="void" hint="Verify or create the logging table">
		<cfset var dsn = getProperty("dsn")>
		<cfset var qTables = 0>
		<cfset var tableFound = false>
		<cfset var qCreate = "">
		<cfset var cols = instance.columns>
		
		<!--- Get Tables on this DSN --->
		<cfdbinfo datasource="#dsn#" name="qTables" type="tables" />

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
					#listgetAt(cols,6)# #getProperty("textDBType")#,
					#listgetAt(cols,7)# #getProperty("textDBType")#,
					PRIMARY KEY (id)
				)
			</cfquery>
		<cfelseif NOT tableFound and NOT getProperty('autoCreate')>
			<!--- Throw Error --->
			<cfthrow message="Table #getProperty('table')# was not found in the defined datasource: #dsn#. Please create the appropriate logging table."
					 detail="The autocreate property for this appender is set to false."
					 type="DBAppender.TableNotFoundException">
		</cfif>
	</cffunction>
	
	<!--- checkColumnMap --->
	<cffunction name="checkColumnMap" output="false" access="private" returntype="void" hint="Check a column map definition">
		<cfscript>
			var map = getProperty('columnMap');
			var key = "";
			
			for(key in map){
				if( NOT listFindNoCase(instance.columns,key) ){
					$throw(message="Invalid column map key: #key#",detail="The available keys are #instance.columns#",type="DBAppender.InvalidColumnMapException");
				}
			}
		</cfscript>
	</cffunction>
	
</cfcomponent>