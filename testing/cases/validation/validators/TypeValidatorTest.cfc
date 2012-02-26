/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
ssn,email,url,alpha,boolean,date,usdate,eurodate,numeric,GUID,UUID,integer,string,telephone,zipcode,ipaddress,creditcard,binary,component,query,struct
*/
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.validation.validators.TypeValidator"{

	function setup(){
		super.setup();
		model.init();
	}
	
	function testValidate(){
		result = getMockBox().createMock("coldbox.system.validation.result.ValidationResult").init();
		
		// ssn
		r = model.validate(result,this,'test',"123","ssn");
		assertEquals( false, r );
		r = model.validate(result,this,'test',"111-11-1111","ssn");
		assertEquals( true, r );
		
		// email
		r = model.validate(result,this,'test',"123","email");
		assertEquals( false, r );
		r = model.validate(result,this,'test',"lmajano@coldbox.org","email");
		assertEquals( true, r );
		
		// url
		r = model.validate(result,this,'test',"123","url");
		assertEquals( false, r );
		r = model.validate(result,this,'test',"http://www.luismajano.com","url");
		assertEquals( true, r );
		
		// alpha
		r = model.validate(result,this,'test',"123","alpha");
		assertEquals( false, r );
		r = model.validate(result,this,'test',"lmajano","alpha");
		assertEquals( true, r );
		
		// boolean
		r = model.validate(result,this,'test',"XXX","boolean");
		assertEquals( false, r );
		r = model.validate(result,this,'test',"true","boolean");
		assertEquals( true, r );
		
		// date
		r = model.validate(result,this,'test',"1aa","date");
		assertEquals( false, r );
		r = model.validate(result,this,'test', now() ,"date");
		assertEquals( true, r );
		
		// usdate
		r = model.validate(result,this,'test',"1aa","usdate");
		assertEquals( false, r );
		r = model.validate(result,this,'test', "01/01/2012" ,"usdate");
		assertEquals( true, r );
		
		// eurodate
		r = model.validate(result,this,'test',"1aa","eurodate");
		assertEquals( false, r );
		r = model.validate(result,this,'test', "23/01/2012","eurodate");
		assertEquals( true, r );
		
		// numeric
		r = model.validate(result,this,'test',"1aa","numeric");
		assertEquals( false, r );
		r = model.validate(result,this,'test', "123","numeric");
		assertEquals( true, r );
		
		// guid
		r = model.validate(result,this,'test',"1aa","guid");
		assertEquals( false, r );
		r = model.validate(result,this,'test', "88888888-1234-1234-1234-888888886676","guid");
		assertEquals( true, r );
		
		// integer
		r = model.validate(result,this,'test',"1aa","integer");
		assertEquals( false, r );
		r = model.validate(result,this,'test', "234","integer");
		assertEquals( true, r );
		
		// string
		r = model.validate(result,this,'test', this ,"string");
		assertEquals( false, r );
		r = model.validate(result,this,'test', "asdf","string");
		assertEquals( true, r );
		
		// telephone
		r = model.validate(result,this,'test', 'asdf' ,"telephone");
		assertEquals( false, r );
		r = model.validate(result,this,'test', "305-305-0909","telephone");
		assertEquals( true, r );
		
		// zipcode
		r = model.validate(result,this,'test', '234' ,"zipcode");
		assertEquals( false, r );
		r = model.validate(result,this,'test', "91701","zipcode");
		assertEquals( true, r );
		
		// ipaddress
		r = model.validate(result,this,'test', '234' ,"ipaddress");
		assertEquals( false, r );
		r = model.validate(result,this,'test', "127.0.0.1","ipaddress");
		assertEquals( true, r );
		
		// creditcard
		r = model.validate(result,this,'test', '234' ,"creditcard");
		assertEquals( false, r );
		r = model.validate(result,this,'test', "378734493671000","creditcard");
		assertEquals( true, r );
		
		// component
		r = model.validate(result,this,'test', '234' ,"component");
		assertEquals( false, r );
		r = model.validate(result,this,'test', this,"component");
		assertEquals( true, r );
		
		// creditcard
		r = model.validate(result,this,'test', '234' ,"query");
		assertEquals( false, r );
		r = model.validate(result,this,'test', queryNew(""),"query");
		assertEquals( true, r );
		
		// creditcard
		r = model.validate(result,this,'test', '234' ,"struct");
		assertEquals( false, r );
		r = model.validate(result,this,'test', {name='luis'},"struct");
		assertEquals( true, r );
		
		r = model.validate(result,this,'test', '{s:,}' ,"json");
		assertEquals( false, r );
		r = model.validate(result,this,'test', serializeJSON({name='luis'}) ,"json");
		assertEquals( true, r );
		
		r = model.validate(result,this,'test', '234' ,"xml");
		assertEquals( false, r );
		r = model.validate(result,this,'test', "<root></root>","xml");
		assertEquals( true, r );
		
		
	}
}