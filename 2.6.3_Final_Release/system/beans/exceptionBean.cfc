<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model an exception structure

Modification History:
08/07/2006 - new method, getTagContextAsString(). Updated the return types.
----------------------------------------------------------------------->
<cfcomponent name="exceptionBean"
			 hint="I model a Coldfusion/Coldbox Exception"
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfscript>
		variables.instance = structnew();
		// CFMX Exception Structure ;
		instance.exceptionStruct = structnew();
		// Exception Message ;
		instance.extramessage = "";
		// Exception ExtraInformation variable, could be anything. ;
		instance.extraInfo = "";
		// Exception type, either application or framework ;
		instance.errorType = "application";
		// Null Declarations ;
		variables.STRINGNULL = "";
		variables.ARRAYNULL = ArrayNew(1);
	</cfscript>

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="coldbox.system.beans.exceptionBean" output="false">
		<!--- ************************************************************* --->
		<cfargument name="errorStruct" 		type="any" 		required="false" hint="The CF error Structure" 		default="#structnew()#" />
		<cfargument name="extramessage" 	type="string" 	required="false" hint="The custom error message" 	default="" />
		<cfargument name="extraInfo" 		type="any" 		required="false" hint="Extra information" 			default="" />
		<cfargument name="errorType" 		type="string" 	required="false" default="application" 				hint="application/framework">
		<!--- ************************************************************* --->
		<!--- Set instance for exception structure --->
		<cfset instance.exceptionStruct = duplicate(arguments.errorStruct) />
		<cfif not isStruct(instance.exceptionStruct)>
			<cfset instance.exceptionStruct = structnew()>
		</cfif>
		<!--- Set extra exception messages --->
		<cfset instance.extramessage = arguments.extramessage>
		<cfset instance.extraInfo = arguments.extraInfo>
		<!--- Verify errorType --->
		<cfif not reFindnocase("^(application|framework)$",arguments.errorType)>
			<cfset instance.errorType = "application">
		<cfelse>
			<cfset instance.errorType = arguments.errorType>
		</cfif>
		<cfreturn this >
	</cffunction>
	<!--- ************************************************************* --->
<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="getMemento" access="public" returntype="any" output="false" hint="Get the memento">
		<cfreturn variables.instance >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setmemento" access="public" returntype="void" output="false" hint="Set the memento">
		<cfargument name="memento" type="struct" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getErrorType" access="public" returntype="string" output="false">
		<cfreturn instance.errorType >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getExceptionStruct" access="public" returntype="struct" output="false">
		<cfreturn instance.exceptionStruct >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getExtraMessage" access="public" returntype="string" output="false">
		<cfreturn instance.extramessage >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getExtraInfo" access="public" returntype="any" output="false">
		<cfreturn instance.extraInfo >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfif structKeyExists(instance.exceptionStruct, "Type")>
			<cfreturn instance.exceptionStruct.type >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getMessage" access="public" returntype="string" output="false">
		<cfif structkeyExists(instance.exceptionStruct,"message")>
			<cfreturn instance.exceptionStruct.message >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getDetail" access="public" returntype="string" output="false">
		<cfif structkeyExists(instance.exceptionStruct,"detail")>
			<cfreturn instance.exceptionStruct.detail >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getStackTrace" access="public" returntype="string" output="false">
		<cfif structKeyExists(instance.exceptionStruct, 'StackTrace')>
			<cfreturn instance.exceptionStruct.StackTrace >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getTagContext" access="public" returntype="array" output="false">
		<cfif structkeyExists(instance.exceptionStruct, "TagContext")>
			<cfreturn instance.exceptionStruct.tagContext >
		<cfelse>
			<cfreturn variables.ARRAYNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getTagContextAsString" access="public" returntype="string" output="false" hint="I return the tagcontext in string format.">
		<cfset var arrayTagContext = getTagContext()>
		<cfset var rtnString = "">
		<cfset var i = 1>
		<cfset var entry = "">
		<cfset var tagContextLength = ArrayLen(arrayTagContext)>
		<cfif structkeyExists(instance.exceptionStruct, "TagContext") and tagContextLength>
			<cfloop from="1" to="#tagContextLength#" index="i">
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
		<cfif StructKeyExists(instance.exceptionStruct,'nativeErrorCode')>
			<cfreturn instance.exceptionStruct.nativeErrorCode >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>


	<!--- SQL Types --->
	<!--- ************************************************************* --->
	<cffunction name="getSqlState" access="public" returntype="string" output="false">
		<cfif StructKeyExists(instance.exceptionStruct,'sqlState')>
			<cfreturn instance.exceptionStruct.sqlState >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getSql" access="public" returntype="string" output="false">
		<cfif StructKeyExists(instance.exceptionStruct,'sql')>
			<cfreturn instance.exceptionStruct.sql >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getQueryError" access="public" returntype="string" output="false">
		<cfif StructKeyExists(instance.exceptionStruct,'queryError')>
			<cfreturn instance.exceptionStruct.queryError >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getWhere" access="public" returntype="string" output="false">
		<cfif StructKeyExists(instance.exceptionStruct,'where')>
			<cfreturn instance.exceptionStruct.where >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getErrNumber" access="public" returntype="string" output="false">
		<cfif StructKeyExists(instance.exceptionStruct,'errNumber')>
			<cfreturn instance.exceptionStruct.errNumber >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getMissingFileName" access="public" returntype="string" output="false">
		<cfif StructKeyExists(instance.exceptionStruct,'missingFileName')>
			<cfreturn instance.exceptionStruct.missingFileName >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getLockName" access="public" returntype="string" output="false">
		<cfif StructKeyExists(instance.exceptionStruct,'lockName')>
			<cfreturn instance.exceptionStruct.lockName >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getLockOperation" access="public" returntype="string" output="false">
		<cfif StructKeyExists(instance.exceptionStruct,'lockOperation')>
			<cfreturn instance.exceptionStruct.lockOperation >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getErrorCode" access="public" returntype="string" output="false">
		<cfif StructKeyExists(instance.exceptionStruct,'errorCode')>
			<cfreturn instance.exceptionStruct.errorCode >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getExtendedInfo" access="public" returntype="string" output="false">
		<cfif StructKeyExists(instance.exceptionStruct,'extendedInfo')>
			<cfreturn instance.exceptionStruct.extendedInfo >
		<cfelse>
			<cfreturn variables.STRINGNULL>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>