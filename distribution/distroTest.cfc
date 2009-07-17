<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setUp" returntype="void" access="public" hint="put things here that you want to run before each test">
		<cfscript>
			this.distro = CreateObject("component","updatews");
			this.current = "2.5.2";
		</cfscript>		
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public" hint="put things here that you want to run after each test">	
	
	</cffunction>
		
	<cffunction name="testParsing" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			makePublic(this.distro,"parseDistributionObjects","_parseDistributionObjects");
			this.distro._parseDistributionObjects();
		</cfscript>
	</cffunction>
	
	<cffunction name="testGetUpdateInfo" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			/* Available */
			results = this.distro.GetUpdateInfo('1.1.0','1.1.0');
			AssertTrue( isStruct(results) );
			AssertEquals( results.coldboxAvailableUpdate, true);
			AssertEquals( results.dashboardAvailableUpdate, true);
			
			/* Not Av */
			results = this.distro.GetUpdateInfo('10.1.0','10.1.0');
			AssertTrue( isStruct(results) );
			AssertEquals( results.coldboxAvailableUpdate, false);
			AssertEquals( results.dashboardAvailableUpdate, false);
			
		</cfscript>
	</cffunction>
	
	<cffunction name="getCurrentColdboxVersion" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			cv = this.distro.getCurrentColdboxVersion();
			debug(cv);
		</cfscript>
	</cffunction>
	
	<cffunction name="getCurrentDashboardVersion" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			cv = this.distro.getCurrentDashboardVersion();
			debug(cv);
		</cfscript>
	</cffunction>
	
</cfcomponent>