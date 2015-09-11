<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	A dummy appender for usage in unit testing.
	
Properties:

----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="A dummy appender">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="DummyAppender" hint="Constructor" output="false" >
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
			
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the appender.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="any" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<!--- Dummy Empty --->   
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	
</cfcomponent>