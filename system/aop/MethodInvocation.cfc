<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I model a method invocation call
----------------------------------------------------------------------->
<cfcomponent output="false" hint="I model a method invocation call">
	
<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- init --->    
    <cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">    
    	<cfargument name="method" 			type="any" required="true" hint="The method name that was intercepted"/>
		<cfargument name="args" 			type="any" required="true" hint="The argument collection that was intercepted"/>
		<cfargument name="methodMetadata" 	type="any" required="true" hint="The method metadata that was intercepted"/>
		<cfargument name="target" 			type="any" required="true" hint="The target object reference that was intercepted"/>
		<cfargument name="targetName"		type="any" required="true" hint="The name of the target wired up"/>
		<cfargument name="targetMapping" 	type="any" required="true" hint="The target's mapping object reference" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
		<cfargument name="interceptors" 	type="any" required="true" hint="The array of interceptors for this invocation"/>
    	<cfscript>
			
			// store references
			instance = {
				// Method intercepted
				method  			= arguments.method,
				// Arguments intercepted
				args				= arguments.args,
				// Method metadata
				methodMetadata		= deserializeJSON( URLDecode( arguments.methodMetadata ) ),
				// Target intercepted
				target				= arguments.target,
				// Target name
				targetName			= arguments.targetName,
				// Target Mapping Reference
				targetMapping		= arguments.targetMapping,
				// Interceptor array chain
				interceptors		= arguments.interceptors,
				// Current index to start execution
				interceptorIndex 	= 1,
				// Length of interceptor
				interceptorLen		= arrayLen( arguments.interceptors )
			};
			
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- incrementInterceptorIndex --->    
    <cffunction name="incrementInterceptorIndex" output="false" access="public" returntype="any" hint="Increment the interceptor index pointer">    
    	<cfscript>
			instance.interceptorIndex++;
			return this;	    
    	</cfscript>    
    </cffunction>

	<!--- getInterceptorIndex --->    
    <cffunction name="getInterceptorIndex" output="false" access="public" returntype="any" hint="Get the currently executing interceptor index" colddoc:generic="numeric">    
    	<cfscript>
			return instance.interceptorIndex;	    
    	</cfscript>    
    </cffunction>

	<!--- getMethod --->    
    <cffunction name="getMethod" output="false" access="public" returntype="any" hint="Return the method name that was intercepted for this method invocation">    
    	<cfscript>	   
			return instance.method; 
    	</cfscript>    
    </cffunction>
    
    <!--- getMethodMetadata --->    
    <cffunction name="getMethodMetadata" output="false" access="public" returntype="any" hint="Return methods's metadata that was intercepted for this method invocation">    
    	<cfscript>	   
			return instance.methodMetadata; 
    	</cfscript>    
    </cffunction>
    
    <!--- getTarget --->    
    <cffunction name="getTarget" output="false" access="public" returntype="any" hint="Get the original target object of this method invocation">    
    	<cfscript>
			return instance.target;	    
    	</cfscript>    
    </cffunction>
    
    <!--- getTargetName --->    
    <cffunction name="getTargetName" output="false" access="public" returntype="any" hint="Get the name of this target">    
    	<cfscript>
			return instance.targetName;	    
    	</cfscript>    
    </cffunction>
    
    <!--- getTargetMapping --->    
    <cffunction name="getTargetMapping" output="false" access="public" returntype="any" hint="Get the wirebox mapping of this target">    
    	<cfscript>
			return instance.targetMapping;	    
    	</cfscript>    
    </cffunction>    

	<!--- getArgs --->    
    <cffunction name="getArgs" output="false" access="public" returntype="any" hint="Get the argument collection of this method invocation" colddoc:generic="struct">    
    	<cfscript>	
			return instance.args;    
    	</cfscript>    
    </cffunction>
    
    <!--- setArgs --->
	<cffunction name="setArgs" output="false" access="public" returntype="any" hint="Set the argument collection of this method invocation, override orginal">
		<cfargument name="args" type="any" required="true" hint="The argument collection that you want to now use"/>
		<cfscript>
			instance.args = arguments.args;
			return this;
		</cfscript>
	</cffunction>

    <!--- getInterceptors --->    
    <cffunction name="getInterceptors" output="false" access="public" returntype="any" hint="Get the array of aspect interceptors for this method invocation" colddoc:generic="array">    
    	<cfscript>
			return instance.interceptors;	    
    	</cfscript>    
    </cffunction>
    
	<!--- proceed --->    
    <cffunction name="proceed" output="false" access="public" returntype="any" hint="Proceed execution of the method invocation">    
    	<cfscript>
			// We will now proceed with our interceptor execution chain or regular method pointer call
			// execute the next interceptor in the chain
				
			// Check Current Index against interceptor length
			if( instance.interceptorIndex LTE instance.interceptorLen ){
				return instance.interceptors[ instance.interceptorIndex ].invokeMethod( this.incrementInterceptorIndex() );
			}
			
			// If we get here all interceptors have fired and we need to fire the original proxied method
			return instance.target.$wbAOPInvokeProxy(method=instance.method,args=instance.args);
		</cfscript>	
    </cffunction>
	
</cfcomponent>