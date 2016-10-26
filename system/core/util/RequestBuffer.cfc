<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	A buffer object that lives in the request scope.
----------------------------------------------------------------------->
<cfcomponent name="RequestBuffer" output="false" hint="A buffer object that lives in the request scope. It switches its implementation depending on the JDK its running on.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="RequestBuffer" hint="Constructor">
		<cfscript>
			instance = structnew();
			/* Setup properties */
			instance.bufferKey = "_cbox_request_buffer";
			// class id code
			instance.classID = createObject("java", "java.lang.System").identityHashCode( this );

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- clear --->
	<cffunction name="clear" output="false" access="public" returntype="void" hint="Clear the buffer">
		<cfscript>
			var oBuffer = getBufferObject();
			oBuffer.delete(0,oBuffer.length());
		</cfscript>
	</cffunction>

	<!--- append --->
	<cffunction name="append" output="false" access="public" returntype="void" hint="Append to the buffer.">
		<cfargument name="str" type="string" required="true" hint="The string to append"/>
		<cfset getBufferObject().append(arguments.str)>
	</cffunction>

	<!--- length --->
	<cffunction name="length" output="false" access="public" returntype="numeric" hint="Returns the length (character count)">
		<cfreturn getBufferObject().length()>
	</cffunction>

	<!--- getString --->
	<cffunction name="getString" output="false" access="public" returntype="any" hint="Get the string representation of the buffer">
		<cfreturn getBufferObject().toString()>
	</cffunction>

	<!--- isBufferInScope --->
	<cffunction name="isBufferInScope" output="false" access="public" returntype="boolean" hint="Checks if the buffer has been created or not">
		<cfreturn structKeyExists(request, instance.bufferKey)>
	</cffunction>

	<!--- getBufferObject --->
	<cffunction name="getBufferObject" output="false" access="public" returntype="any" hint="Get the raw buffer object">
		<cfset var oBuffer = 0>

		<!--- Double Lock --->
		<cfif not isBufferInScope()>
			<cflock name="#instance.classID#.#instance.bufferkey#" type="exclusive" timeout="10" throwontimeout="true">
				<cfif not isBufferInScope()>
					<!--- Create Buffer --->
					<cfset oBuffer = createObject("java","java.lang.StringBuilder").init('')>
					<!--- Place in Scope --->
					<cfset request[instance.bufferKey] = oBuffer>
				</cfif>
			</cflock>
		</cfif>

		<!--- Return Buffer --->
		<cfreturn request[instance.bufferKey]>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>


</cfcomponent>