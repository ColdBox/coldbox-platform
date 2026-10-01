/**
 * The BrowserTesting core module: test-only login and logout endpoints and their security checks
 */
component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "BrowserTesting core module", () => {
			beforeEach( ( currentSpec ) => {
				setup()
				variables.settings            = getController().getModuleSettings( "BrowserTesting" )
				variables.originalSettings    = structCopy( variables.settings )
				variables.originalEnvironment = getController().getSetting( "environment" )
				// A fully enabled module whose closures record their calls
				request.browserTestingCalls   = []
				variables.settings.enabled    = true
				variables.settings.token      = "unit-test-token"
				variables.settings.login      = function( id, event, rc, prc ){
					request.browserTestingCalls.append( { action : "login", id : arguments.id } )
				}
				variables.settings.logout = function( event, rc, prc ){
					request.browserTestingCalls.append( { action : "logout" } )
				}
				getController().setSetting( "environment", "testing" )
			} )

			afterEach( ( currentSpec ) => {
				structClear( variables.settings )
				structAppend(
					variables.settings,
					variables.originalSettings,
					true
				)
				getController().setSetting( "environment", variables.originalEnvironment )
			} )

			it( "is registered as a core module with the __browser-testing entry point", () => {
				var config = getController().getSetting( "modules" )
				expect( config ).toHaveKey( "BrowserTesting" )
				expect( config.BrowserTesting.entryPoint ).toBe( "__browser-testing" )
				expect( config.BrowserTesting.path ).toInclude( "system" )
			} )

			it( "is disabled by default with an empty token and no closures", () => {
				var config = prepareMock( new coldbox.system.modules.BrowserTesting.ModuleConfig() )
				config.configure()
				var defaults = config.$getProperty( "settings" )
				expect( defaults.enabled ).toBeFalse()
				expect( defaults.token ).toBe( "" )
				expect( defaults.login ).toBe( "" )
				expect( defaults.logout ).toBe( "" )
			} )

			it( "takes the application overrides from moduleSettings.browserTesting", () => {
				expect( variables.originalSettings.enabled ).toBeTrue()
				expect( variables.originalSettings.token ).toBe( "coldbox-test-harness-browser-token" )
				var login = variables.originalSettings.login
				expect( isClosure( login ) || isCustomFunction( login ) ).toBeTrue()
			} )

			it( "logs in through the login closure with the token in the request", () => {
				var event = get( route = "/__browser-testing/login/42", params = { token : "unit-test-token" } )
				expect( event.getStatusCode() ).toBe( 200 )
				expect( event.getRenderedContent() ).toBe( "OK" )
				expect( request.browserTestingCalls ).toHaveLength( 1 )
				expect( request.browserTestingCalls[ 1 ].action ).toBe( "login" )
				expect( request.browserTestingCalls[ 1 ].id ).toBe( 42 )
			} )

			it( "logs in with the token in the X-Browser-Testing-Token header", () => {
				var event = getRequestContext()
				prepareMock( event )
					.$( "getHTTPHeader" )
					.$args( "X-Browser-Testing-Token", "" )
					.$results( "unit-test-token" )
				event = get( route = "/__browser-testing/login/7" )
				expect( event.getStatusCode() ).toBe( 200 )
				expect( request.browserTestingCalls ).toHaveLength( 1 )
				expect( request.browserTestingCalls[ 1 ].id ).toBe( 7 )
			} )

			it( "logs out through the logout closure", () => {
				var event = get( route = "/__browser-testing/logout", params = { token : "unit-test-token" } )
				expect( event.getStatusCode() ).toBe( 200 )
				expect( request.browserTestingCalls ).toHaveLength( 1 )
				expect( request.browserTestingCalls[ 1 ].action ).toBe( "logout" )
			} )

			it( "answers 404 outside the testing environment", () => {
				getController().setSetting( "environment", "development" )
				expectNotFound( "/__browser-testing/login/1", { token : "unit-test-token" } )
				getController().setSetting( "environment", "production" )
				expectNotFound( "/__browser-testing/logout", { token : "unit-test-token" } )
			} )

			it( "answers 404 when disabled", () => {
				variables.settings.enabled = false
				expectNotFound( "/__browser-testing/login/1", { token : "unit-test-token" } )
				variables.settings.enabled = "yes please"
				expectNotFound( "/__browser-testing/login/1", { token : "unit-test-token" } )
			} )

			it( "answers 404 when no token is configured, even for an empty request token", () => {
				variables.settings.token = ""
				expectNotFound( "/__browser-testing/login/1", { token : "" } )
				expectNotFound( "/__browser-testing/login/1", {} )
			} )

			it( "answers 404 for a missing or wrong request token", () => {
				expectNotFound( "/__browser-testing/login/1", {} )
				expectNotFound( "/__browser-testing/login/1", { token : "wrong-token" } )
				expectNotFound( "/__browser-testing/login/1", { token : "unit-test-toke" } )
				expectNotFound( "/__browser-testing/logout", { token : "UNIT-TEST-TOKEN" } )
			} )

			it( "answers 404 when the closure of the endpoint is not set", () => {
				variables.settings.login = ""
				expectNotFound( "/__browser-testing/login/1", { token : "unit-test-token" } )
				variables.settings.logout = "not a closure"
				expectNotFound( "/__browser-testing/logout", { token : "unit-test-token" } )
			} )

			it( "guards the convention route of the module too", () => {
				variables.settings.enabled = false
				expectNotFound( "/__browser-testing/auth/login", { token : "unit-test-token", id : 1 } )
			} )

			it( "only accepts GET requests", () => {
				var event = this.post(
					route  = "/__browser-testing/login/1",
					params = { token : "unit-test-token" }
				)
				expect( event.getRenderedContent() ).notToBe( "OK" )
				expect( request.browserTestingCalls ).toBeEmpty()
			} )

			it( "builds its named routes under the entry point", () => {
				var link = getRequestContext().route( "login@BrowserTesting", { id : 3 } )
				expect( link ).toInclude( "/__browser-testing/login/3" )
				expect( getRequestContext().route( "logout@BrowserTesting" ) ).toInclude( "/__browser-testing/logout" )
			} )
		} )
	}

	/**
	 * Execute a GET request and expect the plain 404 of the module, without any closure call
	 *
	 * @route  The route to execute
	 * @params The request parameters
	 */
	private function expectNotFound( required string route, struct params = {} ){
		var event = get( route = arguments.route, params = arguments.params )
		expect( event.getStatusCode() ).toBe(
			404,
			"Expected a 404 for #arguments.route# #serializeJSON( arguments.params )#"
		)
		expect( event.getRenderedContent() ).toBe( "Not Found" )
		expect( request.browserTestingCalls ).toBeEmpty()
		setup()
	}

}
