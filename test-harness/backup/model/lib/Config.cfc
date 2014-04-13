<!-----------------------------------------------------------------------
Author :	lmajano
Date   :	12/9/2008
Description : 			
	Config
				

Modification History:
 
----------------------------------------------------------------------->
<cfcomponent name="Config" displayname="Config" hint="Config" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" returntype="Config" output="false" hint="Constructor">
		<cfargument name="ApplicationPath" required="true" type="string" hint="">
		<cfscript>
			instance = structnew();
			structAppend(instance,arguments);
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="getmemento" access="public" output="false" returntype="any" hint="Get memento">
		<cfreturn instance/>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>