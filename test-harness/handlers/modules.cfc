<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	4/8/2008
Description : 			
 default handler
		
Modification History:

----------------------------------------------------------------------->
<cfcomponent output="false">

			 
<!------------------------------------------- PUBLIC ------------------------------------------->	 	

	<cffunction name="viewRendering" access="public" returntype="any" output="false">
		<cfargument name="event">
		<cfset var rc = event.getCollection()>
		 
		<cfreturn getPlugin("Renderer").renderView(view="test1",module="test1")>
	</cffunction>
	
	<cffunction name="viewBadRendering" access="public" returntype="any" output="false">
		<cfargument name="event">
		<cfset var rc = event.getCollection()>
		 
		<cfreturn getPlugin("Renderer").renderView(view="bogus",module="test1")>
	</cffunction>
	
	<cffunction name="layoutRendering" access="public" returntype="any" output="false">
		<cfargument name="event">
		<cfset var rc = event.getCollection()>
		 
		<cfreturn getPlugin("Renderer").renderLayout(layout="test1",view="test1",module="test1")>
	</cffunction>
	
	<cffunction name="layoutBadRendering" access="public" returntype="any" output="false">
		<cfargument name="event">
		<cfset var rc = event.getCollection()>
		 
		<cfreturn getPlugin("Renderer").renderLayout(layout="test2",view="test1",module="test1")>
	</cffunction>
	
	
</cfcomponent>