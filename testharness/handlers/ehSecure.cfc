<!-----------------------------------------------------------------------
Author 	 :	Sana Ullah
Date     :	15/06/2008
Description : 			
 security handler
		
Modification History:

----------------------------------------------------------------------->
<cfcomponent name="ehSecure" 
			 hint="a default handler" 
			 extends="coldbox.system.EventHandler" 
			 output="false"
			 autowire="false">

			 
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->	 	

	<cffunction name="init" access="public" returntype="ehSecure" output="false" hint="Optional Constructor">
		<cfargument name="controller" type="coldbox.system.Controller">
		
		<!--- Mandatory Super call --->
		<cfset super.init(arguments.controller)>
		
		<!--- Any custom constructor code here --->
		
		<cfreturn this>
	</cffunction>
			 
<!------------------------------------------- PUBLIC ------------------------------------------->	 	

	<!--- do something --->
	<cffunction name="dspUser" access="public" returntype="Void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.RequestContext" required="yes">
		<cfset var rc = event.getCollection()>
		
		<cfset event.renderData('plain','I got in')>
	</cffunction>
	
	
<!------------------------------------------- PRIVATE ------------------------------------------->	 	

	
</cfcomponent>
