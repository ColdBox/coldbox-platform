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
	
	<cfscript>
	instance = structnew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="AbstractIOCAdapter" hint="Constructor" output="false" >
		<cfargument name="controller"  type="coldbox.system.web.Controller" required="true" hint="The ColdBox controller">
		<cfargument name="IOCPlugin"   type="coldbox.system.plugins.IOC" required="true" hint="The IOC plugin object">
		<cfscript>
		instance.controller = arguments.controller;
		instance.IOCPlugin = arguments.IOCPlugin;
		return this;
		</cfscript>
	</cffunction>


<!----------------------------------------- PUBLIC ------------------------------------->	

	<cffunction name="createFactory" access="public" returntype="void" hint="Create the factory" output="false" >
	</cffunction>

	<cffunction name="getbeanFactory" access="public" output="false" returntype="any" hint="Get the bean factory">
		<cfreturn instance.beanFactory/>
	</cffunction>
	
	<cffunction name="getBean" access="public" output="false" returntype="any" hint="Get a Bean from the object factory">
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">
	</cffunction>
	
	<cffunction name="containsBean" access="public" returntype="boolean" hint="Check if the bean factory contains a bean" output="false" >
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">	
	</cffunction>

	<cffunction name="invokeFactoryMethod" access="public" returntype="any" hint="Invoke a factory method in the bean factory. If the factory returns a void/null, this method returns void or null" output="false" >
		<cfargument name="method"   type="string" required="true" hint="The method to invoke">
		<cfargument name="args"  	type="struct" required="false" default="#structnew()#" hint="The arguments to pass into the method">
		<cfset var results = 0>
		
		<cfinvoke component="#getBeanFactory()#"
				  method="#arguments.method#"
				  argumentcollection="#arguments.args#"
				  returnvariable="results">
				  
		<cfreturn results>
	</cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	

	<cffunction name="getcontroller" access="private" output="false" returntype="coldbox.system.web.Controller" hint="Get the ColdBox controller">
		<cfreturn instance.controller/>
	</cffunction>
	
	<cffunction name="getIOCPlugin" access="private" output="false" returntype="coldbox.system.plugins.IOC" hint="Get IOCPlugin">
		<cfreturn instance.IOCPlugin/>
	</cffunction>
	
</cfcomponent>