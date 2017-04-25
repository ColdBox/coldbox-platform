component extends="coldbox.system.testing.BaseInterceptorTest" interceptor="coldbox.system.interceptors.SES"{

    function beforeAll() {
        super.setup();
        variables.ses = variables.interceptor;
    }

    function run() {
        describe( "SES addResource", function(){
            beforeEach( function(){
                ses.$reset();
                ses.$("addRoute");
            } );
            it( "can add all the RESTful routes for a resource", function() {
                ses.addResource( "photos" );

                var cl = ses.$callLog().addRoute;

                expect( cl ).toHaveLength( 4, "addRoute should have been called 4 times" );
                expect( cl ).toHaveLength( 4, "addRoute should have been called 4 times" );
                expect( cl[ 1 ] ).toBe( { pattern = "/photos/:id/edit", handler = "photos", action = { GET = "edit" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                expect( cl[ 2 ] ).toBe( { pattern = "/photos/new", handler = "photos", action = { GET = "new" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                expect( cl[ 3 ] ).toBe( { pattern = "/photos/:id", handler = "photos", action = { GET = "show", PUT = "update", PATCH = "update", DELETE = "delete" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                expect( cl[ 4 ] ).toBe( { pattern = "/photos", handler = "photos", action = { GET = "index", POST = "create" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
            } );

            it( "can override the handler used", function() {
                ses.addResource( "photos", "PhotosController" );

                var cl = ses.$callLog().addRoute;
                debug( cl );

                expect( cl ).toHaveLength( 4, "addRoute should have been called 4 times" );
                expect( cl[ 1 ] ).toBe( { pattern = "/photos/:id/edit", handler = "PhotosController", action = { GET = "edit" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                expect( cl[ 2 ] ).toBe( { pattern = "/photos/new", handler = "PhotosController", action = { GET = "new" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                expect( cl[ 3 ] ).toBe( { pattern = "/photos/:id", handler = "PhotosController", action = { GET = "show", PUT = "update", PATCH = "update", DELETE = "delete" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                expect( cl[ 4 ] ).toBe( { pattern = "/photos", handler = "PhotosController", action = { GET = "index", POST = "create" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
            } );

            describe( "limiting the routes created by action", function() {
                describe( "using the `only` parameter", function() {
                    it( "can take a list of actions and only generate those routes", function() {
                        ses.addResource( name = "photos", only = "index,show" );

                        var cl = ses.$callLog().addRoute;
                        debug( cl );

                        expect( cl ).toHaveLength( 2, "addRoute should have been called 2 times" );
                        expect( cl[ 1 ] ).toBe( { pattern = "/photos/:id", handler = "photos", action = { GET = "show" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                        expect( cl[ 2 ] ).toBe( { pattern = "/photos", handler = "photos", action = { GET = "index" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                    } );

                    it( "can take an array of actions and only generate those routes", function() {
                        ses.addResource( name = "photos", only = [ "index", "show" ] );

                        var cl = ses.$callLog().addRoute;
                        debug( cl );

                        expect( cl ).toHaveLength( 2, "addRoute should have been called 2 times" );
                        expect( cl[ 1 ] ).toBe( { pattern = "/photos/:id", handler = "photos", action = { GET = "show" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                        expect( cl[ 2 ] ).toBe( { pattern = "/photos", handler = "photos", action = { GET = "index" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                    } );
                } );

                describe( "using the `except` parameter", function() {
                    it( "can take a list of actions and generate all except those routes", function() {
                        ses.addResource( name = "photos", except = "create,edit,update,delete" );

                        var cl = ses.$callLog().addRoute;
                        debug( cl );

                        expect( cl ).toHaveLength( 3, "addRoute should have been called 3 times" );
                        expect( cl[ 1 ] ).toBe( { pattern = "/photos/new", handler = "photos", action = { GET = "new" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                        expect( cl[ 2 ] ).toBe( { pattern = "/photos/:id", handler = "photos", action = { GET = "show" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                        expect( cl[ 3 ] ).toBe( { pattern = "/photos", handler = "photos", action = { GET = "index" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                    } );

                    it( "can take an array of actions and generate all except those routes", function() {
                        ses.addResource( name = "photos", except = [ "create", "edit", "update", "delete" ] );

                        var cl = ses.$callLog().addRoute;
                        debug( cl );

                        expect( cl ).toHaveLength( 3, "addRoute should have been called 3 times" );
                        expect( cl[ 1 ] ).toBe( { pattern = "/photos/new", handler = "photos", action = { GET = "new" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                        expect( cl[ 2 ] ).toBe( { pattern = "/photos/:id", handler = "photos", action = { GET = "show" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                        expect( cl[ 3 ] ).toBe( { pattern = "/photos", handler = "photos", action = { GET = "index" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                    } );
                } );

                describe( "using both `only` and `except`", function() {
                    it( "can apply both the `only` and the `except` parameters", function() {
                        ses.addResource( name = "photos", only = [ "index", "show" ], except = "show" )

                        var cl = ses.$callLog().addRoute;
                        debug( cl );

                        expect( cl ).toHaveLength( 1, "addRoute should have been called 1 time" );
                        expect( cl[ 1 ] ).toBe( { pattern = "/photos", handler = "photos", action = { GET = "index" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                    } );
                } );
            } );

            it( "can override the parameterName used", function() {
                ses.addResource( name = "photos", parameterName = "photoId" );

                var cl = ses.$callLog().addRoute;
                debug( cl );

                expect( cl ).toHaveLength( 4, "addRoute should have been called 4 times" );
                expect( cl[ 1 ] ).toBe( { pattern = "/photos/:photoId/edit", handler = "photos", action = { GET = "edit" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                expect( cl[ 2 ] ).toBe( { pattern = "/photos/new", handler = "photos", action = { GET = "new" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                expect( cl[ 3 ] ).toBe( { pattern = "/photos/:photoId", handler = "photos", action = { GET = "show", PUT = "update", PATCH = "update", DELETE = "delete" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
                expect( cl[ 4 ] ).toBe( { pattern = "/photos", handler = "photos", action = { GET = "index", POST = "create" } }, "The route did not match.  Remember that order matters.  Add the most specific routes first." );
            } );

            it( "returns itself to continue chaining", function() {
                var result = ses.addResource( "photos" );

                expect( result ).toBe( ses );
            } );
        } );
    }

}