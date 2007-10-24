<!--- Document Information -----------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Title:      JavaLoader.cfc

Author:     Mark Mandel & Luis Majano
Email:      mark@compoundtheory.com
Website:    http://www.compoundtheory.com
Purpose:    Utlitity class for loading Java Classes
Usage:
Modification Log:
Name			Date			Description
================================================================================
Mark Mandel		08/05/2006		Created
Mark Mandel		22/06/2006		Added verification that the path exists
Luis Majano		07/11/2006		Updated it to work with ColdBox. look at license in the install folder.
------------------------------------------------------------------------------->
<cfcomponent name="JavaLoader"
			 hint="Loads External Java Classes, while providing access to ColdFusion classes"
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true" 
			 cachetimeout="0">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="JavaLoader" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("Java Loader")>
		<cfset setpluginVersion("1.0")>
		<cfset setpluginDescription("Java Loader plugin, based on Mark Mandel's brain.")>
		
		<!--- Set a static UUID for the loader --->
		<cfset setStaticIDKey("cbox-javaloader-CF712A27-CF1E-5C1B-90A648E384F900AC")>
		<cfreturn this>
	</cffunction>


<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="setup" hint="setup the loader" access="public" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="loadPaths" hint="An array of directories of classes, or paths to .jar files to load" 
					type="array" default="#ArrayNew(1)#" required="no">
		<cfargument name="loadColdFusionClassPath" hint="Loads the ColdFusion libraries" 
					type="boolean" required="No" default="false">
		<cfargument name="parentClassLoader" hint="(Expert use only) The parent java.lang.ClassLoader to set when creating the URLClassLoader" 
					type="any" default="" required="false">
		<!--- ************************************************************* --->
		<cfscript>
			
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="create" hint="Retrieves a reference to the java class. To create a instance, you must run init() on this object" access="public" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="className" hint="The name of the class to create" type="string" required="Yes">
		<!--- ************************************************************* --->
		<cfreturn getJavaLoaderFromScope().create(argumentCollection=arguments)>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getURLClassLoader" hint="Returns the java.net.URLClassLoader in case you need access to it" access="public" returntype="any" output="false">
		<cfreturn getJavaLoaderFromScope().getURLClassLoader() />
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getVersion" hint="Retrieves the version of the loader you are using" access="public" returntype="string" output="false">
		<cfreturn getJavaLoaderFromScope().getVersion()>
	</cffunction>

	<!--- ************************************************************* --->

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- setJavaLoaderInScope --->
	<cffunction name="setJavaLoaderInScope" output="false" access="public" returntype="any" hint="Set the javaloader in server scope">
		<cfscript>
		
		</cfscript>
	</cffunction>
	
	<!--- getJavaLoaderFromScope --->
	<cffunction name="getJavaLoaderFromScope" output="false" access="public" returntype="any" hint="Get the javaloader from server scope">
		<cfscript>
		
		</cfscript>
	</cffunction>
	
	<!--- isJavaLoaderInScope --->
	<cffunction name="isJavaLoaderInScope" output="false" access="public" returntype="boolean" hint="Checks if the javaloader has been loaded into server scope">
		<cfscript>
		
		</cfscript>
	</cffunction>
	
	<!--- Get the static javaloder id --->
	<cffunction name="getstaticID" access="public" returntype="string" output="false">
		<cfreturn instance.staticID>
	</cffunction>
	
	<!--- set the static javaloader id --->
	<cffunction name="setstaticID" access="public" returntype="void" output="false">
		<cfargument name="staticID" type="string" required="true">
		<cfset instance.staticID = arguments.staticID>
	</cffunction>
	

</cfcomponent>