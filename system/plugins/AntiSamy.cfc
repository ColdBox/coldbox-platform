<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Sana Ullah
Date     :	November 10, 2008
Description:
			http://www.owasp.org/index.php/Category:OWASP_AntiSamy_Project
			http://code.google.com/p/owaspantisamy/downloads/list
----------------------------------------------------------------------->
<cfcomponent hint="OWASP AntiSamy Project that provides XSS cleanup operations to ColdBox applications"
			 extends="coldbox.system.Plugin"
			 output="false"
			 singleton="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="init" access="public" returntype="AntiSamy" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			var javaLoader 	= "";
			var libPath 	= "/coldbox/system/plugins/AntiSamy-lib";
			
			super.init(arguments.controller);
			
			// Properties
			setpluginName("OWASP AntiSamy Project");
			setpluginVersion("1.4.1");
			setpluginDescription("AntiSamy to protect from XSS hacks.");
			setpluginAuthor("Sana Ullah");
			setpluginAuthorURL("http://www.coldbox.org");
			
			// Create Policy Structure			
			instance.policyFileStruct = StructNew();
			
			// Load jar files.
			getPlugin("JavaLoader").appendPaths(expandPath("#libPath#"));
			
			// AntiSamy policyfile
			instance.policyFileStruct['antisamy'] = expandPath('#libPath#/antisamy-anythinggoes-1.4.4.xml');
			//Load eBay policyfile
			instance.policyFileStruct['ebay']	  = expandPath('#libPath#/antisamy-ebay-1.4.4.xml');
			//Load myspace policyfile
			instance.policyFileStruct['myspace']  = expandPath('#libPath#/antisamy-myspace-1.4.4.xml');
			//Load slashdot policyfile
			instance.policyFileStruct['slashdot'] = expandPath('#libPath#/antisamy-slashdot-1.4.4.xml');
			//Load tinymce policyfile
			instance.policyFileStruct['tinymce'] = expandPath('#libPath#/antisamy-tinymce-1.4.4.xml');
			
			// Custom Policy
			if( settingExists("AntiSamy_Custom_Policy") ){
				instance.policyFileStruct['custom'] = getSetting("AntiSamy_Custom_Policy");
			}
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- HTMLSanitizer --->
	<cffunction name="HTMLSanitizer" returntype="Any" output="false" hint="clean HTML from XSS scripts using the AntiSamy project. The available policies are antisamy, ebay, myspace, slashdot, custom">
		<!--- ************************************************************* --->
		<cfargument name="HTMLData"		 type="string"  required="true" hint="The html text to sanitize">
		<cfargument name="policyFile"	 type="string"  required="false" default="ebay" hint="Provide policy file to scan html. Available options are: antisamy, ebay, myspace, slashdot, tinymce, custom">
		<cfargument name="resultsObject" type="boolean" required="false" default="false" hint="Return the cleaned HTML or the results object. By default it is the cleaned HTML"/>
		<!--- ************************************************************* --->
		<cfscript>
			// you can use any xml, our your own customised policy xml
			var cleanedHtml  = "";
			var antiSamy	= getPlugin("JavaLoader").create("org.owasp.validator.html.AntiSamy");
			
			// validate policy file
			if( NOT structKeyExists(instance.policyFileStruct, arguments.policyFile) ){
				$throw("Invalid Policy File: #arguments.policyFile#","The available policy files are #structKeyList(instance.policyFileStruct)#","AntiSamy.InvalidPolicyException");
			}
			
			// Clean with policy
			cleanedHtml	= antiSamy.scan(arguments.htmlData, instance.policyFileStruct[arguments.policyFile]);
			
			// returning results object or just clean HTML?
			if( arguments.resultsObject ){
				return cleanedHtml;
			} 
			
			return cleanedHTML.getCleanHTML();
		</cfscript>
	</cffunction>
	
</cfcomponent>
