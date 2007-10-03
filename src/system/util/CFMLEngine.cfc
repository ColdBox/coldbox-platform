<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	A facade to server so I can determine CF Version and Type
----------------------------------------------------------------------->
<cfcomponent name="CFMLEngine" output="false" hint="A facade to determine the current running CFML Version and Engine">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="init" access="public" returntype="CFMLEngine" output="false" hint="Constructor">
		<cfscript>
			//setup the engine properties
			this.ADOBE = "ADOBE";
			this.BLUEDRAGON = "BLUEDRAGON";
			this.RAILO = "RAILO";
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