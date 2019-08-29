/**
 * My BDD Test
 */
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.aop.aspects.CFTransaction" {

    /*********************************** LIFE CYCLE Methods ***********************************/

    // executes before all suites+specs in the run() method
    function beforeAll(){
        super.setup();
        model.init();
        // mockings
        mockLogger = createEmptyMock( "coldbox.system.logging.Logger" )
            .$( "canDebug", true )
            .$( "error" )
            .$( "debug" );

        model.$property( "log", "variables", mockLogger );
    }

    // executes after all suites+specs in the run() method
    function afterAll(){
        super.afterAll();
    }

    /*********************************** BDD SUITES ***********************************/

    function run( testResults, testBox ){
        // all your suites go here.
        describe( "CF Transaction aspect", function(){
            it( "can invoke with transaction on request", function(){
                var mockInvocation = createEmptyMock( "coldbox.system.aop.MethodInvocation" )
                    .$( "getTargetName", "MyMock" )
                    .$( "getMethod", "execute" )
                    .$( "proceed", "called" );

                request[ "cbox_aop_transaction" ] = true;

                var results = model.invokeMethod( mockInvocation );
                expect( results ).toBe( "called" );
                expect( mockLogger.$once( "debug" ) ).toBeTrue();
            } );

            it( "can invoke with no transaction on request", function(){
                var mockInvocation = createEmptyMock( "coldbox.system.aop.MethodInvocation" )
                    .$( "getTargetName", "MyMock" )
                    .$( "getMethod", "execute" )
                    .$( "proceed", "called" );

                var results = model.invokeMethod( mockInvocation );
                expect( results ).toBe( "called" );
            } );
        } );
    }

}
