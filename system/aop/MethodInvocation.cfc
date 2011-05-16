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
    	<cfargument name="method" 	type="any" required="true"/>
		<cfargument name="args" 	type="any" required="true"/>
		<cfargument name="target" 	type="any" required="true"/>
    	<cfscript>
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- proceed --->    
    <cffunction name="proceed" output="false" access="public" returntype="any" hint="Proceed execution of the method invocation">    
    	<cfscript>
			
		</cfscript>	
    </cffunction>
	
</cfcomponent>