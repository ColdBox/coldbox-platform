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
<cfcomponent name="ColdSpringAdapter" 
			 hint="The ColdBox ColdSpring IOC factory adapter"
			 extends="coldbox.system.ioc.AbstractIOCAdapter" 
			 output="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
	
	<cffunction name="init" access="public" returntype="ColdSpringAdapter" hint="Constructor" output="false" >
		<cfargument name="coldbox" type="any" required="false" default="" hint="A coldbox application that this instance of logbox can be linked to."/>
		<cfscript>
			super.init(argumentCollection=arguments);
			
			return this;
		</cfscript>
	</cffunction>


<!----------------------------------------- PUBLIC ------------------------------------->	

	<!--- createFactory --->
	<cffunction name="createFactory" access="public" returntype="void" hint="Create the ColdSpring Factory" output="false" >
		<cfscript>
			
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

<!----------------------------------------- PRIVATE ------------------------------------->	

	
	
</cfcomponent>