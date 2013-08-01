<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano & Henrik Joreteg
Date        :	06/18/2009
Description :
	An incredible validator for all the following:
	
Validations:
- boolean
- date
- email
- eurodate
- exactLen-X
- numeric or float
- guid
- integer
- maxLen-X
- minLen-X
- range-1..4
- regex-{regexhere}
- sameAs-{fieldname}
- ssn
- string
- telephone
- URL
- uuid
- USdate: a U.S. date of the format mm/dd/yy, with 1-2 digit days and months, 1-4 digit years. 
- zipcode 5 or 9 digit format zip codes

----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.core.util.Validator" 
			 output="false" 
			 hint="Our incredible validator for EVERYTHING!"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor">
		<cfscript>
			super.init();
			
			// Plugin Properties
			setPluginName("Validator");
			setPluginVersion("1.0");
			setPluginDescription("Validate Stuff now!");
			setPluginAuthor("Luis Majano & Henrik Joreteg");
			setPluginAuthorURL("http://coldbox.org,http://joreteg.com/");

			return this;
		</cfscript>
	</cffunction>
	
</cfcomponent>