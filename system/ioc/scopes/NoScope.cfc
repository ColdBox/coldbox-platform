<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I am the NoScope Scope of Scopes
	
----------------------------------------------------------------------->
<cfcomponent output="false" implements="coldbox.system.ioc.scopes.IScope" hint="I am the NoScope Scope of Scopes">

	<!--- configure --->
    <cffunction name="configure" output="false" access="public" returntype="void" hint="Configure your scope for operation">
    	<cfargument name="wirebox" type="coldbox.system.ioc.Injector" required="true" hint="The linked WireBox injector"/>
		<cfscript>
			instance = {
				wirebox = arguments.wirebox
			};
		</cfscript>
    </cffunction>

	<!--- getFromScope --->
    <cffunction name="getFromScope" output="false" access="public" returntype="any" hint="Retrieve an object from scope or create it if not found in scope">
    	<cfargument name="mapping" type="coldbox.system.ioc.config.Mapping" required="true" hint="The object mapping"/>
		<cfscript>
			// create and return the no scope instance, no locking needed.
			var object = wirebox.constructInstance(arguments.mapping);
			// wire it
			instance.wireBox.autowire( object );
			// send it back
			return object;
		</cfscript>
    </cffunction>
	
</cfcomponent>