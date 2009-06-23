<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano & Henrik Joreteg
Date        :	06/18/2009
Description :
	An incredible validatoridator for all the following:
	
validatoridations (Can be a list):
- boolean
- date
- email
- eurodate
- exactLen-X
- numeric or float
- guid
- integer
- maxLen-X
- minLen-X
- range-1..4
- regex-{regexhere}
- sameAs-{fieldname}
- ssn
- string
- telephone
- udf-{UDF Method}
- URL
- uuid
- USdate: a U.S. date of the format mm/dd/yy, with 1-2 digit days and months, 1-4 digit years. 
- zipcode 5 or 9 digit format zip codes

----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>

	function setup(){
		validator = getMockBox().createMock(className="coldbox.system.plugins.Validator");		
	}
		
	function testcheckAlphaOnly(){
		assertTrue( validator.checkALphaOnly('abc') );
		assertFalse(validator.checkAlphaOnly('123') );
	}
	
	function testcheckBoolean(){ 
		assertTrue( validator.checkBoolean(true) );
		assertFalse(validator.checkBoolean('xys') );
	}
		
	function testcheckDate(){
		assertTrue( validator.checkDate(now()) );
		assertFalse(validator.checkDate('12ab3') );
	}
	
	function testcheckEmail(){
		assertTrue( validator.checkEmail('lmajano@esri.com') );
		assertFalse(validator.checkEmail('123') );
	}
	
	function testcheckEurodate(){
		assertTrue( validator.checkEurodate('12/12/09') );
		assertFalse(validator.checkEurodate('asdf1234') );
	}
	
	function testcheckExactLen(){
		assertTrue( validator.checkExactLen('abc',3) );
		assertFalse(validator.checkExactLen('123',2) );
		assertFalse(validator.checkExactLen('123',5) );
	}
	
	function testcheckNumeric(){
		assertTrue( validator.checkNumeric('123') );
		assertTrue( validator.checkNumeric('12.23') );
		assertFalse(validator.checkNumeric('abc234') );
	}
	
	function testcheckGUID(){
		assertTrue( validator.checkGUID('12345678-1234-1234-1234-123456789123') );
		assertFalse(validator.checkGUID('123') );
	}
	
	function testcheckInteger(){	
		assertTrue( validator.checkInteger('13') );
		assertFalse(validator.checkInteger('12.3') );
	}
	
	function testcheckMaxLen(){
		assertTrue( validator.checkMaxLen('abc',4) );
		assertFalse(validator.checkMaxLen('123',1) );
		assertFalse(validator.checkMaxLen('12',1) );
	}
	
	function testcheckMinLen(){
		assertTrue( validator.checkMinLen('abc',3) );
		assertFalse(validator.checkMinLen('123',4) );
	}
	
	function testcheckRange(){
		assertTrue( validator.checkRange(5,1,10) );
		assertFalse(validator.checkRange(1,5,10) );
	}
	
	function testcheckRegex(){
		assertTrue( validator.checkRegex('abc','^[a-z]+$') );
		assertFalse(validator.checkRegex('123','^[a-z]$') );
	}
	
	function testcheckSameAsNoCase(){
		assertTrue( validator.checkSameAsNoCase('abc','ABC') );
		assertFalse(validator.checkSameAsNoCase('123','absc') );
	}
	
	function testcheckSameAs(){
		assertTrue( validator.checkSameAs('abc','abc') );
		assertFalse(validator.checkSameAs('123','adasf') );
		assertFalse(validator.checkSameAs('abc','ABC') );
	}
	
	function testcheckSSN(){
		assertTrue( validator.checkSSN('555-55-5555') );
		assertFalse(validator.checkSSN('123') );
	}
	
	function testcheckString(){
		assertTrue( validator.checkString('abc') );
		assertFalse(validator.checkString(structnew()) );
	}
	
	function testcheckTelephone(){
		assertTrue( validator.checkTelephone('3055555555') );
		assertFalse(validator.checkTelephone('123') );
	}
	
	function testcheckWithUDF(){
		assertTrue( validator.checkWithUDF(true,variables.myUDF) );
		assertFalse(validator.checkWithUDF('2342-asb',variables.myUDF) );
	}
	
	function testcheckURL(){
		assertTrue( validator.checkURL('http://www.coldbox.org') );
		assertFalse(validator.checkURL('234-asdf-') );
	}
	
	function testcheckUUID(){
		assertTrue( validator.checkUUID(createUUID()) );
		assertFalse(validator.checkUUID('123') );
	}
	
	function testcheckUSDate(){
		assertTrue( validator.checkUSDate('04/24/2009') );
		assertFalse(validator.checkUSDate('123') );
	}
	
	function testcheckZipCode(){
		assertTrue( validator.checkZipCode('91739') );
		assertFalse(validator.checkZipCode('123') );
	}
	
	function testcheckIPAddress(){
		assertTrue( validator.checkIPAddress('10.0.0.1') );
		assertFalse(validator.checkIPAddress('123') );
	}	
</cfscript>

<cffunction name="myUDF" access="private" returntype="boolean">
	<cfargument name="str" type="string" required="true" default="" hint=""/>
	<cfreturn isBoolean(arguments.str)>
</cffunction>
</cfcomponent>