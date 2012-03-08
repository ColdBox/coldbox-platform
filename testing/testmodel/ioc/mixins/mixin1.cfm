<cfscript>
	public function printDateTime(d,f="full"){
		return dateFormat(d,f) & " " & timeFormat(d,f);
	}
	public function echo(e){ return e; }
</cfscript>