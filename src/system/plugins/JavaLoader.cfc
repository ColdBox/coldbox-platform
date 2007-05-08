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
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="JavaLoader" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("Java Loader")>
		<cfset setpluginVersion("1.0")>
		<cfset setpluginDescription("Java Loader plugin, based on Mark Mandel's brain.")>
		<!--- This plugins' properties --->
		<cfset variables.instance.classLoader = "">
		<cfreturn this>
	</cffunction>


<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="setup" hint="setup the loader" access="public" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="loadPaths" hint="A comma delimited list of paths to load into the loader, these path(s) will be expanded here. This will be converted into an array" 		type="any" default="" required="no">
		<cfargument name="parentClassLoader" hint="(Expert use only) The parent java.lang.ClassLoader to set when creating the URLClassLoader"  type="any" default="#getClass().getClassLoader()#" required="false">
		<!--- ************************************************************* --->
		<cfscript>
			var iterator = "";
			var Array = createObject("java", "java.lang.reflect.Array");
			var Class = createObject("java", "java.lang.Class");
			var URLs = "";
			var file = 0;
			var classLoader = 0;
			var counter = 0;
			var paths = ArrayNew(1);
			var x = 1;

			//Setup the paths
			for (x=1; x lte listlen(arguments.loadPaths); x=x+1){
				arrayAppend(paths, expandPath(listgetat(arguments.loadPaths,x)));
			}
			//Init
			iterator = paths.iterator();
			URLs = Array.newInstance(Class.forName("java.net.URL"), JavaCast("int", ArrayLen(paths)));

			while(iterator.hasNext()){
				file = createObject("java", "java.io.File").init(iterator.next());
				if(NOT file.exists()){
					throw("The path you have specified could not be found", file.getAbsolutePath() & " does not exist", "Framework.plugins.JavaLoader.PathNotFoundException");
				}
				Array.set(URLs, JavaCast("int", counter), file.toURL());
				counter = counter + 1;
			}

			//alternate approach to getting the system class loader
			//var Thread = createObject("java", "java.lang.Thread");
			//classLoader = createObject("java", "java.net.URLClassLoader").init(URLs, Thread.currentThread().getContextClassLoader());

			//pass in the system loader
			classLoader = createObject("java", "java.net.URLClassLoader").init(URLs, arguments.parentClassLoader);
			setURLClassLoader(classLoader);
			return this;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="create" hint="Retrieves a reference to the java class. To create a instance, you must run init() on this object" access="public" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="className" hint="The name of the class to create" type="string" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			var class = getURLClassLoader().loadClass(arguments.className);
			return createObject("java", "coldfusion.runtime.java.JavaProxy").init(class);
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getURLClassLoader" hint="Returns the java.net.URLClassLoader in case you need access to it" access="public" returntype="any" output="false">
		<cfreturn instance.ClassLoader />
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getVersion" hint="Retrieves the version of the loader you are using" access="public" returntype="string" output="false">
		<cfreturn "0.2">
	</cffunction>

	<!--- ************************************************************* --->

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="setURLClassLoader" access="private" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="ClassLoader" type="any" required="true">
		<!--- ************************************************************* --->
		<cfset instance.ClassLoader = arguments.ClassLoader />
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>