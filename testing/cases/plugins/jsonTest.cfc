<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	securityTest
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" appMapping="/coldbox/testharness">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		reset();
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testPlugin" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("JSON");
			
			AssertTrue( isObject(plugin) );
		</cfscript>
	</cffunction>	
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("JSON");
			var jsonText = "{name:'luis',number:'23423'}";
			var local = structnew();
			
			assertTrue(isStruct(plugin.decode(jsonText)), "Inflation");
			
			assertTrue(isArray(plugin.decode("[1,2,3,4]")), "Inflation");
			
			plugin.encode( listToArray('luis,majano') );
			plugin.encode( local );
			
			complexData = {
				name="luis",
				age = 32,
				numbers = [1,2,3,4],
				term={ data=1, age=32}
			};
			results = plugin.encode( complexData );
			debug( results );
			
			complexData =[
				{class="test",name="test",props={n=1,y=2}},
				{class="test",name="test",props={n=1,y=2}},
				{class="test",name="test",props={n=1,y=2}}
			];
			results = plugin.encode( complexData );
			debug( results );
		</cfscript>
	</cffunction>
	
	<!--- testNulls --->
    <cffunction name="testNulls" output="false" access="public" returntype="any" hint="">
    	<cfscript>
    	var plugin = getController().getPlugin("JSON");
			
		var data = {
			firstname = "luis",
			homePhone = javaCast("null",""),
			numbers = [javaCast("null",""),1,2,3]
		};
		
		results = plugin.encode( data );
		debug(serializeJSON(data));
		debug(results);
		results = plugin.decode( results );
		assertEquals('', results.homePhone);
		</cfscript>
    </cffunction>

	
</cfcomponent>