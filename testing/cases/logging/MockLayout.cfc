<cfcomponent extends="coldbox.system.logging.Layout"><cfscript>

	function format(logevent){
		return logevent.getTimestamp() & ". My Funky Layout Worked Man!!";
		
	}	
</cfscript></cfcomponent>