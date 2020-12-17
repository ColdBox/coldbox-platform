/**
 * Build process for ColdBox Modules
 * Adapt to your needs.
 */
component{

    /**
     * Constructor
     */
    function init(){
        // Setup Pathing
        variables.cwd           = getCWD().reReplace( "\.$", "" );
        variables.artifactsDir  = cwd & "/.artifacts";
        variables.buildDir      = cwd & "/.tmp";
        variables.apiDocsURL    = "http://localhost:60299/apidocs/";
        variables.testRunner    = "http://localhost:60299/tests/runner.cfm";

        // Source Excludes Not Added to final binary
        variables.excludes      = [
            ".gitignore",
            ".travis.yml",
            ".artifacts",
            ".tmp",
            "build",
            "test-harness",
            ".DS_Store",
            ".git"
        ];

        // Cleanup + Init Build Directories
        [ variables.buildDir, variables.artifactsDir ].each( function( item ){
            if( directoryExists( item ) ){
                directoryDelete( item, true );
            }
            // Create directories
            directoryCreate( item, true, true );
		} );

		// Create Mappings
		fileSystemUtil.createMapping( "coldbox", variables.cwd & "test-harness/coldbox" );

        return this;
    }

    /**
     * Run the build process: test, build source, docs, checksums
     *
     * @projectName The project name used for resources and slugs
     * @version The version you are building
     * @buldID The build identifier
     * @branch The branch you are building
     */
    function run(
        required projectName,
        version="1.0.0",
        buildID=createUUID(),
        branch="development"
    ){
		// Create project mapping
		fileSystemUtil.createMapping( arguments.projectName, variables.cwd );

        // Run the tests
        runTests();

        // Build the source
        buildSource( argumentCollection=arguments );

        // Build Docs
        arguments.outputDir = variables.buildDir & "/apidocs";
        docs( argumentCollection=arguments );

        // checksums
		buildChecksums();

		// Build latest changelog
		latestChangelog();

        // Finalize Message
        print.line()
            .boldMagentaLine( "Build Process is done! Enjoy your build!" )
            .toConsole();
    }

    /**
     * Run the test suites
     */
    function runTests(){
        // Tests First, if they fail then exit
        print.blueLine( "Testing the package, please wait..." ).toConsole();

        command( 'testbox run' )
            .params(
                runner = variables.testRunner,
				verbose = true,
				outputFile = "build/results.json"
            )
            .run();

        // Check Exit Code?
        if( shell.getExitCode() ){
            return error( "Cannot continue building, tests failed!" );
        }
    }

    /**
     * Build the source
	 *
	 * @projectName The project name used for resources and slugs
     * @version The version you are building
     * @buldID The build identifier
     * @branch The branch you are building
     */
    function buildSource(
        required projectName,
        version="1.0.0",
        buildID=createUUID(),
        branch="development"
    ){
        // Build Notice ID
        print.line()
            .boldMagentaLine( "Building #arguments.projectName# v#arguments.version#+#arguments.buildID# from #cwd# using the #arguments.branch# branch." )
            .toConsole();

        // Prepare exports directory
        variables.exportsDir = variables.artifactsDir & "/#projectName#/#arguments.version#";
        directoryCreate( variables.exportsDir, true, true );

        // Project Build Dir
        variables.projectBuildDir = variables.buildDir & "/#projectName#";
        directoryCreate( variables.projectBuildDir, true, true );

        // Copy source
        print.blueLine( "Copying source to build folder..." ).toConsole();
        copy( variables.cwd, variables.projectBuildDir );

        // Create build ID
        fileWrite( "#variables.projectBuildDir#/#projectName#-#version#+#buildID#", "Built with love on #dateTimeFormat( now(), "full")#" );

        // Updating Placeholders
        print.greenLine( "Updating version identifier to #arguments.version#" ).toConsole();
        command( 'tokenReplace' )
            .params(
                path = "/#variables.projectBuildDir#/**",
                token = "@build.version@",
                replacement = arguments.version
            )
            .run();

        print.greenLine( "Updating build identifier to #arguments.buildID#" ).toConsole();
        command( 'tokenReplace' )
            .params(
                path = "/#variables.projectBuildDir#/**",
                token = ( arguments.branch == "master" ? "@build.number@" : "+@build.number@" ),
                replacement = ( arguments.branch == "master" ? arguments.buildID : "-snapshot" )
            )
            .run();

        // zip up source
        var destination = "#variables.exportsDir#/#projectName#-#version#.zip";
        print.greenLine( "Zipping code to #destination#" ).toConsole();
        cfzip(
            action="zip",
            file="#destination#",
            source="#variables.projectBuildDir#",
            overwrite=true,
            recurse=true
        );

        // Copy box.json for convenience
        fileCopy( "#variables.projectBuildDir#/box.json", variables.exportsDir );
    }

    /**
     * Produce the API Docs
     */
    function docs( required projectName, version="1.0.0", outputDir=".tmp/apidocs" ){
        // Generate Docs
        print.greenLine( "Generating API Docs, please wait..." ).toConsole();
        directoryCreate( arguments.outputDir, true, true );

        command( 'docbox generate' )
            .params(
                "source"               =  "models",
                "mapping"              =  "models",
                "strategy-projectTitle" = "#arguments.projectName# v#arguments.version#",
                "strategy-outputDir"   = arguments.outputDir
            )
            .run();

        print.greenLine( "API Docs produced at #arguments.outputDir#" ).toConsole();

        var destination = "#variables.exportsDir#/#projectName#-docs-#version#.zip";
        print.greenLine( "Zipping apidocs to #destination#" ).toConsole();
        cfzip(
            action="zip",
            file="#destination#",
            source="#arguments.outputDir#",
            overwrite=true,
            recurse=true
        );
	}

	/**
	 * Build the latest changelog file: changelog-latest.md
	 */
	function latestChangelog(){
		print.blueLine( "Building latest changelog..." ).toConsole();

		if( !fileExists( variables.cwd & "changelog.md" ) ){
			return error( "Cannot continue building, changelog.md file doesn't exist!" );
		}

		fileWrite(
			variables.cwd & "changelog-latest.md",
			fileRead( variables.cwd & 'changelog.md' ).split( '----' )[2].trim() & chr( 13 ) & chr( 10 )
		);

		print
			.greenLine( "Latest changelog file created at `changelog-latest.md`" )
			.line()
			.line( fileRead( variables.cwd & "changelog-latest.md" ) );
	}

    /********************************************* PRIVATE HELPERS *********************************************/

    /**
     * Build Checksums
     */
    private function buildChecksums(){
        print.greenLine( "Building checksums" ).toConsole();
        command( 'checksum' )
            .params( path = '#variables.exportsDir#/*.zip', algorithm = 'SHA-512', extension="sha512", write=true )
            .run();
        command( 'checksum' )
            .params( path = '#variables.exportsDir#/*.zip', algorithm = 'md5', extension="md5", write=true )
            .run();
    }

    /**
     * DirectoryCopy is broken in lucee
     */
    private function copy( src, target, recurse=true ){
        // process paths with excludes
        directoryList( src, false, "path", function( path ){
            var isExcluded = false;
            variables.excludes.each( function( item ){
                if( path.replaceNoCase( variables.cwd, "", "all" ).findNoCase( item ) ){
                    isExcluded = true;
                }
            } );
            return !isExcluded;
        }).each( function( item ){
            // Copy to target
            if( fileExists( item ) ){
                print.blueLine( "Copying #item#" ).toConsole();
                fileCopy( item, target );
            } else {
                print.greenLine( "Copying directory #item#" ).toConsole();
                directoryCopy( item, target & "/" & item.replace( src, "" ), true );
            }
        } );
    }

    /**
	 * Gets the last Exit code to be used
	 **/
	private function getExitCode() {
		return (createObject( 'java', 'java.lang.System' ).getProperty( 'cfml.cli.exitCode' ) ?: 0);

	}

}