/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Description :
	This is the ColdBox Criteria Builder Class that helps you create a nice programmatic
	DSL language for building hibernate criteria queries and projections without the added
	complexities.

*/
import coldbox.system.orm.hibernate.*;
component accessors="true"{
	
	// The criteria values this criteria builder builds upon.
	property name="criterias" type="array";
	
	// Constructor
	Criteria function init(){		
		// restrictions linkage
		this.restrictions = new criterion.Restrictions();
		// local criteria values
		setCriterias( arrayNew(1) );
		 
		return this;
	}
	
	any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments){
		
		// funnel missing methods to restrictions and append to criterias
		arrayAppend( criterias, evaluate("this.restrictions.#arguments.missingMethodName#(argumentCollection=arguments.missingMethodArguments)") );
		return this;
	}
	
	
}
