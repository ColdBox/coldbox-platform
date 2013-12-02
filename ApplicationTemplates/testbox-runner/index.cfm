<cfsetting showdebugoutput="false">
<cfparam name="url.reporter" default="simple">
<cfscript>
	tb = new coldbox.system.testing.TestBox( directory={ recurse=true, mapping="test.specs" }, reporter=url.reporter );
	writeOutput( tb.run() );
</cfscript>