/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Michael McKellip , Luis Majano
Description :
	A proxy to hibernate org.hibernate.criterion.Restrictions object to allow
	for criteria based querying
*/
component singleton{
	
	// Constructor
	Restrictions function init(){		
		restrictions = CreateObject("java","org.hibernate.criterion.Restrictions");
		return this;
	}
	
	// Get the native hibernate restrictions object: org.hibernate.criterion.Restrictions
	any function getNativeClass(){
		return restrictions;
	}
	
	// Where the property value is between two distinct values
	any function between(required string property, required any minValue, required any maxValue){
		return restrictions.between(arguments.property, arguments.minValue, arguments.maxValue);
	}
	
	// Where a property equals a particular value, you can also use eq()
	any function isEq(required string property, required any propertyValue){
		return restrictions.eq(arguments.property, arguments.propertyValue);
	}
	
	// Where a property is true
	any function isTrue(required string property){
		return restrictions.eq(arguments.property, javaCast("boolean",true) );
	}
	
	// Where a property is false
	any function isFalse(required string property){
		return restrictions.eq(arguments.property, javaCast("boolean",false) );
	}
	
	// Where one property must equal another
	any function eqProperty(required string property, required string otherProperty){
		return restrictions.eqProperty(arguments.property, arguments.otherProperty);
	}
	
	// Where a property is greater than a particular value, you can also use gt()
	any function isGt(required string property, required any propertyValue){
		return restrictions.gt(arguments.property, arguments.propertyValue);
	}
	
	// Where a one property must be greater than another
	any function gtProperty(required string property, required string otherProperty){
		return restrictions.gtProperty(arguments.property, arguments.otherProperty);
	}
	
	// Where a property is greater than or equal to a particular value, you can also use ge()
	any function isGe(required string property, required any propertyValue){
		return restrictions.ge(arguments.property, arguments.propertyValue);
	}
	
	// Where a one property must be greater than or equal to another
	any function geProperty(required string property, required string otherProperty){
		return restrictions.geProperty(arguments.property, arguments.otherProperty);
	}
	
	// Where an objects id equals the specified value
	any function idEQ(required any propertyValue){
		return restrictions.idEQ(arguments.propertyValue);
	}
	
	// A case-insensitive 'like' expression
	any function ilike(required string property, required string propertyValue){
		return restrictions.ilike(arguments.property, arguments.propertyValue);
	}
	
	// Where a property is contained within the specified list of values, the property value can be a collection (struct) or array or list, you can also use in()
	any function isIn(required string property, required any propertyValue){
		// infalte to array if simple values
		if( isSimpleValue(arguments.propertyValue) ){ arguments.propertyValue = listToArray( arguments.propertyValue); } 
		return restrictions.in(arguments.property, arguments.propertyValue);
	}
	
	// Where a collection property is empty
	any function isEmpty(required string property){
		return restrictions.isEmpty(arguments.property);
	}
	
	// Where a collection property is not empty
	any function isNotEmpty(required string property){
		return restrictions.isNotEmpty(arguments.property);
	}
	
	// Where a property is null
	any function isNull(required string property){
		return restrictions.isNull(arguments.property);
	}
	
	// Where a property is not null
	any function isNotNull(required string property){
		return restrictions.isNotNull(arguments.property);
	}
	
	// Where a property is less than a particular value, you can also use lt()
	any function islt(required string property, required any propertyValue){
		return restrictions.lt(arguments.property, arguments.propertyValue);
	}
	
	// Where a one property must be less than another
	any function ltProperty(required string property, required string otherProperty){
		return restrictions.ltProperty(arguments.property, arguments.otherProperty);
	}
	
	// Where a property is less than or equal a particular value, you can also use le()
	any function isle(required string property, required any propertyValue){
		return restrictions.le(arguments.property, arguments.propertyValue);
	}
	
	// Where a one property must be less than or equal to another
	any function leProperty(required string property, required string otherProperty){
		return restrictions.leProperty(arguments.property, arguments.otherProperty);
	}
	
	// Equivalent to SQL like expression
	any function like(required string property, required string propertyValue){
		return restrictions.like(arguments.property, arguments.propertyValue);
	}
	
	// Where a property does not equal a particular value
	any function ne(required string property, required any propertyValue){
		return restrictions.ne(arguments.property, arguments.propertyValue);
	}
	
	// Where one property does not equal another
	any function neProperty(required string property, required any otherProperty){
		return restrictions.neProperty(arguments.property, arguments.otherProperty);
	}
	
	// Where a collection property's size equals a particular value
	any function sizeEq(required string property, required any propertyValue){
		return restrictions.sizeEq(arguments.property, arguments.propertyValue);
	}
	
	// Where a collection property's size is greater than a particular value
	any function sizeGT(required string property, required any propertyValue){
		return restrictions.sizeGT(arguments.property, arguments.propertyValue);
	}
	
	// Where a collection property's size is greater than or equal a particular value
	any function sizeGE(required string property, required any propertyValue){
		return restrictions.sizeGE(arguments.property, arguments.propertyValue);
	}
	
	// Where a collection property's size is less than a particular value
	any function sizeLT(required string property, required any propertyValue){
		return restrictions.sizeLT(arguments.property, arguments.propertyValue);
	}
	
	// Where a collection property's size is less than or equal a particular value
	any function sizeLE(required string property, required any propertyValue){
		return restrictions.sizeLE(arguments.property, arguments.propertyValue);
	}
	
	// Where a collection property's size is not equal to a particular value
	any function sizeNE(required string property, required any propertyValue){
		return restrictions.sizeNE(arguments.property, arguments.propertyValue);
	}
	
	// Use arbitrary SQL to modify the resultset
	any function sqlRestriction(required string sql){
		return restrictions.sqlRestriction(arguments.sql);
	}
	
	// Group expressions together in a single conjunction (A and B and C...) and return the conjunction
	any function conjunction(required array restrictionValues){
		var cj = restrictions.conjunction();
		
		for(var i=1; i LTE ArrayLen(arguments.restrictionValues); i++){
			cj.add( arguments.restrictionValues[i] );
		}
		
		return cj;
	}
	
	// Return the conjuction of N expressions as arguments
	any function $and(){
		var expressions = [];
		for(var key in arguments){
			arrayAppend(expressions, arguments[key]);
		}
		return this.conjunction(expressions);
	}
	
	// Return the disjunction of N expressions as arguments
	any function $or(){
		var expressions = [];
		for(var key in arguments){
			arrayAppend(expressions, arguments[key]);
		}
		return this.disjunction(expressions);
	}
	
	// Group expressions together in a single disjunction (A or B or C...)
	any function disjunction(required array restrictionValues){
		var dj = restrictions.disjunction();
		
		for(var i=1; i LTE ArrayLen(arguments.restrictionValues); i++){
			dj.add( arguments.restrictionValues[i] );
		}
		
		return dj;
	}
	
	// Return the negation of an expression
	any function isNot(required any criterion){
		return restrictions.not(arguments.criterion);
	}
	
	any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments){
		// build args to array
 		var args = [];
 		for(var i = 1; i <= structCount(arguments.missingMethodArguments); i++){
 			ArrayAppend(args, "arguments.missingMethodArguments[#i#]");
 		}
				
		switch(arguments.missingMethodName){
			case "eq":
				return isEq(argumentCollection=arguments.missingMethodArguments);
				break;
			case "in":
				return isIn(argumentCollection=arguments.missingMethodArguments);
				break;
			case "gt":
				return isGt(argumentCollection=arguments.missingMethodArguments);
				break;
			case "lt":
				return isLT(argumentCollection=arguments.missingMethodArguments);
				break;
			case "le":
				return isLE(argumentCollection=arguments.missingMethodArguments);
				break;
			case "ge":
				return isGe(argumentCollection=arguments.missingMethodArguments);
				break;
			case "and":
				return $and(argumentCollection=arguments.missingMethodArguments);
				break;
			case "or":
				return $or(argumentCollection=arguments.missingMethodArguments);
				break;
			case "not":
				return isNot(argumentCollection=arguments.missingMethodArguments);
				break;
			default:{
				if( arrayLen(args) ){
					return evaluate("restrictions.#arguments.missingMethodName#(#arrayToList(args)#)");
				}
				return evaluate("restrictions.#arguments.missingMethodName#()");
			}
		}
	
	}
}
