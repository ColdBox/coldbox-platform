/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.validators.UniqueValidator"{

	function setup(){
		super.setup();
		model.init();
	}

	function testValidate(){
		result = getMockBox().createMock("coldbox.system.validation.result.ValidationResult").init();
		var category = entityNew("Category");

		// null
		r = model.validate(result, category, 'category', javacast("null",""), "true");
		assertEquals( false, r );

		// 1: No ID, Unique
		r = model.validate(result, category, 'category', "luis", "true");
		assertEquals( true, r );
		// 2: No ID, Not Unique
		r = model.validate(result, category, 'category', "ORM", "true");
		assertEquals( false, r );

		var category = entityLoad("Category", {category="ORM"} , true);
		// 3: With ID, the same
		r = model.validate(result, category, 'category', "ORM", "true");
		assertEquals( true, r );
		// 3: With ID, and unique
		r = model.validate(result, category, 'category', "THIS IS UNIQUE", "true");
		assertEquals( true, r );
		// 4: With ID, and NOT unique
		r = model.validate(result, category, 'category', "News", "true");
		assertEquals( false, r );

	}
}