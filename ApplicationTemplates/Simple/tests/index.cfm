<cfsetting showdebugoutput="false" >
<!--- CPU Integration --->
<cfparam name="url.cpu" default="false">
<!--- SETUP THE ROOTS OF THE BROWSER RIGHT HERE --->
<cfset rootMapping 	= "/tests/specs">
<cfif directoryExists( rootMapping )>
	<cfset rootPath = rootMapping>
<cfelse>
	<cfset rootPath = expandPath( rootMapping )>
</cfif>

<!--- param incoming --->
<cfparam name="url.path" default="/">

<!--- Decodes & Path Defaults --->
<cfset url.path = urlDecode( url.path )>
<cfif !len( url.path )>
	<cfset url.path = "/">
</cfif>

<!--- Prepare TestBox --->
<cfset testbox = new testbox.system.TestBox()>

<!--- Run Tests Action?--->
<cfif structKeyExists( url, "action")>
	<cfif directoryExists( expandPath( rootMapping & url.path ) )>
		<cfoutput>#testbox.init( directory=rootMapping & url.path ).run()#</cfoutput>
	<cfelse>
		<cfoutput><h1>Invalid incoming directory: #rootMapping & url.path#</h1></cfoutput>
	</cfif>
	<cfabort>

</cfif>

<!--- Get list of files --->
<cfdirectory action="list" directory="#rootPath & url.path#" name="qResults" sort="asc" >
<!--- Get the execute path --->
<cfset executePath = rootMapping & ( url.path eq "/" ? "/" : url.path & "/" )>
<!--- Get the Back Path --->
<cfif url.path neq "/">
	<cfset backPath = replacenocase( url.path, listLast( url.path, "/" ), "" )>
	<cfset backPath = reReplace( backpath, "/$", "" )>
</cfif>

<!--- Do HTML --->
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="generator" content="TestBox v#testbox.getVersion()#">
	<title>TestBox Global Runner</title>
	<script><cfinclude template="/testbox/system/reports/assets/js/jquery.js"></script>
	<script>
	$(document).ready(function() {

	});
	function runTests(){
		$("#btn-run").html( 'Running...' ).css( "opacity", "0.5" );
		$("#tb-results").load( "index.cfm", $("#runnerForm").serialize(), function( data ){
			$("#btn-run").html( 'Run' ).css( "opacity", "1" );
		} );
	}
	function clearResults(){
		$("#tb-results").html( '' );
		$("#target").html( '' );
		$("#labels").html( '' );
	}
	</script>
	<style>
	body{
		font-family:  Monaco, "Lucida Console", monospace;
		font-size: 10.5px;
		line-height: 20px;
	}
	h1,h2,h3,h4{ margin-top: 3px;}
	h1{ font-size: 14px;}
	h2{ font-size: 13px;}
	h3{ font-size: 12px;}
	h4{ font-size: 11px; font-style: italic;}
	ul{ margin-left: -10px;}
	li{ margin-left: -10px; list-style: none;}
	a{ text-decoration: none;}
	a:hover{ text-decoration: underline;}
	/** utility **/
	.centered { text-align: center !important; }
	.inline{ display: inline !important; }
	.margin10{ margin: 10px; }
	.padding10{ padding: 10px; }
	.margin0{ margin: 0px; }
	.padding0{ padding: 0px; }
	.box{ border:1px solid gray; margin: 10px 0px; padding: 10px; background-color: #f5f5f5}
	.pull-right{ float: right;}
	.pull-left{ float: left;}
	#tb-runner{ min-height: 155px}
	#tb-runner #tb-left{ width: 17%; margin-right: 10px; margin-top: 0px; height: 135px; float:left;}
	#tb-runner #tb-right{ width: 80%; }
	#tb-runner fieldset{ padding: 10px; margin: 10px 0px; border: 1px dotted gray;}
	#tb-runner input{ padding: 5px; margin: 2px 0px;}
	#tb-runner .btn-red {
		background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #f24537), color-stop(1, #c62d1f) );
		background:-moz-linear-gradient( center top, #f24537 5%, #c62d1f 100% );
		filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#f24537', endColorstr='#c62d1f');
		background-color:#f24537;
		-webkit-border-top-left-radius:5px;
		-moz-border-radius-topleft:5px;
		border-top-left-radius:5px;
		-webkit-border-top-right-radius:5px;
		-moz-border-radius-topright:5px;
		border-top-right-radius:5px;
		-webkit-border-bottom-right-radius:5px;
		-moz-border-radius-bottomright:5px;
		border-bottom-right-radius:5px;
		-webkit-border-bottom-left-radius:5px;
		-moz-border-radius-bottomleft:5px;
		border-bottom-left-radius:5px;
		text-indent:1.31px;
		border:1px solid #d02718;
		display:inline-block;
		color:#ffffff;
		font-weight:bold;
		font-style:normal;
		padding: 2px 5px;
		margin: 2px 0px;
		text-decoration:none;
		text-align:center;
		cursor: pointer;
	}
	#tb-runner .btn-red:hover {
		background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #c62d1f), color-stop(1, #f24537) );
		background:-moz-linear-gradient( center top, #c62d1f 5%, #f24537 100% );
		filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#c62d1f', endColorstr='#f24537');
		background-color:#c62d1f;
	}
	#tb-runner .btn-red:active {
		position:relative;
		top:1px;
	}
	#tb-results{ padding: 10px;}
	code{ padding: 2px 4px; color: #d14; white-space: nowrap; background-color: #f7f7f9; border: 1px solid #e1e1e8;}
	</style>
</head>
<cfoutput>
<body>

<!--- Title --->
<div id="tb-runner" class="box">
<form name="runnerForm" id="runnerForm">
<input type="hidden" name="opt_run" id="opt_run" value="true">

	<div id="tb-left" class="centered">
		<img src="http://www.ortussolutions.com/__media/testbox-185.png" alt="TestBox" id="tb-logo"/><br>v#testbox.getVersion()#<br>

		<a href="index.cfm?action=runTestBox&path=#URLEncodedFormat( url.path )#" target="_blank"><button class="btn-red" type="button">Run All</button></a>
	</div>

	<div id="tb-right">
		<h1>TestBox Test Browser: </h1>
		<p>
			Below is a listing of the files and folders starting from your root <code>#rootPath#</code>.  You can click on individual tests in order to execute them
			or click on the <strong>Run All</strong> button on your left and it will execute a directory runner from the visible folder.
		</p>

		<fieldset><legend>Contents: #executePath#</legend>
		<cfif url.path neq "/">
			<a href="index.cfm?path=#URLEncodedFormat( backPath )#"><button type="button" class="btn-red">&lt;&lt; Back</button></a><br><hr>
		</cfif>
		<cfloop query="qResults">
			<cfif refind( "^\.", qResults.name )>
				<cfcontinue>
			</cfif>

			<cfset dirPath = URLEncodedFormat( ( url.path neq '/' ? '#url.path#/' : '/' ) & qResults.name )>
			<cfif qResults.type eq "Dir">
				+<a href="index.cfm?path=#dirPath#">#qResults.name#</a><br/>
			<cfelseif listLast( qresults.name, ".") eq "cfm">
				<a class="btn-red" href="#executePath & qResults.name#" <cfif !url.cpu>target="_blank"</cfif>>#qResults.name#</a><br/>
			<cfelseif listLast( qresults.name, ".") eq "cfc" and qresults.name neq "Application.cfc">
				<a class="test btn-red" href="#executePath & qResults.name#?method=runRemote" <cfif !url.cpu>target="_blank"</cfif>>#qResults.name#</a><br/>
			<cfelse>
				#qResults.name#<br/>
			</cfif>

		</cfloop>
		</fieldset>

	</div>

</form>
</div>

<!--- Results --->
<div id="tb-results"></div>

</body>
</html>
</cfoutput>