<!--- mockArgs --->
<cffunction name="mockArgs" output="true" access="public" returntype="any" hint="">
	<cfdump var="#hash(arguments.toString())#">
	<cfset tm = createObject("java","java.util.TreeMap").init(arguments)>
	<cfdump var="#tm.values().toString()#">
	<cfdump var="#tm.keySet().toString()#">
</cffunction>

<cfscript>
mockArgs(name="hello",testArg="99");
mockArgs("hello","99");
</cfscript>

