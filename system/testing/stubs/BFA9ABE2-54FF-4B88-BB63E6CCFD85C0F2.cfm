<cfset this["getData"] = getData>

			<cfset variables["getData"] = getData>
			<cffunction name="getData" access="public" output="false" returntype="any">
			
			<cfset var results = this._mockResults>
			<cfset var resultsKey = "getData">
			<cfset var resultsCounter = 0>
			<cfset var internalCounter = 0>
			<cfset var resultsLen = 0>
			
			<cfdump var="#this._mockArgResults#">
			<cfdump var="#resultsKey#">
			<cfdump var="#hash(arguments)#">
			<!--- If Method & argument Hash Results, switch the results struct --->
			<cfif structKeyExists(this._mockArgResults,resultsKey & hash(arguments))>
				<cfset results = this._mockArgResults>
				<cfset resultsKey = resultsKey & hash(arguments)>
			</cfif>
			
			<!--- Get the statemachine counter --->
			<cfset resultsLen = arrayLen(results[resultsKey])>
			<!--- Log the Method Call --->
			<cfset this._mockMethodCallCounters[resultsKey] = this._mockMethodCallCounters[resultsKey] + 1>
			<!--- Get the CallCounter Reference --->
			<cfset internalCounter = this._mockMethodCallCounters[resultsKey]>
			
				<cfif internalCounter gt resultsLen>
					<cfset resultsCounter = internalCounter - ( resultsLen*fix( (internalCounter-1)/resultsLen ) )>
					<cfreturn results[resultsKey][resultsCounter]>
				<cfelse>
					<cfreturn results[resultsKey][internalCounter]>
				</cfif>
				</cffunction>
