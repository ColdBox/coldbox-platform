<cfoutput>
<cfset assetPath = repeatstring( '../', listlen( arguments.package, "." ) )>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>	#arguments.package# </title>
	<meta name="keywords" content="#arguments.package# package">
	<cfmodule template="inc/common.html" rootPath="#assetPath#">
</head>
<body class="withNavbar">

	<cfmodule template="inc/nav.html"
				page="Package"
				projectTitle= "#arguments.projectTitle#"
				package = "#arguments.package#"
				file="#replace(arguments.package, '.', '/', 'all')#/package-summary"
				>
	<h2>
	<span class="label label-success">#arguments.package#</span>
	</h2>
	
	<div class="table-responsive">
	<cfif arguments.qInterfaces.recordCount>
		<table class="table table-striped table-hover table-bordered">
			<thead>
				<tr class="info">
					<th align="left" colspan="2"><font size="+2">
					<b>interface summary</b></font></th>
				</tr>
			</thead>
	
			<cfloop query="arguments.qinterfaces">
				<tr>
					<td width="15%"><b><a href="#name#.html" title="class in #package#">#name#</a></b></td>
					<td>
						<cfset meta = metadata>
						<cfif structkeyexists(meta, "hint")>
							#listgetat(meta.hint, 1, chr(13)&chr(10)&'.' )#
						</cfif>
					</td>
				</tr>
			</cfloop>
	
		</table>
	</cfif>
	
	<cfif arguments.qClasses.recordCount>
		<table class="table table-striped table-hover table-bordered">
			<thead>
				<tr class="info">
					<th align="left" colspan="2"><font size="+2">
					<b>class summary</b></font></th>
				</tr>
			</thead>
	
			<cfloop query="arguments.qclasses">
				<tr>
					<td width="15%"><b><a href="#name#.html" title="class in #package#">#name#</a></b></td>
					<td>
						<cfset meta = metadata>
						<cfif structkeyexists(meta, "hint") and len(meta.hint) gt 0>
							#listgetat( meta.hint, 1, chr(13)&chr(10)&'.' )#
						</cfif>
					</td>
				</tr>
			</cfloop>
	
		</table>
	</cfif>
	</div>

</body>
</html>
</cfoutput>