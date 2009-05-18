<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Ben Garrett and Luis Majano
Date        :	18/05/2009
Version     :	2 (beta 18May09)
License		: 	Apache 2 License

EXTRAS

----------------------------------------------------------------------->
<cfcomponent name="FeedGenerator"
			 hint="xxx">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="FeedGenerator" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.Controller">
		<!--- ************************************************************* --->
		<cfscript>
		

			
			return this;
		</cfscript>
	</cffunction>

</cfcomponent>