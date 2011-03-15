<cfcomponent hint="Compiles Java source dirs to an array of .jar files." output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor" access="public" returntype="JavaCompiler" output="false">
	<cfargument name="jarDirectory" hint="the directory to build the .jar file in, defaults to ./tmp" type="string" required="No" default="#getDirectoryFromPath(getMetadata(this).path)#/tmp">
	<cfscript>
		var data = {};
		var defaultCompiler = "com.sun.tools.javac.api.JavacTool";

		//we have to manually go looking for the compiler

		try
		{
			data.compiler = getPageContext().getClass().getClassLoader().loadClass(defaultCompiler).newInstance();
		}
		catch(any exc)
		{
			println("Error loading compiler:");
			println(exc.toString());
		}

		/*
		If not by THIS point do we have a compiler, then throw an exception
		 */
		if(NOT StructKeyExists(data, "compiler"))
		{
			throwException("javaCompiler.NoCompilerAvailableException",
				"No Java Compiler is available",
				"There is no Java Compiler available. Make sure tools.jar is in your classpath and you are running Java 1.6+");
		}

		setCompiler(data.compiler);
		setJarDirectory(arguments.jarDirectory);

		return this;
	</cfscript>
</cffunction>

<cffunction name="compile" hint="compiles Java to bytecode, and returns a JAR" access="public" returntype="any" output="false">
	<cfargument name="directoryArray" hint="array of directories to compile" type="array" required="Yes">
	<cfargument name="classLoader" hint="a optional URLClassloader to use as the parent for compilation" type="any" required="false">
    <cfargument name="jarName" hint="The name of the jar file. Defaults to a UUID" type="string" required="false" default="#createUUID()#.jar">	
	<cfscript>
		//setup file manager with default exception handler, default locale, and default character set
		var fileManager = getCompiler().getStandardFileManager(JavaCast("null", ""), JavaCast("null", ""), JavaCast("null", ""));
		var qFiles = 0;
		var fileArray = [];
		var directoryToCompile = 0;
		var fileObjects = 0;
		var osw = createObject("java", "java.io.StringWriter").init();
		var options = [];
		var compilePass = 0;
		var jarPath = getJarDirectory() & "/" & arguments.jarName;
    </cfscript>

	<cfloop array="#arguments.directoryArray#" index="directoryToCompile">
		<cfdirectory action="list" directory="#directoryToCompile#" name="qFiles" recurse="true" filter="*.java">

		<cfloop query="qFiles">
			<cfscript>
				ArrayAppend(fileArray, qFiles.directory & "/" & qFiles.name);
	        </cfscript>
		</cfloop>

		<cfscript>
			if(structKeyExists(arguments, "classLoader"))
			{
				options = addClassLoaderFiles(options, arguments.classLoader, arguments.directoryArray);
			}

			fileObjects = fileManager.getJavaFileObjectsFromStrings(fileArray);
        </cfscript>
	</cfloop>

	<cfscript>
		//does the compilation
		compilePass = getCompiler().getTask(osw, fileManager, JavaCast("null", ""), options, JavaCast("null", ""), fileObjects).call();

		if(NOT compilePass)
		{
			throwException("javacompiler.SourceCompilationException", "There was an error compiling your source code", osw.toString());
		}
    </cfscript>

	<!--- wrap it up in a jar --->
	<cfloop array="#arguments.directoryArray#" index="directoryToCompile">
		<!--- do this again, as if there ARE files in it, we should create a .jar --->
		<cfdirectory action="list" directory="#directoryToCompile#" name="qFiles">

		<!--- can't do zips on empty directories --->
		<cfif qFiles.recordCount>
			<cfzip action="zip" file="#jarPath#" recurse="yes" source="#directoryToCompile#" overwrite="no">
		</cfif>
	</cfloop>

	<!--- we won't bother with an manifest, as we don't really need one --->

	<cfreturn jarPath />
</cffunction>

<cffunction name="getVersion" hint="returns the version number" access="public" returntype="string" output="false">
	<cfreturn "0.1.b" />
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="addClassLoaderFiles" hint="adds a set of files to the file manager from the urlclassloader" access="private" returntype="array" output="false">
	<cfargument name="options" hint="the options array" type="array" required="Yes">
	<cfargument name="classLoader" hint="URLClassloader to use as the parent for compilation" type="any" required="true">
	<cfargument name="directoryArray" hint="array of directories to compile" type="array" required="Yes">
	<cfscript>
		var urls = 0;
		var uri = 0;
		var classPaths = createObject("java", "java.lang.StringBuilder").init();
		var File = createObject("java", "java.io.File");
		var path = 0;
    </cfscript>

	<!--- add in the classloader, and all its parents --->
	<cfloop condition="#structKeyExists(arguments, "classLoader")#">
		<cfset urls = arguments.classLoader.getURLs()>
		<cfloop array="#urls#" index="uri">
			<cfscript>
				classPaths.append(uri.getFile()).append(File.pathSeparator);
            </cfscript>
		</cfloop>
		<cfset arguments.classLoader = arguments.classLoader.getParent()>
	</cfloop>

	<!--- add in the folders we are compiling from --->
	<cfloop array="#arguments.directoryArray#" index="path">
		<cfset classPaths.append(path).append(File.pathSeparator)>
	</cfloop>

	<cfscript>
		ArrayAppend(arguments.options, "-classpath");
		ArrayAppend(arguments.options, classPaths.toString());

		return arguments.options;
    </cfscript>
</cffunction>

<cffunction name="getCompiler" access="private" returntype="any" output="false">
	<cfreturn instance.Compiler />
</cffunction>

<cffunction name="setCompiler" access="private" returntype="void" output="false">
	<cfargument name="Compiler" type="any" required="true">
	<cfset instance.Compiler = arguments.Compiler />
</cffunction>

<cffunction name="getJarDirectory" access="private" returntype="string" output="false">
	<cfreturn instance.jarDirectory />
</cffunction>

<cffunction name="setJarDirectory" access="private" returntype="void" output="false">
	<cfargument name="jarDirectory" type="string" required="true">
	<cfset instance.jarDirectory = arguments.jarDirectory />
</cffunction>

<cffunction name="throwException" access="private" hint="Throws an Exception" output="false">
	<cfargument name="type" hint="The type of exception" type="string" required="Yes">
	<cfargument name="message" hint="The message to accompany the exception" type="string" required="Yes">
	<cfargument name="detail" type="string" hint="The detail message for the exception" required="No" default="">
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#">
</cffunction>

<cffunction name="println" hint="" access="private" returntype="void" output="false">
	<cfargument name="str" hint="" type="string" required="Yes">
	<cfscript>
		createObject("Java", "java.lang.System").out.println(arguments.str);
	</cfscript>
</cffunction>

</cfcomponent>