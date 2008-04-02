<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Sana Ullah
Date     :	April 02, 2008
Description:
			http://www.owasp.org/index.php/Category:OWASP_AntiSamy_Project
			http://code.google.com/p/owaspantisamy/downloads/list
----------------------------------------------------------------------->

<cfcomponent name="AntiSamy"
			 hint="OWASP AntiSamy Project."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" access="public" returntype="AntiSamy" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("OWASP AntiSamy Project")>
		<cfset setpluginVersion("1.0")>
		<cfset setpluginDescription("AntiSamy to protect from XSS hacks.")>

		<cfscript>
		// assume you have .jar file in includes folder 
		// download latest .jar file and change the name of jar accordingly
		getPlugin("JavaLoader").setup(ExpandPath("./includes/antisamy-bin.1.1.jar.jar"));	
 
		//Load AntiSamy Class
		variables.AntiSamy  = getPlugin("JavaLoader").create("org.owasp.validator.html.AntiSamy");
		
		//Load eBay policyfile and assume you have .xml file in inlcudes folder
		variables.ebay  = expandPath('./includes/antisamy-ebay-1.1.xml');
		
		//Load eBay policyfile and assume you have .xml file in inlcudes folder (best one)
		variables.myspace  = expandPath('./includes/antisamy-myspace-1.1.xml');
		
		//Load eBay policyfile and assume you have .xml file in inlcudes folder
		variables.antisamyxml  = expandPath('./includes/antisamy-1.1.xml');
		
		//Load eBay policyfile and assume you have .xml file in inlcudes folder
		variables.slashdot  = expandPath('./includes/antisamy-slashdot-1.1.xml');
		</cfscript>
 		
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	<cffunction name="sanitizer" returntype="Any" output="false" hint="clean HTML from XSS scripts">
		<cfargument name="HtmlData" type="string" required="yes" hint="html text">
		
		<cfscript>
			// you can use any xml, our your own customised policy xml
			var CleanedHtml  = "";
			CleanedHtml = variables.AntiSamy.scan(arguments.HtmlData, variables.myspace);
			
			return CleanedHtml.getCleanHTML(); 
		</cfscript>
	</cffunction>
	
</cfcomponent>
