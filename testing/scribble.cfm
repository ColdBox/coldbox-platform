<cfsetting showdebugoutput="false">
<!--- Dump facade --->
<cffunction name="dump" access="private" hint="Facade for cfmx dump" returntype="void">
	<cfargument name="var" required="yes" type="any">
	<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
	<cfdump var="#var#">
	<cfif arguments.isAbort><cfabort></cfif>
</cffunction>



<cfscript>
props = structnew();
props.base = "coldbox.testing.model";
props.AppMapping = "/coldbox/testharness";
props.Singletons = "false";
props.SecurityService = "securityDev";

function placeHolderReplacer(str, settings){
	var returnString = arguments.str;
	var regex = "\$\{([0-9a-z\-\.\_]+)\}";
	var lookup = 0;
	var varName = 0;
	var varValue = 0;
	/* Loop and Replace */
	while(true){
		/* Search For Pattern */
		lookup = reFindNocase(regex,returnString,1,true);	
		/* Found? */
		if( lookup.pos[1] ){
			/* Get Variable Name From Pattern */
			varName = mid(returnString,lookup.pos[2],lookup.len[2]);
			/* Lookup Value */
			if( isDefined("arguments.settings.#varName#") ){
				varValue = Evaluate("arguments.settings.#varName#");
			}
			else{
				varValue = "VAR_NOT_FOUND";
			}
			
			/* Remove PlaceHolder Entirely */
			returnString = removeChars(returnString, lookup.pos[1], lookup.len[1]);
			/* Insert Var Value */
			returnString = insert(varValue, returnString, lookup.pos[1]-1);
		}
		else{
			break;
		}	
	}
	/* Return Parsed String. */
	return returnString;
}


str1 = "MyPath";
str2 = "${AppMapping}/myPathing";
str3 = "${base}.security.${SecurityService}";

</cfscript>
<cfoutput>
#str1# = #placeHolderReplacer(str1,props)#<br />
#str2# = #placeHolderReplacer(str2,props)#<br />
#str3# = #placeHolderReplacer(str3,props)#<br />
</cfoutput>