<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I am an AOP mixer utility method
----------------------------------------------------------------------->
<cfcomponent output="false" hint="I am an AOP mixer utility method">
	
<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- init --->    
    <cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">    
    	<cfscript>
			return this;	    
    	</cfscript>    
    </cffunction>

<!------------------------------------------- AOP UTILITY MIXINS ------------------------------------------>
    
     <!--- $wbAOPStoreJointPoint --->    
    <cffunction name="$wbAOPStoreJointPoint" output="false" access="public" returntype="any" hint="Store JointPoint information">    
    	<cfargument name="jointpoint" 	type="any" required="true" hint="The jointpoint to proxy"/>
		<cfargument name="interceptors" type="any" required="true" hint="The jointpoint interceptors"/>
		<cfscript>
			this.$wbAOPTargets[arguments.jointpoint] = {
				udfPointer 	 = variables[ arguments.jointpoint ],
				interceptors = arguments.interceptors
			};
		</cfscript>
    </cffunction>
    
    <!--- $wbAOPInvokeProxy --->    
    <cffunction name="$wbAOPInvokeProxy" output="false" access="public" returntype="any" hint="Invoke a mixed in proxy method">    
    	<cfargument name="method" 	type="any" required="true" hint="The method to proxy execute"/>
		<cfargument name="args" 	type="any" required="true" hint="The method args to proxy execute"/>
    	<cfreturn this.$wbAOPTargets[ arguments.method ].udfPointer(argumentCollection=arguments.args)>
    </cffunction>
    
    <!--- $wbAOPInclude --->    
    <cffunction name="$wbAOPInclude" output="false" access="public" returntype="any" hint="Mix in a template on an injected target">    
    	<cfargument name="templatePath" type="any" required="true" hint="The template to mix in"/>
    	<cfinclude template="#arguments.templatePath#" >   
    </cffunction>
    
    <!--- $wbAOPRemove --->    
    <cffunction name="$wbAOPRemove" output="false" access="public" returntype="any" hint="Remove a method from this target mixin">    
    	<cfargument name="methodName" type="any" required="true" hint="The method to poof away!"/>
    	<cfscript>
			structDelete(this,arguments.methodName);
			structDelete(variables,arguments.methodName);    
    	</cfscript>    
    </cffunction>
    
<!------------------------------------------- Utility Methods ------------------------------------------>
	
	<!--- throw it --->
	<cffunction name="throwit" access="public" hint="Facade for cfthrow" output="false">
		<cfargument name="message" 	required="true">
		<cfargument name="detail" 	required="false" default="">
		<cfargument name="type"  	required="false" default="Framework">
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
	<!--- writeAspect --->    
    <cffunction name="writeAspect" output="false" access="public" returntype="any" hint="Write an aspect to disk">    
    	<cfargument name="genPath"	required="True">
		<cfargument name="code"		required="True">
    	<cfscript>	    
			fileWrite(arguments.genPath, arguments.code);
    	</cfscript>    
    </cffunction>
	
	<!--- writeAspect --->    
    <cffunction name="removeAspect" output="false" access="public" returntype="any" hint="Remove an aspect from disk">    
    	<cfargument name="filePath"	required="True">
		<cfscript>	    
			if( fileExists(arguments.filePath) ){
				fileDelete( arguments.filePath );
			}
    	</cfscript>    
	</cffunction>

</cfcomponent>