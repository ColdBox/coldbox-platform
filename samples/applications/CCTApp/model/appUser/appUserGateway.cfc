<cfcomponent displayname="appUserGateway" hint="This is the appUserGateway component" output="false" cache="true" cachetimeout="0">
	
	<cffunction name="init" access="public" output="false" returntype="appUserGateway">
		<cfargument name="oTransfer" type="any" required="true" />
		<cfargument name="oDatasource" type="any" required="true" />
		
		<cfset variables.oTransfer = arguments.oTransfer />
		<cfset variables.oDatasource = arguments.oDatasource />
		<cfset variables.sDBType = variables.oDatasource.getDatabaseType() />
		
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="browseRecords" access="public" output="No" returntype="struct">
		<cfargument name="className" required="No" type="string" default="AppUser.AppUser" />
		<cfargument name="tableName" required="No" type="string" default="" />
		<cfargument name="primaryKey" required="No" type="string" default="" />
		<cfargument name="dbType" required="Yes" type="string" default="#variables.sDBType#" />
		<cfargument name="columnList" required="No" type="string" default="" />
		<cfargument name="searchField" required="No" type="string" default="" />
		<cfargument name="searchFor" required="No" type="string" default="" />
		<cfargument name="sortBy" required="No" type="string" default="" />
		<cfargument name="sortDir" required="No" type="string" default="asc" />
		<cfargument name="groupNumber" required="No" type="numeric" default="1" />
		<cfargument name="groupSize" required="No" type="numeric" default="10" />
		<cfargument name="dateFrom" required="No" type="date" default="#now()#" />
		<cfargument name="dateTo" required="No" type="date" default="#now()#" />
		<cfargument name="dateFields" required="No" type="string" default="" />
		<cfargument name="booleanFields" required="No" type="string" default="" />
		<cfargument name="numericFields" required="No" type="string" default="" />
		
		<cfset var stReturn = structNew() />
			
		<cfset stReturn.startRow = (arguments.groupNumber - 1) * arguments.groupSize + 1 />
		<cfset stReturn.endRow = stReturn.startRow + (arguments.groupSize - 1) />
		
		<cfif len(arguments.className)>
			<cfif not len(arguments.tableName)>
				<cfset arguments.tableName = variables.oTransfer.getTransferMetaData(arguments.className).getTable() />
			</cfif>
			<cfif not len(arguments.primaryKey)>
				<cfset arguments.primaryKey = variables.oTransfer.getTransferMetaData(arguments.className).getPrimaryKey().getColumn() />
			</cfif>
			<cfif not len(arguments.columnList)>
				<cfset arguments.columnList = variables.oTransfer.new(arguments.className).listColumns() />
			</cfif>
			<cfif not len(arguments.dateFields)>
				<cfset arguments.dateFields = variables.oTransfer.new(arguments.className).listPropertiesByType('date') />
			</cfif>
			<cfif not len(arguments.booleanFields)>
				<cfset arguments.booleanFields = variables.oTransfer.new(arguments.className).listPropertiesByType('boolean') />
			</cfif>
			<cfif not len(arguments.numericFields)>
				<cfset arguments.numericFields = variables.oTransfer.new(arguments.className).listPropertiesByType('numeric') />
			</cfif>
		<cfelseif not len(arguments.tableName)>
			<cfthrow detail="No Transfer Class or Table Name To Query">
		</cfif>
		
		<cfset arguments.columnList =  listAppend(arguments.primaryKey,arguments.columnList) />
			
		<cfif not len(arguments.sortBy) and len(arguments.searchField) and listFindNoCase('#arguments.columnList#',arguments.searchField)>
			<cfset arguments.sortBy = arguments.searchField />
		<cfelseif not len(arguments.sortBy) and len(arguments.primaryKey)>
			<cfset arguments.sortBy = arguments.primaryKey />
		<cfelseif not len(arguments.primaryKey)>
			<cfthrow detail="No Order By or Primary Key Defined">
		</cfif>
		
		<cfset arguments.dateFrom =  createOdbcDateTime(createDateTime(datePart('yyyy',arguments.dateFrom),datePart('m',arguments.dateFrom),datePart('d',arguments.dateFrom),0,0,0)) />
		<cfset arguments.dateTo =  createOdbcDateTime(createDateTime(datePart('yyyy',arguments.dateTo),datePart('m',arguments.dateTo),datePart('d',arguments.dateTo),23,59,59)) />
		
		<cfif not listFindNoCase(arguments.columnList,arguments.searchField) >
			<cfset arguments.searchField = '' />
		</cfif>
		
		<cfswitch expression="#arguments.dbType#">
			<cfcase value="mssql">
				<cfquery name="stReturn.results" datasource="#variables.oDatasource.getName()#" username="#variables.oDatasource.getUsername()#" password="#variables.oDatasource.getPassword()#">
					WITH [sqlStatement] AS
					(
					    SELECT <cfif len(arguments.columnList)>#arguments.columnList#<cfelse>*</cfif>, ROW_NUMBER() OVER( ORDER BY #arguments.sortBy# #arguments.sortDir# ) AS rowNumber FROM [#arguments.tableName#]
						WHERE 0 = 0
						<!--- date fields --->				
						<cfif listFindNoCase(arguments.dateFields,arguments.searchField)>
							AND #arguments.searchField# BETWEEN <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateTo#" />
						<!--- numeric or boolean values --->
						<cfelseif listFindNoCase(arguments.numericFields,arguments.searchField) or listFindNoCase(arguments.booleanFields,arguments.searchField) and reFind('^(0|1){1}$',arguments.searchFor)>
							AND #arguments.searchField# = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.searchFor#" />
						<!--- text or all --->
						<cfelseif len(arguments.searchFor) and len(arguments.searchField) and listFindNoCase('#arguments.columnList#',arguments.searchField)>
							AND #arguments.searchField# like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.searchFor#%" />
						</cfif>
					)
					SELECT * FROM [sqlStatement]
					WHERE rowNumber BETWEEN <cfqueryparam cfsqltype="cf_sql_numeric" value="#stReturn.startRow#" /> AND <cfqueryparam cfsqltype="cf_sql_numeric" value="#stReturn.endRow#" />
				</cfquery>
					<cfquery name="stReturn.totalRecords" datasource="#variables.oDatasource.getName()#" username="#variables.oDatasource.getUsername()#" password="#variables.oDatasource.getPassword()#"> 
						<cfoutput>
							SELECT count(*) as totalRecords FROM [#arguments.tableName#]
							WHERE 0 = 0
							<!--- date fields --->				
							<cfif listFindNoCase(arguments.dateFields,arguments.searchField)>
								AND #arguments.searchField# BETWEEN <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateTo#" />
							<!--- numeric or boolean values --->
							<cfelseif listFindNoCase(arguments.numericFields,arguments.searchField) or listFindNoCase(arguments.booleanFields,arguments.searchField) and reFind('^(0|1){1}$',arguments.searchFor)>
								AND #arguments.searchField# = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.searchFor#" />
							<!--- text or all --->
							<cfelseif len(arguments.searchFor) and len(arguments.searchField) and listFindNoCase('#arguments.columnList#',arguments.searchField)>
								AND #arguments.searchField# like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.searchFor#%" />
							</cfif>
						</cfoutput>
					</cfquery>
			</cfcase>
			<cfcase value="mysql">
				<cfquery name="stReturn.results" datasource="#variables.oDatasource.getName()#" username="#variables.oDatasource.getUsername()#" password="#variables.oDatasource.getPassword()#">
						SELECT
						<cfif len(arguments.columnList)>#arguments.columnList#<cfelse>*</cfif>				
						FROM #arguments.tableName#
						WHERE 0 = 0
						<!--- date fields --->				
						<cfif listFindNoCase(arguments.dateFields,arguments.searchField)>
							AND #arguments.searchField# BETWEEN <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateTo#" />
						<!--- numeric or boolean values --->
						<cfelseif listFindNoCase(arguments.numericFields,arguments.searchField) or listFindNoCase(arguments.booleanFields,arguments.searchField) and reFind('^(0|1){1}$',arguments.searchFor)>
							AND #arguments.searchField# = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.searchFor#" />
						<!--- text or all --->
						<cfelseif len(arguments.searchFor) and len(arguments.searchField)>
							AND #arguments.searchField# like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.searchFor#%" />
						</cfif>
						ORDER BY #arguments.sortBy# #arguments.sortDir#
						LIMIT #arguments.groupSize# OFFSET #(stReturn.startRow - 1)#
				</cfquery>
				<cfquery name="stReturn.totalRecords" datasource="#variables.oDatasource.getName()#" username="#variables.oDatasource.getUsername()#" password="#variables.oDatasource.getPassword()#"> 
					<cfoutput>
						SELECT count(*) as totalRecords FROM #arguments.tableName#
						WHERE 0 = 0
						<!--- date fields --->				
						<cfif listFindNoCase(arguments.dateFields,arguments.searchField)>
							AND #arguments.searchField# BETWEEN <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateTo#" />
						<!--- numeric or boolean values --->
						<cfelseif listFindNoCase(arguments.numericFields,arguments.searchField) or listFindNoCase(arguments.booleanFields,arguments.searchField) and reFind('^(0|1){1}$',arguments.searchFor)>
							AND #arguments.searchField# = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.searchFor#" />
						<!--- text or all --->
						<cfelseif len(arguments.searchFor) and len(arguments.searchField) and listFindNoCase('#arguments.columnList#',arguments.searchField)>
							AND #arguments.searchField# like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.searchFor#%" />
						</cfif>
					</cfoutput>
				</cfquery>	
			</cfcase>
			<cfcase value="postgresql">
				<cfquery name="stReturn.results" datasource="#variables.oDatasource.getName()#" username="#variables.oDatasource.getUsername()#" password="#variables.oDatasource.getPassword()#">
						SELECT
						<cfif len(arguments.columnList)>#arguments.columnList#<cfelse>*</cfif>
						FROM #arguments.tableName#
						WHERE 0 = 0
						<!--- date fields --->				
						<cfif listFindNoCase(arguments.dateFields,arguments.searchField)>
							AND #arguments.searchField# BETWEEN <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateTo#" />
						<!--- numeric or boolean values --->
						<cfelseif listFindNoCase(arguments.numericFields,arguments.searchField) or listFindNoCase(arguments.booleanFields,arguments.searchField) and reFind('^(0|1){1}$',arguments.searchFor)>
							AND #arguments.searchField# = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.searchFor#" />
						<!--- text or all --->
						<cfelseif len(arguments.searchFor) and len(arguments.searchField)>
							AND #arguments.searchField# like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.searchFor#%" />
						</cfif>
						ORDER BY #arguments.sortBy# #arguments.sortDir#
						LIMIT #arguments.groupSize# OFFSET #(stReturn.startRow - 1)#
				</cfquery>
				<cfquery name="stReturn.totalRecords" datasource="#variables.oDatasource.getName()#" username="#variables.oDatasource.getUsername()#" password="#variables.oDatasource.getPassword()#"> 
					<cfoutput>
						SELECT count(*) as totalRecords FROM #arguments.tableName#
						WHERE 0 = 0
						<!--- date fields --->				
						<cfif listFindNoCase(arguments.dateFields,arguments.searchField)>
							AND #arguments.searchField# BETWEEN <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dateTo#" />
						<!--- numeric or boolean values --->
						<cfelseif listFindNoCase(arguments.numericFields,arguments.searchField) or listFindNoCase(arguments.booleanFields,arguments.searchField) and reFind('^(0|1){1}$',arguments.searchFor)>
							AND #arguments.searchField# = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.searchFor#" />
						<!--- text or all --->
						<cfelseif len(arguments.searchFor) and len(arguments.searchField) and listFindNoCase('#arguments.columnList#',arguments.searchField)>
							AND #arguments.searchField# like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.searchFor#%" />
						</cfif>
					</cfoutput>
				</cfquery>	
			</cfcase>
		</cfswitch>
		
		<cfset stReturn.totalRecords = stReturn.totalRecords.totalRecords />
		
		<cfreturn stReturn />
	</cffunction>
</cfcomponent>