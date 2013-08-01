<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	BeanFactoryTest
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false" appMapping="/coldbox/testharness">
	<cfscript>
	
		function setup(){
			super.setup();
			bf = getController().getPlugin("BeanFactory");
		}
	
		function testPopulateFromStruct(){
			stime = getTickCount();
			
			/* We are using the formBean object: fname,lname,email,initDate */
			obj = getMockBox().createMock('coldbox.testing.testmodel.formBean');
			
			/* Struct */
			myStruct = structnew();
			myStruct.fname = "Luis";
			myStruct.lname = "Majano";
			myStruct.email = "test@coldboxframework.com";
			myStruct.initDate = now();
			
			/* Populate From Struct */
			obj = bf.populateFromStruct(obj,myStruct);
			objInstance = obj.getInstance();
			
			//debug("Timer: #getTickCount()-stime#");
			
			/* Assert Population */
			for( key in objInstance ){
				AssertEquals(objInstance[key], myStruct[key], "Asserting #key# From Struct" );
			}
			
			/* populate using scope now */
			obj = getMockBox().createMock('coldbox.testing.testmodel.formBean');
			obj = bf.populateFromStruct(obj,myStruct,"variables.instance");
			objInstance = obj.getInstance();
			/* Assert Population */
			for( key in objInstance ){
				AssertEquals(objInstance[key], myStruct[key], "Asserting by Scope #key# From Struct" );
			}		
			
			/* Populate using onMissingMethod */
			obj = getMockBox().createMock('coldbox.testing.testmodel.formImplicitBean');
			obj = bf.populateFromStruct(target=obj,memento=myStruct,trustedSetter=true);
			objInstance = obj.getInstance();
			/* Assert Population */
			for( key in objInstance ){
				AssertEquals(objInstance[key], myStruct[key], "Asserting by Trusted Setter #key# From Struct" );
			}
		}
	
	
		function testpopulateFromJSON(){
			JSONUtil  = createObject("component","coldbox.system.core.conversion.JSON").init();
			
			/* We are using the formBean object: fname,lname,email,initDate */
			obj = getMockBox().createMock('coldbox.testing.testmodel.formBean');
			
			/* Struct */
			myStruct = structnew();
			myStruct.fname = "Luis";
			myStruct.lname = "Majano";
			myStruct.email = "test@coldboxframework.com";
			myStruct.initDate = now();
			/* JSON Packet */
			myJSON = JSONUtil.encode(myStruct);
			
			/* Populate From JSON */
			obj = bf.populateFromJSON(obj,myJSON);
			objInstance = obj.getInstance();
			
			/* Assert Population */
			for( key in objInstance ){
				AssertEquals(objInstance[key], myStruct[key], "Asserting #key# From JSON" );
			}		
		}
	
		function testPopulateFromXML(){
		
			/* We are using the formBean object: fname,lname,email,initDate */
			obj = getMockBox().createMock('coldbox.testing.testmodel.formBean');
			
			/* Struct */
			xml = "<root>
			<fname>Luis</fname>
			<lname>Majano</lname>
			<email>test@coldbox.org</email>
			<initDate>#now()#</initDate>
			</root>
			";
			xml = xmlParse( xml );
			
			obj = bf.populateFromXML(obj,xml);
			objInstance = obj.getInstance();
			
			assertEquals( "Luis", obj.getFName() );
			assertEquals( "Majano", obj.getLname() );
			assertEquals( "test@coldbox.org", obj.getEmail() );
		}
		
		function testpopulateFromQuery(){
			
			// We are using the formBean object: fname,lname,email,initDate 
			obj = getMockBox().createMock('coldbox.testing.testmodel.formBean');
			
			// Query 
			myQuery = QueryNew('fname,lname,email,initDate');
			QueryAddRow(myQuery,1);
			querySetCell(myQuery, "fname", "Sana");
			querySetCell(myQuery, "lname", "Ullah");
			querySetCell(myQuery, "email", "test13@test13.com");
			querySetCell(myQuery, "initDate", now());
		
			// Populate From Query 
			obj = bf.populateFromQuery(obj,myQuery);
			
			AssertEquals(myQuery["fname"][1],obj.getfname());
			AssertEquals(myQuery["lname"][1],obj.getlname());
			AssertEquals(myQuery["email"][1],obj.getemail());
		}
		
		function testLocateModel(){
			bf = getController().getPlugin("BeanFactory");
			
			assertTrue( bf.locateModel('testService').length() );
			
			assertFalse( bf.locateModel('whatever').length() );
		}	
	</cfscript>
</cfcomponent>