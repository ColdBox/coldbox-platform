<cfcomponent extends="coldbox.system.testing.BaseTestCase">
	

	<!--- mockPluginMethods --->
    <cffunction name="mockPluginMethods" output="false" access="private" returntype="void" hint="">
    	<cfargument name="plugin" type="any" required="true" default="" hint=""/>
    	<cfscript>
    		var p = arguments.plugin;
			
			p.$("setPluginName");
			p.$("setPluginAuthor");
			p.$("setPluginAuthorURL");
			p.$("setPluginDescription");
			p.$("setPluginVersion");
			
		</cfscript>
    </cffunction>

</cfcomponent>
