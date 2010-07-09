<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	may 7, 2009
Description :
	This is a base abstract IOC Adapter

----------------------------------------------------------------------->
<cfcomponent name="AbstractIOCAdapter" 
			 hint="The ColdBox base IOC factory adapter in usage by the ioc plugin" 
			 output="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
	
	<cffunction name="init" access="public" returntype="AbstractIOCAdapter" hint="Constructor" output="false" >
		<cfargument name="coldbox" type="any" required="false" default="" hint="A coldbox application that this instance of logbox can be linked to, not used if not using within a ColdBox Application."/>
		<cfscript>
			instance 		 		= structnew();
			instance.coldbox 		= "";
			instance.factory 		= "";
			
			// Link to coldbox if passed
			if( isObject(arguments.coldbox) ){ instance.coldbox = arguments.coldbox; }
			
			return this;
		</cfscript>
	</cffunction>


<!----------------------------------------- PUBLIC ------------------------------------->	
	
	<!--- getColdBox --->
	<cffunction name="getColdBox" access="public" output="false" returntype="coldbox.system.web.Controller" hint="Get the ColdBox controller this adapter is linked to. If not linked and exception is thrown">
		<cfreturn instance.coldbox/>
	</cffunction>
	
	<!--- createFactory --->
	<cffunction name="createFactory" access="public" returntype="void" output="false" hint="Create the factory" >
	</cffunction>

	<!--- getFactory --->
	<cffunction name="getFactory" access="public" output="false" returntype="any" hint="Get the factory">
		<cfreturn instance.factory/>
	</cffunction>
	
	<!--- getBean --->
	<cffunction name="getBean" access="public" output="false" returntype="any" hint="Get a Bean from the object factory">
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">
	</cffunction>
	
	<!--- containsBean --->
	<cffunction name="containsBean" access="public" returntype="boolean" hint="Check if the bean factory contains a bean" output="false" >
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">	
	</cffunction>

	<!--- invokeFactoryMethod --->
	<cffunction name="invokeFactoryMethod" access="public" returntype="any" hint="Invoke a factory method in the bean factory. If the factory returns a void/null, this method returns void or null" output="false" >
		<cfargument name="method"   type="string" required="true" hint="The method to invoke">
		<cfargument name="args"  	type="struct" required="false" default="#structnew()#" hint="The arguments to pass into the method">
		<cfset var refLocal = structnew()>
		
		<cfinvoke component="#getFactory()#"
				  method="#arguments.method#"
				  argumentcollection="#arguments.args#"
				  returnvariable="refLocal.results">
		
		<cfif structKeyExists(refLocal,"results")>
			<cfreturn refLocal.results>
		</cfif>
	</cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>	
	
</cfcomponent>