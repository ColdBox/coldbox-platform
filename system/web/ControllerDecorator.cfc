<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	This is the object used to inherit to create Controller Decorators
----------------------------------------------------------------------->
<cfcomponent hint="This is the object used to inherit to create Controller Decorators" output="false" extends="coldbox.system.web.Controller">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
		
	<cffunction name="init" access="public" output="false" hint="constructor" returntype="ControllerDecorator">
		<!--- ************************************************************* --->
		<cfargument name="controller" 	type="any" 	required="true"	hint="The original ColdBox controller">
		<!--- ************************************************************* --->
		<cfscript>
			// Store Original Controller
			originalController = arguments.controller;
			// Store Original Controller Memento of instance data and services
			var memento = arguments.controller.getMemento();
			instance = memento.instance;
			services = memento.services;
			return this;
		</cfscript>		
	</cffunction>

	<!--- Get Original Controller --->
	<cffunction name="getController" access="public" output="false" returntype="any" hint="Get the original Controller object: coldbox.system.web.Controller">
		<cfreturn originalController/>
	</cffunction>	

	<!--- Configure --->
	<cffunction name="configure" access="public" returntype="void" hint="Override to provide a pseudo-constructor for your decorator" output="false" >
	</cffunction>
	
</cfcomponent>