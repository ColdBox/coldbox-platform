<!-----------------------------------------------------------------------
Author :	lmajano
Date   :	12/9/2008
Description : 			
	TestLib
				

Modification History:
 
----------------------------------------------------------------------->
<cfcomponent name="TestLib" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" returntype="TestLib" output="false" hint="Constructor">
		<cfargument name="AppMapping" 	required="true" type="any" >
		<cfargument name="AppName" 		required="true" type="any" >
		<cfargument name="Config" 		required="true" type="any" hint="">
		<cfscript>
			instance = structnew();
			structAppend(instance,arguments);
			
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="setConfigSetter" access="public" output="false" returntype="void" hint="Set ConfigSetter">
		<cfargument name="ConfigSetter" type="any" required="true"/>
		<cfset instance.ConfigSetter = arguments.ConfigSetter/>
	</cffunction>
	
	<cffunction name="setDefaultEvent" access="public" output="false" returntype="void" hint="Set DefaultEvent">
		<cfargument name="DefaultEvent" type="string" required="true"/>
		<cfset instance.DefaultEvent = arguments.DefaultEvent/>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="getmemento" access="public" output="false" returntype="any" hint="Get memento">
		<cfreturn instance/>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>