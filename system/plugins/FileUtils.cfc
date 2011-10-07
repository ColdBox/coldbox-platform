<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is a utilities library that are file related, most of them.


Modification History:
----------------------------------------------------------------------->
<cfcomponent hint="This is a File Utilities CFC" output="false" cache="true" extends="coldbox.system.core.util.FileUtils">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="FileUtils" output="false">
		<cfscript>

			setpluginName("File Utilities Plugin");
			setpluginVersion("1.0");
			setpluginDescription("This plugin provides various file utilities");
			setpluginAuthor("Luis Majano, Sana Ullah");
			setpluginAuthorURL("http://www.coldbox.org");

			return this;
		</cfscript>
	</cffunction>

</cfcomponent>