<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	5/31/2008
Description : 			
 mock interceptor
		
Modification History:

----------------------------------------------------------------------->
<cfcomponent name="mock" 
			 hint="mock interceptor" 
			 extends="coldbox.system.Interceptor" 
			 output="false"
			 autowire="false">
  
<!------------------------------------------- PUBLIC ------------------------------------------->	 	

   
    <cffunction name="configure" access="public" returntype="void" output="false" hint="Configure your interceptor">
		
	</cffunction>
    

<!------------------------------------------- PRIVATE ------------------------------------------->	 	

	<cffunction name="unittest" access="public" returntype="void" hint="Unit Testing" output="false">
		<cfargument name="event" 		 required="true" type="coldbox.system.web.context.RequestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		
		<cfset arguments.event.setValue('unittest',true)>
	</cffunction>

</cfcomponent>