<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
    this.loadColdBox = false;
    
    function beforeTests(){
        personObj = getMockBox().createMock( className="tests.resources.Person");
    }

    function setup(){
        populator = getMockBox().createMock(className="coldbox.system.core.dynamic.BeanPopulator").init();
    }

    function testPopulateFromJSON() {
        json = serializeJSON({ "FIRSTNAME" = "Luis", "lastname" = "Majano" });

        populator.populateFromJSON( target = personObj, jsonString = json );

        // test normal poputlation
        $assert.isEqualWithCase( expected = "Luis", actual = personObj.getFirstName(), message="First Name Was Populated with [ Luis ]" );
        $assert.isEqualWithCase( expected = "Majano", actual = personObj.getLastName(), message="Last Name Name Was Populated with [ Majano ]" );

    }

    function testPopulateFromXML() skip="true" {
        assertTrue( true );
    }

    function testPopulateFromQuery() {
        //test the keyCasing From Properties
        // Mock a query
        qMockPeople = getMockBox().querySim(
            "id, firstName, lastName
            1 | luis | majano
            2 | joe | louis
            3 | bob | lainez");

        populator.populateFromQuery( target = personObj, qry = qMockPeople, keyCasingFromProperties = true );

        json = serializeJSON( personObj );
        
        // make sure the json is returned using the property names this is more of an ACF issue than lucee
        $assert.includesWithCase( json, '"firstName":"luis","lastName":"majano"', "properly cased values found in the returned json" );
    }

    function testPopulateFromQueryWithPrefix() skip="true"{
        assertTrue( true );
    }

    function testPopulateFromStructWithPrefix() skip="true"{
        
    }

    function testPopulateFromStruct(){

        data = { "FIRSTNAME" = "Luis", "lastName" = "Majano" };

        populator.populateFromStruct( target = personObj, memento = data );

        $assert.isEqualWithCase( expected = "Luis", actual = personObj.getFirstName(), message="First Name Was Populated with [ Luis ]" );
        $assert.isEqualWithCase( expected = "Majano", actual = personObj.getLastName(), message="Last Name Name Was Populated with [ Majano ]" );


    }

</cfscript>
</cfcomponent>
