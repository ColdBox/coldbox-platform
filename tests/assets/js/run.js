document.addEventListener( "alpine:init", () => {
	Alpine.data( "testboxRun", () => ( {
		// State
		isLoading: true,
		isRunning: false,
		globalError: null,
		globalErrorDetail: null,
		globalErrorUrl: null,

		// Preferences (Merged with URL options)
		preferences: {
			theme: "dark",
			editor: "vscode",
			runnerUrl: "",
			directory: "",
			recurse: true,
			bundlesPattern: "",
			labels: "",
			excludes: ""
		},

		// Data
		bundles: [],
		globalStats: {
			totalBundles: 0,
			totalSuites: 0,
			totalSpecs: 0,
			totalDuration: 0,
			totalPass: 0,
			totalFail: 0,
			totalError: 0,
			totalSkipped: 0
		},

		// UI Filters
		searchQuery: "",
		statusFilters: {
			passed: true,
			failed: true,
			error: true,
			skipped: true
		},

		// The active EventSource connection for streaming test results
		eventSource: null,
		// Indicates testRunEnd was received for the current stream
		runCompleted: false,
		// Indicates we are intentionally stopping/closing the current stream
		isStopping: false,
		// Set to the bundle path when running a single bundle; null when running all
		activeBundlePath: null,
		// Counts specEnd events received during the current run for progress tracking
		specsCompleted: 0,
		// Internal flag to ensure init runs only once
		_initialized: false,

		/**
		 * Initializes the Alpine Component. Runs exactly once to load preferences and kick off the dry run.
		 */
		init() {
			if ( this._initialized ) return;
			this._initialized = true;

			this.loadPreferences();
			this.fetchDryRun();
			this.initKeyboardShortcuts();
		},

		/**
		 * Loads configuration from LocalStorage and merges it with the URL initial options.
		 */
		loadPreferences() {
			// Start with defaults, override with localStorage, then override with URL params on first load
			let savedPref = localStorage.getItem( "testboxPreferences" );
			let urlParams = new URLSearchParams( window.location.search );
			let hasSavedPreferences = false;

			if ( savedPref ) {
				try {
					Object.assign( this.preferences, JSON.parse( savedPref ) );
					hasSavedPreferences = true;
				} catch ( e ) {
					console.error( "Failed to parse saved preferences", e );
					localStorage.removeItem( "testboxPreferences" );
				}
			}

			// Apply window.initialOptions injected from run.bxm URL params
			if ( window.initialOptions ) {
				// First load (no localStorage): apply all server-provided defaults.
				// After preferences exist: only apply explicit URL overrides.
				for ( let key in window.initialOptions ) {
					let hasValue = window.initialOptions[ key ] !== null && window.initialOptions[ key ] !== undefined && window.initialOptions[ key ] !== "";
					let shouldApply = hasValue && ( !hasSavedPreferences || urlParams.has( key ) );

					if ( shouldApply ) {
						// typecast recurse correctly
						if ( key === "recurse" ) {
							this.preferences[ key ] = ( window.initialOptions[ key ] === true || window.initialOptions[ key ] === "true" );
						} else {
							this.preferences[ key ] = window.initialOptions[ key ];
						}
					}
				}
			}
		},

		/**
		 * Persists the current configuration to LocalStorage and reloads the window to apply them.
		 */
		savePreferences() {
			localStorage.setItem( "testboxPreferences", JSON.stringify( this.preferences ) );
			// Reload page to apply new settings via URL or we could just fetchDryRun again, but reload is cleaner to reset state
			window.location.reload();
		},

		/**
		 * Clears all saved preferences from LocalStorage and reloads the window to restore defaults.
		 */
		resetPreferences() {
			localStorage.removeItem( "testboxPreferences" );
			window.location.reload();
		},

		/**
		 * Toggles the UI theme between dark and light modes, persisting the choice.
		 */
		toggleTheme() {
			this.preferences.theme = this.preferences.theme === "dark" ? "light" : "dark";
			localStorage.setItem( "testboxPreferences", JSON.stringify( this.preferences ) );
		},

		/**
		 * Builds the runner URL with query parameters based on preferences and any additional params provided.
		 * This allows us to easily switch between dry run and actual run with streaming, as well as apply filters.
		 *
		 * @param {object} params - Dictionary of additional URL overrides to inject
		 * @returns {string} The fully constructed URL.
		 */
		buildRunnerUrl( params = {} ) {
			// Start with the base runner URL and append query parameters
			let url = new URL( this.preferences.runnerUrl, window.location.href );

			// Core parameters from preferences
			url.searchParams.append( "directory", this.preferences.directory );
			url.searchParams.append( "recurse", this.preferences.recurse );
			url.searchParams.append( "bundlesPattern", this.preferences.bundlesPattern );

			if ( this.preferences.labels ) {
				url.searchParams.append( "labels", this.preferences.labels );
			}

			if ( this.preferences.excludes ) {
				url.searchParams.append( "excludes", this.preferences.excludes );
			}

			for ( let key in params ) {
				url.searchParams.append( key, params[ key ] );
			}

			return url.toString();
		},

		/**
		 * Performs a dry run to fetch the test structure and initialize the UI state before actual execution.
		 * This allows us to display all bundles/suites/specs in a pending state and then update them in real-time as the tests run.
		 */
		async fetchDryRun() {
			this.isLoading = true;
			this.globalError = null;
			this.globalErrorUrl = null;

			let url = this.buildRunnerUrl( { dryRun : true } );

			try {
				let response = await fetch( url );
				if ( !response.ok ) {
					throw new Error( `HTTP Error: ${ response.status } ${ response.statusText }` );
				}

				let text = await response.text();
				let data;
				try {
					data = JSON.parse( text );
				} catch ( e ) {
					throw new Error( "Invalid JSON returned from runner." );
				}

				this.initializeState( data );
			} catch ( e ) {
				this.globalError = "Failed to load test structure.";
				this.globalErrorDetail = e.message;
				this.globalErrorUrl = url;
			} finally {
				this.isLoading = false;
			}
		},

		/**
		 * Parses the dry run JSON payload and maps it into the reactive bundles state array.
		 *
		 * @param {object} data - The dry run JSON payload from the server.
		 */
		initializeState( data ) {
			// Reset stats
			this.globalStats = {
				totalBundles: 0,
				totalSuites: 0,
				totalSpecs: 0,
				totalDuration: 0,
				totalPass: 0,
				totalFail: 0,
				totalError: 0,
				totalSkipped: 0
			};

			this.bundles = [];

			if ( !data.bundles ) return;

			data.bundles.forEach( ( b, bundleIdx ) => {
				let bundleKey = b.path || b.name || ( "bundle-" + bundleIdx );
				let bundle = {
					id: b.id || bundleKey,
					uid: bundleKey,
					name: b.name,
					path: b.path,
					status: "pending",
					expanded: false,
					type: "bundle",
					totalDuration: 0,
					totalPass: 0,
					totalFail: 0,
					totalError: 0,
					totalSkipped: 0,
					hasStats: false,
					debugBuffer: [],
					showDebug: false,
					suites: [],
					specs: [] // top-level specs
				};

				if ( b.suites && b.suites.length ) {
					this.collectSuiteNodes( {
						suites: b.suites,
						bundle,
						bundleUid: bundle.uid
					} );
				} else if ( b.specs && b.specs.length ) {
					// xUnit or no suites
					b.specs.forEach( ( sp, specIdx ) => {
						bundle.specs.push( this.createSpecNode( sp, bundle.uid, null, specIdx ) );
					} );
				}

				this.bundles.push( bundle );
			} );
		},

		/**
		 * Recursively collects suite nodes so nested dry-run suites are visible in the UI.
		 *
		 * @param {array} suites - The incoming dry-run suite array.
		 * @param {object} bundle - The mutable bundle state node.
		 * @param {string} bundleUid - Stable bundle identifier for local UI node IDs.
		 * @param {string} parentKey - Internal parent key to keep generated IDs unique.
		 */
		collectSuiteNodes( { suites, bundle, bundleUid, parentKey = "root" } ) {
			suites.forEach( ( suitePayload, suiteIdx ) => {
				let suiteSourceId = suitePayload.id || suitePayload.name || ( "suite-" + suiteIdx );
				let suiteUid = bundleUid + "::suite::" + parentKey + "::" + suiteSourceId + "::" + suiteIdx;
				let suite = {
					id: suiteUid,
					sourceId: suiteSourceId,
					name: suitePayload.name,
					status: suitePayload.skip ? "skipped" : "pending",
					expanded: false,
					specs: []
				};

				if ( suitePayload.specs && suitePayload.specs.length ) {
					suitePayload.specs.forEach( ( sp, specIdx ) => {
						suite.specs.push( this.createSpecNode( sp, bundleUid, suiteUid, specIdx ) );
					} );
				}

				bundle.suites.push( suite );

				if ( suitePayload.suites && suitePayload.suites.length ) {
					this.collectSuiteNodes( {
						suites: suitePayload.suites,
						bundle,
						bundleUid,
						parentKey: suiteUid
					} );
				}
			} );
		},

		/**
		 * Helper to factory generate a spec node containing unified baseline reactive properties.
		 *
		 * @param {object} sp - The target spec metadata payload.
		 * @returns {object} The initialized reactive node specification.
		 */
		createSpecNode( sp, bundleUid, suiteUid = null, specIdx = 0 ) {
			let sourceId = sp.id || sp.name || ( "spec-" + specIdx );
			let uidBase = suiteUid || bundleUid || "bundle";
			return {
				id: uidBase + "::spec::" + sourceId + "::" + specIdx,
				sourceId,
				bundleUid,
				suiteUid,
				name: sp.name,
				status: sp.skip ? "skipped" : "pending",
				totalDuration: 0,
				failMessage: "",
				failDetail: "",
				failOrigin: [],
				failStacktrace: "",
				error: null,
				hasExecuted: false,
				showFailureOrigin: false,
				showStacktrace: false
			};
		},

		/**
		 * Returns the primary failure context to preview (first fail origin or first error tagContext).
		 */
		getPrimaryContext( spec ) {
			if ( spec?.status === "failed" && Array.isArray( spec.failOrigin ) && spec.failOrigin.length ) {
				return spec.failOrigin[ 0 ];
			}

			if ( spec?.error && Array.isArray( spec.error.tagContext ) && spec.error.tagContext.length ) {
				return spec.error.tagContext[ 0 ];
			}

			if ( Array.isArray( spec?.failOrigin ) && spec.failOrigin.length ) {
				return spec.failOrigin[ 0 ];
			}

			return null;
		},

		/**
		 * Whether a spec status should render failure tooling.
		 */
		isFailedOrErrored( spec ) {
			return !!spec && spec.hasExecuted === true && ( spec.status === "failed" || spec.status === "error" );
		},

		/**
		 * Single source of truth: should the failure controls toolbar be shown for this spec?
		 * A spec that has executed and landed in a failed/error state always has something to show.
		 */
		shouldShowFailureControls( spec ) {
			return this.isFailedOrErrored( spec );
		},

		/**
		 * Whether this spec has any extended failure/error data to render in the expandable panel.
		 */
		hasFailureDetails( spec ) {
			if ( !this.isFailedOrErrored( spec ) ) return false;

			return !!(
				this.getPrimaryContext( spec ) ||
				( Array.isArray( spec.failOrigin ) && spec.failOrigin.length ) ||
				spec.failDetail ||
				spec.failStacktrace ||
				spec.error?.stackTrace
			);
		},

		/**
		 * Formats context location as template:line for UI labels.
		 */
		formatContextLabel( context ) {
			if ( !context?.template ) return "";
			return context.template + ( context.line ? ":" + context.line : "" );
		},

		/**
		 * Normalizes code print HTML for rendering and falls back to escaped plain code print.
		 */
		getContextCodeHTML( context ) {
			if ( !context ) return "";
			if ( context.codePrintHTML ) return String( context.codePrintHTML );
			if ( context.codePrintPlain ) return "<pre>" + this.escapeHtml( context.codePrintPlain ) + "</pre>";
			return "";
		},

		/**
		 * Escapes unsafe HTML chars for safe x-html fallback rendering.
		 */
		escapeHtml( value ) {
			return String( value )
				.replaceAll( "&", "&amp;" )
				.replaceAll( "<", "&lt;" )
				.replaceAll( ">", "&gt;" )
				.replaceAll( '"', "&quot;" )
				.replaceAll( "'", "&#39;" );
		},

		/**
		 * Opens file+line in VS Code (or configured editor scheme) from failure origin/tag context.
		 */
		openInEditor( template, line = 1 ) {
			if ( !template ) return;

			let editorScheme = this.preferences.editor || "vscode";
			let safePath = encodeURI( template ).replaceAll( "#", "%23" );
			let safeLine = Number.isFinite( Number( line ) ) ? Number( line ) : 1;

			window.location.href = `${ editorScheme }://file${ safePath }:${ safeLine }`;
		},

		/**
		 * Generates an editor deep-link href for a file+line.
		 */
		getEditorHref( template, line = 1 ) {
			if ( !template ) return "#";
			let editorScheme = this.preferences.editor || "vscode";
			let safePath = encodeURI( template ).replaceAll( "#", "%23" );
			let safeLine = Number.isFinite( Number( line ) ) ? Number( line ) : 1;
			return `${ editorScheme }://file${ safePath }:${ safeLine }`;
		},

		/**
		 * Extracts and normalizes a lowercase extension from a stacktrace location path.
		 */
		getFileExtension( filePath ) {
			if ( !filePath ) return "";
			let normalized = String( filePath ).trim();
			let lastDot = normalized.lastIndexOf( "." );
			if ( lastDot < 0 ) return "";
			return normalized.slice( lastDot + 1 ).toLowerCase();
		},

		/**
		 * Returns Java class FQN from a stacktrace line like:
		 * at ortus.boxlang.runtime.interop.DynamicInteropService.dereferenceAndInvoke(DynamicInteropService.java:2266)
		 */
		extractJavaClassFqn( line ) {
			if ( !line ) return "";
			let match = String( line ).match( /^\s*at\s+([A-Za-z0-9_$.]+)\.[A-Za-z0-9_$<>]+\([^)]*\.java:\d+\)\s*$/ );
			return match ? match[ 1 ] : "";
		},

		/**
		 * Builds a GitHub URL to a BoxLang runtime Java source file.
		 */
		getBoxLangGithubHref( classFqn, line = 1 ) {
			if ( !classFqn ) return "";
			let safeLine = Number.isFinite( Number( line ) ) ? Number( line ) : 1;
			let classPath = classFqn.replaceAll( ".", "/" ) + ".java";
			return `https://github.com/ortus-boxlang/boxlang/blob/main/src/main/java/${ classPath }#L${ safeLine }`;
		},

		/**
		 * Resolves whether a stacktrace location should be linked and where.
		 */
		resolveStacktraceLocationLink( filePath, lineNo, stackLine ) {
			const ext = this.getFileExtension( filePath );
			const editorExtensions = new Set( [ "cfc", "cfm", "bxm", "bx", "bxs" ] );

			if ( editorExtensions.has( ext ) ) {
				return {
					href: this.getEditorHref( filePath, lineNo ),
					newWindow: false
				};
			}

			if ( ext === "java" ) {
				let classFqn = this.extractJavaClassFqn( stackLine );
				if ( classFqn.startsWith( "ortus.boxlang.runtime." ) ) {
					return {
						href: this.getBoxLangGithubHref( classFqn, lineNo ),
						newWindow: true
					};
				}
			}

			return null;
		},

		/**
		 * Returns the stacktrace text for the spec (failure first, then error fallback).
		 */
		getStacktrace( spec ) {
			return spec?.failStacktrace || spec?.error?.stackTrace || "";
		},

		/**
		 * Whether stacktrace exists for display.
		 */
		hasStacktrace( spec ) {
			if ( !this.isFailedOrErrored( spec ) ) return false;
			return !!this.getStacktrace( spec );
		},

		/**
		 * Formats stacktrace text to HTML with highlighted locations and caused-by lines.
		 */
		formatStacktraceHTML( stacktrace ) {
			if ( !stacktrace ) return "";

			const locationPattern = /\(([^\)]+?):(\d+)\)/g;
			return String( stacktrace )
				.split( /\r?\n/ )
				.map( ( line ) => {
					let rendered = "";
					let lastIndex = 0;

					locationPattern.lastIndex = 0;
					for ( const match of line.matchAll( locationPattern ) ) {
						const full = match[ 0 ];
						const filePath = match[ 1 ];
						const lineNo = Number( match[ 2 ] );
						const matchIndex = match.index ?? 0;

						rendered += this.escapeHtml( line.slice( lastIndex, matchIndex ) );

						const linkInfo = this.resolveStacktraceLocationLink( filePath, lineNo, line );
						const label = this.escapeHtml( `${ filePath }:${ lineNo }` );

						if ( linkInfo?.href ) {
							const href = this.escapeHtml( linkInfo.href );
							const targetAttrs = linkInfo.newWindow ? ' target="_blank" rel="noopener noreferrer"' : "";
							rendered += `<span class="stacktrace-location">(<a class="stacktrace-link" href="${ href }"${ targetAttrs }>${ label }</a>)</span>`;
						} else {
							rendered += `<span class="stacktrace-location">${ this.escapeHtml( full ) }</span>`;
						}

						lastIndex = matchIndex + full.length;
					}

					rendered += this.escapeHtml( line.slice( lastIndex ) );

					if ( /^\s*caused by\s*:/i.test( line ) ) {
						rendered = `<span class="stacktrace-caused-by">${ rendered }</span>`;
					}

					return `<div class="stacktrace-line">${ rendered }</div>`;
				} )
				.join( "" );
		},

		/**
		 * Dynamically calculates global counting statistics across all bundles, suites, and specs (Getter).
		 * - After a completed run: returns the accurate stats received from the testRunEnd SSE event.
		 * - During a run or before any run: computes structure from the bundle tree. For single-bundle
		 *   runs the structure is scoped to the active bundle, giving an accurate progress bar denominator.
		 */
		get metaGlobalStats() {
			// Post-run: return the accurate server-reported counts verbatim.
			if ( this.runCompleted ) {
				return { ...this.globalStats };
			}

			// During a run / initial load: derive structure from the bundle tree.
			// For single-bundle runs scope to only the active bundle so the progress
			// bar denominator matches what the server is actually executing.
			let targetBundles = ( this.isRunning && this.activeBundlePath )
				? this.bundles.filter( b => b.path === this.activeBundlePath )
				: this.bundles;

			let totalB  = ( this.isRunning && this.activeBundlePath ) ? 1 : this.bundles.length;
			let totalSu = 0;
			let totalSp = 0;

			targetBundles.forEach( b => {
				totalSu += b.suites.length;
				totalSp += b.specs.length;
				b.suites.forEach( s => {
					totalSp += s.specs.length;
				} );
			} );

			return {
				totalBundles: totalB,
				totalSuites:  totalSu,
				totalSpecs:   totalSp,
				totalDuration: this.globalStats.totalDuration,
				totalPass:     this.globalStats.totalPass,
				totalFail:     this.globalStats.totalFail,
				totalError:    this.globalStats.totalError,
				totalSkipped:  this.globalStats.totalSkipped
			};
		},

		/**
		 * Overall run status for styling the results summary card border.
		 */
		get globalRunStatus() {
			if ( this.isRunning ) return 'running';
			const s = this.metaGlobalStats;
			if ( s.totalFail > 0 )    return 'failed';
			if ( s.totalError > 0 )   return 'error';
			if ( s.totalPass > 0 )    return 'passed';
			if ( s.totalSkipped > 0 ) return 'skipped';
			return 'pending';
		},

		/**
		 * Returns the tree of bundles recursively filtered by search query and status selections (Getter).
		 */
		get filteredBundles() {
			return this.bundles.filter( b => {
				// if search matches bundle name, show it
				let searchMatch = b.path.toLowerCase().includes( this.searchQuery.toLowerCase() );
				let statusMatch = this.isStatusVisible( b.status );

				if ( !statusMatch ) return false;

				if ( searchMatch ) return true;

				// check children
				let hasVisibleSuite = b.suites.some( s => this.isSuiteVisible( s, true ) );
				let hasVisibleSpec = b.specs.some( sp => this.isSpecVisible( sp, true ) );

				return hasVisibleSuite || hasVisibleSpec;
			} );
		},

		/**
		 * Evaluates a suite's visibility based on active user filters and direct matches.
		 *
		 * @param {object} suite - Target suite configuration.
		 * @param {boolean} ignoreParentMatch - Ignores parent scoping matches.
		 * @returns {boolean} Whether the item should be visible in HTML tree.
		 */
		isSuiteVisible( suite, ignoreParentMatch = false ) {
			let statusMatch = this.isStatusVisible( suite.status );
			if ( !statusMatch ) return false;

			if ( !ignoreParentMatch && this.searchQuery && suite.name.toLowerCase().includes( this.searchQuery.toLowerCase() ) ) return true;

			return suite.specs.some( sp => this.isSpecVisible( sp, true ) ) || ( suite.name.toLowerCase().includes( this.searchQuery.toLowerCase() ) );
		},

		/**
		 * Evaluates a spec's visibility based on name search and explicit status filters.
		 *
		 * @param {object} spec - Target spec configuration.
		 * @param {boolean} ignoreStatus - Force ignoring status filters.
		 * @returns {boolean} Whether the item should be visible in HTML tree.
		 */
		isSpecVisible( spec, ignoreStatus = false ) {
			if ( !ignoreStatus && !this.isStatusVisible( spec.status ) ) return false;
			return spec.name.toLowerCase().includes( this.searchQuery.toLowerCase() );
		},

		/**
		 * Returns whether a spec duration badge should be shown.
		 * Completed specs can legitimately report 0ms and should still display a badge.
		 *
		 * @param {object} spec - Target spec node.
		 * @returns {boolean} True when duration is renderable for this spec.
		 */
		shouldShowSpecDuration( spec ) {
			if ( !spec ) return false;
			if ( !spec.hasExecuted ) return false;
			if ( spec.status === "pending" || spec.status === "running" ) return false;
			return spec.totalDuration !== undefined && spec.totalDuration !== null;
		},

		/**
		 * Formats a spec duration value as a badge label.
		 *
		 * @param {object} spec - Target spec node.
		 * @returns {string} Duration text.
		 */
		formatSpecDuration( spec ) {
			return ( spec?.totalDuration ?? 0 ) + "ms";
		},

		/**
		 * Checks if a specific status type is active in the global toggles.
		 * Pending and Running states bypass strict filter.
		 *
		 * @param {string} status - Test execution status condition.
		 * @returns {boolean} Resultant status eligibility.
		 */
		isStatusVisible( status ) {
			// 'pending' and 'running' are always visible unless we are strictly filtering
			if ( status === "pending" || status === "running" ) return true;
			if ( status === "passed" && !this.statusFilters.passed ) return false;
			if ( status === "failed" && !this.statusFilters.failed ) return false;
			if ( status === "error" && !this.statusFilters.error ) return false;
			if ( status === "skipped" && !this.statusFilters.skipped ) return false;
			return true;
		},

		/**
		 * Retrieves the bootstrap icon visual representation for a given status or node type.
		 *
		 * @param {string} status - Node execution status.
		 * @param {string} type - Node classification (bundle, suite, spec).
		 * @returns {string} Fully qualified bootstrap icon string CSS.
		 */
		getStatusIcon( status, type = "" ) {
			switch ( status ) {
				case "passed": return "bi-check-circle-fill text-success";
				case "failed": return "bi-x-circle-fill text-danger";
				case "error": return "bi-exclamation-octagon-fill text-warning";
				case "skipped": return "bi-dash-circle-fill text-info";
				case "running": return "bi-hourglass-split text-primary spinner-icon";
				default:
					if ( type === "bundle" ) return "bi-box";
					if ( type === "suite" ) return "bi-folder2-open";
					// spec
					return "bi-circle text-secondary";
			}
		},

		/**
		 * Transforms a test execution status into a specific Bootstrap contextual color class.
		 *
		 * @param {string} status - Target execution status label.
		 * @returns {string} Resolving BS semantic intent class (e.g., success/danger).
		 */
		getStatusColorClass( status ) {
			switch ( status ) {
				case "passed": return "success";
				case "failed": return "danger";
				case "error": return "warning";
				case "skipped": return "info";
				case "running": return "primary";
				default: return "secondary";
			}
		},

		/**
		 * Whether a bundle has aggregate results worth showing in the strip.
		 *
		 * @param {object} bundle - Target bundle node.
		 * @returns {boolean}
		 */
		computeBundleHasStats( bundle ) {
			if ( !bundle ) return false;
			return ( ( bundle.totalPass || 0 ) + ( bundle.totalFail || 0 ) + ( bundle.totalError || 0 ) + ( bundle.totalSkipped || 0 ) ) > 0;
		},

		/**
		 * Resets duration, statistics, and state indicators back to "pending".
		 * When bundlePath is provided, only that bundle (and its children) is reset;
		 * all other bundles are left untouched so their previous results remain visible.
		 *
		 * @param {string|null} bundlePath - If set, only reset this bundle; otherwise reset all.
		 */
		resetExecutionState( bundlePath = null ) {
			this.runCompleted = false;
			this.isStopping = false;

			const resetSpec = ( sp ) => {
				sp.status = "pending";
				sp.totalDuration = 0;
				sp.failMessage = "";
				sp.failDetail = "";
				sp.failOrigin = [];
				sp.failStacktrace = "";
				sp.error = null;
				sp.hasExecuted = false;
				sp.showFailureOrigin = false;
				sp.showStacktrace = false;
			};

			const resetBundle = ( b ) => {
				b.status = "pending";
				b.totalDuration = 0;
				b.totalPass = 0;
				b.totalFail = 0;
				b.totalError = 0;
				b.totalSkipped = 0;
				b.hasStats = false;
				b.suites.forEach( s => {
					s.status = "pending";
					s.specs.forEach( resetSpec );
				} );
				b.specs.forEach( resetSpec );
			};

			if ( bundlePath ) {
				const b = this.bundles.find( b => b.path === bundlePath );
				if ( b ) resetBundle( b );
			} else {
				this.bundles.forEach( resetBundle );
			}

			// Always wipe run stats so metaGlobalStats reflects the new run, not the previous one.
			this.globalStats = {
				totalBundles: 0, totalSuites: 0, totalSpecs: 0, totalDuration: 0,
				totalPass: 0, totalFail: 0, totalError: 0, totalSkipped: 0
			};
			this.specsCompleted = 0;
			this.globalError = null;
			this.globalErrorDetail = null;
			this.globalErrorUrl = null;
		},

		/**
		 * Initiates a full systematic test run handling all loaded framework bundles.
		 */
		runAllTests() {
			this.activeBundlePath = null;
			this.resetExecutionState();
			this.isRunning = true;
			this.startEventSource( this.buildRunnerUrl( { streaming : true } ) );
		},

		/**
		 * Initiates a targeted isolated test run for a single bundle.
		 * Only that bundle resets to pending; all other bundles keep their last result (dimmed).
		 *
		 * @param {string} bundlePath - Bundle path to run.
		 */
		runBundle( bundlePath ) {
			this.activeBundlePath = bundlePath;
			this.resetExecutionState( bundlePath );
			this.isRunning = true;

			// Expand the target bundle and all its suites so results are immediately visible
			const b = this.bundles.find( b => b.path === bundlePath );
			if ( b ) {
				b.expanded = true;
				b.suites.forEach( s => s.expanded = true );
			}

			// Single-bundle run: only pass streaming + bundles — no directory/recurse/pattern
			let url = new URL( this.preferences.runnerUrl, window.location.href );
			url.searchParams.append( "streaming", "true" );
			url.searchParams.append( "bundles", bundlePath );
			this.startEventSource( url.toString() );
		},

		/**
		 * Initiates a targeted isolated test run for a single suite within a bundle.
		 * Only that bundle resets to pending; other bundles keep their last result (dimmed).
		 *
		 * @param {string} bundlePath - Bundle that owns the suite.
		 * @param {string} suiteId    - Suite unique identifier to run (passed as testSuites param).
		 */
		runSuite( bundlePath, suiteId ) {
			this.activeBundlePath = bundlePath;
			this.resetExecutionState( bundlePath );
			this.isRunning = true;

			const b = this.bundles.find( b => b.path === bundlePath );
			if ( b ) {
				b.expanded = true;
				const suite = b.suites.find( s => s.sourceId === suiteId );
				if ( suite ) suite.expanded = true;
			}

			let url = new URL( this.preferences.runnerUrl, window.location.href );
			url.searchParams.append( "streaming", "true" );
			url.searchParams.append( "bundles", bundlePath );
			url.searchParams.append( "testSuites", suiteId );
			this.startEventSource( url.toString() );
		},

		/**
		 * Initiates a targeted isolated test run for a single spec within a bundle.
		 * Only that bundle resets to pending; other bundles keep their last result (dimmed).
		 *
		 * @param {string} bundlePath - Bundle that owns the spec.
		 * @param {string} specId     - Spec unique identifier to run (passed as testSpecs param).
		 */
		runSpec( bundlePath, specId ) {
			this.activeBundlePath = bundlePath;
			this.resetExecutionState( bundlePath );
			this.isRunning = true;

			const b = this.bundles.find( b => b.path === bundlePath );
			if ( b ) {
				b.expanded = true;
				b.suites.forEach( s => s.expanded = true );
			}

			let url = new URL( this.preferences.runnerUrl, window.location.href );
			url.searchParams.append( "streaming", "true" );
			url.searchParams.append( "bundles", bundlePath );
			url.searchParams.append( "testSpecs", specId );

			this.startEventSource( url.toString() );
		},

		/**
		 * Safely initiates connection with the underlying BoxLang runner's Server-Sent Events stream
		 * and subsequently wires listeners mapping real-time broadcast payloads logically to the interface states.
		 *
		 * @param {string} url - The targeted SSE endpoint string.
		 */
		startEventSource( url ) {
			this.eventSource = new EventSource( url );

			this.eventSource.addEventListener( "bundleStart", ( e ) => {
				let data = JSON.parse( e.data );
				let bundle = this.bundles.find( b => b.path === data.path || b.id === data.id );
				if ( bundle ) bundle.status = "running";
			} );

			this.eventSource.addEventListener( "bundleEnd", ( e ) => {
				let data = JSON.parse( e.data );
				let bundle = this.bundles.find( b => b.path === data.path || b.id === data.id );
				if ( bundle ) {
					bundle.status = this.determineBundleStatus( data );
					bundle.totalDuration = data.totalDuration || 0;
					bundle.totalPass = data.totalPass || 0;
					bundle.totalFail = data.totalFail || 0;
					bundle.totalError = data.totalError || 0;
					bundle.totalSkipped = data.totalSkipped || 0;
					bundle.hasStats = this.computeBundleHasStats( bundle );
					bundle.debugBuffer = data.debugBuffer || [];
				}
			} );

			this.eventSource.addEventListener( "suiteStart", ( e ) => {
				let data = JSON.parse( e.data );
				let suiteAndBundle = this.findSuite( data.id, data.bundlePath );
				if ( suiteAndBundle ) suiteAndBundle.suite.status = "running";
			} );

			this.eventSource.addEventListener( "suiteEnd", ( e ) => {
				let data = JSON.parse( e.data );
				let suiteAndBundle = this.findSuite( data.id, data.bundlePath );
				if ( suiteAndBundle ) suiteAndBundle.suite.status = this.determineBundleStatus( data );
			} );

			this.eventSource.addEventListener( "specStart", ( e ) => {
				let data = JSON.parse( e.data );
				let specInfo = this.findSpec( data.id, data.bundlePath, data.suiteId );
				if ( specInfo ) {
					specInfo.spec.status = "running";
					specInfo.spec.hasExecuted = true;
				}
			} );

			this.eventSource.addEventListener( "specEnd", ( e ) => {
				let data = JSON.parse( e.data );
				let specInfo = this.findSpec( data.id, data.bundlePath, data.suiteId );
				if ( specInfo ) {
					specInfo.spec.status = data.status.toLowerCase();
					specInfo.spec.totalDuration = data.totalDuration || 0;
					specInfo.spec.failMessage = data.failMessage || "";
					specInfo.spec.failDetail = data.failDetail || "";
					specInfo.spec.failOrigin = Array.isArray( data.failOrigin ) ? data.failOrigin : [];
					specInfo.spec.failStacktrace = data.failStacktrace || "";
					specInfo.spec.error = data.error || null;
					specInfo.spec.hasExecuted = true;
					specInfo.spec.showFailureOrigin = false;
					specInfo.spec.showStacktrace = false;
				}
				this.specsCompleted++;
			} );

			// Server-sent fatal error (event: error with JSON payload)
			this.eventSource.addEventListener( "error", ( e ) => {
				if ( !e.data ) return; // native connection close fires with no data — let onerror handle it
				let data = JSON.parse( e.data );
				this.globalError = data.message || "A fatal error occurred during testing.";
				this.globalErrorDetail = data.detail || "";
				this.isStopping = true;
				this.stopTests();
			} );

			this.eventSource.addEventListener( "testRunEnd", ( e ) => {
				let data = JSON.parse( e.data );
				// Capture all run-level counters so metaGlobalStats can reflect exactly
				// what was executed (full harness *or* a single-bundle run).
				this.globalStats.totalBundles  = data.totalBundles;
				this.globalStats.totalSuites   = data.totalSuites;
				this.globalStats.totalSpecs    = data.totalSpecs;
				this.globalStats.totalDuration = data.totalDuration;
				this.globalStats.totalPass     = data.totalPass;
				this.globalStats.totalFail     = data.totalFail;
				this.globalStats.totalError    = data.totalError;
				this.globalStats.totalSkipped  = data.totalSkipped;
				this.runCompleted = true;
				this.isStopping = true;
				this.stopTests();
			} );

			this.eventSource.onerror = () => {
				// onerror races with testRunEnd on normal server close — defer one tick
				// so testRunEnd has a chance to set runCompleted/isStopping first.
				setTimeout( () => {
					if ( this.isStopping || this.runCompleted || !this.isRunning ) return;
					this.globalError = "Connection to test runner lost.";
					this.isStopping = true;
					this.stopTests();
				}, 0 );
			};
		},

		/**
		 * Manually closes the active SSE communication stream dropping the runner state,
		 * gracefully transitioning dangling/timeout instances to an explicit stopped status.
		 */
		stopTests() {
			if ( this.eventSource ) {
				// Detach handlers before closing to avoid close-related onerror noise.
				this.eventSource.onerror = null;
				this.eventSource.onmessage = null;
				this.eventSource.onopen = null;
				this.eventSource.close();
				this.eventSource = null;
			}
			this.isRunning = false;
			this.activeBundlePath = null;

			// Mark any stuck 'running' states as 'error' or 'skipped' (optional)
			this.bundles.forEach( b => {
				if ( b.status === "running" ) b.status = "error";
				b.suites.forEach( s => {
					if ( s.status === "running" ) s.status = "error";
					s.specs.forEach( sp => {
						if ( sp.status === "running" ) sp.status = "skipped";
					} );
				} );
				b.specs.forEach( sp => {
					if ( sp.status === "running" ) sp.status = "skipped";
				} );
			} );
		},

		/**
		 * Performs an iterative traversal nested search to isolate a matching suite configuration by ID.
		 *
		 * @param {string} id - Active reference ID representing requested target.
		 * @returns {object|null} Resolving pair returning parent and matched item explicitly.
		 */
		findSuite( id, bundlePath = null ) {
			for ( let b of this.bundles ) {
				if ( bundlePath && b.path !== bundlePath ) continue;
				for ( let s of b.suites ) {
					if ( s.sourceId === id ) return { bundle: b, suite: s };
				}
			}
			return null;
		},

		/**
		 * Performs an iterative traversal nested search to isolate a corresponding spec node configuration by ID.
		 * Supports deep-diving internal suite-bound lists or standalone xUnit top-tier bounds respectively.
		 *
		 * @param {string} id - Extrapolated reference ID of lookup element.
		 * @returns {object|null} Extended trace collection grouping targeting tree elements implicitly.
		 */
		findSpec( id, bundlePath = null, suiteId = null ) {
			for ( let b of this.bundles ) {
				if ( bundlePath && b.path !== bundlePath ) continue;
				for ( let s of b.suites ) {
					if ( suiteId && s.sourceId !== suiteId ) continue;
					for ( let sp of s.specs ) {
						if ( sp.sourceId === id ) return { bundle: b, suite: s, spec: sp };
					}
				}
				// Top-level specs (xUnit style — no parent suite)
				for ( let sp of b.specs ) {
					if ( sp.sourceId === id ) return { bundle: b, suite: null, spec: sp };
				}
			}
			return null;
		},

		/**
		 * Resets the entire UI to initial discovery state, wiping all run results and
		 * re-fetching the test bundle structure via a fresh dry run. Stops any active run first.
		 */
		refreshTests() {
			if ( this.isRunning ) {
				this.stopTests();
			}
			this.bundles           = [];
			this.runCompleted      = false;
			this.activeBundlePath  = null;
			this.specsCompleted    = 0;
			this.globalError       = null;
			this.globalErrorDetail = null;
			this.globalStats = {
				totalBundles: 0, totalSuites: 0, totalSpecs: 0, totalDuration: 0,
				totalPass: 0, totalFail: 0, totalError: 0, totalSkipped: 0
			};
			this.fetchDryRun();
		},

		/**
		 * Toggles all bundles and their suites between fully expanded and fully collapsed.
		 */
		toggleAllBundles() {
			const anyExpanded = this.bundles.some( b => b.expanded );
			if ( anyExpanded ) {
				this.collapseAll();
			} else {
				this.expandAll();
			}
		},

		/**
		 * Expands all bundle cards in the test tree.
		 */
		expandAll() {
			this.bundles.forEach( b => {
				b.expanded = true;
				b.suites.forEach( s => s.expanded = true );
			} );
		},

		/**
		 * Registers global keyboard shortcuts for common actions.
		 *
		 * Shortcuts:
		 *   Ctrl+K / ⌘K     — Focus the search / filter input
		 *   Escape           — Clear the search query (when search input is focused)
		 *   Ctrl+Enter       — Run all tests
		 *   Ctrl+.           — Reload (re-fetch dry run without full page reload)
		 *   Ctrl+,           — Open the Settings modal
		 *   Ctrl+H / ⌘H     — Open the Help / About dialog
		 *   Ctrl+B           — Toggle expand / collapse all bundles
		 *   Ctrl+D           — Toggle dark / light theme
		 */
		initKeyboardShortcuts() {
			document.addEventListener( "keydown", ( e ) => {
				const tag = document.activeElement?.tagName?.toLowerCase();
				const inInput = tag === "input" || tag === "textarea" || tag === "select" || document.activeElement?.isContentEditable;

				// Ctrl+K / ⌘K  →  focus search
				if ( ( e.ctrlKey || e.metaKey ) && e.key === "k" ) {
					e.preventDefault();
					const searchEl = document.getElementById( "searchInput" );
					if ( document.activeElement === searchEl ) {
						searchEl?.blur();
					} else {
						searchEl?.focus();
						searchEl?.select();
					}
					return;
				}

				// Escape  →  clear search (only while search input has focus)
				if ( e.key === "Escape" && document.activeElement?.id === "searchInput" ) {
					this.searchQuery = "";
					document.activeElement.blur();
					return;
				}

				// All remaining shortcuts require Ctrl/Meta and must not fire inside text inputs
				if ( !( e.ctrlKey || e.metaKey ) || inInput ) return;

				switch ( e.key ) {
					case "Enter":
						// Ctrl+Enter  →  run all tests
						e.preventDefault();
						if ( !this.isRunning ) this.runAllTests();
						break;

					case ".":
						// Ctrl+.  →  reload (re-fetch dry run without full page reload)
						e.preventDefault();
						if ( !this.isRunning ) this.fetchDryRun();
						break;

					case ",":
						// Ctrl+,  →  open settings modal
						e.preventDefault();
						bootstrap.Modal.getOrCreateInstance( document.getElementById( "settingsModal" ) ).show();
						break;

					case "h":
					case "H":
						// Ctrl+H / ⌘H  →  open About / Help modal
						e.preventDefault();
						bootstrap.Modal.getOrCreateInstance( document.getElementById( "aboutModal" ) ).show();
						break;

					case "b":
					case "B":
						// Ctrl+B  →  toggle expand/collapse all bundles
						e.preventDefault();
						this.toggleAllBundles();
						break;

					case "d":
					case "D":
						// Ctrl+D  →  toggle dark/light theme
						e.preventDefault();
						this.toggleTheme();
						break;
				}
			} );
		},

		/**
		 * Collapses all bundle cards in the test tree.
		 */
		collapseAll() {
			this.bundles.forEach( b => {
				b.expanded = false;
				b.suites.forEach( s => s.expanded = false );
			} );
		},

		/**
		 * Computes the overarching roll-up derivation status of dynamic container
		 * representations mapping test results progressively.
		 *
		 * @param {object} data - Reference map holding error, fail, or sequence metric states.
		 * @returns {string} Derived string representing logical test aggregate status.
		 */
		determineBundleStatus( data ) {
			if ( data.totalError > 0 ) return "error";
			if ( data.totalFail > 0 ) return "failed";
			if ( data.totalPass > 0 ) return "passed";
			if ( data.totalSkipped > 0 ) return "skipped";
			return "pending"; // default
		}
	} ) );

	// x-tooltip: wraps Bootstrap 5 Tooltip per element.
	// Usage: x-tooltip (reads data-bs-title or title attr) | x-tooltip.bottom (placement modifier)
	Alpine.directive( "tooltip", ( el, { modifiers }, { cleanup } ) => {
		let instance = new bootstrap.Tooltip( el, {
			title:     () => el.getAttribute( "data-bs-title" ) || el.getAttribute( "title" ) || "",
			trigger:   "hover focus",
			placement: modifiers[ 0 ] || "top"
		} );
		// Hide immediately on click so tooltips don't linger after buttons are pressed
		const hideOnClick = () => instance.hide();
		el.addEventListener( "click", hideOnClick );
		cleanup( () => {
			el.removeEventListener( "click", hideOnClick );
			instance.dispose();
		} );
	} );
} );
