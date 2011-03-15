<!--- Document Information -----------------------------------------------------

Title:      JavaLoader.cfc

Author:     Mark Mandel
Email:      mark@compoundtheory.com

Website:    http://www.compoundtheory.com

Purpose:    Utlitity class for loading Java Classes

------------------------------------------------------------------------------->
<cfcomponent name="JavaLoader" hint="Loads External Java Classes, while providing access to ColdFusion classes">

<cfscript>
	instance = StructNew();
	instance.static.uuid = "A0608BEC-0AEB-B46A-0E1E1EC5F3CE7C9C";
</cfscript>

<cfimport taglib="tags" prefix="jl">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor" access="public" returntype="JavaLoader" output="false">
	<cfargument name="loadPaths" hint="An array of directories of classes, or paths to .jar files to load" type="array" default="#ArrayNew(1)#" required="no">
	<cfargument name="loadColdFusionClassPath" hint="Loads the ColdFusion libraries" type="boolean" required="No" default="false">
	<cfargument name="parentClassLoader" hint="(Expert use only) The parent java.lang.ClassLoader to set when creating the URLClassLoader" type="any" default="" required="false">
	<cfargument name="sourceDirectories" hint="Directories that contain Java source code that are to be dynamically compiled" type="array" required="No">
	<cfargument name="compileDirectory" hint="the directory to build the .jar file for dynamic compilation in, defaults to ./tmp" type="string" required="No" default="#getDirectoryFromPath(getMetadata(this).path)#/tmp">
	<cfargument name="trustedSource" hint="Whether or not the source is trusted, i.e. it is going to change? Defaults to false, so changes will be recompiled and loaded" type="boolean" required="No" default="false">

	<cfscript>
		initUseJavaProxyCFC();

		if(arguments.loadColdFusionClassPath)
		{
			//arguments.parentClassLoader = createObject("java", "java.lang.Thread").currentThread().getContextClassLoader();
			//can't use above, as doesn't work in some... things

			arguments.parentClassLoader = getPageContext().getClass().getClassLoader();

			//arguments.parentClassLoader = createObject("java", "java.lang.ClassLoader").getSystemClassLoader();
			//can't use the above, it doesn't have the CF stuff in it.
		}

		setClassLoadPaths(arguments.loadPaths);
		setParentClassLoader(arguments.parentClassLoader);

		ensureNetworkClassLoaderOnServerScope();

		loadClasses();

		if(structKeyExists(arguments, "sourceDirectories") AND ArrayLen(arguments.sourceDirectories))
		{
			setJavaCompiler(createObject("component", "JavaCompiler").init(arguments.compileDirectory));
			setSourceDirectories(arguments.sourceDirectories);
			setCompileDirectory(arguments.compileDirectory);

            setTrustedSource(arguments.trustedSource);

			compileSource();

			setSourceLastModified(calculateSourceLastModified());

			//do the method switching for non-trusted source
			if(NOT arguments.trustedSource)
			{
				variables.createWithoutCheck = variables.create;

				StructDelete(this, "create");
				StructDelete(variables, "create");

				this.create = variables.createWithSourceCheck;
			}
		}

		return this;
	</cfscript>
</cffunction>

<cffunction name="create" hint="Retrieves a reference to the java class. To create a instance, you must run init() on this object" access="public" returntype="any" output="false">
	<cfargument name="className" hint="The name of the class to create" type="string" required="Yes">
	<cfscript>
		try
		{
			//do this in one line just for speed.
			return createJavaProxy(getURLClassLoader().loadClass(arguments.className));
		}
		catch(java.lang.ClassNotFoundException exc)
		{
			throwException("javaloader.ClassNotFoundException", "The requested class could not be found.", "The requested class '#arguments.className#' could not be found in the loaded jars/directories.");
		}
	</cfscript>
</cffunction>

<cffunction name="getURLClassLoader" hint="Returns the com.compoundtheory.classloader.NetworkClassLoader in case you need access to it" access="public" returntype="any" output="false">
	<cfreturn instance.ClassLoader />
</cffunction>

<cffunction name="getVersion" hint="Retrieves the version of the loader you are using" access="public" returntype="string" output="false">
	<cfreturn "1.0">
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="createWithSourceCheck" hint="does the create call, but first makes a source check" access="private" returntype="any" output="false">
	<cfargument name="className" hint="The name of the class to create" type="string" required="Yes">
	<cfscript>
		var dateLastModified = calculateSourceLastModified();

		/*
			If the source has changed in any way, recompile and load
		*/
		if(dateCompare(dateLastModified, getSourceLastModified()) eq 1)
		{
			loadClasses();
			compileSource();
		}

		//if all the comilation goes according to plan, set the date last modified
		setSourceLastModified(dateLastModified);

		return createWithoutCheck(argumentCollection=arguments);
    </cfscript>
</cffunction>

<cffunction name="loadClasses" hint="loads up the classes in the system" access="private" returntype="void" output="false">
	<cfscript>
		var iterator = getClassLoadPaths().iterator();
		var file = 0;
		var classLoader = 0;
		var networkClassLoaderClass = 0;
		var networkClassLoaderProxy = 0;

		networkClassLoaderClass = getServerURLClassLoader().loadClass("com.compoundtheory.classloader.NetworkClassLoader");

		networkClassLoaderProxy = createJavaProxy(networkClassLoaderClass);

		if(isObject(getParentClassLoader()))
		{
			classLoader = networkClassLoaderProxy.init(getParentClassLoader());
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
				throwException("javaloader.PathNotFoundException", "The path you have specified could not be found", file.getAbsolutePath() & " does not exist");
			}

			classLoader.addUrl(file.toURL());
		}

		setURLClassLoader(classLoader);
    </cfscript>
</cffunction>

<cffunction name="compileSource" hint="compile dynamic source" access="private" returntype="void" output="false">
	<cfscript>
		var dir = 0;
		var path = 0;

		var paths = 0;
		var file = 0;
		var counter = 1;
		var len = 0;
		var directories = 0;

		//do check to see if the compiled jar is already there
		var jarName = calculateJarName(getSourceDirectories());
		var jar = getCompileDirectory() & "/" & jarName;
    </cfscript>

    <cfif fileExists(jar)>
        <cfif isTrustedSource()>
            <!--- add that jar to the classloader --->
            <cfset file = createObject("java", "java.io.File").init(jar)>
            <cfset getURLClassLoader().addURL(file.toURL())>
            <cfreturn />
        <cfelse>
            <cffile action="delete" file="#jar#"/>
        </cfif>
    </cfif>

	<cftry>
	    <cfset path = getCompileDirectory() & "/" & createUUID()/>

		<cfdirectory action="create" directory="#path#">

		<cfscript>
			//first we copy the source to our tmp dir
			directories = getSourceDirectories();
			len = arraylen(directories);
			for(; counter lte len; counter = counter + 1)
			{
				dir = directories[counter];
				directoryCopy(dir, path);
			}

			//then we compile it, and grab that jar

			paths = ArrayNew(1); //have to write it this way so CF7 compiles
			ArrayAppend(paths, path);

			jar = getJavaCompiler().compile(paths, getURLClassLoader(), jarName);
        </cfscript>

		<!--- add that jar to the classloader --->
		<cfset file = createObject("java", "java.io.File").init(jar)>
		<cfset getURLClassLoader().addURL(file.toURL())>

		<!--- delete the files --->
		<cfif directoryExists(path)>
			<cfdirectory action="delete" recurse="true" directory="#path#">
		</cfif>

        <!--- save the file for when trusted source is on ---->
		<cfif fileExists(jar) AND NOT isTrustedSource()>
			<cffile action="delete" file="#jar#" />
		</cfif>

		<cfcatch>
			<!--- make sure the files are deleted --->
			<cfif directoryExists(path)>
				<cfdirectory action="delete" recurse="true" directory="#path#">
			</cfif>

			<cfrethrow>
		</cfcatch>
	</cftry>
</cffunction>

<cffunction name="calculateJarName" hint="returns the jar file name for a directory array" access="private" returntype="string" output="false">
    <cfargument name="directoryArray" hint="array of directories to compile" type="array" required="Yes">
    <cfscript>
        var file = hash(arrayToList(arguments.directoryArray)) & ".jar";

        return file;
    </cfscript>
</cffunction>

<cffunction name="calculateSourceLastModified" hint="returns what the source last modified was" access="private" returntype="date" output="false">
	<cfscript>
		var lastModified = createDate(1900, 1, 1);
		var dir = 0;
		var qLastModified = 0;
		var directories = getSourceDirectories();
		var len = arraylen(directories);
		var counter = 0;
    </cfscript>

	<!--- cf7 syntax. Yuck. --->
	<cfloop from="1" to="#len#" index="counter">
		<cfset dir = directories[counter]>
		<jl:directory action="list" directory="#dir#" recurse="true"
					type="file"
					sort="dateLastModified desc"
					name="qLastModified">
		<cfscript>
			//it's possible there are no source files.
			if(qLastModified.recordCount)
			{
				//get the latest date modified
				if(dateCompare(lastModified, qlastModified.dateLastModified) eq -1)
				{
					/*
						This is here, because cfdirectory only ever gives you minute accurate modified
						date, which is not good enough.
					*/
					lastModified = createObject("java", "java.util.Date").init(createObject("java", "java.io.File").init(qLastModified.directory & "/" & qLastModified.name).lastModified());
				}
			}
			else
			{
				lastModified = Now();
			}
        </cfscript>
	</cfloop>

	<cfreturn lastModified />
</cffunction>

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
	</cfscript>

	<cfif NOT StructKeyExists(server, key)>
    	<cflock name="javaloader.networkclassloader" throwontimeout="true" timeout="60">
    	<cfscript>
    		if(NOT StructKeyExists(server, key))
    		{
				while(iterator.hasNext())
				{
					Array.set(urls, counter, createObject("java", "java.io.File").init(iterator.next()).toURL());
					counter = counter + 1;
				}

				urlClassLoader = createObject("java", "java.net.URLClassLoader").init(urls);

				//put it on the server scope
				server[key] = urlClassLoader;
			}
    	</cfscript>
    	</cflock>
    </cfif>
</cffunction>

<cffunction name="createJavaProxy" hint="create a javaproxy, dependent on CF server settings" access="private" returntype="any" output="false">
	<cfargument name="class" hint="the java class to create the proxy with" type="any" required="Yes">
	<cfscript>
		return createObject("java", "coldfusion.runtime.java.JavaProxy").init(arguments.class);
	</cfscript>
</cffunction>

<cffunction name="createJavaProxyCFC" hint="create a javaproxy, dependent on CF server settings" access="private" returntype="any" output="false">
	<cfargument name="class" hint="the java class to create the proxy with" type="any" required="Yes">
	<cfscript>
		return createObject("component", "JavaProxy")._init(arguments.class);
	</cfscript>
</cffunction>

<cffunction name="initUseJavaProxyCFC" hint="initialise whether or not to use the JavaProxy CFC instead of the coldfusion java object" access="private" returntype="string" output="false">
	<cfscript>
		try
		{
			createObject("java", "coldfusion.runtime.java.JavaProxy");
		}
		catch(Object exc)
		{
			//do method replacement, as it will be much faster long term
			variables.createJavaProxy = variables.createJavaProxyCFC;
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

<cffunction name="getClassLoadPaths" access="private" returntype="array" output="false">
	<cfreturn instance.classLoadPaths />
</cffunction>

<cffunction name="setClassLoadPaths" access="private" returntype="void" output="false">
	<cfargument name="classLoadPaths" type="array" required="true">
	<cfset instance.classLoadPaths = arguments.classLoadPaths />
</cffunction>

<cffunction name="getParentClassLoader" access="private" returntype="any" output="false">
	<cfreturn instance.parentClassLoader />
</cffunction>

<cffunction name="setParentClassLoader" access="private" returntype="void" output="false">
	<cfargument name="parentClassLoader" type="any" required="true">
	<cfset instance.parentClassLoader = arguments.parentClassLoader />
</cffunction>

<cffunction name="getServerURLClassLoader" hint="returns the server URL class loader" access="private" returntype="any" output="false">
	<cfreturn server[instance.static.uuid & "." & getVersion()] />
</cffunction>

<cffunction name="setURLClassLoader" access="private" returntype="void" output="false">
	<cfargument name="ClassLoader" type="any" required="true">
	<cfset instance.ClassLoader = arguments.ClassLoader />
</cffunction>

<cffunction name="hasJavaCompiler" hint="whether this object has a javaCompiler" access="private" returntype="boolean" output="false">
	<cfreturn StructKeyExists(instance, "javaCompiler") />
</cffunction>

<cffunction name="getJavaCompiler" access="private" returntype="JavaCompiler" output="false">
	<cfreturn instance.javaCompiler />
</cffunction>

<cffunction name="setJavaCompiler" access="private" returntype="void" output="false">
	<cfargument name="javaCompiler" type="JavaCompiler" required="true">
	<cfset instance.javaCompiler = arguments.javaCompiler />
</cffunction>

<cffunction name="getSourceDirectories" access="private" returntype="array" output="false">
	<cfreturn instance.sourceDirectories />
</cffunction>

<cffunction name="setSourceDirectories" access="private" returntype="void" output="false">
	<cfargument name="sourceDirectories" type="array" required="true">
	<cfset instance.sourceDirectories = arguments.sourceDirectories />
</cffunction>

<cffunction name="getSourceLastModified" access="private" returntype="date" output="false">
	<cfreturn instance.sourceLastModified />
</cffunction>

<cffunction name="setSourceLastModified" access="private" returntype="void" output="false">
	<cfargument name="sourceLastModified" type="date" required="true">
	<cfset instance.sourceLastModified = arguments.sourceLastModified />
</cffunction>

<cffunction name="hasSourceLastModified" hint="whether this object has a sourceLastModified" access="private" returntype="boolean" output="false">
	<cfreturn StructKeyExists(instance, "sourceLastModified") />
</cffunction>

<cffunction name="getCompileDirectory" access="private" returntype="string" output="false">
	<cfreturn instance.compileDirectory />
</cffunction>

<cffunction name="setCompileDirectory" access="private" returntype="void" output="false">
	<cfargument name="compileDirectory" type="string" required="true">
	<cfset instance.compileDirectory = arguments.compileDirectory />
</cffunction>

<cffunction name="throwException" access="private" hint="Throws an Exception" output="false">
	<cfargument name="type" hint="The type of exception" type="string" required="Yes">
	<cfargument name="message" hint="The message to accompany the exception" type="string" required="Yes">
	<cfargument name="detail" type="string" hint="The detail message for the exception" required="No" default="">
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#">
</cffunction>

<cffunction name="isTrustedSource" access="private" returntype="boolean" output="false">
	<cfreturn instance.isTrustedSource />
</cffunction>

<cffunction name="setTrustedSource" access="private" returntype="void" output="false">
	<cfargument name="isTrustedSource" type="boolean" required="true">
	<cfset instance.isTrustedSource = arguments.isTrustedSource />
</cffunction>

<!---
Copies a directory.

@param source      Source directory. (Required)
@param destination      Destination directory. (Required)
@param nameConflict      What to do when a conflict occurs (skip, overwrite, makeunique). Defaults to overwrite. (Optional)
@return Returns nothing.
@author Joe Rinehart (joe.rinehart@gmail.com)
@version 1, July 27, 2005
--->
<cffunction name="directoryCopy" access="private" output="true">
    <cfargument name="source" required="true" type="string">
    <cfargument name="destination" required="true" type="string">
    <cfargument name="nameconflict" required="true" default="overwrite">

    <cfset var contents = "" />
    <cfset var dirDelim = createObject("java", "java.lang.System").getProperty("file.separator")>

    <cfif not(directoryExists(arguments.destination))>
        <cfdirectory action="create" directory="#arguments.destination#">
    </cfif>

    <cfdirectory action="list" directory="#arguments.source#" name="contents">

    <cfloop query="contents">
        <cfif contents.type eq "file">
            <cffile action="copy" source="#arguments.source#/#name#" destination="#arguments.destination#/#name#" nameconflict="#arguments.nameConflict#">
        <cfelseif contents.type eq "dir">
            <cfset directoryCopy(arguments.source & dirDelim & name, arguments.destination & dirDelim & name) />
        </cfif>
    </cfloop>
</cffunction>

</cfcomponent>