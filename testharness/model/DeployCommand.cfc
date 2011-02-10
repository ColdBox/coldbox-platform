<!-----------------------------------------------------------------------
Author :	lmajano
Date   :	8/23/2008
Description : 			
	This is a deploy cleanup command
				

Modification History:
 
----------------------------------------------------------------------->
<cfcomponent name="Deploycleanup" hint="This is a deploy cleanup command" output="false">

	<cfproperty name="logger" type="coldbox:plugin:Logger" scope="instance">
	
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" returntype="DeployCommand" output="false" hint="Constructor">
		<cfargument name="controller" required="false" type="coldbox.system.web.Controller" hint="The coldbox controller">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="execute" access="public" returntype="void" hint="The cleanup execution" output="false" >
		<cfscript>
			instance.logger.logEntry('debug',"Cleanup command executed nice!!");
		</cfscript>
	</cffunction>


<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>