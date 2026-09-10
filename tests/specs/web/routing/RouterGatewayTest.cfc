/**
 * AI Gateway Routing Tests — covers the toAiGateway() terminator
 */
component extends="coldbox.system.testing.BaseModelTest" skip="notBoxlang" {

	boolean function notBoxlang(){
		return !isBoxLang()
	}

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll()
		// Controller mock with bxai module registered so ensureBoxLang() passes
		variables.controller = createMock( "coldbox.system.web.Controller" )
			.init( expandPath( "/coldbox/test-harness" ), "cbController" )
			.setSetting( "AppMapping", "" )
			.setSetting( "RoutingAppMapping", "/" )
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		if ( notBoxlang() ) {
			return;
		}

		describe( "AI Gateway Routing — toAiGateway()", function(){
			beforeEach( function(){
				variables.router = createMock( "coldbox.system.web.routing.Router" )
					.init()
					.setController( controller )
					.setLogBox( controller.getLogBox() )
					.setLog( controller.getLogBox().getLogger( this ) )
					.setCacheBox( controller.getCacheBox() )
					.setWireBox( controller.getWireBox() )
			} )

			story( "I want to expose a gateway surface behind a base route pattern", function(){
				given( "no gateway name", function(){
					then( "it should register the sub-route family with a :gateway placeholder", function(){
						router.route( "/gateways" ).toAiGateway()

						var routes   = router.getRoutes()
						var patterns = routes.map( ( r ) => r.pattern )

						expect( routes ).toHaveLength( 4 )
						expect( patterns ).toInclude( "gateways/:gateway/events/" )
						expect( patterns ).toInclude( "gateways/interactions/:requestID/" )
						expect( patterns ).toInclude( "gateways/interactions/:requestID/decisions/" )
						expect( patterns ).toInclude( "gateways/info/" )
					} )
				} )

				given( "a pinned gateway name", function(){
					then( "the events route should carry no placeholder", function(){
						router.route( "/webhooks/slack" ).toAiGateway( "slack" )

						var patterns = router.getRoutes().map( ( r ) => r.pattern )

						expect( patterns ).toInclude( "webhooks/slack/events/" )
						expect( patterns ).notToInclude( "webhooks/slack/:gateway/events/" )
					} )

					then( "every sub-route should carry gateway=true and the gateway name", function(){
						router.route( "/webhooks/slack" ).toAiGateway( "slack" )

						var routes = router.getRoutes()
						routes.each( ( r ) => {
							expect( r.gateway ).toBeTrue()
							expect( r.gatewayName ).toBe( "slack" )
						} )
					} )
				} )

				given( "a session WireBox id", function(){
					then( "every sub-route should carry it as gatewaySession", function(){
						router.route( "/gateways" ).toAiGateway( session = "SupportAgentSession" )

						var routes = router.getRoutes()
						routes.each( ( r ) => {
							expect( r.gatewaySession ).toBe( "SupportAgentSession" )
						} )
					} )
				} )

				given( "a registered gateway route family", function(){
					then( "the events route should answer both GET and POST", function(){
						router.route( "/gateways" ).toAiGateway()

						var routes      = router.getRoutes()
						var eventsRoute = routes.filter( ( r ) => r.pattern == "gateways/:gateway/events/" )[ 1 ]

						expect( eventsRoute.verbs ).toBe( "GET,POST" )
					} )

					then( "interactions should be GET, decisions POST, and info GET", function(){
						router.route( "/gateways" ).toAiGateway()

						var byPattern = {}
						var routes    = router.getRoutes()
						routes.each( ( r ) => {
							byPattern[ r.pattern ] = r;
						} )

						expect( byPattern[ "gateways/interactions/:requestID/" ].verbs ).toBe( "GET" )
						expect( byPattern[ "gateways/interactions/:requestID/decisions/" ].verbs ).toBe( "POST" )
						expect( byPattern[ "gateways/info/" ].verbs ).toBe( "GET" )
					} )
				} )

				given( "a named base route", function(){
					then( "sub-routes should inherit the base name as a prefix", function(){
						router.route( pattern = "/gateways", name = "gw" ).toAiGateway()

						var names = router.getRoutes().map( ( r ) => r.name )

						expect( names ).toInclude( "gw.gateway.events" )
						expect( names ).toInclude( "gw.gateway.interaction" )
						expect( names ).toInclude( "gw.gateway.decision" )
						expect( names ).toInclude( "gw.gateway.info" )
					} )
				} )

				given( "a base route with withSSL() set", function(){
					then( "all sub-routes should inherit ssl=true", function(){
						router
							.route( "/gateways" )
							.withSSL()
							.toAiGateway()

						var routes = router.getRoutes()
						routes.each( ( r ) => {
							expect( r.ssl ).toBeTrue()
						} )
					} )
				} )

				given( "a base route with withCondition() set", function(){
					then( "all sub-routes should inherit the condition", function(){
						router
							.route( "/gateways" )
							.withCondition( ( route, params, event ) => true )
							.toAiGateway()

						var routes = router.getRoutes()
						routes.each( ( r ) => {
							expect( isClosure( r.condition ) || isCustomFunction( r.condition ) ).toBeTrue()
						} )
					} )
				} )
			} )

			story( "I want argument validation on toAiGateway()", function(){
				given( "a numeric value as session", function(){
					then( "it should throw InvalidArgumentException", function(){
						expect( function(){
							router.route( "/gateways" ).toAiGateway( "slack", 123 )
						} ).toThrow( "InvalidArgumentException" )
					} )
				} )

				given( "an array as session", function(){
					then( "it should throw InvalidArgumentException", function(){
						expect( function(){
							router.route( "/gateways" ).toAiGateway( "slack", [] )
						} ).toThrow( "InvalidArgumentException" )
					} )
				} )
			} )

			story( "I want the gateway name and session resolved per request", function(){
				beforeEach( function(){
					makePublic( router, "resolveGatewayName" )
					makePublic( router, "resolveGatewaySession" )
				} )

				given( "a pinned gateway name", function(){
					then( "it wins over anything in the request collection", function(){
						expect( router.resolveGatewayName( "slack", { "gateway" : "spoofed" } ) ).toBe( "slack" )
					} )
				} )

				given( "no pinned gateway name", function(){
					then( "the matched :gateway placeholder is used", function(){
						expect( router.resolveGatewayName( "", { "gateway" : "telegram" } ) ).toBe( "telegram" )
					} )

					then( "an absent placeholder resolves to an empty name", function(){
						expect( router.resolveGatewayName( "", {} ) ).toBe( "" )
					} )
				} )

				given( "no session", function(){
					then( "it resolves to null, meaning parse without dispatching", function(){
						expect( isNull( router.resolveGatewaySession( "" ) ) ).toBeTrue()
					} )
				} )

				given( "a live session instance", function(){
					then( "it is used as-is, with no WireBox lookup", function(){
						var fakeSession = createStub()
						expect( router.resolveGatewaySession( fakeSession ) ).toBe( fakeSession )
					} )
				} )
			} )
		} )
	}

}
