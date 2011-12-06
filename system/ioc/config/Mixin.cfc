<cfcomponent output="false">
	
	<!--- $init --->    
    <cffunction name="$init" output="false" access="public" returntype="any" hint="Constructor">    
    	<cfargument name="mixins" required="true"/>
    	
    	<cfset var x 		= 1>
    	<cfset var mixinLen = arrayLen( mixins )>
    	<cfset var key 		= "">
		
    	<!--- Include the mixins --->
    	<cfloop from="1" to="#mixinLen#" index="x">
			<!---verify .cfm or not--->
			<cfif listLast(mixins[x],".") NEQ "cfm" >
				<cfinclude template="#trim(mixins[x])#.cfm" >
			<cfelse>
				<cfinclude template="#trim(mixins[x])#" >
			</cfif>
		</cfloop>
		
		<!--- Expose them --->
		<cfscript>
			for(key in variables){
				if( isCustomFunction( variables[key] ) AND NOT structKeyExists(this, key) ){
					this[ key ] = variables[ key ];
				}
			}			
			return this;
		</cfscript> 	    
    </cffunction>
	
</cfcomponent>