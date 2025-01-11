<cfscript>
	// No cf debugging
	cfsetting( showdebugoutput="false" );
	// GLOBAL VARIABLES
	ASSETS_DIR = expandPath( "/testbox/system/reports/assets" );
	TESTBOX_VERSION = new testBox.system.TestBox().getVersion();
	// TEST LOCATIONS -> UPDATE AS YOU SEE FIT
	rootMapping = "/tests";

	// Local Variables
	rootPath 	= expandPath( rootMapping );
	targetPath 	= rootPath;

	// Incoming Navigation
	param name="url.path" default="";
	if( len( url.path ) ){
		targetPath = getCanonicalPath( rootpath & "/" & url.path );
		// Avoid traversals, reset to root
		if( !findNoCase( rootpath, targetPath ) ){
			targetPath = rootpath;
		}
	}

	// Get the actual execution path
	executePath = rootMapping & ( len( url.path ) ? "/#url.path#" : "/" );
	// Execute an incoming path
	if( !isNull( url.action ) ){
		if( directoryExists( targetPath ) ){
			writeOutput( "#new testbox.system.TestBox( directory=executePath ).run()#" );
		} else {
			writeOutput( "<h2>Invalid Directory: #encodeForHTML( targetPath )#</h2>" );
		}
		abort;
	}

	// Get the tests to navigate
	qResults = directoryList( targetPath, false, "query", "", "name" );

	// Calculate the back navigation path
	if( len( url.path ) ){
		backPath = url.path.listToArray( "/\" );
		backPath.pop();
		backPath = backPath.toList( "/" );
	}
</cfscript>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="generator" content="TestBox v#TESTBOX_VERSION#">
	<title>TestBox Browser</title>
	<cfoutput>
		<style>#fileRead( '#ASSETS_DIR#/css/main.css' )#</style>
		<script>#fileRead( '#ASSETS_DIR#/js/jquery-3.3.1.min.js' )#</script>
		<script>#fileRead( '#ASSETS_DIR#/js/popper.min.js' )#</script>
		<script>#fileRead( '#ASSETS_DIR#/js/bootstrap.min.js' )#</script>
		<script>#fileRead( '#ASSETS_DIR#/js/stupidtable.min.js' )#</script>
	</cfoutput>
</head>
<cfoutput>
<body>

<div id="tb-runner" class="container">

	<!--- Header --->
	<div class="row">
		<div class="col-md-4 text-center mx-auto">
			<img class="mt-3" src="http://www.ortussolutions.com/__media/testbox-185.png" alt="TestBox" id="tb-logo"/>
			<br>
			v#TESTBOX_VERSION#
			<br>
			<a
				href="index.cfm?action=runTestBox&path=#URLEncodedFormat( url.path )#"
				target="_blank"
			>
				<button
					class="btn btn-primary btn-sm my-1"
					type="button">
					Run All
				</button>
			</a>
		</div>
	</div>

	<!--- Runners --->
	<div class="row">
		<div class="col-md-12 mb-4">
			<h2>Availble Test Runners: </h2>
			<p>
				Below is a listing of the runners matching the "runner*.(cfm|bxm)" pattern.
			</p>

			<cfset runners = directoryList( targetPath, false, "query", "runner*.cfm|runner*.bxm" )>
			<cfif runners.recordCount eq 0>
				<p class="alert alert-warning">No runners found in this directory</p>
			<cfelse>
				<cfloop query="runners">
					<a
						href="#runners.name#"
						target="_blank"
						<cfif listLast( runners.name, "." ) eq "bxm">
							class="btn btn-success btn-sm my-1 mx-1"
						<cfelse>
							class="btn btn-info btn-sm my-1 mx-1"
						</cfif>
					>
						#runners.name#
					</a>
				</cfloop>
			</cfif>
		</div>
	</div>

	<!--- Listing --->
	<div class="row">
		<div class="col-md-12">
			<form name="runnerForm" id="runnerForm">
				<input type="hidden" name="opt_run" id="opt_run" value="true">
				<h2>TestBox Test Browser: </h2>
				<p>
					Below is a listing of the files and folders starting from your root <code>#rootMapping#</code>.  You can click on individual tests in order to execute them
					or click on the <strong>Run All</strong> button on your left and it will execute a directory runner from the visible folder.
				</p>

				<fieldset>
					<legend>#targetPath.replace( rootPath, "" )#</legend>

					<!--- Show Back If we are traversing --->
					<cfif len( url.path )>
						<a href="index.cfm?path=#URLEncodedFormat( backPath )#">
							<button type="button" class="btn btn-secondary btn-sm my-1">&##xAB; Back</button>
						</a>
						<br>
						<hr>
					</cfif>

					<cfloop query="qResults">
						<!--- Skip . folder file names and runners and Application.bx, cfc--->
						<cfif
							refind( "^\.", qResults.name )
							OR
							( listLast( qresults.name, ".") eq "cfm" OR listLast( qresults.name, ".") eq "bxm" )
							OR
							( qResults.name eq "Application.cfc" OR qResults.name eq "Application.bx" )
						>
							<cfcontinue>
						</cfif>

						<cfif qResults.type eq "Dir">
							<a
								class="btn btn-secondary btn-sm my-1"
								href="index.cfm?path=#urlEncodedFormat( url.path & "/" & qResults.name )#"
							>
								&##x271A; #qResults.name#
							</a>
							<br />
						<cfelseif listLast( qresults.name, ".") eq "cfm" OR listLast( qresults.name, ".") eq "bxm">
							<a
								class="btn btn-primary btn-sm my-1"
								href="#executePath & "/" & qResults.name#"
								target="_blank"
							>
								#qResults.name#
							</a>
							<br />
						<cfelseif
							listLast( qresults.name, ".") eq "cfc" OR listLast( qresults.name, ".") eq "bx"
						>
							<a
								<cfif listLast( qresults.name, ".") eq "bx">
									data-bx="true"
									class="btn btn-success btn-sm my-1"
								<cfelse>
									data-bx="false"
									class="btn btn-info btn-sm my-1"
								</cfif>
								href="#executePath & "/" & qResults.name#?method=runRemote"
								target="_blank"
							>
								#qResults.name#
							</a>
							<br />
						</cfif>

					</cfloop>
				</fieldset>
			</form>
		</div>
	</div>
</div>

</body>
</html>
</cfoutput>
