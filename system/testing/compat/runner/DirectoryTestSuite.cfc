<cfcomponent hint="MXUnit Compat Automatic Test Suite Runner" output="false">

	<cffunction name="run" access="public" hint="Runs a directory of tests via TestBox" returntype="any" output="false">
		<cfargument name="directory" required="true" hint="directory of tests to run">
		<cfargument name="componentPath" required="false" hint="the component path to put in front of all tests found (i.e. 'com.blah'). If no path is passed, we'll attempt to discover it ourselves" default="">
		<cfargument name="recurse" required="false" type="boolean" default="true" hint="whether to recurse down the directory tree">
		<cfargument name="excludes" required="false" default="" hint="list of Tests, in cfc notation, to exclude. uses ListContains so it's as greedy as possible. Currently does not support ant-style syntax or whole-directory filtering">
	
		<cfscript>
			if( NOT len( arguments.componentPath ) ){
				arguments.componentPath = getComponentPath( arguments.directory );
			}
			return new Results( argumentCollection=arguments ); 
		</cfscript>
		
	</cffunction>
	
	<cffunction name="getComponentPath" access="remote" returntype="string" hint="Given a directory path, returns the corresponding CFC package according to CFMX" output="false">
		<cfargument name="path" type="string" required="true" />
		<cfscript>
		var explorer 	= createObject( "component", "CFIDE.componentutils.cfcexplorer" );
		var target 		= explorer.normalizePath( arguments.path );
		var cfcs 		= explorer.getcfcs( true ); //true == refresh cache
		var package 	= "";

		for( var i = 1; i lte arraylen( cfcs ); i++ ){
			var cfc = cfcs[ i ];
			//Assumes that CF always stores path info with fwd slash
			//and strip last element to get path.
			var cfcpath = ListDeleteAt( cfc.path, listlen( cfc.path, "/" ), "/" );

			//Array of structs. Doesn't seem possible to do binary search
			if( cfcpath eq target ){
				package = cfc.package;
				break;
			}
		}

		return package;
		</cfscript>
	</cffunction>

</cfcomponent>