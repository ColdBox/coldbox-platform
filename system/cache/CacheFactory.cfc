<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	may 7, 2009
Description :
	This is a cfc that handles the creation and management of caches


----------------------------------------------------------------------->
<cfcomponent name="CacheFactory" 
			 hint="The ColdBox Cache Factory" 
			 output="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
	
	<cfscript>
	instance = structnew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="CacheFactory" hint="Constructor" output="false" >
		<cfscript>
		instance.CFMLEngine = createObject("component","coldbox.system.core.util.CFMLEngine").init();
		
		return this;
		</cfscript>
	</cffunction>


<!----------------------------------------- PUBLIC ------------------------------------->	


<!----------------------------------------- PRIVATE ------------------------------------->	

	
</cfcomponent>