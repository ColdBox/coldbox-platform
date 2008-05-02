<cfcomponent name="utilTest" output="false" extends="mxunit.framework.TestCase">
	
	<cffunction name="testCFMLEngine" access="public" returntype="void" output="false" >
		<cfscript>
			var obj = CreateObject("component","coldbox.system.util.CFMLEngine").init();
			
			AssertTrue( len(obj.getEngine()) gt 0, "Engine test" );
			
			AssertTrue( isNumeric(obj.getVersion()) , "Version Test");
		</cfscript>
	</cffunction>
	
	<cffunction name="testDictionary" access="public" returntype="void" hint="Test the dictionary" output="false" >
		<cfscript>
			var obj = CreateObject("component","coldbox.system.util.baseDictionary").init();
			AssertTrue( isObject(obj) );
			
			obj = CreateObject("component","coldbox.system.util.baseDictionary").init('MyTest');
			AssertTrue( isObject(obj) );
			
			AssertEquals("MyTest", obj.getName() ,"name test");
			
			AssertEquals(structnew(), obj.getDictionary(), "dictionary test");
			
			AssertFalse( obj.keyExists('nothing'), "key test");
			
			obj.setKey('test','test');
			AssertEquals('test', obj.getKey('test'), "get Key test");
			AssertTrue( obj.keyExists('test'), "Exists Test");
			
			obj.clearKey('test');
			AssertFalse( obj.keyExists('test'), "clear test");
			
			obj.clearAll();
			AssertTrue( structisEmpty(obj.getDictionary()), "empty test");
			
			
		</cfscript>
	</cffunction>

</cfcomponent>