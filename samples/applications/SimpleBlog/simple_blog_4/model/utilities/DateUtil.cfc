<cfcomponent displayname="DateUtil" output="false">

<!----------------------------------- CONSTRUCTOR --------------------------------------->	
	
	<cfscript>
		//instance scope
		instance = structnew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">
		<!--- Any constructor code here --->
		<cfreturn this>
	</cffunction>


<!----------------------------------- PUBLIC METHODS --------------------------------------->


	<!--- formatDateTime --->
	<cffunction name="formatDateTime" access="public" returntype="any" output="false" hint="Decorator for Entry getTime function.">
		<cfargument name="time">
		<cfargument name="format" required="yes" default="long">
		
		<cfscript>
			var result = "";
			switch(arguments.format){
				case "long": {
					result = dateFormat(arguments.time,"medium") & " " & timeFormat(arguments.time,"medium");
					break;
				}
				
				case "short": {
					result = dateFormat(arguments.time,"short") & " " & timeFormat(arguments.time,"short");
				}	
			}
		</cfscript>
	     
		<cfreturn result>
	
    </cffunction>
</cfcomponent>