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
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<!--- any --->    
    <cffunction name="any" output="false" access="public" returntype="any" hint="Match against any method or class">    
    	<cfscript>
		
		</cfscript>	
    </cffunction>
    
    <!--- returns --->    
    <cffunction name="returns" output="false" access="public" returntype="any" hint="Match against return types in methods only">    
    	<cfscript>	
			
		</cfscript>    
    </cffunction>
	
	
</cfcomponent>