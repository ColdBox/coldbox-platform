/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
A generic object that can simulate an object getters from a collection structure.
Great for when you want to validate a form that is not represented by an object.
*/
component{
			
	// constructor
	GenericObject function init(struct memento=structNew()){
		collection = arguments.memento;
		return this;
	}
	
	// Get the object's collection memento
	any function getMemento(){
		return collection;
	}
	
	// Process getters and setters
	any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments){
		
		var key = replacenocase( arguments.missingMethodName, "get","");
		
		if( structKeyExists(collection, key) ){
			return collection[key];
		}
		
		throw(message="The key requested '#key#' does not exist in the collection",
			  detail="The valid keys are #structKeyList(collection)#",
			  type="GenericObject.InvalidKey");
		
	}
}