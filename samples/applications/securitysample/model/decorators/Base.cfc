<cfcomponent output="false" extends="transfer.com.TransferDecorator">

	<cffunction name="listProperties" access="public" returntype="string" output="false" hint="Returns a List of the Properties">
		<cfargument name="type" required="no" default="ALL">
		
		<cfset var propertyList = ''>
		<cfset var iterator = getTransfer().getTransferMetaData(this.getClassName()).getPropertyIterator()>
		<cfset var property =  ''>
		
		<cfloop condition="#iterator.hasNext()#">
			<cfset property =  iterator.next()>
			<cfif arguments.type neq 'ALL' and arguments.type eq property.getType()>
				<cfset propertyList = listAppend(propertyList,property.getName())>
			</cfif>
		</cfloop>
		
		<cfreturn propertyList>
	</cffunction>
	
	<cffunction name="listColumns" access="public" returntype="string" output="false" hint="Returns a List of the Property Column Names">
		<cfset var columnList = ''>
		<cfset var iterator = getTransfer().getTransferMetaData(this.getClassName()).getPropertyIterator()>

		<cfloop condition="#iterator.hasNext()#">
			<cfset columnList = listAppend(columnList,iterator.next().getColumn())>
		</cfloop>
		
		<cfreturn columnList>
	</cffunction>	
	
</cfcomponent>