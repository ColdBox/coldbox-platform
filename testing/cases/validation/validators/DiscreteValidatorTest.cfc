/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
ssn,email,url,alpha,boolean,date,usdate,eurodate,numeric,GUID,UUID,integer,string,telephone,zipcode,ipaddress,creditcard,binary,component,query,struct
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.validators.DiscreteValidator"{

	function setup(){
		super.setup();
		model.init();
	}
	
	function testValidate(){
		result = getMockBox().createMock("coldbox.system.validation.result.ValidationResult").init();
		
		// eq
		r = model.validate(result,this,'test',"123","eq:1");
		assertEquals( false, r );
		r = model.validate(result,this,'test',"111","eq:111");
		assertEquals( true, r );
		
		// neq
		r = model.validate(result,this,'test',"123","neq:123");
		assertEquals( false, r );
		r = model.validate(result,this,'test',"123","neq:1");
		assertEquals( true, r );
		
		// lt
		r = model.validate(result,this,'test',"123","lt:4");
		assertEquals( false, r );
		r = model.validate(result,this,'test',"1","lt:7");
		assertEquals( true, r );
		
		// lte
		r = model.validate(result,this,'test',"123","lte:4");
		assertEquals( false, r );
		r = model.validate(result,this,'test',"4","lte:4");
		assertEquals( true, r );
		
		// gt
		r = model.validate(result,this,'test',"44","gt:85323");
		assertEquals( false, r );
		r = model.validate(result,this,'test',"44","gt:3");
		assertEquals( true, r );
		
		// gte
		r = model.validate(result,this,'test',"3","gte:4");
		assertEquals( false, r );
		r = model.validate(result,this,'test', 4 ,"gte:4");
		assertEquals( true, r );
		
	}
}