<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Date        :	01/10/2008
License		: 	Apache 2 License
Description :
	A facade to server so I can determine CF Version and Type.

----------------------------------------------------------------------->
<cfcomponent name="cfengine" 
			 extends="coldbox.system.plugin" 
			 output="false" 
			 hint="A facade to determine the current running CFML Version and Engine"
			 cache="true"
			 cacheTimeout="0">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="init" access="public" returntype="cfengine" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>			
			super.init(arguments.controller);
			
			/* internal properties */
			setpluginName("cfengine");
			setpluginVersion("1.0");
			setpluginDescription("Determines cf engine and type");
		
			/* Public Properties */
			this.ADOBE = "ADOBE";
			this.BLUEDRAGON = "BLUEDRAGON";
			this.RAILO = "RAILO";
			
			/* return instance. */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get the current CFML Version --->
	<cffunction name="getVersion" access="public" returntype="numeric" hint="Returns the current running CFML version" output="false" >
		<cfscript>
			return listfirst(server.coldfusion.productversion);
		</cfscript>
	</cffunction>
	
	<!--- Get the CFML Engine according to my standards --->
	<cffunction name="getEngine" access="public" returntype="string" hint="Get the current CFML Engine" output="false" >
		<cfscript>
			var engine = "ADOBE";
			
			if ( server.coldfusion.productname eq "BlueDragon" ){
				engine = "BLUEDRAGON";	
			}
			else if ( server.coldfusion.productname eq "Railo" ){
				engine = "RAILO";
			}
			
			return engine;
		</cfscript>
	</cffunction>	

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>