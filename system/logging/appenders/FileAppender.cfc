<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	Simple File Logger
----------------------------------------------------------------------->
<cfcomponent name="SimpleLogger" 
			 extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="This is a simple implementation of a logger that is file based.">
			 
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="SimpleLogger" hint="Constructor" output="false">
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this logger."/>
		<cfargument name="levelMin" 	type="numeric" required="false" default="0" hint="The default log level for this logger, by default it is 0. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="levelMax" 	type="numeric" required="false" default="5" hint="The default log level for this logger, by default it is 5. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the logger"/>
		<!--- ************************************************************* --->
		<cfscript>
			/* Super init it */
			super.init(argumentCollection=arguments);

		</cfscript>
	</cffunction>
	


<!------------------------------------------- PUBLIC ------------------------------------------->
			 

</cfcomponent>