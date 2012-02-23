<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I match class and method names to data in this matcher
----------------------------------------------------------------------->
<cfcomponent output="false" hint="I match class and method names to data in this matcher">
	
<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- init --->    
    <cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">    
    	<cfscript>
			reset();
			
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<!--- reset --->    
    <cffunction name="reset" output="false" access="public" returntype="any" hint="Reset the matcher memento to defaults">    
    	<cfscript>
			// prepare instance for this matcher
			instance = {
				any = false,
				returns = "",
				annotation = "",
				mappings = "",
				instanceOf = "",
				regex = "",
				methods = ""
			};
			
			// Aggregators
			instance.and = "";
			instance.or  = "";	
			
			return this;	    
    	</cfscript>    
    </cffunction>
	
	<!--- getMemento --->    
    <cffunction name="getMemento" output="false" access="public" returntype="any" hint="Get the matcher memento">    
    	<cfscript>
			return instance;	    
    	</cfscript>    
    </cffunction>
	
	<!--- matchClass --->    
    <cffunction name="matchClass" output="false" access="public" returntype="boolean" hint="Matches a class to this matcher according to its criteria">    
    	<cfargument name="target"  type="any" required="true" hint="The target to match against to"/>
		<cfargument name="mapping" type="any" required="true" hint="The target mapping to match against to" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
    	<cfscript>
			var results = matchClassRules(argumentCollection=arguments);
			
			// AND matcher set?
			if( isObject( instance.and ) ){ return (results AND instance.and.matchClass(argumentCollection=arguments) ); }
			// OR matcher set?
			if( isObject( instance.or ) ){ return (results OR instance.or.matchClass(argumentCollection=arguments) ); }
			
			return results;			
    	</cfscript>    
    </cffunction>
    
    <!--- matchMethod --->    
    <cffunction name="matchMethod" output="false" access="public" returntype="boolean" hint="Matches a method to this matcher according to its criteria">    
    	<cfargument name="metadata"  type="any" required="true" hint="The UDF metadata to use for matching"/>
		<cfscript>
			var results = matchMethodRules(arguments.metadata);
			
			// AND matcher set?
			if( isObject( instance.and ) ){ return (results AND instance.and.matchMethod(arguments.metadata) ); }
			// OR matcher set?
			if( isObject( instance.or ) ){ return (results OR instance.or.matchMethod(arguments.metadata) ); }
			
			return results;			
    	</cfscript>    
    </cffunction>
    
     <!--- matchMethodRules --->    
    <cffunction name="matchMethodRules" output="false" access="private" returntype="boolean" hint="Go through all the rules in this matcher and match">    
    	<cfargument name="metadata"  type="any" required="true" hint="The UDF metadata to use for matching"/>
		<cfscript>	 
			// Some metadata defaults
			var name 	= arguments.metadata.name;
			var returns = "any";
			
			if( structKeyExists(arguments.metadata, "returntype") ){ returns = arguments.metadata.returntype; }
			
			// Start with any()
			if( instance.any ){ return true; }
			// Check explicit methods
			if( len(instance.methods) AND listFindNoCase( instance.methods, name ) ){
				return true;
			}
			// regex
			if( len(instance.regex) AND reFindNoCase(instance.regex, name) ){
				return true;
			}
			// returns
			if( len(instance.returns) AND instance.returns EQ returns ){
				return true;
			}
			// annotation
			if( len(instance.annotation) AND structKeyExists(arguments.metadata, instance.annotation)){
				// No annotation value
				if( NOT structKeyExists(instance,"annotationValue") ){ return true; }
					
				// check annotation value
				if( structKeyExists(instance,"annotationValue") AND arguments.metadata[instance.annotation] EQ instance.annotationValue ){
					return true;	
				}
			}
			
			return false;   
    	</cfscript>    
    </cffunction>
    
    <!--- matchRules --->    
    <cffunction name="matchClassRules" output="false" access="private" returntype="boolean" hint="Go through all the rules in this matcher and match">    
    	<cfargument name="target"  type="any" required="true" hint="The target to match against to"/>
		<cfargument name="mapping" type="any" required="true" hint="The target mapping to match against to" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
    	<cfscript>	 
			var md	  = arguments.mapping.getObjectMetadata();
			var path  = reReplace(md.name, "(\/|\\)", ".","all");
			
			// Start with any()
			if( instance.any ){ return true; }
			// Check explicit mappings
			if( len(instance.mappings) AND listFindNoCase( instance.mappings, arguments.mapping.getName() ) ){
				return true;
			}
			// regex
			if( len(instance.regex) AND reFindNoCase(instance.regex, path) ){
				return true;
			}
			// instanceOf
			if( len(instance.instanceOf) AND isInstanceOf(arguments.target,instance.instanceOf) ){
				return true;
			}
			// annotation
			if( len(instance.annotation) AND structKeyExists(md, instance.annotation)){
				// No annotation value
				if( NOT structKeyExists(instance,"annotationValue") ){ return true; }
					
				// check annotation value
				if( structKeyExists(instance,"annotationValue") AND md[instance.annotation] EQ instance.annotationValue ){
					return true;	
				}
			}
			
			return false;   
    	</cfscript>    
    </cffunction>
	
	<!--- any --->    
    <cffunction name="any" output="false" access="public" returntype="any" hint="Match against any method name or class path">    
    	<cfscript>
			instance.any = true;
			return this;
		</cfscript>	
    </cffunction>
    
    <!--- returns --->    
    <cffunction name="returns" output="false" access="public" returntype="any" hint="Match against return types in methods only">    
    	<cfargument name="type" type="any" required="true" hint="The type of return to match against.  Only for method matching"/>
    	<cfscript>	
			instance.returns = arguments.type;
			return this;
		</cfscript>    
    </cffunction>
    
    <!--- annotatedWith --->    
    <cffunction name="annotatedWith" output="false" access="public" returntype="any" hint="Matches annotations on components or methods with or without a value">    
    	<cfargument name="annotation" 	type="any" required="true" hint="The annotation to discover"/>
		<cfargument name="value" 		type="any" required="false" hint="The value of the annotation that must match. OPTIONAL"/>
    	<cfscript>
			instance.annotation = arguments.annotation;
			// the value of the annotation
			if( structKeyExists(arguments, "value") ){
				instance.annotationValue = arguments.value;
			}
			return this;
    	</cfscript>    
    </cffunction>
	
	<!--- mappings --->    
    <cffunction name="mappings" output="false" access="public" returntype="any" hint="Match one, list or array of mapping names. Class Matching Only.">    
    	<cfargument name="mappings" type="any" required="true" hint="One, list or array of mappings to match"/>
    	<cfscript>
			if( isArray( arguments.mappings ) ){ arguments.mappings = arrayToList(arguments.mappings); }
			instance.mappings = arguments.mappings;
			return this;
    	</cfscript>    
    </cffunction>
    
    <!--- instanceOf --->    
    <cffunction name="instanceOf" output="false" access="public" returntype="any" hint="Matches against a family of components according to the passed classPath. Class Matching Only.">    
    	<cfargument name="classPath" type="any" required="true" hint="The class path to verify instance of"/>
    	<cfscript>	    
			instance.instanceOf = arguments.classPath;
			return this;
    	</cfscript>    
    </cffunction>
    
    <!--- regex --->    
    <cffunction name="regex" output="false" access="public" returntype="any" hint="Matches a class path or method name to this regular expression">    
    	<cfargument name="regex" type="any" required="true" hint="The regular expression to match against"/>
    	<cfscript>
			instance.regex = arguments.regex;
			return this;	    
    	</cfscript>    
    </cffunction>
    
    <!--- methods --->    
    <cffunction name="methods" output="false" access="public" returntype="any" hint="A list, one or an array of methods to explicitly match">    
    	<cfargument name="methods" type="any" required="true" hint="One, list or array of methods to match"/>
    	<cfscript>
			if( isArray( arguments.methods ) ){ arguments.methods = arrayToList(arguments.methods); }
			instance.methods = arguments.methods;
			return this;
    	</cfscript> 
    </cffunction>
    
    <!--- andMatch --->    
    <cffunction name="andMatch" output="false" access="public" returntype="any" hint="AND this matcher with another matcher">    
    	<cfargument name="matcher" type="any" required="true" hint="The matcher to AND this matcher with" colddoc:generci="coldbox.system.aop.Matcher"/>
    	<cfscript>	    
			instance.and = arguments.matcher;
			return this;
    	</cfscript>    
    </cffunction>
	
	 <!--- orMatch --->    
    <cffunction name="orMatch" output="false" access="public" returntype="any" hint="OR this matcher with another matcher">    
    	<cfargument name="matcher" type="any" required="true" hint="The matcher to OR this matcher with" colddoc:generci="coldbox.system.aop.Matcher"/>
    	<cfscript>	    
			instance.or = arguments.matcher;
			return this;
    	</cfscript>    
    </cffunction>
	
</cfcomponent>