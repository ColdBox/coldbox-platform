<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	4/8/2008
Description : 			
 default handler
		
Modification History:

----------------------------------------------------------------------->
<cfcomponent name="default" 
			 hint="a default handler" 
			 
			 output="false"
			 autowire="false">

			 
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->	 	

	<cffunction name="init" access="public" returntype="default" output="false" hint="Optional Constructor">
		<cfargument name="controller" type="coldbox.system.web.Controller">
		
		<!--- Mandatory Super call --->
		<cfset super.init(arguments.controller)>
		
		<!--- Any custom constructor code here --->
		
		<cfreturn this>
	</cffunction>
			 
<!------------------------------------------- PUBLIC ------------------------------------------->	 	

	<!--- do something --->
	<cffunction name="index" access="public" returntype="Void" output="false">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">
		<cfset var rc = event.getCollection()>
		 
		<cfset event.setView('vwQuote')>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->	 	

	
	
</cfcomponent>