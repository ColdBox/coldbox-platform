<cfcomponent>

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any">
    	<cfreturn this>
    </cffunction>

	<!--- getName --->
    <cffunction name="getTargetObject" output="false" access="public" returntype="any" hint="">
    	<cfargument name="name" type="string" required="true"/>
		<cfargument name="cool" type="boolean" required="true"/>
    	<cfscript>
    		var o = createObject("component","Simple").init();
			
			o.name = arguments.name;
			o.cool = arguments.cool;
			
			return o;			
    	</cfscript>
    </cffunction>


</cfcomponent>