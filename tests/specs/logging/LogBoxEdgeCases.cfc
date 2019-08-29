/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

    function run( testResults, testBox ){
        // all your suites go here.
        describe( "LogBox edge cases", function(){
            story( "I want to load LogBox with no appenders", function(){
                given( "No appenders", function(){
                    then( "I can start LogBox", function(){
                        var config = new coldbox.system.logging.config.LogBoxConfig();
                        var logbox = new coldbox.system.logging.LogBox( config );

                        var logger = logBox.getLogger( "MyCat" );
                        expect( logger ).toBeComponent();
                        // if we run then we are ok, we can log with no appenders
                        logger.info( "Test" );
                    } );
                } );
            } );
        } );
    }

}
