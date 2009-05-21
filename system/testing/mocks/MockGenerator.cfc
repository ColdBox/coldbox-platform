<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 		: Luis Majano
Date     		: April 20, 2009
Description		: 
	A mock generator
----------------------------------------------------------------------->
<cfcomponent name="MockGenerator" output="false" hint="The guy in charge of creating mocks">

	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="MockGenerator" hint="Constructor">
		<cfargument name="mockBox" type="coldbox.system.testing.MockBox" required="true"/>
		<cfscript>
			instance.mockBox = arguments.mockBox;
			return this;
		</cfscript>
	</cffunction>
	
	<!--- generate --->
	<cffunction name="generate" output="false" access="public" returntype="any" hint="Generate a mock method">
		
	</cffunction>
	

</cfcomponent>