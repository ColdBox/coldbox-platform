/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

    /*********************************** BDD SUITES ***********************************/

    function run( testResults, testBox ){
        // all your suites go here.
        describe( "Injector creation suite", function(){
            story( "I want to create an Injector", function(){
                given( "an instance of a binder", function(){
                    then( "I should create the injector successfully.", function(){
                        new coldbox.system.ioc.Injector(
                            createObject( "component", "coldbox.system.ioc.config.DefaultBinder" )
                        );
                    } );
                } );

                given( "a path to a binder", function(){
                    then( "I should create the injector successfully", function(){
                        new coldbox.system.ioc.Injector( "coldbox.system.ioc.config.DefaultBinder" );
                    } );
                } );

                given( "no binder", function(){
                    then( "I should create the injector with the default binder", function(){
                        new coldbox.system.ioc.Injector();
                    } );
                } );
            } );
        } );
    }

}
