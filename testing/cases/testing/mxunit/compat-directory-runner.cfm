<cfset r = new coldbox.system.testing.compat.runner.DirectoryTestSuite()
				.run( directory="#expandPath( '/coldbox/testing/cases/testing/specs' )#", 
					  componentPath="coldbox.testing.cases.testing.specs" )>
<cfoutput>#r.getResultsOutput( 'simple' )#</cfoutput>
