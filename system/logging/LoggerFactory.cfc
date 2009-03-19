<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This is the main factory that produces and stores logger objects.
----------------------------------------------------------------------->
<cfcomponent name="LoggerFactory" output="false" hint="This is the main factory that produces and stores logger objects. Please remember to persist this factory once it has been created.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		instance = structnew();
	</cfscript>
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="LoggerFactory" hint="Constructor" output="false" >
		<cfscript>
			/* Prepare Logger Object Registry */
			instance.loggerRegistry = structnew();
			
			/* Return Factory */
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->

</cfcomponent>