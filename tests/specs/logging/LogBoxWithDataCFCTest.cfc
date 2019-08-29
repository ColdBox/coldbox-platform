<cfcomponent extends="coldbox.system.testing.BaseModelTest">
    <cfscript>
    function setup(){
        // LogBox
        logbox = createMock( className = "coldbox.system.logging.LogBox" );
    }

    function testLoader(){
        // My Data Object
        dataConfig = createObject( "component", "coldbox.tests.specs.logging.config.LogBoxConfig" );
        // Config LogBox
        config = createObject( "component", "coldbox.system.logging.config.LogBoxConfig" ).init(
            CFCConfig = dataConfig
        );
        // Create it
        logBox.init( config );
    }

    function testLoader2(){
        // Config LogBox
        config = createObject( "component", "coldbox.system.logging.config.LogBoxConfig" ).init(
            CFCConfigPath = "coldbox.tests.specs.logging.config.LogBoxConfig"
        );
        // Create it
        logBox.init( config );
    }
    </cfscript>
</cfcomponent>
