/**
 * Bootstrap for the Bleeding Edge ColdBox performance app.
 * Maps /coldbox to the repo root (current development branch).
 * Maps /cbperfapp to the shared ../app/ directory.
 * COLDBOX_APP_ROOT_PATH points to ../app/ so ColdBox discovers handlers/views there.
 */
component {

	// ─── Application properties ───────────────────────────────────────────────
	this.name              = "ColdBoxPerfBE_" & hash( getCurrentTemplatePath() )
	this.sessionManagement = true
	this.sessionTimeout    = createTimespan( 0, 0, 10, 0 )
	this.setClientCookies  = false
	this.timezone          = "UTC"

	// ─── Path resolution ──────────────────────────────────────────────────────
	// beAppPath  = /…/tests/perf-harness/be-app/
	// repoRoot   = /…/coldbox-platform/
	// sharedApp  = /…/tests/perf-harness/app/
	beAppPath  = getDirectoryFromPath( getCurrentTemplatePath() )
	repoRoot   = reReplaceNoCase( beAppPath, "tests[/\\]perf-harness[/\\]be-app[/\\]", "" )
	sharedApp  = repoRoot & "tests/perf-harness/app/"

	// ─── CF Mappings ──────────────────────────────────────────────────────────
	// /coldbox  → bleeding edge framework (repo root)
	this.mappings[ "/coldbox"    ] = repoRoot
	// /cbperfapp → shared ColdBox application components
	this.mappings[ "/cbperfapp"  ] = sharedApp

	// ─── ColdBox bootstrap settings ───────────────────────────────────────────
	COLDBOX_APP_ROOT_PATH = sharedApp
	COLDBOX_CONFIG_FILE   = "cbperfapp.config.ColdBox"
	COLDBOX_APP_KEY       = "cbperf_be"
	COLDBOX_APP_MAPPING   = "cbperfapp"
	COLDBOX_WEB_MAPPING   = "tests/perf-harness/be-app"
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
			lock name="cbperf_be_reinit" type="exclusive" timeout="10" throwonTimeout=true {
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
