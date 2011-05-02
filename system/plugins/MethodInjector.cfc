<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	This is a method injector based on the work by Mark Mandel and ColdBox
----------------------------------------------------------------------->
<cfcomponent hint="It provides a nice way to mixin and remove methods from cfc's"
			 extends="coldbox.system.core.dynamic.MixerUtil"
			 output="false"
			 singleton>

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="MethodInjector" output="false" hint="Constructor">
		<cfscript>
			
			// Plugin Properties
			setPluginName("Method Injector");
			setPluginVersion("2.0");
			setPluginDescription("A way to inject and remove methods from cfc's");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			
			// init super
			super.init();
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC METHODS ------------------------------------------->

</cfcomponent>