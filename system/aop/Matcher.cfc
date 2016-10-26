/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* I match class and method names to data in this matcher
*/
component accessors="true"{

	/**
	* Any matcher
	*/
	property name="any";
	/**
	* Matching returns
	*/
	property name="returns";
	/**
	* Matching annotations
	*/
	property name="annotation";
	/**
	* Matching annotation value
	*/
	property name="annotationValue";
	/**
	* Matching mapping names
	*/
	property name="mappings";
	/**
	* Matching instances
	*/
	property name="instanceOf";
	/**
	* Matchin regex
	*/
	property name="regex";
	/**
	* Mathching method names
	*/
	property name="methods";
	/**
	* And operator
	*/
	property name="and";
	/**
	* OR operator
	*/
	property name="or";

	/**
	* Constructor
	*/
    function init(){    
		reset();
		return this;
    }

    /**
    * Reset the matcher memento to defaults
    */
    function reset(){    
		// prepare instance for this matcher
		variables.any 				= false;
		variables.returns 			= "";
		variables.annotation 		= "";
		variables.mappings 			= "";
		variables.instanceOf 		= "";
		variables.regex 			= "";
		variables.methods 			= "";
		
		// Aggregators
		variables.and 				= "";
		variables.or  				= "";	
		
		return this;	    
    }
	
    /**
    * Get the matcher memento
    */
    function getMemento(){
		var props = listToArray( "and,or,any,returns,annotation,annotationValue,mappings,instanceOf,regex,methods" );
		var memento = {};
		for( var thisProp in props ){
			if( structKeyExists( variables, thisProp) ){
				memento[ thisProp ] = variables[ thisProp ];
			}
		}
		return memento;
    }
	
    /**
    * Matches a class to this matcher according to its criteria
    * @target	The target to match against to
	* @mapping	The target mapping to match against
	* @mapping.doc_generic coldbox.system.ioc.config.Mapping
    */
    boolean function matchClass( required target, required mapping ){    
		var results = matchClassRules( argumentCollection=arguments );
		
		// AND matcher set?
		if( isObject( variables.and ) ){ 
			return ( results AND variables.and.matchClass( argumentCollection=arguments ) ); 
		}
		// OR matcher set?
		if( isObject( variables.or ) ){ 
			return ( results OR variables.or.matchClass( argumentCollection=arguments ) ); 
		}
		
		return results;			
    }
    
    /**
    * Matches a method to this matcher according to its criteria
    * @metadata The UDF metadata to use for matching
    */
    boolean function matchMethod( required metadata ){    
		var results = matchMethodRules( arguments.metadata );
		
		// AND matcher set?
		if( isObject( variables.and ) ){ 
			return ( results AND variables.and.matchMethod( arguments.metadata ) ); 
		}
		// OR matcher set?
		if( isObject( variables.or ) ){ 
			return ( results OR variables.or.matchMethod( arguments.metadata ) ); 
		}
		
		return results;			
    }
    
    /**
    * Go through all the rules in this matcher and match
    * @metadata The UDF metadata to use for matching
    */
    private boolean function matchMethodRules( required metadata ){    
		// Some metadata defaults
		var name 	= arguments.metadata.name;
		var returns = "any";
		
		if( structKeyExists( arguments.metadata, "returntype" ) ){ 
			returns = arguments.metadata.returntype; 
		}
		
		// Start with any()
		if( variables.any ){ return true; }
		// Check explicit methods
		if( len( variables.methods ) AND listFindNoCase( variables.methods, name ) ){
			return true;
		}
		// regex
		if( len( variables.regex ) AND reFindNoCase( variables.regex, name ) ){
			return true;
		}
		// returns
		if( len( variables.returns ) AND variables.returns EQ returns ){
			return true;
		}
		// annotation
		if( len( variables.annotation ) AND structKeyExists( arguments.metadata, variables.annotation ) ){
			// No annotation value
			if( NOT structKeyExists( variables, "annotationValue" ) ){ 
				return true; 
			}
				
			// check annotation value
			if( structKeyExists( variables, "annotationValue" ) AND arguments.metadata[ variables.annotation ] EQ variables.annotationValue ){
				return true;	
			}
		}
		
		return false;   
    }
    
    /**
    * Go through all the rules in this matcher and match
    * @target	The target to match against to
	* @mapping	The target mapping to match against
	* @mapping.doc_generic coldbox.system.ioc.config.Mapping
    */
    private boolean function matchClassRules( required target, required mapping ){    
		var md	  = arguments.mapping.getObjectMetadata();
		var path  = reReplace( md.name, "(\/|\\)", ".", "all" );
		
		// Start with any()
		if( variables.any ){ 
			return true; 
		}
		// Check explicit mappings
		if( len( variables.mappings ) AND listFindNoCase( variables.mappings, arguments.mapping.getName() ) ){
			return true;
		}
		// regex
		if( len( variables.regex ) AND reFindNoCase( variables.regex, path ) ){
			return true;
		}
		// instanceOf
		if( len( variables.instanceOf ) AND isInstanceOf( arguments.target,variables.instanceOf ) ){
			return true;
		}
		// annotation
		if( len( variables.annotation ) AND structKeyExists( md, variables.annotation ) ){
			// No annotation value
			if( NOT structKeyExists( variables, "annotationValue" ) ){ 
				return true; 
			}
				
			// check annotation value
			if( structKeyExists( variables, "annotationValue" ) AND md[ variables.annotation ] EQ variables.annotationValue ){
				return true;	
			}
		}
		
		return false;   
    }
	
    /**
    * Match against any method name or class path
    */
    function any(){    
		variables.any = true;
		return this;
    }
    
    /**
    * Match against return types in methods only
    * @type The type of return to match against.  Only for method matching
    */
    function returns( required type ){    
		variables.returns = arguments.type;
		return this;
    }
    
    /**
    * Matches annotations on components or methods with or without a value
    * @annotation The annotation to discover
    * @value The value of the annotation that must match. OPTIONAL
    */
    function annotatedWith( required annotation, value ){    
		variables.annotation = arguments.annotation;
		// the value of the annotation
		if( structKeyExists( arguments, "value" ) ){
			variables.annotationValue = arguments.value;
		}
		return this;
    }
	
    /**
    * Match one, list or array of mapping names. Class Matching Only.
    * @mappings One, list or array of mappings to match
    */
    function mappings( required mappings ){    
		if( isArray( arguments.mappings ) ){ 
			arguments.mappings = arrayToList( arguments.mappings ); 
		}
		variables.mappings = arguments.mappings;
		return this;
    }
    
    /**
    * Matches against a family of components according to the passed classPath. Class Matching Only.
    * @classPath The class path to verify instance of
    */
    function instanceOf( required classPath ){    
		variables.instanceOf = arguments.classPath;
		return this;
    }
    
    /**
    * Matches a class path or method name to this regular expression
    * @regex The regular expression to match against
    */
    function regex( required regex ){    
		variables.regex = arguments.regex;
		return this;	    
    }
    
    /**
    * A list, one or an array of methods to explicitly match
    * @methods One, list or array of methods to match
    */
    function methods( required methods ){    
		if( isArray( arguments.methods ) ){ 
			arguments.methods = arrayToList( arguments.methods ); 
		}
		variables.methods = arguments.methods;
		return this;
    }
    
    /**
    * AND this matcher with another matcher
    * @matcher The matcher to AND this matcher with
    * @matcher.doc_generic coldbox.system.aop.Matcher
    */
    function andMatch( required matcher ){    
		variables.and = arguments.matcher;
		return this;
    }
	
    /**
    * OR this matcher with another matcher
    * @matcher The matcher to AND this matcher with
    * @matcher.doc_generic coldbox.system.aop.Matcher
    */
    function orMatch( required matcher ){    
		variables.or = arguments.matcher;
		return this;
    }
	
}