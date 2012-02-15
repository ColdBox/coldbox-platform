<cfscript>
	public function printDateTime2(d,f="full"){
		return dateFormat(d,f) & " " & timeFormat(d,f);
	}
	public function echo2(e){ return e; }
</cfscript>