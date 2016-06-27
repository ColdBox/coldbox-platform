<cfscript>

addRoute( pattern="/", handler="test", action="index" );
addRoute( pattern="/:handler/:action?" );

</cfscript>