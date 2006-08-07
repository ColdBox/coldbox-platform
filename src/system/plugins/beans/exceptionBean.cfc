<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model an exception structure

Modification History:
08/07/2006 - new method, getTagContextAsString(). Updated the return types.
----------------------------------------------------------------------->
<cfcomponent name="exceptionBean" hint="I model a Coldfusion/Coldbox Exception" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfset variables.exceptionStruct = structnew()>
	<cfset variables.extramessage = "">
	<cfset variables.extraInfo = "">
	<cfset variables.errorType = "application">
	<!--- Null Declarations --->
	<cfset variables.StringNull = "">
	<cfset variables.ArrayNull = ArrayNew(1)>
<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="errorStruct" 		type="any" required="false" hint="The CF error Structure" 		default="#structnew()#" />
		<cfargument name="extramessage" 	type="any" required="false" hint="The custom error message" 	default="" />
		<cfargument name="extraInfo" 		type="any" required="false" hint="Extra information" 			default="" />
		<cfargument name="errorType" 		type="any" required="false" default="application" 				hint="application/framework">
		<!--- Set variables --->
		<cfset variables.exceptionStruct = duplicate(arguments.errorStruct) />
		<cfif not isStruct(variables.exceptionStruct)>
			<cfset variables.exceptionStruct = structnew()>
		</cfif>
		<cfset variables.extramessage = arguments.extramessage>
		<cfset variables.extraInfo = arguments.extraInfo>
		<cfif not reFindnocase("(application|framework)",arguments.errorType)>
			<cfset variables.errorType = "application">
		<cfelse>
			<cfset variables.errorType = arguments.errorType>
		</cfif>
		<cfreturn this >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getErrorType" access="public" returntype="string" output="false">
		<cfreturn variables.errorType >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getExceptionStruct" access="public" returntype="struct" output="false">
		<cfreturn variables.exceptionStruct >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getExtraMessage" access="public" returntype="string" output="false">
		<cfreturn variables.extramessage >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getExtraInfo" access="public" returntype="any" output="false">
		<cfreturn variables.extraInfo >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfif structKeyExists(variables.exceptionStruct, "Type")>
			<cfreturn variables.exceptionStruct.type >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getMessage" access="public" returntype="string" output="false">
		<cfif structkeyExists(variables.exceptionStruct,"message")>
			<cfreturn variables.exceptionStruct.message >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getDetail" access="public" returntype="string" output="false">
		<cfif structkeyExists(variables.exceptionStruct,"detail")>
			<cfreturn variables.exceptionStruct.detail >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getStackTrace" access="public" returntype="string" output="false">
		<cfif structKeyExists(variables.exceptionStruct, 'StackTrace')>
			<cfreturn variables.exceptionStruct.StackTrace >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getTagContext" access="public" returntype="array" output="false">
		<cfif structkeyExists(variables.exceptionStruct, "TagContext")>
			<cfreturn variables.exceptionStruct.tagContext >
		<cfelse>
			<cfreturn variables.ArrayNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getTagContextAsString" access="public" returntype="string" output="false" hint="I return the tagcontext in string format.">
		<cfset var arrayTagContext = getTagContext()>
		<cfset var rtnString = "">
		<cfif structkeyExists(variables.exceptionStruct, "TagContext") and ArrayLen(variables.exceptionStruct.TagContext)>
			<cfloop from="1" to="#arrayLen(arrayTagContext)#" index="i">
			  <cfsavecontent variable="entry"><cfoutput>ID: <cfif not structKeyExists(arrayTagContext[i], "ID")>N/A<cfelse>#arrayTagContext[i].ID#</cfif>; LINE: #arrayTagContext[i].LINE#; TEMPLATE: #arrayTagContext[i].Template# #chr(13)#</cfoutput></cfsavecontent>
			  <cfset rtnString = rtnString & entry>
			</cfloop>
			<cfreturn rtnString>
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="getNativeErrorCode" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.exceptionStruct,'nativeErrorCode')>
			<cfreturn variables.exceptionStruct.nativeErrorCode >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- SQL Types --->
	<!--- ************************************************************* --->
	<cffunction name="getSqlState" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.exceptionStruct,'sqlState')>
			<cfreturn variables.exceptionStruct.sqlState >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getSql" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.exceptionStruct,'sql')>
			<cfreturn variables.exceptionStruct.sql >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getQueryError" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.exceptionStruct,'queryError')>
			<cfreturn variables.exceptionStruct.queryError >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getWhere" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.exceptionStruct,'where')>
			<cfreturn variables.exceptionStruct.where >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->
	<cffunction name="getErrNumber" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.exceptionStruct,'errNumber')>
			<cfreturn variables.exceptionStruct.errNumber >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getMissingFileName" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.exceptionStruct,'missingFileName')>
			<cfreturn variables.exceptionStruct.missingFileName >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getLockName" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.exceptionStruct,'lockName')>
			<cfreturn variables.exceptionStruct.lockName >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getLockOperation" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.exceptionStruct,'lockOperation')>
			<cfreturn variables.exceptionStruct.lockOperation >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getErrorCode" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.exceptionStruct,'errorCode')>
			<cfreturn variables.exceptionStruct.errorCode >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getExtendedInfo" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.exceptionStruct,'extendedInfo')>
			<cfreturn variables.exceptionStruct.extendedInfo >
		<cfelse>
			<cfreturn variables.StringNull>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>