/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A WireBox provider object that retrieves objects by using the provider pattern.
 *
 * @see coldbox.system.ioc.IProvider
 **/
component accessors="true" {

	/**
	 * The name of the mapping this provider is binded to, MUTEX with name
	 */
	property name="name";

	/**
	 * The DSL string this provider is binded to, MUTEX with name
	 */
	property name="dsl ";

	/**
	 * he injector scope registration structure
	 */
	property name="scopeRegistration";

	/**
	 * The scope storage utility
	 */
	property name="scopeStorage";

	/**
	 * The target object that requested the provider
	 */
	property name="targetObject";

	/**
	 * Constructor
	 *
	 * @scopeRegistration             The injector scope registration structure
	 * @scopeRegistration.doc_generic struct
	 * @scopeStorage                  The scope storage utility
	 * @scopeStorage.doc_generic      coldbox.system.core.collections.ScopeStorage
	 * @name                          The name of the mapping this provider is binded to, MUTEX with name
	 * @dsl                           The DSL string this provider is binded to, MUTEX with name
	 * @targetObject                  The target object that requested the provider.
	 */
	Provider function init(
		required scopeRegistration,
		required scopeStorage,
		name,
		dsl,
		required targetObject
	){
		variables.name              = "";
		variables.dsl               = "";
		variables.scopeRegistration = arguments.scopeRegistration;
		variables.scopeStorage      = arguments.scopeStorage;
		variables.targetObject      = arguments.targetObject;

		// Verify incoming name or DSL
		if ( structKeyExists( arguments, "name" ) ) {
			variables.name = arguments.name;
		}
		if ( structKeyExists( arguments, "dsl" ) ) {
			variables.dsl = arguments.dsl;
		}

		return this;
	}

	/**
	 * Get the provided object
	 */
	any function $get(){
		var scopeInfo = variables.scopeRegistration;

		// Return if scope exists, else throw exception
		if ( variables.scopeStorage.exists( scopeInfo.key, scopeInfo.scope ) ) {
			// retrieve by name or DSL
			if ( len( variables.name ) ) {
				return variables.scopeStorage
					.get( scopeInfo.key, scopeInfo.scope )
					.getInstance( name = variables.name, targetObject = variables.targetObject );
			}

			if ( len( variables.dsl ) ) {
				return variables.scopeStorage
					.get( scopeInfo.key, scopeInfo.scope )
					.getInstance( dsl = variables.dsl, targetObject = variables.targetObject );
			}
		}

		throw(
			message = "Injector not found in scope registration information",
			detail  = "Scope information: #scopeInfo.toString()#",
			type    = "Provider.InjectorNotOnScope"
		);
	}

	/**
	 * Proxy calls to provided element
	 *
	 * @missingMethodName      missing method name
	 * @missingMethodArguments missing method arguments
	 */
	any function onMissingMethod( required missingMethodName, required missingMethodArguments ){
		var results = invoke(
			$get(),
			arguments.missingMethodName,
			arguments.missingMethodArguments
		);

		if ( !isNull( local.results ) ) {
			return results;
		}
	}

}
