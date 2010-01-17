<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	may 7, 2009
Description :
	This is a concrete LightWire Adapter


----------------------------------------------------------------------->
<cfcomponent name="LightWireAdapter" 
			 hint="The ColdBox LightWire IOC factory adapter" 
			 output="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
	
	<cffunction name="init" access="public" returntype="LightWireAdapter" hint="Constructor" output="false" >
		<cfargument name="controller"  type="coldbox.system.web.Controller" required="true" hint="The ColdBox controller">
		<cfscript>
		super.init(argumentCollection=arguments);
		
		return this;
		</cfscript>
	</cffunction>


<!----------------------------------------- PUBLIC ------------------------------------->	

	<cffunction name="createFactory" access="public" returntype="void" hint="Create the ColdSpring Factory" output="false" >
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

<!----------------------------------------- PRIVATE ------------------------------------->	


	
</cfcomponent>