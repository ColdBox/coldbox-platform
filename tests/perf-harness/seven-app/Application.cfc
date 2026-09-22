/**
 * Bootstrap for the ColdBox 7.x (latest) performance app.
 * Maps /coldbox to ./coldbox/ (installed via box install coldbox@7.x).
 * Maps /cbperfapp to the shared ../app/ directory.
 * COLDBOX_APP_ROOT_PATH points to ../app/ so ColdBox discovers handlers/views there.
 */
component {

	// ─── Application properties ───────────────────────────────────────────────
	this.name              = "ColdBoxPerfSeven_" & hash( getCurrentTemplatePath() )
	this.sessionManagement = true
	this.sessionTimeout    = createTimespan( 0, 0, 10, 0 )
	this.setClientCookies  = false
	this.timezone          = "UTC"

	// ─── Path resolution ──────────────────────────────────────────────────────
	// sevenAppPath = /…/tests/perf-harness/seven-app/
	// sharedApp    = /…/tests/perf-harness/app/
	sevenAppPath = getDirectoryFromPath( getCurrentTemplatePath() )
	repoRoot     = reReplaceNoCase( sevenAppPath, "tests[/\\]perf-harness[/\\]seven-app[/\\]", "" )
	sharedApp    = repoRoot & "tests/perf-harness/app/"

	// ─── CF Mappings ──────────────────────────────────────────────────────────
	// /coldbox  → ColdBox 7.x installed in seven-app/coldbox/
	this.mappings[ "/coldbox"   ] = sevenAppPath & "coldbox/"
	// /cbperfapp → shared ColdBox application components
	this.mappings[ "/cbperfapp" ] = sharedApp

	// ─── ColdBox bootstrap settings ───────────────────────────────────────────
	COLDBOX_APP_ROOT_PATH = sharedApp
	COLDBOX_CONFIG_FILE   = "cbperfapp.config.ColdBox"
	COLDBOX_APP_KEY       = "cbperf_seven"
	COLDBOX_APP_MAPPING   = "cbperfapp"
	COLDBOX_WEB_MAPPING   = "tests/perf-harness/seven-app"
	COLDBOX_FAIL_FAST     = true

	// ─── Lifecycle ────────────────────────────────────────────────────────────
	public boolean function onApplicationStart(){
		application.cbBootstrap = new coldbox.system.Bootstrap(
			COLDBOX_CONFIG_FILE,
			COLDBOX_APP_ROOT_PATH,
			COLDBOX_APP_KEY,
			COLDBOX_APP_MAPPING,
			COLDBOX_FAIL_FAST,
			COLDBOX_WEB_MAPPING
		)
		application.cbBootstrap.loadColdbox()
		return true
	}

	public boolean function onRequestStart( string targetPage ){
		// Allow reinit via ?bsReinit=1
		if( structKeyExists( url, "bsReinit" ) || !structKeyExists( application, "cbBootstrap" ) ){
			lock name="cbperf_seven_reinit" type="exclusive" timeout="10" throwonTimeout=true {
				structDelete( application, "cbBootstrap" )
				onApplicationStart()
			}
		}
		application.cbBootstrap.onRequestStart( arguments.targetPage )
		return true
	}

	public boolean function onApplicationEnd( struct appScope ){
		arguments.appScope.cbBootstrap.onApplicationEnd( arguments.appScope )
		return true
	}

	public void function onSessionStart(){
		application.cbBootstrap.onSessionStart()
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		arguments.appScope.cbBootstrap.onSessionEnd( argumentCollection=arguments )
	}

	public boolean function onMissingTemplate( string template ){
		return application.cbBootstrap.onMissingTemplate( argumentCollection=arguments )
	}

}
