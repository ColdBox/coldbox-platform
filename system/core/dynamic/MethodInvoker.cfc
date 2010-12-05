<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	This object invokes methods on target CFCs
----------------------------------------------------------------------->
<cfcomponent hint="This object invokes methods on target CFCs" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" hint="Constructor" access="public" returntype="MethodInvoker" output="false">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="invokeMethod" hint="Invokes a method and returns its result. If no results, then it returns null" access="public" returntype="any" output="false">
		<cfargument name="component"	required="true" hint="The component to invoke against">
		<cfargument name="methodName"   required="true" hint="The name of the method to invoke">
		<cfargument name="args" 		required="false" default="#structNew()#" hint="Argument Collection to pass in to execution">
	
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