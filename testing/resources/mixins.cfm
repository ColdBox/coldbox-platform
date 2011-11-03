<cfscript>
	this.repeatThis = variables.repeatThis;
	this.add 		= variables.add;
	function repeatThis(str){ return arguments.str; }
	function add(val1,val2) { return val1+val2; }
</cfscript>