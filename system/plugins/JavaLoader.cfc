<!------------------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
<cfcomponent hint="Loads External Java Classes, while providing access to ColdFusion classes"
			 extends="coldbox.system.Plugin"
			 output="false"
			 singleton="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="JavaLoader" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<!--- ************************************************************* --->
		<cfscript>
			var dirs = arrayNew(1);
			var x    = 1;
			
			super.init(arguments.controller);
			
			// Plugin Properties
			setpluginName("Java Loader");
			setpluginVersion("2.0");
			setpluginDescription("Java Loader plugin, based on Mark Mandel's brain.");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			
			// Set a static ID for the loader
			setStaticIDKey("cbox-javaloader-#getController().getAppHash()#");
			
			// Set up default lib paths by looking at its settings?
			if( settingExists("javaloader_libpath") ){
				dirs = getSetting("javaloader_libpath");
				// Convert simple location to array format
				if( isSimpleValue(dirs) ){ dirs = listToArray(dirs); }
				// iterate and classload
				for(x=1; x lte arrayLen(dirs); x=x+1){
					appendPaths( dirs[x] );
				}
			}
			else{
				setup();
			}
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Setup the Loader --->
	<cffunction name="setup" hint="Setup the URL loader with paths to load and how to treat class loaders" access="public" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="loadPaths" 				type="array" 	required="false" default="#ArrayNew(1)#" hint="An array of directories of classes, or paths to .jar files to load">
		<cfargument name="loadColdFusionClassPath"  type="boolean"  required="false" default="false" hint="Loads the ColdFusion libraries">
		<cfargument name="parentClassLoader" 		type="any" 		required="false" default=""  hint="(Expert use only) The parent java.lang.ClassLoader to set when creating the URLClassLoader">
		<!--- ************************************************************* --->
			<cfset var JavaLoader = "">
			
			<!--- setup the javaloader --->
			<cfif ( not isJavaLoaderInScope() )>
				<cflock name="#getStaticIDKey()#" throwontimeout="true" timeout="30" type="exclusive">
					<cfif ( not isJavaLoaderInScope() )>
						<!--- Place java loader in scope, create it. --->
						<cfset setJavaLoaderInScope( CreateObject("component","coldbox.system.core.javaloader.JavaLoader").init(argumentCollection=arguments) )>
					</cfif>
				</cflock>
			<cfelse>
				<cflock name="#getStaticIDKey()#" throwontimeout="true" timeout="30" type="readonly">
					<!--- Get the javaloader. --->
					<cfset getJavaLoaderFromScope().init(argumentCollection=arguments)>
				</cflock>
			</cfif>
	</cffunction>
	
	<!--- getJavaLoader --->
    <cffunction name="getJavaLoader" output="false" access="public" returntype="any" hint="Get the original JavaLoader object">
    	<cfreturn getJavaLoaderFromScope()>
    </cffunction>

	<!--- Create a Class --->
	<cffunction name="create" hint="Retrieves a reference to the java class. To create a instance, you must run init() on this object" access="public" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="className" hint="The name of the class to create" type="string" required="Yes">
		<!--- ************************************************************* --->
		<cfreturn getJavaLoaderFromScope().create(argumentCollection=arguments)>
	</cffunction>
	
	<!--- appendPaths --->
	<cffunction name="appendPaths" output="false" access="public" returntype="void" hint="Appends a directory path of *.jar's,*.classes to the current loaded class loader.">
		<cfargument name="dirPath" type="string" required="true" default="" hint="The directory path to query"/>
		<cfargument name="filter"  type="string" required="false" default="*.jar" hint="The directory filter to use"/>
		<cfscript>
			// Convert paths to array of file locations
			var qFiles	  		= queryJars(argumentCollection=arguments);
			var iterator 		= qFiles.iterator();
			var thisFile 		= "";
			var URLClassLoader  = "";
			
			// Try to check if javaloader in scope? else, set it up.
			if( NOT isJavaLoaderInScope() ){
				setup(qFiles);
				return;
			}
			
			// Get URL Class Loader
			URLClassLoader = getURLClassLoader();
			
			// Try to load new locations
			while( iterator.hasNext() ){
				thisFile = createObject("java", "java.io.File").init(iterator.next());
				if(NOT thisFile.exists()){
					$throw(message="The path you have specified could not be found",detail=thisFile.getAbsolutePath() & "does not exist",type="PathNotFoundException");
				}
				// Load up the URL
				URLClassLoader.addUrl(thisFile.toURL());
			}		
		</cfscript>
	</cffunction>
	
	<!--- getLoadedURLs --->
	<cffunction name="getLoadedURLs" output="false" access="public" returntype="array" hint="Returns the paths of all the loaded java classes and resources.">
		<cfscript>
			var loadedURLs 	= getURLClassLoader().getURLs();
			var returnArray = arrayNew(1);
			var x			= 1;
			
			for(x=1; x lte ArrayLen(loadedURLs); x=x+1){
				arrayAppend(returnArray, loadedURLs[x].toString());
			}
			
			return returnArray;
		</cfscript>
	</cffunction>

	<!--- Get URL Class Loader --->
	<cffunction name="getURLClassLoader" hint="Returns the java.net.URLClassLoader in case you need access to it" access="public" returntype="any" output="false">
		<cfreturn getJavaLoaderFromScope().getURLClassLoader() />
	</cffunction>

	<!--- Get This Version --->
	<cffunction name="getVersion" hint="Retrieves the version of the loader you are using" access="public" returntype="string" output="false">
		<cfreturn getJavaLoaderFromScope().getVersion()>
	</cffunction>
	
	<!--- Get the static javaloder id --->
	<cffunction name="getStaticIDKey" access="public" returntype="string" output="false" hint="Return the original server id static key">
		<cfreturn instance.staticIDKey>
	</cffunction>
	
	<!--- set the static javaloader id --->
	<cffunction name="setStaticIDKey" access="public" returntype="void" output="false" hint="override the static server key for this javaloader instance.">
		<cfargument name="staticIDKey" type="string" required="true">
		<cfset instance.staticIDKey = arguments.staticIDKey>
	</cffunction>
	
	<!--- Get jars from a path as an array --->
	<cffunction name="queryJars" hint="pulls a query of all the jars in the folder passed" access="public" returntype="array" output="false">
		<cfargument name="dirPath" type="string" required="true" default="" hint="The directory path to query"/>
		<cfargument name="filter" type="string" required="false" default="*.jar" hint="The directory filter to use"/>
	
		<cfset var qJars = 0>
		<cfset var aJars = ArrayNew(1)>
		<cfset var path = arguments.dirPath>
		
		<!--- Verify It --->
		<cfif not directoryExists(path)>
			<cfthrow message="Invalid library path" detail="The path is #path#" type="JavaLoader.DirectoryNotFoundException">
		</cfif>
		
		<!--- Get Listing --->
		<cfdirectory action="list" name="qJars" directory="#path#" filter="#arguments.filter#" sort="name desc"/>
		
		<!--- Loop and create the array that we will use to load. --->
		<cfloop query="qJars">
			<cfset ArrayAppend(aJars, directory & "/" & name)>
		</cfloop>
	
		<cfreturn aJars>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- setJavaLoaderInScope --->
	<cffunction name="setJavaLoaderInScope" output="false" access="private" returntype="any" hint="Set the javaloader in server scope">
		<!--- ************************************************************* --->
		<cfargument name="javaloader" required="true" type="coldbox.system.core.javaloader.javaLoader" hint="The javaloader instance to scope">
		<!--- ************************************************************* --->
		<cfscript>
			structInsert(server, getstaticIDKey(), arguments.javaloader);
		</cfscript>
	</cffunction>
	
	<!--- getJavaLoaderFromScope --->
	<cffunction name="getJavaLoaderFromScope" output="false" access="private" returntype="any" hint="Get the javaloader from server scope">
		<cfscript>
			return server[getstaticIDKey()];
		</cfscript>
	</cffunction>
	
	<!--- isJavaLoaderInScope --->
	<cffunction name="isJavaLoaderInScope" output="false" access="private" returntype="boolean" hint="Checks if the javaloader has been loaded into server scope">
		<cfscript>
			return structKeyExists( server, getstaticIDKey());
		</cfscript>
	</cffunction>	
	
</cfcomponent>