<cfcomponent name="utilTest" output="false" extends="org.cfcunit.framework.TestCase">
	
	<cffunction name="testCFMLEngine" access="public" returntype="void" output="false" >
		<cfscript>
			var obj = CreateObject("component","coldbox.system.util.CFMLEngine").init();
			
			AssertTrue( len(obj.getEngine()) gt 0, "Engine test" );
			
			AssertTrue( isNumeric(obj.getVersion()) , "Version Test");
		</cfscript>
	</cffunction>

</cfcomponent>