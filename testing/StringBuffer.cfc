<!---
StringBuffer.cfc
This CFC greatly increases the speed of string concatenation. CF strings are immutable. When you append a string
to another string, a whole new string is created. This is fine for a small number of iterations but painfully
slow and memory intensive for a large number of concatenation operations.

greg.lively@gmail.com
Use this program however you want.

To use:
<cfscript>
	variables.joStringBuffer = createObject('component', 'StringBuffer');
	variables.joStringBuffer.append(variables.someDataVar);
	writeOutput(variables.joStringBuffer.getString());
</cfscript>

from Java 1.5 API:
StringBuffer
A thread-safe, mutable sequence of characters. A string buffer is like a String, but can be modified. At any point in
time it contains some particular sequence of characters, but the length and content of the sequence can be changed
through certain method calls.

String buffers are safe for use by multiple threads. The methods are synchronized where necessary so that all the
operations on any particular instance behave as if they occur in some serial order that is consistent with the
order of the method calls made by each of the individual threads involved.
--->
<cfcomponent displayname="StringBuffer">

	<cfset variables.joStringBuffer = createObject("java","java.lang.StringBuffer") />

	<cffunction name="init" returntype="StringBuffer" access="public" output="No" hint="initializes the StringBuffer CF/java object">
		<cfargument name="strIn" type="string" required="No" default="" hint="a string to add to the buffer" />
		
		<cfset variables.joStringBuffer.init(javaCast("string", arguments.strIn)) />

		<cfreturn this />
	</cffunction>

	<cffunction name="append" returntype="void" access="public" output="No">
		<cfargument name="strIn" type="string" required="No" default="" hint="a string to append to the buffer" />

		<cfset variables.joStringBuffer.append(javaCast("string", arguments.strIn)) />
	</cffunction>

	<cffunction name="delete" returntype="void" access="public" output="No">
		<cfargument name="startPos" type="numeric" required="Yes" hint="The beginning index, inclusive." />
		<cfargument name="endPos" type="numeric" required="Yes" hint="The ending index, exclusive." />

		<cfset variables.joStringBuffer.delete(javaCast("int", arguments.startPos),javaCast("int", arguments.endPos)) />
	</cffunction>

	<cffunction name="insertStr" returntype="void" access="public" output="No">
		<cfargument name="offSet" type="numeric" required="No" default="0" hint="the offset" />
		<cfargument name="inStr" type="string" required="Yes" hint="a string" />

		<cfset variables.joStringBuffer.insert(javaCast("int", arguments.offSet), javaCast("string", arguments.inStr)) />
	</cffunction>

	<cffunction name="replaceStr" returntype="void" access="public" output="No">
		<cfargument name="startPos" type="numeric" required="Yes" hint="The beginning index, inclusive." />
		<cfargument name="endPos" type="numeric" required="Yes" hint="The ending index, exclusive." />
		<cfargument name="inStr" type="string" required="Yes" hint="a string" />

		<cfset variables.joStringBuffer.replace(javaCast("int", arguments.startPos), javaCast("int", arguments.endPos), javaCast("string", arguments.inStr)) />
	</cffunction>

	<cffunction name="indexOf" returntype="numeric" access="public" output="No">
		<cfargument name="inStr" type="string" required="Yes" hint="the substring for which to search" />
		<cfargument name="fromPos" type="numeric" required="No" default="0" hint="the index from which to start the search" />

		<cfreturn variables.joStringBuffer.indexOf(javaCast("string", arguments.inStr),javaCast("int", arguments.fromPos)) />
	</cffunction>

	<cffunction name="lastIndexOf" returntype="numeric" access="public" output="No">
		<cfargument name="inStr" type="string" required="Yes" hint="the substring for which to search" />
		<cfargument name="fromPos" type="numeric" required="No" default="0" hint="the index from which to start the search" />

		<cfreturn variables.joStringBuffer.lastIndexOf(javaCast("string", arguments.inStr),javaCast("int", arguments.fromPos)) />
	</cffunction>

	<cffunction name="substring" returntype="string" access="public" output="No">
		<cfargument name="startPos" type="numeric" required="Yes" hint="The beginning index, inclusive." />
		<cfargument name="endPos" type="numeric" required="No" default="#(variables.joStringBuffer.length() - 1)#" hint="The ending index, exclusive." />

		<cfreturn variables.joStringBuffer.substring(javaCast("int", arguments.startPos),javaCast("int", arguments.endPos)) />
	</cffunction>

	<cffunction name="reverseStr" returntype="void" access="public" output="No">

		<cfset variables.joStringBuffer.reverse() />
	</cffunction>

	<cffunction name="length" returntype="numeric" access="public" output="No">

		<cfreturn variables.joStringBuffer.length() />
	</cffunction>

	<cffunction name="getString" returntype="string" access="public" output="No" hint="Returns a string representing the data in this object">
		<cfreturn variables.joStringBuffer.toString() />
	</cffunction>

</cfcomponent>