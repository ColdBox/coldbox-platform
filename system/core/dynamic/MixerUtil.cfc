/**
 * A utility object that provides runtime mixins
 */
component accessors="true" {

	// The mixins map to inject
	property name="mixins";

	/**
	 * Constructor
	 */
	function init(){
		variables.mixins = {
			"$wbMixer"            : true,
			"removeMixin"         : variables.removeMixin,
			"injectMixin"         : variables.injectMixin,
			"invokerMixin"        : variables.invokerMixin,
			"injectPropertyMixin" : variables.injectPropertyMixin,
			"removePropertyMixin" : variables.removePropertyMixin,
			"includeitMixin"      : variables.includeitMixin,
			"getPropertyMixin"    : variables.getPropertyMixin,
			"exposeMixin"         : variables.exposeMixin,
			"methodProxy"         : variables.methodProxy,
			"getVariablesMixin"   : variables.getVariablesMixin
		};

		return this;
	}

	/**
	 * Start method injection set -> Injects: includeitMixin,injectMixin,removeMixin,invokerMixin,injectPropertyMixin,removePropertyMixin,getPropertyMixin
	 *
	 * @target target object
	 */
	function start( required target ){
		if ( !structKeyExists( arguments.target, "$wbMixer" ) ) {
			structAppend( arguments.target, variables.mixins, true );
		}
		return arguments.target;
	}

	/**
	 * Remove mixed methods
	 *
	 * @target target object
	 */
	function stop( required target ){
		for ( var udf in variables.mixins ) {
			structDelete( arguments.target, udf );
		}
		return arguments.target;
	}

	/****************** MIXINS ************************/

	/**
	 * Exposes a private function publicly
	 */
	function exposeMixin( required method, newName = "" ){
		// get new name
		if ( !len( arguments.newName ) ) {
			arguments.newName = arguments.method;
		}

		// stash it away
		if ( !structKeyExists( this, "$exposedMethods" ) ) {
			this.$exposedMethods = {};
		}
		this.$exposedMethods[ arguments.method ] = variables[ arguments.method ];

		// replace with proxy.
		this[ arguments.newName ] = this.methodProxy;

		// Create alias if needed
		if ( arguments.newName != arguments.method ) {
			this.$exposedMethods[ arguments.newName ] = this.$exposedMethods[ arguments.method ];
		}

		return this;
	}

	/**
	 * Executes a dynamic method according to injected name
	 */
	function methodProxy(){
		var methodName = getFunctionCalledName();

		if ( !structKeyExists( this.$exposedMethods, methodName ) ) {
			throw(
				message = "The exposed method you are calling: #methodName# does not exist",
				detail  = "Exposed methods are #structKeyList( this.$exposedMethods )#",
				type    = "ExposedMethodProxy"
			);
		}

		var method = this.$exposedMethods[ methodName ];
		return method( argumentCollection = arguments );
	}

	/**
	 * Include a template
	 */
	function includeitMixin( required template ){
		include "#arguments.template#";
		return this;
	}

	/**
	 * Get the variables scope
	 */
	function getVariablesMixin(){
		return variables;
	}

	/**
	 * Injects a method into the CFC
	 */
	function injectMixin( required name, required udf ){
		variables[ arguments.name ] = arguments.udf;
		this[ arguments.name ]      = arguments.udf;
		return this;
	}

	/**
	 * Get a property from a scope
	 */
	function getPropertyMixin(
		required name,
		scope = "variables",
		defaultValue
	){
		var thisScope = arguments.scope eq "this" ? this : variables;

		if ( NOT structKeyExists( thisScope, arguments.name ) AND structKeyExists( arguments, "defaultValue" ) ) {
			return arguments.defaultValue;
		}

		return thisScope[ arguments.name ];
	}

	/**
	 * injects a property into the passed scope
	 */
	function injectPropertyMixin(
		required propertyName,
		required propertyValue,
		scope = "variables"
	){
		"#arguments.scope#.#arguments.propertyName#" = arguments.propertyValue;
		return this;
	}

	/**
	 * Removes a method in a CFC
	 */
	function removeMixin( required UDFName ){
		structDelete( this, arguments.udfName );
		structDelete( variables, arguments.udfName );

		return this;
	}

	/**
	 * Removes a method in a CFC
	 */
	function removePropertyMixin( required propertyName, scope = "variables" ){
		switch ( arguments.scope ) {
			case "variables":
				return structDelete( variables, arguments.propertyName );
				break;
			case "this":
				structDelete( this, arguments.propertyName );
				break;
			default:
				throw( "Invalid scope" );
		}
		return this;
	}

	/**
	 * Calls private/packaged/public methods
	 */
	function invokerMixin( required method, argCollection, argList ){
		var key      = "";
		var refLocal = {};

		// Determine type of invocation
		if ( !isNull( arguments.argCollection ) ) {
			return invoke(
				this,
				arguments.method,
				arguments.argCollection
			);
		} else if ( !isNull( arguments.argList ) ) {
			return invoke(
				this,
				arguments.method,
				arguments.argList
					.listToArray()
					.reduce( function( results, item ){
						results[ listFirst( item, "=" ) ] = listLast( item, "=" );
						return results;
					}, {} )
			);
		} else {
			return invoke( this, arguments.method );
		}
	}

	/**
	 * Utility function injected into target objects that expose delegation
	 * It will allow ANY delegate method to do method delegation lookups
	 *
	 * @throws InvalidDelegateFunction - When a function that has not been delegated has been called
	 */
	function getByDelegate(){
		var targetFunction = getFunctionCalledName();

		if ( !this.$wbDelegateMap.keyExists( targetFunction ) ) {
			throw(
				message: "The requested delegate function (#targetFunction#) has not been registered",
				type   : "InvalidDelegateFunction"
			)
		}

		// Invoke delegation with argument collection
		return invoke(
			this.$wbDelegateMap[ targetFunction ].delegate,
			this.$wbDelegateMap[ targetFunction ].method,
			arguments
		);
	}

}
