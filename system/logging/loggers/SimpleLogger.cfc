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
			 extends="coldbox.system.logging.AbstractLogger" 
			 output="false"
			 hint="This is a simple implementation of a logger that is file based.">
			 
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="SimpleLogger" hint="Constructor" output="false">
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this logger."/>
		<cfargument name="level" 		type="numeric" required="false" default="-1" hint="The default log level for this logger. If not passed, then it will use the highest logging level available."/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the logger"/>
		<!--- ************************************************************* --->
		<cfscript>
			/* Super init it */
			super.init(argumentCollection=arguments);

		</cfscript>
	</cffunction>
	


<!------------------------------------------- PUBLIC ------------------------------------------->
			 

</cfcomponent>