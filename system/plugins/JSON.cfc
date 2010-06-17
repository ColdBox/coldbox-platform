<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Serialize and deserialize JSON data into native ColdFusion objects
http://www.epiphantastic.com/cfjson/

Authors: Jehiah Czebotar (jehiah@gmail.com)
         Thomas Messier  (thomas@epiphantastic.com)
Version: 1.9 February 20, 2008

Modifications:
	- Contributed by Ernst van der Linden (evdlinden@gmail.com) ]
	- Sana Ullah (adjusted the compatibility with coldbox plugins).
	- Luis Majano (adaptations & best practices)
----------------------------------------------------------------------->
<cfcomponent name="JSON"
			 hint="JSON Plugin is used to serialize and deserialize JSON data to/from native ColdFusion objects."
			 extends="coldbox.system.core.conversion.JSON"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="JSON" output="false">
		<cfscript>
			
			super.init();
			
			// Decorated ColdBox Plugin Methods thanks to new 3.0.0 zero inheritance
			setpluginName("JSON");
			setpluginVersion("1.9");
			setpluginDescription("JSON Plugin is used to serialize and deserialize JSON data to/from native ColdFusion objects");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	
</cfcomponent>