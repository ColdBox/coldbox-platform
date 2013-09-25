/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* This is a base spec object that is used to test XUnit and BDD style specification methods
*/ 
component{
			
	// MockBox mocking framework
	this.$mockBox 			= new coldbox.system.testing.MockBox();
	// Assertions object
	this.$assert			= new coldbox.system.testing.Assertion();
	// Custom Matchers
	this.$customMatchers 	= {};
	// Utility object
	this.$utility 			= new coldbox.system.core.util.Util();
	// Test Suites are stored here
	this.$suites 			= [];
	
	/************************************** EXPECTATIONS *********************************************/
	
	/**
	* Assert that the passed expression is true
	* @facade
	*/
	function assert(required expression, message=""){
		return this.$assert.assert(argumentCollection=arguments);
	}

	/**
	* Fail an assertion
	* @facade
	*/
	function fail(message=""){
		this.$assert.fail(argumentCollection=arguments);
	}

	/**
	* Start an expectation expression. This returns an instance of Expectation so you can work with its matchers.
	*/
	Expectation function expect( required any actual ){
		// build an expectation 
	}
	
	/**
	* Add custom matchers to your expectations
	* @matchers.hint The structure of custom matcher functions to register or a path or instance of a CFC containing all the matcher functions to register
	*/
	function addMatchers(required any matchers){

		if( isStruct( arguments.matchers ) ){
			// register the custom matchers with override
			structAppend( this.$customMatchers, arguments.matchers, true );
			return this;
		}

		// Build the Matcher CFC
		var oMatchers = "";
		if( isSimpleValue( arguments.matchers ) ){
			oMatchers = new "#arguments.matchers#"();
		}
		else if( isObject( arguments.matchers ) ){
			oMatchers = arguments.matchers;
		}
		else{
			throw(type="TestBox.InvalidMatcher", message="The matchers argument you sent is not valid, it must be a struct, string or object");
		}

		// Register the methods into our custom matchers



		return this;
	}

	/************************************** UTILITY METHODS *********************************************/
	
	/**
	* Send some information to the console via writedump(output="console")
	* @var.hint The data to send
	* @top.hint Apply a top to the dump, by default it does 9999 levels
	*/
	BaseSpec function console(required var, top=9999){
		writedump(var=arguments.var, output="console", top=arguments.top );
		return this;
	}
	
	/**
	* Debug some information into the TestBox debugger array buffer
	* @var.hint The data to send
	* @deepCopy.hint By default we do not duplicate the incoming information, but you can :)
	*/
	BaseSpec function debug(required var, boolean deepCopy=false){
		var newVar = ( arguments.deepCopy ? duplicate( arguments.var ) : arguments.var );
		arrayAppend( getDebug(), newVar );
		return this;
	}

	/**
	*  Clear the debug array buffer
	*/
	BaseSpec function clearDebug(){
		if( structKeyExists( request, "$testbox_debug" ) ){
			structclear( request.$testbox_debug );
		}
		return this;
	}

	/**
	*  Get the debug array buffer
	*/
	array function getDebug(){
		return ( structKeyExists( request, "$testbox_debug" ) ? request.$testbox_debug : [] );
	}

	/**
	* Write some output to the ColdFusion output buffer
	*/
	BaseSpec function print(required message) output=true{
		writeOutput( arguments.message );
		return this;
	}
	
	/**
	* Write some output to the ColdFusion output buffer using a <br> attached
	*/
	BaseSpec function println(required message) output=true{
		return print( arguments.message & "<br>" );
	}
	
	/************************************** MOCKING METHODS *********************************************/
	
	/**
	* Make a private method on a CFC public with or without a new name and returns the target object
	* @target.hint The target object to expose the method
	* @method.hint The private method to expose
	* @newName.hint If passed, it will expose the method with this name, else just uses the same name
	*/
	any function makePublic( required any target, required string method, string newName="" ){
		
		// mix it
		arguments.target.$exposeMixin = this.$utility.getMixerUtil().exposeMixin;
		// expose it
		arguments.target.$exposeMixin( arguments.method, arguments.newName );

		return arguments.target;
	}

	/**
	* First line are the query columns separated by commas. Then do a consecuent rows separated by line breaks separated by | to denote columns.
	*/
	function querySim(required queryData){
		return this.$mockBox.querySim( arguments.queryData );
	}
	
	/**
	* Get a reference to the MockBox engine 
	*/
	function getMockBox(){
		return this.$mockBox;
	}
	
}