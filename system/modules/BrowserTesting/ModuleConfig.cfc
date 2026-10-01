/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Browser Testing core module: test-only login and logout endpoints that browser tests
 * (coldbox.system.testing.BrowserTestCase) call through loginAs() and logout().
 *
 * Routes, under the `__browser-testing` entry point:
 * - GET /__browser-testing/login/:id : calls the `login` closure with ( id, event, rc, prc )
 * - GET /__browser-testing/logout    : calls the `logout` closure with ( event, rc, prc )
 *
 * Settings, overridden by the application in config/ColdBox.cfc:
 *
 * <pre>
 * moduleSettings = {
 *     browserTesting : {
 *         enabled : true,
 *         token   : getSystemSetting( "BROWSER_TESTING_TOKEN", "" ),
 *         login   : ( id, event, rc, prc ) => auth().login( userService.get( id ) ),
 *         logout  : ( event, rc, prc ) => auth().logout()
 *     }
 * }
 * </pre>
 *
 * Security model: the endpoints log anyone in as any user, so they are locked down by default and
 * every request must pass ALL of these checks, else it gets a plain `404 Not Found`, exactly like a
 * missing page, and no closure runs:
 * - The application environment (the `environment` setting) is `testing`
 * - The `enabled` setting is `true` (it defaults to `false`)
 * - The `token` setting is not empty, and the request sends the same token in the
 *   `X-Browser-Testing-Token` header or the `token` URL/FORM variable. Tokens are compared in constant time
 * - The closure of the endpoint (`login` or `logout`) is set
 * - The request uses GET
 *
 * The checks run in the handler actions on every request, so they also cover the module convention
 * route and `event=` executions. Use a random token per environment, kept out of source control
 * (an environment variable), and never enable the module in an environment that real users can reach.
 * The entry point starts with two underscores so it does not clash with application routes.
 */
component {

	// Module Properties
	this.title          = "Browser Testing"
	this.description    = "Test-only login and logout endpoints for ColdBox browser tests"
	// Model Namespace and module settings key: moduleSettings.browserTesting
	this.modelNamespace = "browserTesting"
	// Route entry point
	this.entryPoint     = "__browser-testing"
	// No models to map
	this.autoMapModels  = false

	/**
	 * Configure the module settings and routes
	 */
	function configure(){
		// module settings - stored in modules.name.settings
		variables.settings = {
			// Browser testing endpoints are off unless the application turns them on
			enabled : false,
			// The shared secret every request must send, an empty token disables the endpoints
			token   : "",
			// The login closure: ( id, event, rc, prc ) => {}
			login   : "",
			// The logout closure: ( event, rc, prc ) => {}
			logout  : ""
		}

		// Module routes
		variables.routes = [
			{
				pattern : "/login/:id",
				handler : "Auth",
				action  : { GET : "login" },
				name    : "login"
			},
			{
				pattern : "/logout",
				handler : "Auth",
				action  : { GET : "logout" },
				name    : "logout"
			}
		]
	}

}
