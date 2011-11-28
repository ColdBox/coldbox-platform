<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Serialize and deserialize JSON data into native ColdFusion objects using native ColdFusion functions now.
----------------------------------------------------------------------->
<cfcomponent hint="Serialize and deserialize JSON data into native ColdFusion objects using native ColdFusion functions now."
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="JSON" output="false">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Decode from JSON to CF --->
	<cffunction name="decode" access="public" returntype="any" output="false" hint="Converts data from JSON to CF format">
		<!--- ************************************************************* --->
		<cfargument name="data" 		required="true"  hint="JSON Packet to inflate" />
		<cfargument name="queryFormat" 	required="false" default="query" hint="query or array on conversion formats" />
		<!--- ************************************************************* --->
		<cfset var strict = true>
		
		<!--- Strict mapping --->
		<cfif arguments.queryFormat eq "array"><cfset strict = false></cfif>
		
		<cfif isJson(arguments.data)>
			<cfreturn deserializeJSON(arguments.data,strict)>
		<cfelse>
			<cfthrow message="Invalid JSON" detail="The document you are trying to decode is not in valid JSON format" type="JSON.InvalidJSON" />
		</cfif>
	</cffunction>
	
	<!--- isValidJSON --->    
    <cffunction name="isValidJSON" output="false" access="public" returntype="boolean" hint="Checks if a data packet is valid JSON or not, great for mocking">    
    	<cfargument name="data" required="true"  hint="JSON Packet to check" />
		<cfscript>
			return isJSON( arguments.data );	    
    	</cfscript>    
    </cffunction>
	
	<!--- convert data to JSON from CF --->
	<cffunction name="encode" access="public" returntype="any" output="false" hint="Converts data from CF to JSON format">
		<!--- ************************************************************* --->
		<cfargument name="data" 			type="any" 		required="Yes" hint="The CF value or data packet" />
		<cfargument name="queryFormat" 		type="string" 	required="No" default="query" hint="query or array on conversion formats" />
		<!--- ************************************************************* --->
		<cfset var strict = true>
		
		<!--- Strict mapping --->
		<cfif arguments.queryFormat eq "array"><cfset strict = false></cfif>
		
		<cfreturn serializeJSON(arguments.data,strict)>
	</cffunction>
	
	<!--- Validate a JSON document --->
	<cffunction name="validate" access="remote" output="yes" returntype="boolean" hint="I validate a JSON document against a JSON schema">
		<!--- ************************************************************* --->
		<cfargument name="doc" 			type="string" 	required="No" />
		<cfargument name="schema"	 	type="string" 	required="No" />
		<cfargument name="errorVar" 	type="string" 	required="No" default="JSONSchemaErrors" />
		<cfargument name="stopOnError" 	type="boolean" 	required="No" default=true />
		<!--- These arguments are for internal use only --->
		<cfargument name="_doc" 		type="any" 		required="No" />
		<cfargument name="_schema" 		type="any" 		required="No" />
		<cfargument name="_item" 		type="string" 	required="No" default="root" />
    	<!--- ************************************************************* --->
		
		<cfset var schemaRules = "" />
		<cfset var JSONDoc = "" />
		<cfset var i = 0 />
		<cfset var key = "" />
		<cfset var isValid = true />
		<cfset var msg = "" />
		
		<cfif StructKeyExists(arguments, "doc")>
			<cfif FileExists(arguments.doc)>
				<cffile action="READ" file="#arguments.doc#" variable="arguments.doc" />
			</cfif>
			
			<cfif FileExists(arguments.schema)>
				<cffile action="READ" file="#arguments.schema#" variable="arguments.schema" />
			</cfif>
			
			<cfset JSONDoc = decode(arguments.doc) />
			<cfset schemaRules = decode(arguments.schema) />
		
			<cfset request[arguments.errorVar] = ArrayNew(1) />
		<cfelseif StructKeyExists(arguments, "_doc")>
			<cfset JSONDoc = arguments._doc />
			<cfset schemaRules = arguments._schema />
		</cfif>
		
		<!--- See if the document matches the rules from the schema --->
		<cfif schemaRules.type EQ "struct">
			<cfif NOT IsStruct(JSONDoc)>
				<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# should be a struct") />
				<cfif arguments.stopOnError>
					<cfreturn false />
				</cfif>
			<cfelse>
				<!--- If specific keys are set to be required, check if they exist --->
				<cfif StructKeyExists(schemaRules, "keys")>
					<cfloop from="1" to="#ArrayLen(schemaRules.keys)#" index="i">
						<cfif NOT StructKeyExists(JSONDoc, schemaRules.keys[i])>
							<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# should have a key named #schemaRules.keys[i]#") />
							<cfif arguments.stopOnError>
								<cfreturn false />
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
				
				<!--- Loop over all the keys for the structure and see if they are valid (if items key is specified) by recursing the validate function --->
				<cfif StructKeyExists(schemaRules, "items")>
					<cfloop collection="#JSONDoc#" item="key">
						<cfif StructKeyExists(schemaRules.items, key)>
							<cfset isValid = validate(_doc=JSONDoc[key], _schema=schemaRules.items[key], _item="#arguments._item#['#key#']", errorVar=arguments.errorVar, stopOnError=arguments.stopOnError) />
							<cfif arguments.stopOnError AND NOT isValid>
								<cfreturn false />
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
		<cfelseif schemaRules.type EQ "array">
			<cfif NOT IsArray(JSONDoc)>
				<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# should be an array") />
				<cfif arguments.stopOnError>
					<cfreturn false />
				</cfif>
			<cfelse>
				<cfparam name="schemaRules.minlength" default="0" />
				<cfparam name="schemaRules.maxlength" default="9999999999" />
				
				<!--- If there are length requirements for the array make sure they are valid --->
				<cfif ArrayLen(JSONDoc) LT schemaRules.minlength>
					<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# is an array that should have at least #schemaRules.minlength# elements") />
					<cfif arguments.stopOnError>
						<cfreturn false />
					</cfif>
				<cfelseif ArrayLen(JSONDoc) GT schemaRules.maxlength>
					<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# is an array that should have at the most #schemaRules.maxlength# elements") />
					<cfif arguments.stopOnError>
						<cfreturn false />
					</cfif>
				</cfif>
				
				<!--- Loop over the array elements and if there are rules for the array items recurse to enforce them --->
				<cfif StructKeyExists(schemaRules, "items")>
					<cfloop from="1" to="#ArrayLen(JSONDoc)#" index="i">
						<cfset isValid = validate(_doc=JSONDoc[i], _schema=schemaRules.items, _item="#arguments._item#[#i#]", errorVar=arguments.errorVar, stopOnError=arguments.stopOnError) />
						<cfif arguments.stopOnError AND NOT isValid>
							<cfreturn false />
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
		<cfelseif schemaRules.type EQ "number">
			<cfif NOT IsNumeric(JSONDoc)>
				<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# should be numeric") />
				<cfif arguments.stopOnError>
					<cfreturn false />
				</cfif>
			<cfelseif StructKeyExists(schemaRules, "min") AND JSONDoc LT schemaRules.min>
				<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# cannot be a number less than #schemaRules.min#") />
				<cfif arguments.stopOnError>
					<cfreturn false />
				</cfif>
			<cfelseif StructKeyExists(schemaRules, "max") AND JSONDoc GT schemaRules.max>
				<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# cannot be a number greater than #schemaRules.max#") />
				<cfif arguments.stopOnError>
					<cfreturn false />
				</cfif>
			</cfif>
		<cfelseif schemaRules.type EQ "boolean" AND ( NOT IsBoolean(JSONDoc) OR ListFindNoCase("Yes,No", JSONDoc) OR IsNumeric(JSONDoc) )>
			<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# should be a boolean") />
			<cfif arguments.stopOnError>
				<cfreturn false />
			</cfif>
		<cfelseif schemaRules.type EQ "date">
			<cfif NOT IsSimpleValue(JSONDoc) OR NOT IsDate(JSONDoc)
					OR ( StructKeyExists(schemaRules, "mask") AND CompareNoCase( JSONDoc, DateFormat(JSONDoc, schemaRules.mask) ) NEQ 0 )>
				<cfif StructKeyExists(schemaRules, "mask")>
					<cfset msg = " in #schemaRules.mask# format" />
				</cfif>
				<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# should be a date#msg#") />
				<cfif arguments.stopOnError>
					<cfreturn false />
				</cfif>
			</cfif>
		<cfelseif schemaRules.type EQ "string">
			<cfif NOT IsSimpleValue(JSONDoc)>
				<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# should be a string") />
				<cfif arguments.stopOnError>
					<cfreturn false />
				</cfif>
			<cfelseif StructKeyExists(schemaRules, "minlength") AND Len(JSONDoc) LT schemaRules.minlength>
				<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# should have a minimum length of #schemaRules.minlength#") />
				<cfif arguments.stopOnError>
					<cfreturn false />
				</cfif>
			<cfelseif StructKeyExists(schemaRules, "maxlength") AND Len(JSONDoc) GT schemaRules.maxlength>
				<cfset ArrayPrepend(request[arguments.errorVar], "#arguments._item# should have a maximum length of #schemaRules.maxlength#") />
				<cfif arguments.stopOnError>
					<cfreturn false />
				</cfif>
			</cfif>
		</cfif>
		
		<cfif ArrayLen(request[arguments.errorVar])>
			<cfreturn false />
		<cfelse>
			<cfreturn true />
		</cfif>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>