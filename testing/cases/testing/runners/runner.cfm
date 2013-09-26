<cfsetting showdebugoutput="false" >
<!--- One runner 
<cfset r = new coldbox.system.testing.Runner( "coldbox.testing.cases.testing.specs.AssertionsTest" ) >
--->
<!--- Directory Runner 
<cfset r = new coldbox.system.testing.Runner( directory={ mapping = "coldbox.testing.cases.testing.specs", recurse = true } ) >
--->
<!--- Directory Runner with filter closure --->
<cfset r = new coldbox.system.testing.Runner( directory={ 
		mapping = "coldbox.testing.cases.testing.specs", 
		recurse = true,
		filter = function( path ){
			return true;
		}
	} 
) >


<cfoutput>#r.run(reporter="simple")#</cfoutput>