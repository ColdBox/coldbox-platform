<cfset this["getName"] = getName>

			<cfset variables["getName"] = getName>
			<cffunction name="getName" access="public" output="false" returntype="any">
			
			<cfset var results = this._mockResults>
			<cfset var resultsKey = "getName">
			<cfset var resultsCounter = 0>
			<cfset var internalCounter = 0>
			<cfset var resultsLen = 0>
			<cfset var argsHashKey = resultsKey & "|" & hash(arguments.toString())>
			
			<!--- If Method & argument Hash Results, switch the results struct --->
			<cfif structKeyExists(this._mockArgResults,argsHashKey)>
				<cfset results = this._mockArgResults>
				<cfset resultsKey = argsHashKey>
			</cfif>
			
			<!--- Get the statemachine counter --->
			<cfset resultsLen = arrayLen(results[resultsKey])>
			<!--- Log the Method Call --->
			<cfset this._mockMethodCallCounters[listFirst(resultsKey,"|")] = this._mockMethodCallCounters[listFirst(resultsKey,"|")] + 1>
			<!--- Get the CallCounter Reference --->
			<cfset internalCounter = this._mockMethodCallCounters[listFirst(resultsKey,"|")]>
			
				<cfif internalCounter gt resultsLen>
					<cfset resultsCounter = internalCounter - ( resultsLen*fix( (internalCounter-1)/resultsLen ) )>
					<cfreturn results[resultsKey][resultsCounter]>
				<cfelse>
					<cfreturn results[resultsKey][internalCounter]>
				</cfif>
				</cffunction>
