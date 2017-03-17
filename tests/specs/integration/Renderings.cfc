/*******************************************************************************
*	Integration Test as BDD (CF10+ or Railo 4.1 Plus)
*
*	Extends the integration class: coldbox.system.testing.BaseTestCase
*
*	so you can test your ColdBox application headlessly. The 'appMapping' points by default to 
*	the '/root' mapping created in the test folder Application.cfc.  Please note that this 
*	Application.cfc must mimic the real one in your root, including ORM settings if needed.
*
*	The 'execute()' method is used to execute a ColdBox event, with the following arguments
*	* event : the name of the event
*	* private : if the event is private or not
*	* prePostExempt : if the event needs to be exempt of pre post interceptors
*	* eventArguments : The struct of args to pass to the event
*	* renderResults : Render back the results of the event
*******************************************************************************/
component extends="coldbox.system.testing.BaseTestCase" appMapping="/cbTestHarness"{
	
	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		reset();
		super.beforeAll();
		// do your own stuff here
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	/**
	 * after renderer init
	 */
	function afterRendererInit( event, interceptData ){
		arguments.interceptData.this.bdd = this;
	}

/*********************************** BDD SUITES ***********************************/
	
	function run(){

		describe( "ColdBox Rendering", function(){

			beforeEach(function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			});

			story( "I want to return the `event` object in any handler", function(){
				given( "You return the `event` object", function(){
					then( "ColdBox should just ignore it as a return marshalling object", function(){
						var e = execute( event="rendering.returnEvent", renderResults=true );
						expect(	e.getRenderedContent() )
							.toInclude( "I can return the event!" );
					});
				
				});
			
			});

			story( "I want to listen to when the renderer is created", function(){
				given( "A new renderer", function(){
					then( "I can listen to renderer creations", function(){
						getController().getInterceptorService().registerInterceptor( interceptorObject=this );
						var renderer = getController().getRenderer();
						expect(	renderer ).toHaveKey( "bdd" );
					});
				});
			});

			story( "I want to be able to render multiple rendering regions", function(){
				given( "a rendering region to setView()", function(){
					then( "it should render using only its name", function(){
						var e = execute( event="rendering.renderingRegions", renderResults=true );
						expect(	e.getRenderedContent() )
							.toInclude( "View with args: true" )
							.toInclude( "Welcome to my main inception module page!" );
					});
				});
				given( "an invalid rendering region to renderview", function(){
					then( "it should throw an exception", function(){
						expect(	function(){
							controller.getRenderer().renderView( name="invalid" );
						} ).toThrow( type="InvalidRenderingRegion" );
					});
				});
			} );

		});

	}
	
}