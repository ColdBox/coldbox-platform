<cfcomponent name="cfmlengine" output="false" extends="coldbox.system.testing.BaseTestCase">
	
	<!--- setup --->
	<cffunction name="setup" output="false" access="public" returntype="any" hint="">
		<cfscript>
			cfmlengine = CreateObject("component","coldbox.system.core.cf.CFMLEngine").init();
		</cfscript>
	</cffunction>
	
	<cffunction name="testCFMLEngine" access="public" returntype="void" output="false" >
		<cfscript>
			version = listfirst(server.coldfusion.productversion);
			engine = server.coldfusion.productname;
			
			if( findnocase("coldfusion",engine) ){
				enginetype = "adobe";
			}
			else if ( findnocase("railo",engine) ){
				enginetype = "railo";
			}
			else if ( findnocase("dragon",engine)){
				enginetype = "bd";
			}
			
			AssertTrue( len(cfmlengine.getEngine()) gt 0, "Engine test" );
			
			AssertTrue( isNumeric(cfmlengine.getVersion()) , "Version Test");

			AssertEquals( cfmlengine.isMT(), (enginetype eq "adobe" and version gte 8) OR (enginetype eq "bd" and version gte 7) OR (enginetype eq "railo" ) );
			
			
		</cfscript>
	</cffunction>

</cfcomponent>