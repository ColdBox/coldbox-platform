<cfcomponent name="coldboxproxy" output="false" extends="coldbox.system.extras.ColdboxProxy">

	<!--- You can override this method if you want to intercept before and after. --->
	<cffunction name="process" output="true" access="remote" returntype="any" hint="Process a remote call and return data/objects back.">
		<cfset var results = "">
		<cfset var jsonData = "">
			
		<cftry>
			<!--- Call the actual proxy --->
			<cfset results = super.process(argumentCollection=arguments)>
	
			<!--- JSON ? --->
			<cfif isDefined('arguments.json')>
				<!--- TODO: check if results is JSON format --->
				<cfset jsonData = getPlugin("JSON").encode(data:results,structKeyCase:"lower")>
				<cfheader name="expires" value="Mon, 03 Sep 1973 00:00:01 GMT">
				<cfheader name="pragma" value="no-cache">
				<cfheader name="cache-control" value="no-cache">
				<cfcontent type="application/json">#jsonData# 	
			<cfelse>
				<cfreturn results>
			</cfif>

			<cfcatch type="any">#processException(cfcatch)#</cfcatch>
		</cftry>

	</cffunction>
	
	<cffunction name="processException" output="false" access="remote" returntype="string" hint="Process exception and returns bugReport">
		<cfargument name="Exception" type="any"	required="true" hint="The exception structure (cfcatch)">
		
		<cfset var exceptionService = "">
		<cfset var ExceptionBean = "">		
		<cfset var interceptData = StructNew()>		
		
		<!--- Get Exception Service --->
		<cfset ExceptionService = getController().getExceptionService()>
		
		<!--- Intercept The Exception --->
		<cfset interceptData.exception = arguments.exception>
		<cfset announceInterception('onException',interceptData)>
		
		<!--- Handle The Exception --->
		<cfset ExceptionBean = ExceptionService.ExceptionHandler(arguments.exception,"coldboxproxy","ColdBox Proxy Exception")>					
		
		<!--- Return rendered bugreport --->
		<cfreturn exceptionService.renderBugReport(ExceptionBean)>
	</cffunction>
	
</cfcomponent>