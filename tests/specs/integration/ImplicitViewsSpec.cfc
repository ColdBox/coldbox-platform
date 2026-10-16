/**
 * Implicit views resolve only from the declared view folders: the views convention, the external views location
 * and module views. Templates elsewhere under the app root are never chosen from the event name.
 * Fixtures: test-harness/handlers/implicitViews.cfc, test-harness/rootOnlyView.cfm,
 * test-harness/main/rootOnlyAction.cfm, test-harness/implicitViews/noView.cfm, test-harness/views/implicitViews/
 */
component extends="tests.resources.BaseIntegrationTest" {

	function run(){
		describe( "Implicit views", function(){
			beforeEach( function( currentSpec ){
				setup()
				// The harness leaves implicit views off. The renderer reads the setting, the handler service caches it.
				variables.handlerService  = getController().getHandlerService()
				variables.originalSetting = getController().getSetting( "ImplicitViews" )
				getController().setSetting( "ImplicitViews", true )
				prepareMock( variables.handlerService ).$property( "implicitViews", "variables", true )
			} )

			afterEach( function( currentSpec ){
				getController().setSetting( "ImplicitViews", variables.originalSetting )
				variables.handlerService.$property(
					"implicitViews",
					"variables",
					variables.originalSetting
				)
			} )

			describe( "dispatch from a declared view folder", function(){
				it( "renders a view in the views folder for a missing handler", function(){
					var e = execute( event = "simpleview", renderResults = true )
					expect( e.getRenderedContent() ).toInclude( "I am a simple view" )
				} )

				it( "renders a view in the external views location for a missing handler", function(){
					var e = execute( event = "externalview", renderResults = true )
					expect( e.getRenderedContent() ).toInclude( "I am an external view" )
				} )

				it( "renders a module view for a missing module handler", function(){
					var e = execute( event = "moduleLookup:module-level", renderResults = true )
					expect( e.getRenderedContent() ).toInclude( "This is a module level view" )
				} )

				it( "renders the views folder view of an action that sets no view", function(){
					var e = execute( event = "implicitViews.withView", renderResults = true )
					expect( e.getRenderedContent() ).toInclude( "IMPLICIT-WITH-VIEW-OK" )
				} )
			} )

			describe( "templates outside the declared view folders", function(){
				it( "are not dispatched for a missing handler", function(){
					var e = execute( event = "rootOnlyView", renderResults = true )
					expect( e.getPrivateValue( "invalidevent", "" ) ).toBe( "rootOnlyView" )
					expect( e.getStatusCode() ).toBe( 404 )
					expect( e.getRenderedContent() ).notToInclude( "ROOT-ONLY-VIEW" )
				} )

				it( "are not dispatched for a missing action", function(){
					var e = execute( event = "main.rootOnlyAction", renderResults = true )
					expect( e.getPrivateValue( "invalidevent", "" ) ).toBe( "main.rootOnlyAction" )
					expect( e.getStatusCode() ).toBe( 404 )
					expect( e.getRenderedContent() ).notToInclude( "ROOT-ONLY-ACTION" )
				} )

				it( "are not rendered for an action that sets no view", function(){
					expect( function(){
						execute( event = "implicitViews.noView", renderResults = true )
					} ).toThrow( type = "Renderer.ImplicitViewNotFoundException" )
				} )

				it( "still render when handler code selects them explicitly", function(){
					var e = execute( event = "implicitViews.explicitRoot", renderResults = true )
					expect( e.getRenderedContent() ).toInclude( "ROOT-ONLY-NO-VIEW" )
				} )
			} )
		} )
	}

}
