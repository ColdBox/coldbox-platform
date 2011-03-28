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
component output="false" singleton{
	
	public Restrictions function init() output="false" {		
		restrictions = CreateObject("java","org.hibernate.criterion.Restrictions");
		return this;
	}
	
	public any function isNull(required string property) output="false" {
		return restrictions.isNull(arguments.property);
	}
	
	public any function isNotNull(required string property) output="false" {
		return restrictions.isNotNull(arguments.property);
	}
	
	public any function isEmpty(required string property) output="false" {
		return restrictions.isEmpty(arguments.property);
	}
	
	public any function isNotEmpty(required string property) output="false" {
		return restrictions.isNotEmpty(arguments.property);
	}
	
	public any function like(required string property, required string propertyValue) output="false" {
		return restrictions.like(arguments.property, arguments.propertyValue);
	}
	
	public any function ilike(required string property, required string propertyValue) output="false" {
		return restrictions.ilike(arguments.property, arguments.propertyValue);
	}
	
	public any function between(required string property, required any minValue, required any maxValue) output="false" {
		return restrictions.between(arguments.property, arguments.minValue, arguments.maxValue);
	}
	
	public any function isIn(required string property, required any propertyValue) output="false" {
		return restrictions.in(arguments.property, arguments.propertyValue);
	}
	
	public any function isEq(required string property, required any propertyValue) output="false" {
		return restrictions.eq(arguments.property, arguments.propertyValue);
	}
	
	public any function ne(required string property, required any propertyValue) output="false" {
		return restrictions.ne(arguments.property, arguments.propertyValue);
	}
	
	public any function isGt(required string property, required any propertyValue) output="false" {
		return restrictions.gt(arguments.property, arguments.propertyValue);
	}
	
	public any function isGe(required string property, required any propertyValue) output="false" {
		return restrictions.ge(arguments.property, arguments.propertyValue);
	}
	
	public any function conjunction(required array restrictionValues) output="false" {
		var conjunction = restrictions.conjunction();
		
		for(var i=1; i LTE ArrayLen(arguments.restrictionValues); i++) {
			conjunction.add(arguments.restrictionValues[i]);
		}
		
		return conjunction;
	}
	
	public any function disjunction(required array restrictionValues) output="false" {
		var disjunction = restrictions.disjunction();
		
		for(var i=1; i LTE ArrayLen(arguments.restrictionValues); i++) {
			disjunction.add(arguments.restrictionValues[i]);
		}
		
		return disjunction;
	}
	
	public any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments) output="false" {
		// build args to array
 		var args = [];
 		for(var i = 1; i <= structCount(arguments.missingMethodArguments); i++){
 			ArrayAppend(args, "arguments.missingMethodArguments[#i#]");
 		}
				
		switch(arguments.missingMethodName) {
			case "eq":
				return isEq(argumentCollection=arguments.missingMethodArguments);
				break;
			case "in":
				return isIn(argumentCollection=arguments.missingMethodArguments);
				break;
			case "gt":
				return isGt(argumentCollection=arguments.missingMethodArguments);
				break;
			case "ge":
				return isGe(argumentCollection=arguments.missingMethodArguments);
				break;
			default: {
				if( arrayLen(args) ){
					return evaluate("restrictions.#arguments.missingMethodName#(#arrayToList(args)#)");
				}
				return evaluate("restrictions.#arguments.missingMethodName#()");
			}
		}
	
	}
}
