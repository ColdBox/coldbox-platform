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
	 * @scopeRegistration The injector scope registration structure
	 * @name              The name of the mapping this provider is binded to
	 * @targetObject      The target object that requested the provider.
	 * @injectorName      The name of the injector requesting the dependency
	 */
	Provider function init(
		required struct scopeRegistration,
		name,
		required targetObject,
		required injectorName
	){
		variables.scopeStorage      = new coldbox.system.core.collections.ScopeStorage();
		variables.scopeRegistration = arguments.scopeRegistration;
		variables.targetObject      = arguments.targetObject;
		variables.injectorName      = arguments.injectorName;
		variables.name              = arguments.name;

		return this;
	}

	/**
	 * Get the provided object
	 */
	any function $get(){
		var scopeInfo = variables.scopeRegistration;

		// Return if scope exists, else throw exception
		if ( variables.scopeStorage.exists( scopeInfo.key, scopeInfo.scope ) ) {
			// Get root injector
			var injector = variables.scopeStorage.get( scopeInfo.key, scopeInfo.scope );
			// Do we need a specific injector
			if ( variables.injectorName != "root" ) {
				injector = injector.getInjectorReference( variables.injectorName );
			}

			return injector.getInstance( name = variables.name, targetObject = variables.targetObject );
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
