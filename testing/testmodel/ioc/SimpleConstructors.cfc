<cfcomponent>

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any">
    	<cfargument name="constant" 	type="any" required="true" hint="A constant value to test"/>
		<cfargument name="constant2" 	type="any" required="false" default="#arrayNew(1)#" hint="A constant non-required value to test"/>
		<cfargument name="dslVar" 		required="true">
		<cfargument name="modelVar" 	required="true">
		<cfargument name="modelVarNonRequired" 	required="false">
    	<cfscript>
    	
    		this.constant = arguments.constant;
			this.constant2 = arguments.constant2;
			this.dslVar = arguments.dslVar;
			this.modelVar = arguments.modelVar;
			
			if( structKeyExists(Arguments,"modelVarNonRequired") ){
				this.modelVarNonRequired = arguments.modelVarNonRequired;
			}
			
    		return this;
		</cfscript>
    </cffunction>


</cfcomponent>