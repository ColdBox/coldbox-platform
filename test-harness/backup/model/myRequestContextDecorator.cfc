<cfcomponent output="false" extends="coldbox.system.web.context.RequestContextDecorator">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	
<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="My Configuration" output="false" >
		<cfset var key = "">
		<cfset var rc = getRequestContext().getCollection()>
		
		<!--- I will trim all of the request collection --->
		<cfloop collection="#rc#" item="key">
			
			<!--- Trim only simple values --->
			<cfif isSimpleValue(rc[key])>
				<cfset rc[key] = trim(rc[key])>
			</cfif>
			
		</cfloop>
		
		<!--- 
		<cfdump var="#getController()#"><cfabort>
		States maintain tests.
		<cfdump var="#getRequestContext().getCollection()#">
		<cfdump var="#getCollection()#">
		<cfset setValue("luis",now())>
		<cfdump var="#getRequestContext().getCollection()#">
		<cfdump var="#getCollection()#">
		<cfabort> 
		--->
		
	</cffunction>	
	
<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>