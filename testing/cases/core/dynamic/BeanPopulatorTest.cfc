<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.core.dynamic.BeanPopulator">

	<cffunction name="setup">
		<cfset super.setup()>
		<cfset populator = model.init()>
	</cffunction>

	<cffunction name="testPopulateFromStruct" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
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
			obj = populator.populateFromStruct(obj,myStruct);
			objInstance = obj.getInstance();
			
			//debug("Timer: #getTickCount()-stime#");
			
			/* Assert Population */
			for( key in objInstance ){
				AssertEquals(objInstance[key], myStruct[key], "Asserting #key# From Struct" );
			}
			
			/* populate using scope now */
			obj = getMockBox().createMock('coldbox.testing.testmodel.formBean');
			obj = populator.populateFromStruct(obj,myStruct,"variables.instance");
			objInstance = obj.getInstance();
			/* Assert Population */
			for( key in objInstance ){
				AssertEquals(objInstance[key], myStruct[key], "Asserting by Scope #key# From Struct" );
			}		
			
			/* Populate using onMissingMethod */
			obj = getMockBox().createMock('coldbox.testing.testmodel.formImplicitBean');
			obj = populator.populateFromStruct(target=obj,memento=myStruct,trustedSetter=true);
			objInstance = obj.getInstance();
			/* Assert Population */
			for( key in objInstance ){
				AssertEquals(objInstance[key], myStruct[key], "Asserting by Trusted Setter #key# From Struct" );
			}	
		</cfscript>
	</cffunction>
	
	<!--- testpopulateFromJSON --->
	<cffunction name="testpopulateFromJSON" output="false" access="public" returntype="any" hint="">
		<cfscript>
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
			obj = populator.populateFromJSON(obj,myJSON);
			objInstance = obj.getInstance();
			
			/* Assert Population */
			for( key in objInstance ){
				AssertEquals(objInstance[key], myStruct[key], "Asserting #key# From JSON" );
			}		
		</cfscript>
	</cffunction>
	
	<cffunction name="testPopulateFromXML" output="false" access="public" returntype="any" hint="">
		<cfscript>
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
			
			obj = populator.populateFromXML(obj,xml);
			objInstance = obj.getInstance();
			
			assertEquals( "Luis", obj.getFName() );
			assertEquals( "Majano", obj.getLname() );
			assertEquals( "test@coldbox.org", obj.getEmail() );
		</cfscript>
	</cffunction>
	
	<cffunction name="testpopulateFromQuery" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			
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
			obj = populator.populateFromQuery(obj,myQuery);
			
			AssertEquals(myQuery["fname"][1],obj.getfname());
			AssertEquals(myQuery["lname"][1],obj.getlname());
			AssertEquals(myQuery["email"][1],obj.getemail());
		</cfscript>
	</cffunction>


</cfcomponent>