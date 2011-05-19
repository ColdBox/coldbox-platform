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
			// prepare instance for this matcher
			instance = {
				any = false,
				returns = "",
				annotation = "",
				mappings = [],
				instanceOf = ""
			};
			// Aggregators
			instance.and = "";
			instance.or  = "";
			
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>
	
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
			if( isSimpleValue( arguments.mappings ) ){ arguments.mappings = listToArray(arguments.mappings); }
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
    
    <!--- and --->    
    <cffunction name="and" output="false" access="public" returntype="any" hint="AND this matcher with another matcher">    
    	<cfargument name="matcher" type="any" required="true" hint="The matcher to AND this matcher with" colddoc:generci="coldbox.system.aop.Matcher"/>
    	<cfscript>	    
			instance.and = arguments.matcher;
			return this;
    	</cfscript>    
    </cffunction>
	
	 <!--- or --->    
    <cffunction name="or" output="false" access="public" returntype="any" hint="OR this matcher with another matcher">    
    	<cfargument name="matcher" type="any" required="true" hint="The matcher to OR this matcher with" colddoc:generci="coldbox.system.aop.Matcher"/>
    	<cfscript>	    
			instance.or = arguments.matcher;
			return this;
    	</cfscript>    
    </cffunction>
	
</cfcomponent>