<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model an exception structure

Modification History:
08/07/2006 - new method, getTagContextAsString(). Updated the return types.
----------------------------------------------------------------------->
<cfcomponent name="exceptionBean" hint="I model a Coldfusion/Coldbox Exception" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfscript>
		variables.instance = structnew();
		// CFMX Exception Structure ;
		variables.instance.exceptionStruct = structnew();
		// Exception Message ;
		variables.instance.extramessage = "";
		// Exception ExtraInformation variable, could be anything. ;
		variables.instance.extraInfo = "";
		// Exception type, either application or framework ;
		variables.instance.errorType = "application";
		// Null Declarations ;
		variables.STRINGNULL = "";
		variables.ARRAYNULL = ArrayNew(1);
	</cfscript>

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="errorStruct" 		type="any" required="false" hint="The CF error Structure" 		default="#structnew()#" />
		<cfargument name="extramessage" 	type="any" required="false" hint="The custom error message" 	default="" />
		<cfargument name="extraInfo" 		type="any" required="false" hint="Extra information" 			default="" />
		<cfargument name="errorType" 		type="any" required="false" default="application" 				hint="application/framework">
		<!--- ************************************************************* --->
		<!--- Set instance for exception structure --->
		<cfset variables.instance.exceptionStruct = duplicate(arguments.errorStruct) />
		<cfif not isStruct(variables.instance.exceptionStruct)>
			<cfset variables.instance.exceptionStruct = structnew()>
		</cfif>
		<!--- Set extra exception messages --->
		<cfset variables.instance.extramessage = arguments.extramessage>
		<cfset variables.instance.extraInfo = arguments.extraInfo>
		<!--- Verify errorType --->
		<cfif not reFindnocase("^(application|framework)$",arguments.errorType)>
			<cfset variables.instance.errorType = "application">
		<cfelse>
			<cfset variables.instance.errorType = arguments.errorType>
		</cfif>
		<cfreturn this >
	</cffunction>
	<!--- ************************************************************* --->
<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="getInstance" access="public" returntype="any" output="false">
		<cfreturn variables.instance >
	</cffunction>
	
	<!--- ************************************************************* --->

	<cffunction name="setInstance" access="public" returntype="void" output="false">
		<cfargument name="instance" type="struct" required="true">
		<cfset variables.instance = arguments.instance>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getErrorType" access="public" returntype="string" output="false">
		<cfreturn variables.instance.errorType >
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getExceptionStruct" access="public" returntype="struct" output="false">
		<cfreturn variables.instance.exceptionStruct >
	</cffunction>
	
	<!--- ************************************************************* --->

	<cffunction name="getExtraMessage" access="public" returntype="string" output="false">
		<cfreturn variables.instance.extramessage >
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getExtraInfo" access="public" returntype="any" output="false">
		<cfreturn variables.instance.extraInfo >
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfif structKeyExists(variables.instance.exceptionStruct, "Type")>
			<cfreturn variables.instance.exceptionStruct.type >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getMessage" access="public" returntype="string" output="false">
		<cfif structkeyExists(variables.instance.exceptionStruct,"message")>
			<cfreturn variables.instance.exceptionStruct.message >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getDetail" access="public" returntype="string" output="false">
		<cfif structkeyExists(variables.instance.exceptionStruct,"detail")>
			<cfreturn variables.instance.exceptionStruct.detail >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getStackTrace" access="public" returntype="string" output="false">
		<cfif structKeyExists(variables.instance.exceptionStruct, 'StackTrace')>
			<cfreturn variables.instance.exceptionStruct.StackTrace >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getTagContext" access="public" returntype="array" output="false">
		<cfif structkeyExists(variables.instance.exceptionStruct, "TagContext")>
			<cfreturn variables.instance.exceptionStruct.tagContext >
		<cfelse>
			<cfreturn variables.ARRAYNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getTagContextAsString" access="public" returntype="string" output="false" hint="I return the tagcontext in string format.">
		<cfset var arrayTagContext = getTagContext()>
		<cfset var rtnString = "">
		<cfif structkeyExists(variables.instance.exceptionStruct, "TagContext") and ArrayLen(variables.instance.exceptionStruct.TagContext)>
			<cfloop from="1" to="#arrayLen(arrayTagContext)#" index="i">
			  <cfsavecontent variable="entry"><cfoutput>ID: <cfif not structKeyExists(arrayTagContext[i], "ID")>N/A<cfelse>#arrayTagContext[i].ID#</cfif>; LINE: #arrayTagContext[i].LINE#; TEMPLATE: #arrayTagContext[i].Template# #chr(13)#</cfoutput></cfsavecontent>
			  <cfset rtnString = rtnString & entry>
			</cfloop>
			<cfreturn rtnString>
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getNativeErrorCode" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.instance.exceptionStruct,'nativeErrorCode')>
			<cfreturn variables.instance.exceptionStruct.nativeErrorCode >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	
	<!--- SQL Types --->
	<!--- ************************************************************* --->
	<cffunction name="getSqlState" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.instance.exceptionStruct,'sqlState')>
			<cfreturn variables.instance.exceptionStruct.sqlState >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getSql" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.instance.exceptionStruct,'sql')>
			<cfreturn variables.instance.exceptionStruct.sql >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getQueryError" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.instance.exceptionStruct,'queryError')>
			<cfreturn variables.instance.exceptionStruct.queryError >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getWhere" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.instance.exceptionStruct,'where')>
			<cfreturn variables.instance.exceptionStruct.where >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="getErrNumber" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.instance.exceptionStruct,'errNumber')>
			<cfreturn variables.instance.exceptionStruct.errNumber >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getMissingFileName" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.instance.exceptionStruct,'missingFileName')>
			<cfreturn variables.instance.exceptionStruct.missingFileName >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->

	<cffunction name="getLockName" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.instance.exceptionStruct,'lockName')>
			<cfreturn variables.instance.exceptionStruct.lockName >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="getLockOperation" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.instance.exceptionStruct,'lockOperation')>
			<cfreturn variables.instance.exceptionStruct.lockOperation >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getErrorCode" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.instance.exceptionStruct,'errorCode')>
			<cfreturn variables.instance.exceptionStruct.errorCode >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getExtendedInfo" access="public" returntype="string" output="false">
		<cfif StructKeyExists(variables.instance.exceptionStruct,'extendedInfo')>
			<cfreturn variables.instance.exceptionStruct.extendedInfo >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->

</cfcomponent>