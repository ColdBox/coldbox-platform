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
	</cfscript>
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="Logger" hint="Constructor" output="false" >
		<cfargument name="category" type="string" required="true" hint="The category name to use this logger with"/>
		<cfscript>
			// Setup the category
			instance.category = arguments.category;
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- FACADE Methods ------------------------------------------->
	
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
		<cfset arguments.category = getCategory()>
		<cfset this.logBox.debug(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Info --->
	<cffunction name="info" access="public" output="false" returntype="void" hint="I log an information message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfset arguments.category = getCategory()>
		<cfset this.logBox.info(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Trace --->
	<cffunction name="trace" access="public" output="false" returntype="void" hint="I log a trace message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfset arguments.category = getCategory()>
		<cfset this.logBox.trace(argumentCollection=arguments)>
	</cffunction>
	
	<!--- warn --->
	<cffunction name="warn" access="public" output="false" returntype="void" hint="I log a warning message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfset arguments.category = getCategory()>
		<cfset this.logBox.warn(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Error --->
	<cffunction name="error" access="public" output="false" returntype="void" hint="I log an error message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfset arguments.category = getCategory()>
		<cfset this.logBox.error(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Fatal --->
	<cffunction name="fatal" access="public" output="false" returntype="void" hint="I log a fatal message.">
		<!--- ************************************************************* --->
		<cfargument name="message" 	 type="string" required="true"  hint="The message to log.">
		<cfargument name="extraInfo" type="any"    required="false" default="" hint="Extra information to send to the loggers.">
		<cfargument name="category"  type="string"  required="false" default="" hint="The category to log this message under.  By default it is blank."/>
		<!--- ************************************************************* --->
		<cfset arguments.category = getCategory()>
		<cfset this.logBox.fatal(argumentCollection=arguments)>
	</cffunction>
		
<!------------------------------------------- PRIVATE ------------------------------------------>


</cfcomponent>