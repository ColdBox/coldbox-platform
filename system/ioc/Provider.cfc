/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* A WireBox provider object that retrieves objects by using the provider pattern.
**/
/**
 * A WireBox provider object that retrieves objects by using the provider pattern.
 */
component implements="coldbox.system.ioc.IProvider" hint="A WireBox provider object that retrieves objects by using the provider pattern." output="false" {
	
	/**
	 * Constructor
	 *
	 * @scopeRegistration The injector scope registration structure
	 * @scopeRegistration.doc_generic struct
	 * @scopeStorage The scope storage utility
	 * @scopeStorage.doc_generic coldbox.system.core.collections.ScopeStorage
	 * @name The name of the mapping this provider is binded to, MUTEX with name
	 * @dsl The DSL string this provider is binded to, MUTEX with name
	 * @targetObject The target object that requested the provider.
	 */
	public Provider function init(required scopeRegistration, required scopeStorage, name, dsl, required targetObject) {
		instance = {
			name = "",
			dsl  = "",
			scopeRegistration 	= arguments.scopeRegistration,
			scopeStorage 		= arguments.scopeStorage,
			targetObject		= arguments.targetObject
		};
			
		// Verify incoming name or DSL
		if( structKeyExists( arguments, "name" ) ){ instance.name = arguments.name; }
		if( structKeyExists( arguments, "dsl" ) ){ instance.dsl = arguments.dsl; }
		
		return this;
	}

	/**
	 * Get the provided object
	 */
	public any function get() {
		var scopeInfo = instance.scopeRegistration;
			
		// Return if scope exists, else throw exception
		if( instance.scopeStorage.exists(scopeInfo.key, scopeInfo.scope) ){
			// retrieve by name or DSL
			if( len( instance.name ) )
				return instance.scopeStorage.get( scopeInfo.key, scopeInfo.scope ).getInstance( name=instance.name, targetObject=instance.targetObject );
			if( len( instance.dsl ) )
				return instance.scopeStorage.get( scopeInfo.key, scopeInfo.scope ).getInstance( dsl=instance.dsl, targetObject=instance.targetObject );
		}
		throw( message="Injector not found in scope registration information", detail="Scope information: #scopeInfo.toString()#", type="Provider.InjectorNotOnScope" );
	}
	
	/**
	 * Proxy calls to provided element
	 *
	 * @missingMethodName missing method name
	 * @missingMethodArguments missing method arguments
	 */
	public any function onMissingMethod(required missingMethodName, required missingMethodArguments) {
		var refLocal = structnew();
		refLocal.results = invoke(get(), arguments.missingMethodName, arguments.missingMethodArguments);
		
		if ( structKeyExists(refLocal,"results") ) {
			return refLocal.results;
		}
		
	}

}