<!--- Document Information -----------------------------------------------------

Title:      JavaLoader.cfc

Author:     Mark Mandel
Email:      mark@compoundtheory.com

Website:    http://www.compoundtheory.com

Purpose:    Utlitity class for loading Java Classes

Usage:

Modification Log:

Name			Date			Description
================================================================================
Mark Mandel		08/05/2006		Created
Mark Mandel		22/06/2006		Added verification that the path exists

------------------------------------------------------------------------------->
<cfcomponent name="JavaLoader" hint="Loads External Java Classes, while providing access to ColdFusion classes">

<cfscript>
	instance = StructNew();
	instance.static.uuid = "A0608BEC-0AEB-B46A-0E1E1EC5F3CE7C9C";
</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor" access="public" returntype="JavaLoader" output="false">
	<cfargument name="loadPaths" hint="An array of directories of classes, or paths to .jar files to load" type="array" default="#ArrayNew(1)#" required="no">
	<cfargument name="loadColdFusionClassPath" hint="Loads the ColdFusion libraries" type="boolean" required="No" default="false">
	<cfargument name="parentClassLoader" hint="(Expert use only) The parent java.lang.ClassLoader to set when creating the URLClassLoader" type="any" default="" required="false">

	<cfscript>
		var iterator = arguments.loadPaths.iterator();
		var file = 0;
		var classLoader = 0;
		var networkClassLoaderClass = 0;
		var networkClassLoaderProxy = 0;

		initUseJavaProxyCFC();

		if(arguments.loadColdFusionClassPath)
		{
			//arguments.parentClassLoader = createObject("java", "java.lang.Thread").currentThread().getContextClassLoader();
			//can't use above, as doesn't work in some... things

			arguments.parentClassLoader = getPageContext().getClass().getClassLoader();

			//arguments.parentClassLoader = createObject("java", "java.lang.ClassLoader").getSystemClassLoader();
			//can't use the above, it doesn't have the CF stuff in it.
		}

		ensureNetworkClassLoaderOnServerScope();

		//classLoader = createObject("java", "com.compoundtheory.classloader0.NetworkClassLoader").init();
		networkClassLoaderClass = getServerURLClassLoader().loadClass("com.compoundtheory.classloader.NetworkClassLoader");

		networkClassLoaderProxy = createJavaProxy(networkClassLoaderClass);

		if(isObject(arguments.parentClassLoader))
		{
			classLoader = networkClassLoaderProxy.init(arguments.parentClassLoader);
		}
		else
		{
			classLoader = networkClassLoaderProxy.init();
		}

		while(iterator.hasNext())
		{
			file = createObject("java", "java.io.File").init(iterator.next());
			if(NOT file.exists())
			{
				throw("PathNotFoundException", "The path you have specified could not be found", file.getAbsolutePath() & " does not exist");
			}

			classLoader.addUrl(file.toURL());
		}

		//pass in the system loader
		setURLClassLoader(classLoader);

		return this;
	</cfscript>
</cffunction>

<cffunction name="create" hint="Retrieves a reference to the java class. To create a instance, you must run init() on this object" access="public" returntype="any" output="false">
	<cfargument name="className" hint="The name of the class to create" type="string" required="Yes">
	<cfscript>
		var class = getURLClassLoader().loadClass(arguments.className);

		return createJavaProxy(class);
	</cfscript>
</cffunction>

<cffunction name="getURLClassLoader" hint="Returns the java.net.URLClassLoader in case you need access to it" access="public" returntype="any" output="false">
	<cfreturn instance.ClassLoader />
</cffunction>

<cffunction name="getVersion" hint="Retrieves the version of the loader you are using" access="public" returntype="string" output="false">
	<cfreturn "0.6">
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="ensureNetworkClassLoaderOnServerScope"
			hint="makes sure there is a URL class loader on the server scope that can load me up some networkClassLoader goodness"
			access="private" returntype="void" output="false">
	<cfscript>
		var Class = createObject("java", "java.lang.Class");
		var Array = createObject("java", "java.lang.reflect.Array");
		var jars = queryJars();
		var iterator = jars.iterator();
		var file = 0;
		var urls = Array.newInstance(Class.forName("java.net.URL"), ArrayLen(jars));
		var counter = 0;
		var urlClassLoader = 0;
		var key = instance.static.uuid & "." & getVersion();
		//server scope uuid

		//we have it already? escape.
		if(StructKeyExists(server, key))
		{
			return;
		}

		while(iterator.hasNext())
		{
			Array.set(urls, counter, createObject("java", "java.io.File").init(iterator.next()).toURL());
			counter = counter + 1;
		}

		urlClassLoader = createObject("java", "java.net.URLClassLoader").init(urls);

		//put it on the server scope
		server[key] = urlClassLoader;
	</cfscript>
</cffunction>

<cffunction name="createJavaProxy" hint="create a javaproxy, dependent on CF server settings" access="private" returntype="any" output="false">
	<cfargument name="class" hint="the java class to create the proxy with" type="any" required="Yes">
	<cfscript>
		if(getUseJavaProxyCFC())
		{
			return createObject("component", "JavaProxy")._init(arguments.class);
		}

		return createObject("java", "coldfusion.runtime.java.JavaProxy").init(arguments.class);
	</cfscript>
</cffunction>

<cffunction name="initUseJavaProxyCFC" hint="initialise whether or not to use the JavaProxy CFC instead of the coldfusion java object" access="public" returntype="string" output="false">
	<cfscript>
		setUseJavaProxyCFC(false);

		try
		{
			createObject("java", "coldfusion.runtime.java.JavaProxy");
		}
		catch(Object exc)
		{
			setUseJavaProxyCFC(true);
		}
	</cfscript>
</cffunction>

<cffunction name="queryJars" hint="pulls a query of all the jars in the /resources/lib folder" access="private" returntype="array" output="false">
	<cfscript>
		var qJars = 0;
		//the path to my jar library
		var path = getDirectoryFromPath(getMetaData(this).path) & "lib/";
		var jarList = "";
		var aJars = ArrayNew(1);
		var libName = 0;
	</cfscript>

	<cfdirectory action="list" name="qJars" directory="#path#" filter="*.jar" sort="name desc"/>
	<cfloop query="qJars">
		<cfscript>
			libName = ListGetAt(name, 1, "-");
			//let's not use the lib's that have the same name, but a lower datestamp
			if(NOT ListFind(jarList, libName))
			{
				ArrayAppend(aJars, path & "/" & name);
				jarList = ListAppend(jarList, libName);
			}
		</cfscript>
	</cfloop>

	<cfreturn aJars>
</cffunction>

<cffunction name="getServerURLClassLoader" hint="returns the server URL class loader" access="private" returntype="any" output="false">
	<cfreturn server[instance.static.uuid & "." & getVersion()] />
</cffunction>

<cffunction name="setURLClassLoader" access="private" returntype="void" output="false">
	<cfargument name="ClassLoader" type="any" required="true">
	<cfset instance.ClassLoader = arguments.ClassLoader />
</cffunction>

<cffunction name="getUseJavaProxyCFC" access="private" returntype="boolean" output="false">
	<cfreturn instance.UseJavaProxyCFC />
</cffunction>

<cffunction name="setUseJavaProxyCFC" access="private" returntype="void" output="false">
	<cfargument name="UseJavaProxyCFC" type="boolean" required="true">
	<cfset instance.UseJavaProxyCFC = arguments.UseJavaProxyCFC />
</cffunction>

<cffunction name="throw" access="private" hint="Throws an Exception" output="false">
	<cfargument name="type" hint="The type of exception" type="string" required="Yes">
	<cfargument name="message" hint="The message to accompany the exception" type="string" required="Yes">
	<cfargument name="detail" type="string" hint="The detail message for the exception" required="No" default="">
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#">
</cffunction>

</cfcomponent>