<cfcomponent displayname="Entry" hint="Entry deceorator" extends="transfer.com.TransferDecorator" output="false">
	
	<!--- getTime --->
	<cffunction name="getTime" access="public" returntype="any" output="false" hint="Decorator for Entry getTime function.">
		<cfargument name="format" required="yes" default="long">
		
		
		<cfscript>
			var result = "";
			var time = getTransferObject().getTime();
			
			switch(arguments.format){
				case "long": {
					result = dateFormat(time,"medium") & " " & timeFormat(time,"medium");
					break;
				}
				
				case "short": {
					result = dateFormat(time,"short") & " " & timeFormat(time,"short");
				}	
			}
		</cfscript>
	     
		<cfreturn result>
	
    </cffunction>
</cfcomponent> 