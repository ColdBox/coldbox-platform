<!-----------------------------------------------------------------------
Author :	lmajano
Date   :	8/23/2008
Description : 			
	This is a deploy cleanup command
				

Modification History:
 
----------------------------------------------------------------------->
<cfcomponent name="Deploycleanup" hint="This is a deploy cleanup command" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" returntype="Deploycleanup" output="false" hint="Constructor">
		<cfargument name="controller" required="true" type="coldbox.system.controller" hint="The coldbox controller">
		<cfscript>
			/* Setup the controller */
			instance.controller = arguments.controller;
			
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="execute" access="public" returntype="void" hint="The cleanup execution" output="false" >
		<cfscript>
			instance.controller.getplugin("logger").logEntry('debug',"Cleanup command executed nice!!");
		</cfscript>
	</cffunction>


<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>