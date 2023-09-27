/**
 * Build process for ColdBox Modules
 * Adapt to your needs.
 */
component {

	/**
	 * Constructor
	 */
	function init(){
		// Setup Pathing
		variables.cwd          = getCWD().reReplace( "\.$", "" );
		variables.artifactsDir = cwd & ".artifacts";
		variables.buildDir     = cwd & ".tmp";
		variables.serverPort   = 8599;
		variables.apiDocs      = "http://localhost:#variables.serverPort#/apidocs";

		// Source Excludes Not Added to final binary
		variables.excludes = [ "^\..*", "build", "test-harness" ];

		variables.libraries = {
			"coldbox" : {
				"standalone" : false,
				"readme"     : "readme.md",
				"boxjson"    : "box-original.json",
				"packages"   : [ "system" ]
			},
			"cachebox" : {
				"standalone" : true,
				"readme"     : "system/cache/readme.md",
				"boxjson"    : "box-cachebox.json",
				"packages"   : [
					"system/async",
					"system/cache",
					"system/core",
					"system/logging"
				]
			},
			"logbox" : {
				"standalone" : true,
				"readme"     : "system/logging/readme.md",
				"boxjson"    : "box-logbox.json",
				"packages"   : [
					"system/async",
					"system/core",
					"system/logging"
				]
			},
			"wirebox" : {
				"standalone" : true,
				"readme"     : "system/ioc/readme.md",
				"boxjson"    : "box-wirebox.json",
				"packages"   : [
					"system/async",
					"system/aop",
					"system/cache",
					"system/core",
					"system/ioc",
					"system/logging"
				]
			}
		};

		// Cleanup + Init Build Directories
		[ variables.buildDir, variables.artifactsDir ].each( function( item ){
			if ( directoryExists( item ) ) {
				directoryDelete( item, true );
			}
			// Create directories
			directoryCreate( item, true, true );
		} );

		// Ensure build directories for each library
		directoryCreate( variables.buildDir & "/dist", true, true )
		directoryCreate( variables.buildDir & "/apidocs", true, true )
		variables.libraries.each( ( lib ) => {
			variables[ lib & "buildDir" ]   = variables.buildDir & "/dist/" & lib
			variables[ lib & "apiDocsDir" ] = variables.buildDir & "/apidocs/" & lib
			directoryCreate( variables[ lib & "buildDir" ], true, true )
			directoryCreate( variables[ lib & "apiDocsDir" ], true, true )
			directoryCreate( variables.artifactsDir & "/#lib#", true, true )
		} );

		// Done!
		systemOutput( "Build Process Initialized at [#variables.cwd#]", true );

		return this;
	}

	/**
	 * Run the build process for all the libraries
	 *
	 * @version The version you are building
	 * @buldID  The build identifier
	 * @branch  The branch you are building
	 * @docs Whether to build the docs or not
	 * @tests Whether to run the tests or not
	 */
	function run(
		version = "1.0.0",
		buildID = createUUID(),
		branch  = "development",
		boolean docs = true,
		boolean tests = false
	){
		// Build the source distributions
		variables.libraries.each( ( lib ) => {
			variables.print
				.line()
				.blueLine( "************************************************************" )
				.boldBlueLine( "< Building Source For [#arguments.lib#] >" )
				.blueLine( "************************************************************" )
				.toConsole()
			buildSource(
				library: arguments.lib,
				version: version,
				buildID: buildID,
				branch : branch
			);
		} );

		// Build the API Docs
		if( arguments.docs ){
			buildDocs( argumentCollection = arguments );
		}

		// RUn tests
		if( arguments.tests ){
			runTests();
		}

		// Finalize Message
		variables.print
			.line()
			.greenLine( "************************************************************" )
			.boldGreenLine( "√ Build Process is done, enjoy your build!" )
			.greenLine( "************************************************************" )
			.toConsole();
	}

	/**
	 * Run the test suites
	 *
	 * @segment The specific runner to run or run all runner segments. Available: integration, mvc, cachebox, logbox, wirebox, core, async
	 */
	function runTests( segment ){
		// Tests First, if they fail then exit
		variables.print
			.blueLine( "*********************************************" )
			.blueBoldLine( "Starting Tests" )
			.blueLine( "*********************************************" )
			.toConsole();

		var runners = {
			"integration" : "runner-integration.cfm",
			"mvc"         : "runner.cfm",
			"cachebox"    : "runner-cachebox.cfm",
			"logbox"      : "runner-logbox.cfm",
			"wirebox"     : "runner-wirebox.cfm",
			"core"        : "runner-core.cfm",
			"async"       : "runner-async.cfm"
		};

		runners.each( ( type, runner ) => {

			if( !isNull( segment ) && type != segment ){
				return;
			}

			print.blueLine( "> Running [#arguments.type#] tests..." ).toConsole();
			directoryCreate(
				variables.cwd & "tests/results/#arguments.type#",
				true,
				true
			);
			command( "testbox run" )
				.params(
					runner        = "http://localhost:#variables.serverPort#/tests/#arguments.runner#",
					verbose       = false,
					outputFile    = "tests/results/#arguments.type#/test-results",
					outputFormats = "json,antjunit"
				)
				.run();
		} );

		variables.print
			.blueLine( "*********************************************" )
			.blueBoldLine( "Tests Finalized" )
			.blueLine( "*********************************************" )
			.toConsole();
	}

	/**
	 * Build the source of the specificed library
	 *
	 * @library The library to generate docs for: coldbox, wirebox, cachebox, and logbox
	 * @version The version you are building
	 * @buldID  The build identifier
	 * @branch  The branch you are building
	 */
	function buildSource(
		required library,
		version = "1.0.0",
		buildID = createUUID(),
		branch  = "development"
	){
		// Build Notice ID
		print
			.line()
			.boldMagentaLine( "Building [#arguments.library#] v#arguments.version#+#arguments.buildID# from [#cwd#] using the [#arguments.branch#] branch." )
			.toConsole();

		// Prep records
		var libRecord      = variables.libraries[ arguments.library ];
		var libArtifactDir = ensureExportDir( arguments.library, arguments.version );
		var libBuildDir    = variables[ arguments.library & "buildDir" ];

		// Create build ID
		fileWrite(
			"#libBuildDir#/#arguments.library#-#arguments.version#+#arguments.buildID#",
			"Built with love on #dateTimeFormat( now(), "full" )#"
		);

		// Copy Sources
		libRecord.packages.each( ( package ) => {
			copy( variables.cwd & "#package#", libBuildDir & "/#package#" )
		} );
		copy( variables.cwd & "license.txt", libBuildDir );
		copy( variables.cwd & libRecord.readme, libBuildDir );
		copy( variables.cwd & libRecord.boxjson, libBuildDir & "/box.json" );

		// Updating Placeholders
		print.greenLine( "Updating version identifier to [#arguments.version#]..." ).toConsole();
		command( "tokenReplace" )
			.params(
				path        = "/#libBuildDir#/**",
				token       = "@build.version@",
				replacement = arguments.version,
				verbose     = true
			)
			.run();

		print.greenLine( "Updating build identifier to [#arguments.buildID#]..." ).toConsole();
		command( "tokenReplace" )
			.params(
				path        = "/#libBuildDir#/**",
				token       = ( arguments.branch == "master" ? "@build.number@" : "+@build.number@" ),
				replacement = ( arguments.branch == "master" ? arguments.buildID : "-snapshot" ),
				verbose     = true
			)
			.run();

		// Refactor Paths
		if ( libRecord.standalone ) {
			print.greenLine( "Refactoring for standalone paths ..." ).toConsole();
			command( "tokenReplace" )
				.params(
					path        = "/#libBuildDir#/**",
					token       = "/coldbox/system/",
					replacement = "/#arguments.library#/system/",
					verbose     = true
				)
				.run();
			command( "tokenReplace" )
				.params(
					path        = "/#libBuildDir#/**",
					token       = "coldbox.system.",
					replacement = "#arguments.library#.system.",
					verbose     = true
				)
				.run();
		}

		// Zip Bundle
		print.greenLine( "Zipping code to [#libArtifactDir#]..." ).toConsole();
		cfzip(
			action    = "zip",
			file      = "#libArtifactDir#/#arguments.library#-#arguments.version#.zip",
			source    = "#libBuildDir#",
			overwrite = true,
			recurse   = true
		);

		// Copy To project artifacts for convenience
		copy( "#libBuildDir#/box.json", libArtifactDir );
		copy( "#libBuildDir#/readme.md", libArtifactDir );

		// Build Checksums
		buildChecksums( libArtifactDir );

		// Move BE to root
		print.greenLine( "Moving BE artifacts..." ).toConsole();
		copy(
			"#libArtifactDir#/#arguments.library#-#arguments.version#.zip",
			"#variables.artifactsDir#/#arguments.library#-be.zip"
		);
	}

	/**
	 * Produce the API Docs
	 *
	 * @version The version you are building
	 */
	function buildDocs( version = "1.0.0" ) depends="buildSource"{
		variables.libraries.each( ( library ) => {
			// Prep records
			var libRecord      = variables.libraries[ arguments.library ];
			var libArtifactDir = ensureExportDir( arguments.library, version );
			var libBuildDir    = variables[ arguments.library & "buildDir" ];
			var libApiDocsDir  = variables[ library & "apiDocsDir" ];
			var docsUrl        = "#variables.apiDocs#/#arguments.library#.cfm?" &
			"version=#version#&" &
			"path=#urlEncodedFormat( libApiDocsDir )#&" &
			"root=#urlEncodedFormat( variables.buildDir & "/dist/" )#";

			variables.print
				.blueLine( "************************************************************" )
				.boldBlueLine( "Building the [#arguments.library#] api docs, please wait..." )
				.line( "+ Doc Url: #docsUrl#" )
				.blueLine( "************************************************************" )
				.line()
				.toConsole();

			// Run the docs
			cfhttp( url = docsUrl, result = "local.docResults" );

			if ( local.docResults.status_code > 400 ) {
				variables.print
					.redLine( "********************************************************************" )
					.redLine( "Docs failed to build!" )
					.redLine( "********************************************************************" )
					.redLine( "Results: #local.docResults.filecontent.toString()#" )
					.redLine( "********************************************************************" )
					.toConsole();
			} else {
				print.blueLine( "Docs built, packaging them..." ).toConsole();
			}

			var destination = "#libArtifactDir#/#arguments.library#-apidocs-#version#.zip";
			print.greenLine( "Zipping [#arguments.library#] apidocs to [#destination#]" ).toConsole();
			cfzip(
				action    = "zip",
				file      = "#destination#",
				source    = "#libApiDocsDir#",
				overwrite = true,
				recurse   = true
			);
		} );
	}

	/********************************************* PRIVATE HELPERS *********************************************/

	/**
	 * Build Checksums
	 *
	 * @target The target directory to checksum
	 */
	private function buildChecksums( required target ){
		print.greenLine( "Building checksums..." ).toConsole();
		command( "checksum" )
			.params(
				path      = "#arguments.target#/*.zip",
				algorithm = "SHA-512",
				extension = "sha512",
				write     = true
			)
			.run();
		command( "checksum" )
			.params(
				path      = "#arguments.target#/*.zip",
				algorithm = "md5",
				extension = "md5",
				write     = true
			)
			.run();
	}

	/**
	 * DirectoryCopy is broken in lucee
	 */
	private function copy( src, target, recurse = true ){
		var srcFileInfo = getFileInfo( arguments.src );

		// file or directory
		if ( srcFileInfo.type == "file" ) {
			print.blueLine( "- File Copied [ #arguments.src#]" ).toConsole();
			fileCopy( arguments.src, arguments.target );
			return;
		}

		print.blueLine( "Copying Source [ #arguments.src#] to [#arguments.target#]" ).toConsole();
		if ( !directoryExists( arguments.target ) ) {
			directoryCreate( arguments.target, true, true );
		}

		// process paths with excludes
		directoryList(
			src,
			false,
			"path",
			function( path ){
				var isExcluded = false;
				variables.excludes.each( function( item ){
					if ( path.replaceNoCase( variables.cwd, "", "all" ).reFindNoCase( item ) ) {
						print.yellowLine( " x Excluded [#item#]" ).toConsole();
						isExcluded = true;
					}
				} );
				return !isExcluded;
			}
		).each( function( item ){
			// Copy to target
			if ( fileExists( item ) ) {
				print.blueLine( "- File Copied [#item#]" ).toConsole();
				fileCopy( item, target );
			} else {
				print.blueLine( "- Directory Copied [#item#] to [#target & item.replace( src, "" )#]" ).toConsole();
				directoryCopy(
					item,
					target & "/" & item.replace( src, "" ),
					true
				);
			}
		} );
	}

	/**
	 * Gets the last Exit code to be used
	 **/
	private function getExitCode(){
		return ( createObject( "java", "java.lang.System" ).getProperty( "cfml.cli.exitCode" ) ?: 0 );
	}

	/**
	 * Ensure the export directory exists at artifacts/{library}/{version}/
	 */
	private function ensureExportDir( required library, version = "1.0.0" ){
		var libExportDir = variables.artifactsDir & "/#arguments.library#/#arguments.version#";

		if ( !directoryExists( libExportDir ) ) {
			directoryCreate( libExportDir, true, true );
		}

		return libExportDir;
	}

}
