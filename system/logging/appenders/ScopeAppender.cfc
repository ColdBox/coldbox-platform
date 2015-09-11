<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	A simple Scope Appender that logs to a specified scope.

Inspiration from Tim Blair <tim@bla.ir> by the cflogger project

Properties:
- scope : the scope to persist to, defaults to request (optional)
- key   : the key to use in the scope, it defaults to the name of the Appender (optional)
- limit : a limit to the amount of logs to rotate. Defaults to 0, unlimited (optional)

----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="A scope appender">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="ScopeAppender" hint="Constructor" output="false" >
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
			if( NOT propertyExists('scope') ){
				setProperty("scope","request");
			}
			if( NOT propertyExists('key') ){
				setProperty("key",getName());
			}
			if( NOT propertyExists('limit') OR NOT isNumeric(getProperty("limit"))){
				setProperty("limit",0);
			}
			
			// Scope storage
			instance.scopeStorage = createObject("component","coldbox.system.core.collections.ScopeStorage").init();
			// Scope Checks
			instance.scopeStorage.scopeCheck(getproperty('scope'));
			// UUID generator
			instance.uuid = createobject("java", "java.util.UUID");
			
						
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="true" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="any" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfscript>
			var logStack = "";
			var entry = structnew();
			var limit = getProperty('limit');
			var loge = arguments.logEvent;
			
			// Verify storage
			ensureStorage();
			
			// Check Limits
			logStack = getStorage();
			
			if( limit GT 0 and arrayLen(logStack) GTE limit ){
				// pop one out, the oldest
				arrayDeleteAt(logStack,1);
			}
			
			// Log Away
			entry.id = instance.uuid.randomUUID().toString();
			entry.logDate = loge.getTimeStamp();
			entry.appenderName = getName();
			entry.severity = severityToString(loge.getseverity());
			entry.message = loge.getMessage();
			entry.extraInfo = loge.getextraInfo();
			entry.category = loge.getCategory();
			
			// Save Storage
			arrayAppend(logStack, entry);
			saveStorage(logStack);		
		</cfscript>	   
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- getStorage --->
	<cffunction name="getStorage" output="false" access="private" returntype="any" hint="Get the storage">
		<cflock name="#getname()#.scopeoperation" type="exclusive" timeout="20" throwOnTimeout="true">
			<cfreturn instance.scopeStorage.get(getProperty('key'), getProperty('scope'))>
		</cflock>
	</cffunction>
	
	<!--- saveStorage --->
	<cffunction name="saveStorage" output="false" access="private" returntype="void" hint="Save Storage">
		<cfargument name="data" required="true" hint="Data to save"/>
		<cflock name="#getname()#.scopeoperation" type="exclusive" timeout="20" throwOnTimeout="true">
			<cfset instance.scopeStorage.put(getProperty('key'), arguments.data, getProperty('scope'))>
		</cflock>
	</cffunction>

	<!--- ensureStorage --->
	<cffunction name="ensureStorage" output="false" access="private" returntype="void" hint="Ensure the first storage in the scope">
		<cfscript>
			if( NOT instance.scopeStorage.exists(getProperty('key'),getproperty('scope')) ){
				instance.scopeStorage.put(getProperty('key'), arrayNew(1), getProperty('scope'));
			}
		</cfscript>
	</cffunction>
	
	
</cfcomponent>