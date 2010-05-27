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
	
		function testcoldboxDSL(){
			
		}
		
		function testGetModelWithDSL(){
			target = bf.getModel(dsl="coldbox:cacheManager");
			assertEquals( getController().getColdBoxOCM(), target); 
		}
		
	</cfscript>
	
	<cffunction name="testPlugin" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("BeanFactory");
			
			assertTrue( isObject(plugin) );			
		</cfscript>
	</cffunction>	
	
	<cffunction name="testCreate" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("BeanFactory");
			var local = structnew();
			
			/* test create */
			local.obj = plugin.create('coldbox.testing.testmodel.formBean');

		</cfscript>
	</cffunction>
	
	<cffunction name="testPopulateFromStruct" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("BeanFactory");
			var local = structnew();
			var event = getRequestContext();
			
			stime = getTickCount();
			
			/* We are using the formBean object: fname,lname,email,initDate */
			local.obj = plugin.create('coldbox.testing.testmodel.formBean');
			
			/* Struct */
			local.myStruct = structnew();
			local.myStruct.fname = "Luis";
			local.myStruct.lname = "Majano";
			local.myStruct.email = "test@coldboxframework.com";
			local.myStruct.initDate = now();
			
			
			/* Populate RC */
			for( local.key in local.myStruct ){
				event.setValue(local.key, local.myStruct[local.key]);
			}
			
			/* Populate From Struct */
			local.obj = plugin.populateFromStruct(local.obj,local.myStruct);
			local.objInstance = local.obj.getInstance();
			//debug("Timer: #getTickCount()-stime#");
			
			/* Assert Population */
			for( local.key in local.objInstance ){
				AssertEquals(local.objInstance[local.key], local.myStruct[local.key], "Asserting #local.key# From Struct" );
			}
			
			/* populate using scope now */
			local.obj = plugin.populateFromStruct('coldbox.testing.testmodel.formBean',local.myStruct,"variables.instance");
			local.objInstance = local.obj.getInstance();
			/* Assert Population */
			for( local.key in local.objInstance ){
				AssertEquals(local.objInstance[local.key], local.myStruct[local.key], "Asserting by Scope #local.key# From Struct" );
			}		
			
			/* Populate using onMissingMethod */
			local.obj = plugin.populateFromStruct(target='coldbox.testing.testmodel.formImplicitBean',memento=local.myStruct,trustedSetter=true);
			local.objInstance = local.obj.getInstance();
			/* Assert Population */
			for( local.key in local.objInstance ){
				AssertEquals(local.objInstance[local.key], local.myStruct[local.key], "Asserting by Trusted Setter #local.key# From Struct" );
			}		
			
				
		</cfscript>
	</cffunction>
	
	<!--- testpopulateFromJSON --->
	<cffunction name="testpopulateFromJSON" output="false" access="public" returntype="any" hint="">
		<cfscript>
			var plugin = getController().getPlugin("BeanFactory");
			var local = structnew();
			/* We are using the formBean object: fname,lname,email,initDate */
			local.obj = plugin.create('coldbox.testing.testmodel.formBean');
			
			/* Struct */
			local.myStruct = structnew();
			local.myStruct.fname = "Luis";
			local.myStruct.lname = "Majano";
			local.myStruct.email = "test@coldboxframework.com";
			local.myStruct.initDate = now();
			/* JSON Packet */
			local.myJSON = getController().getPlugin("JSON").encode(local.myStruct);
			
			/* Populate From JSON */
			local.obj = plugin.populateFromJSON(local.obj,local.myJSON);
			local.objInstance = local.obj.getInstance();
			/* Assert Population */
			for( local.key in local.objInstance ){
				AssertEquals(local.objInstance[local.key], local.myStruct[local.key], "Asserting #local.key# From JSON" );
			}		
		</cfscript>
	</cffunction>
	
	<cffunction name="testpopulateFromQuery" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("BeanFactory");
			var local = structnew();
			
			// We are using the formBean object: fname,lname,email,initDate 
			local.obj = plugin.create('coldbox.testing.testmodel.formBean');
			
			// Query 
			local.myQuery = QueryNew('fname,lname,email,initDate');
			QueryAddRow(local.myQuery,1);
			querySetCell(local.myQuery, "fname", "Sana");
			querySetCell(local.myQuery, "lname", "Ullah");
			querySetCell(local.myQuery, "email", "test13@test13.com");
			querySetCell(local.myQuery, "initDate", now());
		
			// Populate From Query 
			local.obj = plugin.populateFromQuery(local.obj,local.myQuery);
			
			AssertEquals(local.myQuery["fname"][1],local.obj.getfname());
			AssertEquals(local.myQuery["lname"][1],local.obj.getlname());
			AssertEquals(local.myQuery["email"][1],local.obj.getemail());
		</cfscript>
	</cffunction>
	
	<cffunction name="testLocateModel" access="public" returntype="void" output="false">
		<cfscript>
			bf = getController().getPlugin("BeanFactory");
			
			assertTrue( bf.locateModel('testService').length() );
			
			assertFalse( bf.locateModel('whatever').length() );
		</cfscript>
	</cffunction>	
	
	<cffunction name="testContainsModel" access="public" returntype="void" output="false">
		<cfscript>
		bf = getController().getPlugin("BeanFactory");
		
		assertFalse( bf.containsModel('Nothing') );
		
		assertTrue( bf.containsModel('testService') );	
		</cfscript>
	</cffunction>	
	
	<cffunction name="testResolveModelAlias" access="public" returntype="void" output="false">
		<cfscript>
		bf = getController().getPlugin("BeanFactory");
		
		assertEquals( bf.resolveModelAlias('MyFormBean'), "formBean" );
		
		assertEquals( bf.resolveModelAlias('HELLO'), "HELLO" );
		
		bf.addModelMapping(path='mypath.whateverman');
		assertEquals( bf.resolveModelAlias('whateverman'), "mypath.whateverman" );
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetModelMappings" access="public" returntype="void" output="false">
		<cfscript>
		bf = getController().getPlugin("BeanFactory");
		
		assertTrue( isStruct(bf.getModelMappings()) );
		
		</cfscript>
	</cffunction>	
	
	
</cfcomponent>
