<cfcomponent name="BaseDictionaryTest" output="false" extends="coldbox.testing.tests.resources.baseMockCase">
	
	<!--- setup --->
	<cffunction name="setup" output="false" access="public" returntype="any" hint="">
		<cfscript>
			dictionary = CreateObject("component","coldbox.system.util.baseDictionary").init('MyTest');
		</cfscript>
	</cffunction>
	
	<cffunction name="testDictionary" access="public" returntype="void" hint="Test the dictionary" output="false" >
		<cfscript>
			
			AssertEquals("MyTest", dictionary.getName() ,"name test");
			
			AssertEquals(structnew(), dictionary.getDictionary(), "dictionary test");
			
			AssertFalse( dictionary.keyExists('nothing'), "key test");
			
			dictionary.setKey('test','test');
			AssertEquals('test', dictionary.getKey('test'), "get Key test");
			AssertTrue( dictionary.keyExists('test'), "Exists Test");
			
			dictionary.clearKey('test');
			AssertFalse( dictionary.keyExists('test'), "clear test");
			
			dictionary.clearAll();
			AssertTrue( structisEmpty(dictionary.getDictionary()), "empty test");
			
			
		</cfscript>
	</cffunction>

</cfcomponent>