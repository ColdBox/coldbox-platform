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
			 extends="coldbox.system.ioc.AbstractIOCAdapter" 
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


<!----------------------------------------- PRIVATE ------------------------------------->	


	
</cfcomponent>