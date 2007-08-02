<cfcomponent displayname="baseDecorator" hint="This is the baseDecorator component" output="false" extends="transfer.com.TransferDecorator">

	<cffunction name="validate" access="public" returntype="struct" output="false" hint="Validates Property Data">
		<cfset var stReturn = structNew() />
		<cfset var sKey = '' />
		
		<cfset stReturn.results = true />
		<cfset stReturn.message = "Valid Data." />
		<cfset stReturn.messageType = "info" />
		<cfset stReturn.stProperties = getDetailedProperties() />
		<cfset stReturn.longMessage = '' />
		
		<cfloop collection="#stReturn.stProperties#" item="sKey">
			<cftry>
				<cfset stReturn.stProperties[sKey].valid = true />
				<cfset stReturn.stProperties[sKey].message = 'Valid Data' />
				
				<cfif not(stReturn.stProperties[sKey].isNullable) and not(len(stReturn.stProperties[sKey].value))>
					<cfthrow message="Null Value Not Allowed" detail="#sKey#" />
				<cfelseif stReturn.stProperties[sKey].type eq 'string'>
					
				<cfelseif stReturn.stProperties[sKey].type eq 'date'>
					<cfif not(stReturn.stProperties[sKey].isNullable) and not(isDate(stReturn.stProperties[sKey].value))>
						<cfthrow message="Not A Valid Date" detail="#sKey#" />
					</cfif>
				<cfelseif stReturn.stProperties[sKey].type eq 'boolean'>
					<cfif not(stReturn.stProperties[sKey].isNullable) and not(isBoolean(stReturn.stProperties[sKey].value))>
						<cfthrow message="Not A Valid Boolean" detail="#sKey#" />
					</cfif>
				<cfelseif stReturn.stProperties[sKey].type eq 'numeric'>
					<cfif not(stReturn.stProperties[sKey].isNullable) and not(isNumeric(stReturn.stProperties[sKey].value))>
						<cfthrow message="Not A Valid Numeric" detail="#sKey#" />
					</cfif>
				</cfif>
			
				<cfcatch type="Application">				
					<cfset stReturn.stProperties[cfcatch.detail].valid = false />
					<cfset stReturn.stProperties[cfcatch.detail].message = cfcatch.message />
					<cfset stReturn.longMessage = stReturn.longMessage & cfcatch.detail & ' : ' & cfcatch.message & '<br />' />
					
					<cfif stReturn.results>
						<cfset stReturn.results = false />
						<cfset stReturn.message = "Data is Invalid." />
						<cfset stReturn.messageType = "error" />
					</cfif>
				</cfcatch>
			</cftry>
		</cfloop>
		
		<cfreturn stReturn />
	</cffunction>
		
	<cffunction name="listProperties" access="public" returntype="string" output="false" hint="Returns a List of the Properties">
		<cfargument name="type" required="no" default="ALL">
		
		<cfset var lReturn = '' />
		<cfset var oIterator = getTransfer().getTransferMetaData(this.getClassName()).getPropertyIterator() />
		<cfset var oProperty =  '' />
		
		<cfloop condition="#oIterator.hasNext()#">
			<cfset oProperty =  oIterator.next() />
			<cfif arguments.type neq 'ALL' and arguments.type eq oProperty.getType()>
				<cfset lReturn = listAppend(lReturn,oProperty.getName()) />
			</cfif>
		</cfloop>
		
		<cfreturn lReturn />
	</cffunction>
	
	<cffunction name="listColumns" access="public" returntype="string" output="false" hint="Returns a List of the Property Column Names">
		<cfset var lReturn = '' />
		<cfset var oIterator = getTransfer().getTransferMetaData(this.getClassName()).getPropertyIterator() />

		<cfloop condition="#oIterator.hasNext()#">
			<cfset lReturn = listAppend(lReturn,oIterator.next().getColumn()) />
		</cfloop>
		
		<cfreturn lReturn />
	</cffunction>
	
	<cffunction name="listPropertiesByType" access="public" returntype="string" output="false" hint="Returns a List of the Properties For a Specific Data Type">
		<cfargument name="type" type="string" required="yes">
		
		<cfset var lReturn = '' />
		<cfset var oIterator = getTransfer().getTransferMetaData(this.getClassName()).getPropertyIterator() />
		<cfset var oProperty =  '' />
		
		<cfloop condition="#oIterator.hasNext()#">
			<cfset oProperty =  oIterator.next() />
			<cfif len(arguments.type) and lcase(arguments.type) eq lcase(oProperty.getType())>
				<cfset lReturn = listAppend(lReturn,oProperty.getName()) />
			</cfif>
		</cfloop>
		
		<cfreturn lReturn />
	</cffunction>
	
	<cffunction name="getDetailedProperties" access="public" returntype="struct" output="false" hint="Returns a Structure of Structures. Property Name is the Key to the Column, IsNullable, and Type attributes of the Property Detail Structure">
		<cfset var oIterator = getTransfer().getTransferMetaData(this.getClassName()).getPropertyIterator() />
		<cfset var stReturn = structNew() />
		<cfset var stDetails = structNew() />
		<cfset var oProperty = '' />
		
		<cfloop condition="#oIterator.hasNext()#">
			<cfset oProperty = oIterator.next() />
			
			<cfset stDetails['Column'] = oProperty.getColumn() />
			<cfset stDetails['Type'] = oProperty.getType() />
			<cfset stDetails['IsNullable'] = oProperty.getIsNullable() />
			<cfset stDetails['Value'] = evaluate('this.get#oProperty.getName()#()') />
			<cfset stDetails['Column'] = oProperty.getColumn() />
			<cfset stDetails['Valid'] = '' />
			<cfset stDetails['Message'] = '' />
			
			<cfset stReturn[oProperty.getName()] = duplicate(stDetails) />
		</cfloop>
		
		<cfreturn stReturn />
	</cffunction>

	<cffunction name="populateBean" access="public" returntype="void" output="false" hint="Loads Bean With Data from Struct">
		<cfargument name="stValues" type="struct" required="true" />
		
		<cfset var sKey = '' />
		
		<cfset stReturn.results = true />
		<cfset stReturn.message = "Valid Data." />
		<cfset stReturn.messageType = "info" />
		
		<cfloop collection="#arguments.stValues#" item="sKey">
			<cfset sKey = Trim(sKey)>
			<cfif structKeyExists(this, "set" & sKey)>
				<cfset evaluate("this.set#sKey#(arguments.stValues[sKey])")>
			</cfif>
		</cfloop>
	</cffunction>
</cfcomponent>