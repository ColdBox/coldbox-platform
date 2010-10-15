<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	may 7, 2009
Description :
	This is a concrete ColdSpring Adapter

----------------------------------------------------------------------->
<cfcomponent hint="The ColdBox ColdSpring IOC factory adapter"
			 extends="coldbox.system.ioc.AbstractIOCAdapter" 
			 output="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
	
	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="ColdSpringAdapter" hint="Constructor" output="false" >
		<cfargument name="definitionFile" 	type="string" 	required="false" default="" hint="The definition file to load a factory with"/>
		<cfargument name="properties" 		type="struct" 	required="false" default="#structNew()#" hint="Properties to pass to the factory to create"/>
		<cfargument name="coldbox" 			type="any" 		required="false" default="" hint="A coldbox application that this instance of logbox can be linked to, not used if not using within a ColdBox Application."/>
		<cfscript>
			super.init(argumentCollection=arguments);
			
			// ColdSpring Factory Path
			instance.COLDSPRING_FACTORY_PATH = "coldspring.beans.DefaultXmlBeanFactory";
			
			return this;
		</cfscript>
	</cffunction>

<!----------------------------------------- PUBLIC ------------------------------------->	

	<!--- createFactory --->
	<cffunction name="createFactory" access="public" returntype="void" hint="Create the ColdSpring Factory" output="false" >
		<cfscript>
			var properties = getProperties();
			
			//Create the Coldspring Factory
			instance.factory = createObject("component", instance.COLDSPRING_FACTORY_PATH ).init(structnew(),properties);
			
			// Load Bean Definitions
			instance.factory.loadBeans( getDefinitionFile() );
		</cfscript>
	</cffunction>

	<!--- getBean --->
	<cffunction name="getBean" access="public" output="false" returntype="any" hint="Get a Bean from the object factory">
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">
		<cfscript>
			return getFactory().getBean(arguments.beanName);
		</cfscript>
	</cffunction>
	
	<!--- containsBean --->
	<cffunction name="containsBean" access="public" returntype="boolean" hint="Check if the bean factory contains a bean" output="false" >
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">	
		<cfscript>
			return getFactory().containsBean(arguments.beanName);
		</cfscript>
	</cffunction>
	
	<!--- setParentFactory --->
    <cffunction name="setParentFactory" output="false" access="public" returntype="void" hint="Set a parent factory on the adapted factory">
    	<cfargument name="parent" type="any" required="true" hint="The parent factory to add"/>
  		<cfset getFactory().setParent( arguments.parent )>
    </cffunction>
	
	<!--- getParentFactory --->
    <cffunction name="getParentFactory" output="false" access="public" returntype="any" hint="Get the parent factory">
    	<cfreturn getFactory().getParent()>
    </cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	
	
</cfcomponent>