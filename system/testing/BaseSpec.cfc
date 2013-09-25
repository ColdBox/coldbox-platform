component{
			
	// init local properies

	// MockBox mocking framework
	variables.mockBox 			= new coldbox.system.testing.MockBox();
	// Assertion object
	variables.assert 			= new coldbox.system.testing.Assertion();
	// Custom Matchers
	variables.customMatchers 	= {};
	
	/************************************** EXPECTATIONS *********************************************/
	
	/**
	* Assert that the passed expression is true
	* @facade
	*/
	function assert(required expression, message=""){
		return variables.assert.assert(argumentCollection=arguments);
	}

	/**
	* Fail an assertion
	* @facade
	*/
	function fail(message=""){
		variables.assert.fail(argumentCollection=arguments);
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
			structAppend( variables.customMatchers, arguments.matchers, true );
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
	* Debug some information into the TestBox debugger buffer
	* @var.hint The data to send
	* @deepCopy.hint By default we do not duplicate the incoming information, but you can :)
	*/
	BaseSpec function debug(required var, boolean deepCopy=false){
		
		return this;
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
	* Make a private method on a CFC to public.
	*/
	BaseSpec function makePublic(){
		// TODO: implement
		
		return this;
	}
	
	/**
	* Get a reference to MockBox engine 
	*/
	function getMockBox(){
		return variables.mockBox;
	}
	
}