<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	This object invokes methods
----------------------------------------------------------------------->
<cfcomponent hint="Dynamic invokes a method on a CFC by its name" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" hint="Constructor" access="public" returntype="MethodInvoker" output="false">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="invokeMethod" hint="Invokes a method and returns its result. If no results, then it returns null" access="public" returntype="any" output="false">
		<cfargument name="component"	type="any" 		required="true" hint="The component to invoke against">
		<cfargument name="methodName" 	type="string" 	required="true" hint="The name of the method">
		<cfargument name="args" 		type="struct" 	required="false" default="#structNew()#" hint="Argument Collection to pass in">
	
		<cfset var refLocal = StructNew()>
	
		<cfinvoke component="#arguments.component#"
				  method="#arguments.methodName#"
				  argumentcollection="#arguments.args#"
				  returnvariable="refLocal.results">
		
		<cfif structKeyExists(refLocal, "results")>
			<cfreturn refLocal.results>
		</cfif>
	</cffunction>

</cfcomponent>