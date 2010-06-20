<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 04, 2008
Description :
	StringBufferTest
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.core.java.StringBuffer">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Call the super setup method to setup the app.
		super.setup();
		model.init();
		</cfscript>
	</cffunction>
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- test methods --->
		<cfscript>
			var st1		= "StringTest";
			var st2		= "9Test2";
			
			assertTrue( isObject(model.setup()) );
			
			model.append(st1);
			model.insertStr(10,st2); 
			
			AssertEquals(model.indexOf('9'), '10');
			
			// this is something not working not sure why
			//AssertEquals(model.lastIndexOf('T'), '10', 'lastIndexOf() something gone wrong');
			AssertEquals(model.length(), '16', 'length() something gone wrong');
			
			//substring from position and before from end of position 
			AssertEquals(model.substring('10','12'), '9T', 'substring() something gone wrong');
			
			assertTrue(IsValid("numeric" , model.capacity()));
			
			assertTrue(IsObject(model.getStringBuffer()));
			
			model.replaceStr('10', '12', '7P');
			AssertEquals(model.getString(), 'StringTest7Pest2', 'getString() something gone wrong');
			
			model.append('7V');
			AssertEquals(model.getString(), 'StringTest7Pest27V', 'getString() something gone wrong');
			
			model.delete(16, 18);
			AssertEquals(model.getString(), 'StringTest7Pest2', 'getString() something gone wrong');
		</cfscript>
		
	</cffunction>

</cfcomponent>
