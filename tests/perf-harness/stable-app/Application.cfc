/**
 * Bootstrap for the Stable ColdBox 8.1 performance app.
 * Maps /coldbox to ./coldbox/ (installed via box install coldbox@8.1.x).
 * Maps /cbperfapp to the shared ../app/ directory.
 * COLDBOX_APP_ROOT_PATH points to ../app/ so ColdBox discovers handlers/views there.
 */
component {

	// ─── Application properties ───────────────────────────────────────────────
	this.name              = "ColdBoxPerfStable_" & hash( getCurrentTemplatePath() )
	this.sessionManagement = true
	this.sessionTimeout    = createTimespan( 0, 0, 10, 0 )
	this.setClientCookies  = false
	this.timezone          = "UTC"

	// ─── Path resolution ──────────────────────────────────────────────────────
	// stableAppPath = /…/tests/perf-harness/stable-app/
	// sharedApp     = /…/tests/perf-harness/app/
	var stableAppPath = getDirectoryFromPath( getCurrentTemplatePath() )
	var repoRoot      = reReplaceNoCase( stableAppPath, "tests[/\\]perf-harness[/\\]stable-app[/\\]", "" )
	var sharedApp     = repoRoot & "tests/perf-harness/app/"

	// ─── CF Mappings ──────────────────────────────────────────────────────────
	// /coldbox  → stable 8.1 installed in stable-app/coldbox/
	this.mappings[ "/coldbox"   ] = stableAppPath & "coldbox/"
	// /cbperfapp → shared ColdBox application components
	this.mappings[ "/cbperfapp" ] = sharedApp

	// ─── ColdBox bootstrap settings ───────────────────────────────────────────
	COLDBOX_APP_ROOT_PATH = sharedApp
	COLDBOX_CONFIG_FILE   = sharedApp & "config/ColdBox.cfc"
	COLDBOX_APP_KEY       = "cbperf_stable"
	COLDBOX_APP_MAPPING   = "cbperfapp"
	COLDBOX_WEB_MAPPING   = "tests/perf-harness/stable-app"
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
			lock name="cbperf_stable_reinit" type="exclusive" timeout="10" throwonTimeout=true {
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
