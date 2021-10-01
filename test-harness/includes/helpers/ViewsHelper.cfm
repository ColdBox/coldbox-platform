<cfscript>
	function printDate(){
		return dateformat( now(), "medium" ) & " " & timeFormat( now(), "medium" );
	}
</cfscript>