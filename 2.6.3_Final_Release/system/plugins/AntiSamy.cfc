<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Sana Ullah
Date     :	November 10, 2008
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

		<cfscript>
			var AntiSamyJarPath = ArrayNew(1);
			/* Properties */
			super.Init(arguments.controller);
			setpluginName("OWASP AntiSamy Project");
			setpluginVersion("1.0");
			setpluginDescription("AntiSamy to protect from XSS hacks.");
			
			/* Create Policy Structure */			
			instance.PolicyFileStruct = StructNew();
			
			// load AntiSamy .jar file
			ArrayAppend(AntiSamyJarPath, ExpandPath("/coldbox/system/extras/AntiSamy/antisamy-bin.1.2.jar"));
			ArrayAppend(AntiSamyJarPath, ExpandPath("/coldbox/system/extras/AntiSamy/nekohtml.jar"));
			ArrayAppend(AntiSamyJarPath, ExpandPath("/coldbox/system/extras/AntiSamy/batik-util.jar"));
			ArrayAppend(AntiSamyJarPath, ExpandPath("/coldbox/system/extras/AntiSamy/batik-css.jar"));
			ArrayAppend(AntiSamyJarPath, ExpandPath("/coldbox/system/extras/AntiSamy/xml-apis-ext.jar"));
			
			//Load .jar files
			getPlugin("JavaLoader").setup(loadPaths=AntiSamyJarPath,loadColdFusionClassPath = true);
			
			// AntiSamy policyfile
			instance.PolicyFileStruct['antisamy'] = expandPath('/coldbox/system/extras/AntiSamy/antisamy-1.2.xml');
			//Load eBay policyfile
			instance.PolicyFileStruct['ebay']	  = expandPath('/coldbox/system/extras/AntiSamy/antisamy-ebay-1.2.xml');
			//Load myspacwe policyfile
			instance.PolicyFileStruct['myspace']  = expandPath('/coldbox/system/extras/AntiSamy/antisamy-myspace-1.2.xml');
			//Load salshdot policyfile
			instance.PolicyFileStruct['slashdot'] = expandPath('/coldbox/system/extras/AntiSamy/antisamy-slashdot-1.2.xml');
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- HTML Sanitizer --->
	<cffunction name="HtmlSanitizer" returntype="Any" output="false" hint="clean HTML from XSS scripts using the AntiSamy project. The available policies are antisamy, ebay,myspace or slashdot">
		<!--- ************************************************************* --->
		<cfargument name="HtmlData"		type="string" required="true" hint="The html text to sanitize">
		<cfargument name="PolicyFile"	type="string" required="false" default="myspace" hint="Provide policy file to scan html. Available options are: 'antisamy, ebay, myspace, slashdot'">
		<!--- ************************************************************* --->
		<cfscript>
			// you can use any xml, our your own customised policy xml
			var CleanedHtml  = "";
			var AntiSamy	= getPlugin("JavaLoader").create("org.owasp.validator.html.AntiSamy");
			
			CleanedHtml	= AntiSamy.scan(arguments.HtmlData, instance.PolicyFileStruct[arguments.PolicyFile]);
			
			return CleanedHtml.getCleanHTML(); 
		</cfscript>
	</cffunction>
	
</cfcomponent>
