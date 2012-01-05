<!---
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Description :
	Converted this cfc into a ColdBox plugin.

Modification History:
08/01/2006 - Updated the cfc to work for ColdBox.
--->
<cfcomponent name="Zip"
             hint = "A collections of functions that supports the Zip and GZip functionality by using the Java Zip file API."
             extends="coldbox.system.core.util.Zip"
			 output="false"
			 cache="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="Zip" output="false">
		<cfscript>
			// Configure it
			super.init();
			
			//Local Plugin Definition
			setpluginName("Zip");
			setpluginVersion("1.0");
			setpluginDescription("This is a zip utility for the framework.");
			setpluginAuthor("Luis Majano, Sana Ullah");
			setpluginAuthorURL("http://www.coldbox.org");
			
			//Return instance
			return this;
		</cfscript>
	</cffunction>	

</cfcomponent>