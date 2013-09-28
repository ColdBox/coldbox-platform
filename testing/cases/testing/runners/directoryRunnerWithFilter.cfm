<cfsetting showdebugoutput="false" >
<!--- Directory Runner with filter closure --->
<cfset r = new coldbox.system.testing.runners.UnitRunner( directory={ 
		mapping = "coldbox.testing.cases.testing.specs", 
		recurse = true,
		filter = function( path ){
			return true;
		}
	} 
) >
<cfoutput>#r.run(reporter="simple")#</cfoutput>