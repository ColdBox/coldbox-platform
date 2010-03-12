<cfcomponent hint="I am an Abstract Service" output="false">

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="entityname" required="true" hint="I am the entityname">

		<cfset setEntityName(arguments.entityname)>
		<cfset setEntityTableName(arguments.entityname)>
		<cfset setEntityPropertyNames(arguments.entityname)>

		<cfreturn this />
	</cffunction>

	<cffunction name="getEntityName" access="private" returntype="string" output="false">
		<cfreturn variables.instance.entityname />
	</cffunction>

	<cffunction name="setEntityName" access="private" returntype="void" output="false">
		<cfargument name="entityname" required="true" hint="I am the entityname">

		<cfset variables.instance.entityname = arguments.entityname>

	</cffunction>

	<cffunction name="getEntityTableName" access="private" returntype="string" output="false">
		<cfreturn variables.instance.entitytablename />
	</cffunction>

	<cffunction name="setEntityTableName" access="private" returntype="void" output="false">
		<cfargument name="entityname" required="true" hint="I am the entityname">

		<cfset variables.instance.entitytablename = ormGetSessionFactory().getClassMetadata(arguments.entityname).getTableName()>

	</cffunction>

	<cffunction name="getEntityPropertyNames" access="private" returntype="array" output="false">
		<cfreturn variables.instance.entitypropertynames />
	</cffunction>

	<cffunction name="setEntityPropertyNames" access="private" returntype="void" output="false">
		<cfargument name="entityname" required="true" hint="I am the entityname">

		 <cfset var variables.instance.entitypropertynames = ormGetSessionFactory().getClassMetaData(arguments.entityname).getPropertyNames()>

	</cffunction>

	<cffunction name="getEntityPK" access="private" returntype="string" output="false">
		<cfreturn variables.instance.entitypk />
	</cffunction>

	<cffunction name="setEntityPK" access="private" returntype="void" output="false">
		<cfargument name="entityname" required="true" hint="I am the entityname">

		<cfset variables.instance.entitypk = ormGetSessionFactory().getClassMetaData(arguments.entityname).getPropertyNames()>

	</cffunction>

	<cffunction name="get" access="public" output="false" returntype="any">
		<cfargument name="id" type="numeric" required="false" />
		<cfif structKeyExists(arguments,"ID") and len(arguments.ID) and arguments.ID NEQ 0>
			<cfreturn EntityLoadByPK(getEntityName(),arguments.ID) />
		<cfelse>
			<cfreturn EntityNew(getEntityName()) />
		</cfif>
	</cffunction>

	<cffunction name="save" access="public" output="false" returntype="void">
		<cfargument name="theEntity" required="true" hint="I am the entity">

		<cfset EntitySave(arguments.theEntity) />

	</cffunction>

	<cffunction name="delete" access="public" output="false" returntype="void">
		<cfargument name="theEntity" required="true" hint="I am the entity">

		<cfset EntitySave(arguments.theEntity) />

	</cffunction>

	<cffunction name="getByAttributes" access="public" output="false" returntype="array">

		<cfset var sFilter = structNew()>
		<cfset var sResults = structNew()>
		<cfset var arObj = arrayNew(1)>
		<cfset var argumentname = "">

		<cfloop collection="#arguments#" item="argumentname">
			<cfif argumentname NEQ "MaxResults" AND argumentname NEQ "sortorder" AND argumentname NEQ "offset">
				<cfif structKeyExists(arguments,argumentname) and len(#arguments[argumentname]#)>
					<cfset sFilter[#argumentname#] = #arguments[argumentname]#>
				</cfif>
			</cfif>
		</cfloop>

		<cfif structKeyExists(arguments,"maxresults") and len(arguments.maxresults)>
			<cfset sResults["maxresults"] = arguments.maxresults>
			<cfif structKeyExists(arguments,"offset") and len(arguments.offset)>
				<cfset sResults["offset"] = arguments.offset>
			</cfif>
		</cfif>

		<cfif structKeyExists(arguments,"sortorder") and len(arguments.sortorder)>
			<cfset arObj = entityLoad(getEntityName(), sFilter, arguments.sortorder, sResults) />
		<cfelse>
			<cfset arObj = entityLoad(getEntityName(), sFilter, sResults) />
		</cfif>

		<cfreturn arObj />
	</cffunction>

	<cffunction name="getByAttributesCount" access="public" output="false" returntype="numeric">
		<cfset var qCount = QueryNew("blah") />
		<cfset var count = 0 />
		<cfset var tablename = getEntityTableName() />
		<cfset var arPropertyNames = getEntityPropertyNames() />
		<cfset var qs = "" />
		<cfset var whereclause = "" />
		<cfset var argumentname = "" />
		<cfset var propertynameindex = 0 />

		<cfset qs = "SELECT Count(*) AS Count FROM " & getEntityName() & " WHERE 0=0">

		<cfloop collection="#arguments#" item="argumentname">
			<cfif argumentname NEQ "MaxResults" AND argumentname NEQ "sortorder" AND argumentname NEQ "offset">
				<cfif structKeyExists(arguments,argumentname) and len(#arguments[argumentname]#)>
					<cfset propertynameindex = arrayFindNoCase(arPropertyNames,argumentname)>
					<cfif propertynameindex NEQ 0>
					<cfset whereclause = whereclause & " AND " & arPropertyNames[propertynameindex] & " = " & arguments[argumentname] />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

		<cfset qs = qs & whereclause>

		<cfset var sqlregex = "
		(SELECT\s[\w\*\)\(\,\s]+\sFROM\s[\w]+)|
		(UPDATE\s[\w]+\sSET\s[\w\,\'\=]+)|
		(INSERT\sINTO\s[\d\w]+[\s\w\d\)\(\,]*\sVALUES\s\([\d\w\'\,\)]+)|
		(DELETE\sFROM\s[\d\w\'\=]+)|
		(DROP\sTABLE\s[\d\w\'\=]+)">

		<cfif not refindnocase(sqlregex, "#qs#")>
			<cfset count = ormExecuteQuery(qs, true)>
		</cfif>

		<cfreturn count />
	</cffunction>

</cfcomponent>