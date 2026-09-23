/**
 * ColdBox Performance Analysis Suite
 *
 * Compares bleeding-edge (BE / 8.2-dev) vs ColdBox 8.1 stable vs ColdBox 7.x latest
 * across four CFML engines: BoxLang, BoxLang-CFML, Adobe CF 2025, Lucee 7.
 *
 * Measures:
 *   • Engine cold start (server restart + no bytecode cache)
 *   • App bootstrap time (ColdBox onApplicationStart)
 *   • Warm request latency per scenario (min/avg/P95/P99)
 *   • Sequential throughput (RPS)
 *
 * Usage (from repo root):
 *   box task run tests/perf-harness/PerformanceSuite.cfc
 *   box task run tests/perf-harness/PerformanceSuite.cfc engines=boxlang-cfml
 *   box task run tests/perf-harness/PerformanceSuite.cfc versions=be,seven iterations=100 coldStart=false
 *   box run-script perf:run
 *   box run-script perf:run:quick
 */
component {

	// ══════════════════════════════════════════════════════════════════════════
	// CONFIGURATION
	// ══════════════════════════════════════════════════════════════════════════

	variables.TASK_DIR   = getDirectoryFromPath( getCurrentTemplatePath() )
	variables.REPO_ROOT  = reReplaceNoCase( variables.TASK_DIR, "tests[/\\]perf-harness[/\\]", "" )
	variables.BASE_URL   = "http://localhost:8599"
	variables.REPORT_DIR = variables.TASK_DIR & "reports/"

	variables.ENGINES = {
		"boxlang" : {
			name         : "BoxLang",
			serverConfig : variables.TASK_DIR & "server-perf-boxlang.json",
			serverName   : "coldbox-perf-boxlang",
			cacheDir     : variables.REPO_ROOT & ".engine/boxlang/",
			cacheDirs    : [ ".boxlang/classes", "home" ]
		},
		"boxlang-cfml" : {
			name         : "BoxLang CFML",
			serverConfig : variables.TASK_DIR & "server-perf-boxlang-cfml.json",
			serverName   : "coldbox-perf-boxlang-cfml",
			cacheDir     : variables.REPO_ROOT & ".engine/boxlang-cfml-1/",
			cacheDirs    : [ ".boxlang/classes", "home" ]
		},
		"adobe-2025" : {
			name         : "Adobe CF 2025",
			serverConfig : variables.TASK_DIR & "server-perf-adobe2025.json",
			serverName   : "coldbox-perf-adobe2025",
			cacheDir     : variables.REPO_ROOT & ".engine/adobe2025/",
			cacheDirs    : [ "WEB-INF/cfclasses" ]
		},
		"lucee-7" : {
			name         : "Lucee 7",
			serverConfig : variables.TASK_DIR & "server-perf-lucee7.json",
			serverName   : "coldbox-perf-lucee7",
			cacheDir     : variables.REPO_ROOT & ".engine/lucee7/",
			cacheDirs    : [ "WEB-INF/lucee/web/cfclasses", "WEB-INF/lucee/web/tmp" ]
		}
	}

	// Ordered so reports/log output always present versions in a stable, sensible sequence.
	variables.VERSION_ORDER = [ "be", "stable", "seven" ]

	variables.VERSIONS = {
		"be" : {
			label     : "BE (8.2-dev)",
			shortLabel: "BE",
			appDir    : "be-app",
			// The BE app maps /coldbox straight to the repo root — nothing to install.
			installDir: "",
			semver    : ""
		},
		"stable" : {
			label     : "8.1 Stable",
			shortLabel: "Stable",
			appDir    : "stable-app",
			installDir: "coldbox/",
			semver    : "8.1.x"
		},
		"seven" : {
			label     : "7.x Latest",
			shortLabel: "Seven",
			appDir    : "seven-app",
			installDir: "coldbox/",
			semver    : "7.x"
		}
	}

	// Baselines that BE is compared against in delta columns/rows. Both are optional —
	// deltas only render when BE and the given baseline were both actually tested.
	variables.BASELINE_VERSIONS = [ "stable", "seven" ]

	// engine/version combinations known to be unsupported — skipped rather than
	// attempted and left to fail. ColdBox 7.x on native BoxLang isn't validated:
	// its InterceptorService.cfc assumes a component's `extends` metadata key is
	// absent when there's no superclass, but BoxLang always includes it as an
	// empty struct, so `.name` access throws on every request.
	variables.UNSUPPORTED_COMBOS = [ { engine: "boxlang", version: "seven" } ]

	variables.SCENARIOS = [
		{
			id          : "health",
			name        : "Health Check",
			description : "Minimal ColdBox lifecycle — no DI, no view, text response",
			event       : "Main.health"
		},
		{
			id          : "view",
			name        : "Simple View",
			description : "View rendering + layout pipeline",
			event       : "Main.index"
		},
		{
			id          : "api",
			name        : "JSON API",
			description : "WireBox DI + JSON serialization via renderData",
			event       : "Api.list"
		},
		{
			id          : "complex",
			name        : "Complex View",
			description : "Multiple model injections + view with data loops",
			event       : "Main.complex"
		},
		{
			id          : "module",
			name        : "Module Request",
			description : "Full HMVC module routing + module-scoped DI",
			event       : "perf-module%3AItems.index"
		}
	]

	// ══════════════════════════════════════════════════════════════════════════
	// ENTRY POINT
	// ══════════════════════════════════════════════════════════════════════════

	/**
	 * Run the full performance analysis suite.
	 *
	 * @engines       Comma-separated engine IDs or "all". Options: boxlang, boxlang-cfml, adobe-2025, lucee-7
	 * @versions      Comma-separated versions to test. Options: be, stable, seven
	 * @iterations    Number of warm requests per scenario for latency measurement
	 * @warmup        Number of warmup requests to discard before measuring
	 * @throughputSecs Seconds to run the sequential throughput test per version
	 * @coldStart     Whether to measure cold start (requires server restart)
	 * @generateReport Whether to produce HTML + Markdown reports in reports/
	 */
	function run(
		string  engines        = "all",
		string  versions       = "be,stable,seven",
		numeric iterations     = 50,
		numeric warmup         = 10,
		numeric throughputSecs = 10,
		boolean coldStart      = true,
		boolean generateReport = true
	){
		logMsg( "" )
		logMsg( "╔═══════════════════════════════════════════════════════════════╗" )
		logMsg( "║           ColdBox Performance Analysis Suite                  ║" )
		logMsg( "╚═══════════════════════════════════════════════════════════════╝" )
		logMsg( "" )
		logMsg( "  Repo root  : #variables.REPO_ROOT#" )
		logMsg( "  Engines    : #arguments.engines#" )
		logMsg( "  Versions   : #arguments.versions#" )
		logMsg( "  Iterations : #arguments.iterations#" )
		logMsg( "  Warmup     : #arguments.warmup#" )
		logMsg( "  Cold start : #arguments.coldStart#" )
		logMsg( "" )

		var engineList  = parseEngineList( arguments.engines )
		var versionList = parseVersionList( arguments.versions )

		// Ensure any non-BE version (stable, seven, ...) is installed before tests begin
		for( var v in versionList ){
			if( v != "be" ) ensureVersionInstalled( v )
		}

		var results = {
			generated     : now(),
			iterations    : arguments.iterations,
			warmup        : arguments.warmup,
			throughputSecs: arguments.throughputSecs,
			coldStartRun  : arguments.coldStart,
			versionsTested: versionList,
			engines       : {}
		}

		// ── Main test loop ────────────────────────────────────────────────────
		for( var engineId in engineList ){
			var engine = variables.ENGINES[ engineId ]
			results.engines[ engineId ] = { name: engine.name, versions: {} }

			// Drop any version/engine combo known to be unsupported from this
			// engine's matrix entirely, rather than attempting and skipping it.
			var engineVersionList = versionList.filter( function( v ){
				return !variables.UNSUPPORTED_COMBOS.some( function( combo ){
					return combo.engine == engineId && combo.version == v
				} )
			} )

			logMsg( "" )
			logMsg( "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" )
			logMsg( "  Engine: #engine.name#" )
			logMsg( "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" )

			for( var version in engineVersionList ){
				logMsg( "" )
				logMsg( "  ▶ Version: #variables.VERSIONS[ version ].label#" )

				var vData = {
					version      : version,
					coldStart    : {},
					appBootstrap : {},
					scenarios    : {},
					throughput   : {}
				}

				// 1. Cold start — stop server, wipe class cache, restart, time first response
				if( arguments.coldStart ){
					logMsg( "    → Measuring cold start (server restart + cache clear)..." )
					vData.coldStart = measureColdStart( engine, version )
					logMsg( "      Cold start: #vData.coldStart.totalMs#ms (server up in #vData.coldStart.serverStartMs#ms, first response in #vData.coldStart.firstResponseMs#ms)" )
				}

				// 2. Ensure server is running (may already be up from cold start)
				if( !arguments.coldStart ){
					logMsg( "    → Starting server..." )
					startServer( engine )
					var healthUrl = buildUrl( variables.SCENARIOS[ 1 ], version )
					if( !waitForServer( healthUrl, 120 ) ){
						logMsg( "    ✗ Server did not start in time — skipping #engine.name# #version#" )
						continue;
					}
				}

				// 3. App bootstrap (re-init ColdBox, time first request)
				logMsg( "    → Measuring app bootstrap time..." )
				vData.appBootstrap = measureAppBootstrap( version )
				logMsg( "      Bootstrap: #vData.appBootstrap.ms#ms" )

				// 4. Warmup
				logMsg( "    → Warming up (#arguments.warmup# requests)..." )
				var warmupUrl = buildUrl( variables.SCENARIOS[ 1 ], version )
				for( var w = 1; w <= arguments.warmup; w++ ){
					try {
						httpGet( url=warmupUrl, timeout=15 )
					} catch( any e ){
					}
				}

				// 5. Per-scenario latency
				for( var scenario in variables.SCENARIOS ){
					var scenarioUrl = buildUrl( scenario, version )
					logMsg( "    → Scenario [#scenario.name#] (#arguments.iterations# req)..." )
					vData.scenarios[ scenario.id ] = measureScenario( scenarioUrl, arguments.iterations )
					var s = vData.scenarios[ scenario.id ]
					logMsg( "      avg=#s.avg#ms  p95=#s.p95#ms  p99=#s.p99#ms  errors=#s.errors#" )
				}

				// 6. Throughput (sequential)
				var tUrl = buildUrl( variables.SCENARIOS[ 1 ], version )
				logMsg( "    → Throughput (#arguments.throughputSecs#s sequential)..." )
				vData.throughput = measureThroughput( tUrl, arguments.throughputSecs )
				logMsg( "      #vData.throughput.rps# RPS (#vData.throughput.totalRequests# requests)" )

				results.engines[ engineId ].versions[ version ] = vData

				// Stop server after each version test to avoid port conflicts
				logMsg( "    → Stopping server..." )
				stopServer( engine )
				sleep( 2000 )
			}
		}

		// ── Generate reports ──────────────────────────────────────────────────
		if( arguments.generateReport ){
			logMsg( "" )
			logMsg( "  Generating reports..." )
			var ts       = dateTimeFormat( results.generated, "yyyymmdd_HHnnss" )
			var mdPath   = variables.REPORT_DIR & "perf-report-#ts#.md"
			var htmlPath = variables.REPORT_DIR & "perf-report-#ts#.html"
			generateMarkdownReport( results, mdPath )
			generateHTMLReport( results, htmlPath )
			logMsg( "  ✓ Markdown : #mdPath#" )
			logMsg( "  ✓ HTML     : #htmlPath#" )
		}

		logMsg( "" )
		logMsg( "  ✓ Performance analysis complete!" )
		logMsg( "" )
	}

	// ══════════════════════════════════════════════════════════════════════════
	// SETUP
	// ══════════════════════════════════════════════════════════════════════════

	private array function parseEngineList( required string engines ){
		if( arguments.engines == "all" ) return variables.ENGINES.keyArray()
		return listToArray( arguments.engines )
	}

	// Parses the requested version list but always emits them in VERSION_ORDER,
	// so downstream loops/report generation get a stable, predictable sequence.
	private array function parseVersionList( required string versions ){
		var requested = listToArray( arguments.versions )
		return variables.VERSION_ORDER.filter( function( v ){
			return requested.findNoCase( v ) > 0
		} )
	}

	// Builds the request URL for a given scenario + version, e.g.
	// http://localhost:8599/tests/perf-harness/stable-app/index.cfm?event=Main.health
	private string function buildUrl( required struct scenario, required string version ){
		var appDir = variables.VERSIONS[ arguments.version ].appDir
		return variables.BASE_URL & "/tests/perf-harness/#appDir#/index.cfm?event=#arguments.scenario.event#"
	}

	private void function ensureVersionInstalled( required string version ){
		var vMeta = variables.VERSIONS[ arguments.version ]
		// "be" (bleeding edge) maps straight to the repo root — nothing to install
		if( !len( vMeta.installDir ) ){
			return
		}
		var appDir       = variables.TASK_DIR & vMeta.appDir & "/"
		var installedDir = appDir & vMeta.installDir
		if( directoryExists( installedDir ) ){
			logMsg( "  ✓ #vMeta.label# already installed at #installedDir#" )
			return
		}
		logMsg( "  Installing ColdBox #vMeta.semver# into #vMeta.appDir#/..." )
		try {
			command( "cd '#appDir#'" ).run()
			command( "install" ).run()
			command( "cd '#variables.REPO_ROOT#'" ).run()
			logMsg( "  ✓ #vMeta.label# installed." )
		} catch( any e ){
			logMsg( "  ✗ Could not install #vMeta.label#: #e.message#. Skipping this version." )
		}
	}

	// ══════════════════════════════════════════════════════════════════════════
	// SERVER MANAGEMENT
	// ══════════════════════════════════════════════════════════════════════════

	private void function startServer( required struct engine ){
		try {
			command( "server start" )
				.params( serverConfigFile=arguments.engine.serverConfig )
				.flags( "force" )
				.run()
		} catch( any e ){
			logMsg( "  ✗ Server start error: #e.message#" )
		}
	}

	// The CLI's bundled Lucee (5.4.8.2) has multiple bugs around cfhttp() when
	// called from inside a component method: a parser bug when it's the
	// direct child of a try{} block, and its result="varName" attribute
	// silently fails to populate the variable (both in script syntax and via
	// a tag-based include). Bypassing cfhttp with a plain java.net
	// HttpURLConnection sidesteps all of it.
	private struct function httpGet( required string url, numeric timeout=15 ){
		var timeoutMs = javacast( "int", arguments.timeout * 1000 )
		var conn      = createObject( "java", "java.net.URL" ).init( arguments.url ).openConnection()
		conn.setRequestMethod( "GET" )
		conn.setConnectTimeout( timeoutMs )
		conn.setReadTimeout( timeoutMs )
		var status = 0
		var body   = ""
		try {
			status = conn.getResponseCode()
			var reader = createObject( "java", "java.io.BufferedReader" ).init(
				createObject( "java", "java.io.InputStreamReader" ).init( conn.getInputStream() )
			)
			var sb   = createObject( "java", "java.lang.StringBuilder" ).init()
			var line = reader.readLine()
			while( !isNull( line ) ){
				sb.append( line )
				line = reader.readLine()
			}
			body = sb.toString()
			reader.close()
		} catch( any e ){
			status = conn.getResponseCode()
		}
		return { statusCode: status, filecontent: body }
	}

	private void function stopServer( required struct engine ){
		try {
			command( "server stop" )
				.params( name=arguments.engine.serverName )
				.flags( "force" )
				.run()
		} catch( any e ){
			// Server may not be running — ignore
		}
	}

	private boolean function waitForServer( required string healthUrl, numeric timeout=120 ){
		var deadline = getTickCount() + ( arguments.timeout * 1000 )
		while( getTickCount() < deadline ){
			try {
				var probe = httpGet( url=arguments.healthUrl, timeout=5 )
				if( probe.statusCode contains "200" ) return true
			} catch( any e ){}
			sleep( 2000 )
		}
		return false
	}

	private void function clearEngineCache( required struct engine ){
		for( var subDir in arguments.engine.cacheDirs ){
			var fullPath = arguments.engine.cacheDir & subDir & "/"
			if( directoryExists( fullPath ) ){
				try {
					directoryDelete( fullPath, true )
					logMsg( "      Cleared: #fullPath#" )
				} catch( any e ){
					logMsg( "      Warning — could not clear #fullPath#: #e.message#" )
				}
			}
		}
	}

	// ══════════════════════════════════════════════════════════════════════════
	// MEASUREMENT
	// ══════════════════════════════════════════════════════════════════════════

	private struct function measureColdStart( required struct engine, required string version ){
		var healthUrl = buildUrl( variables.SCENARIOS[ 1 ], arguments.version )

		// Stop any running instance
		stopServer( arguments.engine )
		sleep( 3000 )

		// Wipe compiled class caches
		clearEngineCache( arguments.engine )

		// Start server and time until first response
		var serverStart = getTickCount()
		startServer( arguments.engine )

		var serverReady = false
		var firstResponseMs = 0
		var deadline = getTickCount() + 180000 // 3 minute max

		while( getTickCount() < deadline ){
			try {
				var reqStart = getTickCount()
				var cr       = httpGet( url=healthUrl, timeout=10 )
				if( cr.statusCode contains "200" ){
					firstResponseMs = getTickCount() - reqStart
					serverReady     = true
					break
				}
			} catch( any e ){}
			sleep( 1000 )
		}

		var totalMs      = getTickCount() - serverStart
		var serverStartMs = totalMs - firstResponseMs

		return {
			success        : serverReady,
			totalMs        : totalMs,
			serverStartMs  : serverStartMs,
			firstResponseMs: firstResponseMs
		}
	}

	private struct function measureAppBootstrap( required string version ){
		var healthUrl = buildUrl( variables.SCENARIOS[ 1 ], arguments.version )
		var reinitUrl = healthUrl & "&bsReinit=1"

		// Trigger ColdBox re-initialization
		try {
			httpGet( url=reinitUrl, timeout=30 )
		} catch( any e ){}

		sleep( 500 )

		// Time the first post-reinit request (full bootstrap cost)
		var start = getTickCount()
		try {
			httpGet( url=healthUrl, timeout=30 )
		} catch( any e ){}

		return { ms: getTickCount() - start }
	}

	private struct function measureScenario( required string url, required numeric count ){
		var times  = []
		var errors = 0

		for( var i = 1; i <= arguments.count; i++ ){
			var start = getTickCount()
			try {
				var sr = httpGet( url=arguments.url, timeout=30 )
				if( !( sr.statusCode contains "200" ) ) errors++
			} catch( any e ){
				errors++
			}
			times.append( getTickCount() - start )
		}

		if( times.isEmpty() ){
			return { count: 0, errors: errors, min: 0, max: 0, avg: 0, p50: 0, p95: 0, p99: 0, errorPct: 100 }
		}

		var sorted = duplicate( times )
		sorted.sort( "numeric" )
		var total = 0
		for( var t in times ) total += t

		return {
			count    : arguments.count,
			errors   : errors,
			errorPct : round( ( errors / arguments.count ) * 100 * 100 ) / 100,
			min      : sorted[ 1 ],
			max      : sorted[ sorted.len() ],
			avg      : round( total / times.len() ),
			p50      : percentile( sorted, 50 ),
			p95      : percentile( sorted, 95 ),
			p99      : percentile( sorted, 99 )
		}
	}

	// Sequential throughput — measures requests per second for a fixed duration
	private struct function measureThroughput( required string url, required numeric durationSecs ){
		var start    = getTickCount()
		var deadline = start + ( arguments.durationSecs * 1000 )
		var requests = 0
		var errors   = 0

		while( getTickCount() < deadline ){
			try {
				var tr = httpGet( url=arguments.url, timeout=10 )
				if( tr.statusCode contains "200" ) requests++
				else errors++
			} catch( any e ){
				errors++
			}
		}

		var elapsed = ( getTickCount() - start ) / 1000
		return {
			totalRequests : requests,
			errors        : errors,
			durationSecs  : elapsed,
			rps           : ( elapsed > 0 ) ? round( ( requests / elapsed ) * 100 ) / 100 : 0,
			note          : "Sequential single-threaded"
		}
	}

	private numeric function percentile( required array sorted, required numeric p ){
		if( arguments.sorted.isEmpty() ) return 0
		var idx = max( 1, ceiling( arguments.sorted.len() * ( arguments.p / 100 ) ) )
		return arguments.sorted[ min( idx, arguments.sorted.len() ) ]
	}

	// ══════════════════════════════════════════════════════════════════════════
	// REPORT GENERATION — MARKDOWN
	// ══════════════════════════════════════════════════════════════════════════

	private void function generateMarkdownReport( required struct results, required string filePath ){
		var md          = []
		var r           = arguments.results
		var ts          = dateTimeFormat( r.generated, "yyyy-mm-dd HH:nn:ss" )
		var versionList = r.versionsTested
		var baselines   = versionList.filter( function( v ){ return variables.BASELINE_VERSIONS.findNoCase( v ) > 0 } )
		var hasBE       = versionList.findNoCase( "be" ) > 0

		md.append( "## ColdBox Performance Analysis Report" )
		md.append( "" )
		md.append( "Generated: #ts# | Iterations: #r.iterations# | Warmup: #r.warmup# | Cold Start: #r.coldStartRun#" )
		md.append( "" )
		md.append( "Versions tested: " & versionList.map( function( v ){ return variables.VERSIONS[ v ].label } ).toList( ", " ) )
		md.append( "" )

		// ── Cold Start Table ──────────────────────────────────────────────────
		if( r.coldStartRun ){
			md.append( "#### Engine Cold Start (First Request, No Bytecode Cache)" )
			md.append( "" )
			md.append( "| Engine | Version | Server Start (ms) | First Response (ms) | Total (ms) |" )
			md.append( "|--------|---------|:-----------------:|:-------------------:|:----------:|" )
			for( var engineId in r.engines ){
				var eng = r.engines[ engineId ]
				for( var ver in versionList ){
					if( !eng.versions.keyExists( ver ) ) continue;
					var vd = eng.versions[ ver ]
					if( !vd.coldStart.isEmpty() && vd.coldStart.success ){
						md.append( "| #eng.name# | #variables.VERSIONS[ver].shortLabel# | #vd.coldStart.serverStartMs# | #vd.coldStart.firstResponseMs# | #vd.coldStart.totalMs# |" )
					}
				}
			}
			md.append( "" )
		}

		// ── App Bootstrap Table ───────────────────────────────────────────────
		md.append( "#### ColdBox App Bootstrap Time (Re-init)" )
		md.append( "" )
		var bootHeader  = "| Engine |"
		var bootDivider = "|--------|"
		for( var ver in versionList ){
			bootHeader  &= " #variables.VERSIONS[ver].shortLabel# (ms) |"
			bootDivider &= ":------:|"
		}
		if( hasBE ){
			for( var base in baselines ){
				bootHeader  &= " Δ BE-#variables.VERSIONS[base].shortLabel# |"
				bootDivider &= ":------:|"
			}
		}
		md.append( bootHeader )
		md.append( bootDivider )
		for( var engineId in r.engines ){
			var eng = r.engines[ engineId ]
			var row = "| #eng.name# |"
			for( var ver in versionList ){
				var ms = ( eng.versions.keyExists( ver ) ) ? eng.versions[ ver ].appBootstrap.ms : "-"
				row &= " #ms# |"
			}
			if( hasBE ){
				for( var base in baselines ){
					var delta = "-"
					if( eng.versions.keyExists( "be" ) && eng.versions.keyExists( base ) ){
						delta = formatDelta( eng.versions.be.appBootstrap.ms, eng.versions[ base ].appBootstrap.ms )
					}
					row &= " #delta# |"
				}
			}
			md.append( row )
		}
		md.append( "" )

		// ── Scenario Latency Tables ───────────────────────────────────────────
		md.append( "#### Warm Request Latency by Scenario" )
		md.append( "" )
		md.append( "> All times in milliseconds. Delta shows BE change vs the given baseline (negative = BE faster)." )
		md.append( "" )

		for( var scenario in variables.SCENARIOS ){
			md.append( "###### #scenario.name#" )
			md.append( "" )
			md.append( "_#scenario.description#_" )
			md.append( "" )
			md.append( "| Engine | Version | Min | Avg | P95 | P99 | Max | Errors |" )
			md.append( "|--------|---------|:---:|:---:|:---:|:---:|:---:|:------:|" )

			for( var engineId in r.engines ){
				var eng = r.engines[ engineId ]
				for( var ver in versionList ){
					if( !eng.versions.keyExists( ver ) ) continue;
					var vd = eng.versions[ ver ]
					if( vd.scenarios.keyExists( scenario.id ) ){
						var s = vd.scenarios[ scenario.id ]
						md.append( "| #eng.name# | #variables.VERSIONS[ver].shortLabel# | #s.min# | #s.avg# | #s.p95# | #s.p99# | #s.max# | #s.errors# (#s.errorPct#%) |" )
					}
				}
			}

			// Delta rows (BE vs each tested baseline, per engine)
			if( hasBE ){
				for( var engineId in r.engines ){
					var eng = r.engines[ engineId ]
					if( !eng.versions.keyExists( "be" ) ) continue;
					for( var base in baselines ){
						if( !eng.versions.keyExists( base ) ) continue;
						var beS = eng.versions.be.scenarios[ scenario.id ]     ?: {}
						var blS = eng.versions[ base ].scenarios[ scenario.id ] ?: {}
						if( !beS.isEmpty() && !blS.isEmpty() ){
							md.append( "| **#eng.name# Δ** | be vs #variables.VERSIONS[base].shortLabel# | #deltaMs(beS.min,blS.min)# | #deltaMs(beS.avg,blS.avg)# | #deltaMs(beS.p95,blS.p95)# | #deltaMs(beS.p99,blS.p99)# | #deltaMs(beS.max,blS.max)# | — |" )
						}
					}
				}
			}
			md.append( "" )
		}

		// ── Throughput Table ──────────────────────────────────────────────────
		md.append( "#### Throughput (Sequential RPS on Health Check, #r.throughputSecs#s)" )
		md.append( "" )
		var thHeader  = "| Engine |"
		var thDivider = "|--------|"
		for( var ver in versionList ){
			thHeader  &= " #variables.VERSIONS[ver].shortLabel# RPS |"
			thDivider &= ":------:|"
		}
		if( hasBE ){
			for( var base in baselines ){
				thHeader  &= " Δ BE-#variables.VERSIONS[base].shortLabel# |"
				thDivider &= ":------:|"
			}
		}
		for( var ver in versionList ){
			thHeader  &= " #variables.VERSIONS[ver].shortLabel# Requests |"
			thDivider &= ":------:|"
		}
		md.append( thHeader )
		md.append( thDivider )
		for( var engineId in r.engines ){
			var eng = r.engines[ engineId ]
			var row = "| #eng.name# |"
			for( var ver in versionList ){
				var rps = ( eng.versions.keyExists( ver ) && !eng.versions[ ver ].throughput.isEmpty() ) ? eng.versions[ ver ].throughput.rps : "-"
				row &= " #rps# |"
			}
			if( hasBE ){
				for( var base in baselines ){
					var delta = "-"
					if(
						eng.versions.keyExists( "be" ) && !eng.versions.be.throughput.isEmpty() &&
						eng.versions.keyExists( base ) && !eng.versions[ base ].throughput.isEmpty()
					){
						delta = formatDelta( eng.versions.be.throughput.rps, eng.versions[ base ].throughput.rps )
					}
					row &= " #delta# |"
				}
			}
			for( var ver in versionList ){
				var reqs = ( eng.versions.keyExists( ver ) && !eng.versions[ ver ].throughput.isEmpty() ) ? eng.versions[ ver ].throughput.totalRequests : "-"
				row &= " #reqs# |"
			}
			md.append( row )
		}
		md.append( "" )

		// ── Footer ────────────────────────────────────────────────────────────
		md.append( "---" )
		md.append( "_Generated by ColdBox Performance Suite — https://github.com/coldbox/coldbox-platform_" )

		fileWrite( arguments.filePath, md.toList( chr(10) ) )
	}

	// ══════════════════════════════════════════════════════════════════════════
	// REPORT GENERATION — HTML
	// ══════════════════════════════════════════════════════════════════════════

	private void function generateHTMLReport( required struct results, required string filePath ){
		var r           = arguments.results
		var ts          = dateTimeFormat( r.generated, "yyyy-mm-dd HH:nn:ss" )
		var versionList = r.versionsTested
		var hasBE       = versionList.findNoCase( "be" ) > 0
		var baselines   = versionList.filter( function( v ){ return variables.BASELINE_VERSIONS.findNoCase( v ) > 0 } )

		// Colour palette per version (BE always blue, then purple/teal for baselines)
		var versionColors = {
			"be"     : "rgba(13,110,253,0.7)",
			"stable" : "rgba(111,66,193,0.7)",
			"seven"  : "rgba(32,201,151,0.7)"
		}
		var versionBadges = {
			"be"     : "bg-primary",
			"stable" : "bg-secondary",
			"seven"  : "bg-success"
		}

		// Build engine labels
		var engineNames = []
		for( var eid in r.engines ) engineNames.append( r.engines[ eid ].name )

		// Bootstrap / cold start / RPS series, one array per tested version
		var bootstrapSeries = {}
		var coldStartSeries = {}
		var rpsSeries       = {}
		for( var ver in versionList ){
			bootstrapSeries[ ver ] = []
			coldStartSeries[ ver ] = []
			rpsSeries[ ver ]       = []
		}
		for( var eid in r.engines ){
			var eng = r.engines[ eid ]
			for( var ver in versionList ){
				var has = eng.versions.keyExists( ver )
				bootstrapSeries[ ver ].append( ( has && eng.versions[ ver ].appBootstrap.keyExists( "ms" ) ) ? eng.versions[ ver ].appBootstrap.ms : 0 )
				coldStartSeries[ ver ].append( ( has && !eng.versions[ ver ].coldStart.isEmpty() ) ? eng.versions[ ver ].coldStart.totalMs : 0 )
				rpsSeries[ ver ].append( ( has && !eng.versions[ ver ].throughput.isEmpty() ) ? eng.versions[ ver ].throughput.rps : 0 )
			}
		}

		// Build per-scenario chart data (avg + p95 per version)
		var scenarioCharts    = ""
		var scenarioTablesHTML = ""
		var sidx = 0
		for( var scenario in variables.SCENARIOS ){
			sidx++
			var datasets = []
			for( var ver in versionList ){
				var avgs = []
				var p95s = []
				for( var eid in r.engines ){
					var eng = r.engines[ eid ]
					var vs  = ( eng.versions.keyExists( ver ) && eng.versions[ ver ].scenarios.keyExists( scenario.id ) ) ? eng.versions[ ver ].scenarios[ scenario.id ] : {}
					avgs.append( !vs.isEmpty() ? vs.avg : 0 )
					p95s.append( !vs.isEmpty() ? vs.p95 : 0 )
				}
				datasets.append( "{ label: '#variables.VERSIONS[ver].shortLabel# Avg', data: #serializeJSON(avgs)#, backgroundColor: '#versionColors[ver]#' }" )
				var fadedColor = replaceNoCase( versionColors[ ver ], "0.7", "0.3" )
				datasets.append( "{ label: '#variables.VERSIONS[ver].shortLabel# P95', data: #serializeJSON(p95s)#, backgroundColor: '#fadedColor#' }" )
			}

			scenarioCharts &= "
			{
				id: 'chart_scenario_#sidx#',
				title: '#jsStringFormat(scenario.name)# — Avg/P95 Response Time (ms)',
				labels: #serializeJSON(engineNames)#,
				datasets: [#datasets.toList(",")#]
			},"

			// Table
			scenarioTablesHTML &= "<h4 class=""mt-4"">#scenario.name# <small class=""text-muted fs-6"">— #scenario.description#</small></h4>"
			scenarioTablesHTML &= "<div class=""table-responsive""><table class=""table table-sm table-hover table-bordered""><thead class=""table-dark""><tr>"
			scenarioTablesHTML &= "<th>Engine</th><th>Version</th><th>Min</th><th>Avg</th><th>P95</th><th>P99</th><th>Max</th><th>Errors</th></tr></thead><tbody>"
			for( var eid in r.engines ){
				var eng = r.engines[ eid ]
				for( var ver in versionList ){
					if( !eng.versions.keyExists( ver ) ) continue;
					var vd = eng.versions[ ver ]
					if( vd.scenarios.keyExists( scenario.id ) ){
						var s   = vd.scenarios[ scenario.id ]
						var cls = ( ver == "be" ) ? "table-primary" : "table-light"
						scenarioTablesHTML &= "<tr class=""#cls#""><td>#eng.name#</td><td><span class=""badge #versionBadges[ver]#"">#variables.VERSIONS[ver].shortLabel#</span></td>"
						scenarioTablesHTML &= "<td>#s.min#</td><td><strong>#s.avg#</strong></td><td>#s.p95#</td><td>#s.p99#</td><td>#s.max#</td><td>#s.errors# (#s.errorPct#%)</td></tr>"
					}
				}
			}
			scenarioTablesHTML &= "</tbody></table></div>"
		}

		// Cold-start table HTML
		var coldStartHTML = ""
		if( r.coldStartRun ){
			coldStartHTML = "<div class=""table-responsive""><table class=""table table-sm table-hover table-bordered""><thead class=""table-dark""><tr><th>Engine</th><th>Version</th><th>Server Start (ms)</th><th>First Response (ms)</th><th>Total (ms)</th></tr></thead><tbody>"
			for( var eid in r.engines ){
				var eng = r.engines[ eid ]
				for( var ver in versionList ){
					if( !eng.versions.keyExists( ver ) ) continue;
					var vd  = eng.versions[ ver ]
					var cls = ( ver == "be" ) ? "table-primary" : "table-light"
					if( !vd.coldStart.isEmpty() && vd.coldStart.success ){
						coldStartHTML &= "<tr class=""#cls#""><td>#eng.name#</td><td><span class=""badge #versionBadges[ver]#"">#variables.VERSIONS[ver].shortLabel#</span></td>"
						coldStartHTML &= "<td>#vd.coldStart.serverStartMs#</td><td>#vd.coldStart.firstResponseMs#</td><td><strong>#vd.coldStart.totalMs#</strong></td></tr>"
					}
				}
			}
			coldStartHTML &= "</tbody></table></div>"
		}

		// Bootstrap table HTML
		var bootstrapTableHTML = "<div class=""table-responsive""><table class=""table table-sm table-hover table-bordered""><thead class=""table-dark""><tr><th>Engine</th>"
		for( var ver in versionList ) bootstrapTableHTML &= "<th>#variables.VERSIONS[ver].shortLabel# (ms)</th>"
		if( hasBE ) for( var base in baselines ) bootstrapTableHTML &= "<th>Δ BE-#variables.VERSIONS[base].shortLabel#</th>"
		bootstrapTableHTML &= "</tr></thead><tbody>"
		for( var eid in r.engines ){
			var eng = r.engines[ eid ]
			bootstrapTableHTML &= "<tr><td>#eng.name#</td>"
			for( var ver in versionList ){
				var ms = eng.versions.keyExists( ver ) ? eng.versions[ ver ].appBootstrap.ms : "-"
				bootstrapTableHTML &= "<td>#ms#</td>"
			}
			if( hasBE ){
				for( var base in baselines ){
					var delt = "<span>—</span>"
					if( eng.versions.keyExists( "be" ) && eng.versions.keyExists( base ) ){
						delt = formatDeltaHTML( eng.versions.be.appBootstrap.ms, eng.versions[ base ].appBootstrap.ms )
					}
					bootstrapTableHTML &= "<td>#delt#</td>"
				}
			}
			bootstrapTableHTML &= "</tr>"
		}
		bootstrapTableHTML &= "</tbody></table></div>"

		// Throughput table HTML
		var throughputTableHTML = "<div class=""table-responsive""><table class=""table table-sm table-hover table-bordered""><thead class=""table-dark""><tr><th>Engine</th>"
		for( var ver in versionList ) throughputTableHTML &= "<th>#variables.VERSIONS[ver].shortLabel# RPS</th>"
		if( hasBE ) for( var base in baselines ) throughputTableHTML &= "<th>Δ BE-#variables.VERSIONS[base].shortLabel#</th>"
		for( var ver in versionList ) throughputTableHTML &= "<th>#variables.VERSIONS[ver].shortLabel# Requests</th>"
		throughputTableHTML &= "</tr></thead><tbody>"
		for( var eid in r.engines ){
			var eng = r.engines[ eid ]
			throughputTableHTML &= "<tr><td>#eng.name#</td>"
			for( var ver in versionList ){
				var rps = ( eng.versions.keyExists( ver ) && !eng.versions[ ver ].throughput.isEmpty() ) ? eng.versions[ ver ].throughput.rps : "-"
				throughputTableHTML &= "<td>#rps#</td>"
			}
			if( hasBE ){
				for( var base in baselines ){
					var delt = "<span>—</span>"
					if(
						eng.versions.keyExists( "be" ) && !eng.versions.be.throughput.isEmpty() &&
						eng.versions.keyExists( base ) && !eng.versions[ base ].throughput.isEmpty()
					){
						delt = formatDeltaHTML( eng.versions.be.throughput.rps, eng.versions[ base ].throughput.rps )
					}
					throughputTableHTML &= "<td>#delt#</td>"
				}
			}
			for( var ver in versionList ){
				var reqs = ( eng.versions.keyExists( ver ) && !eng.versions[ ver ].throughput.isEmpty() ) ? eng.versions[ ver ].throughput.totalRequests : "-"
				throughputTableHTML &= "<td>#reqs#</td>"
			}
			throughputTableHTML &= "</tr>"
		}
		throughputTableHTML &= "</tbody></table></div>"

		// Legend HTML
		var legendHTML = ""
		for( var ver in versionList ){
			legendHTML &= "<span class=""badge #versionBadges[ver]# me-2"">#variables.VERSIONS[ver].shortLabel#</span> #variables.VERSIONS[ver].label# &nbsp;"
		}

		var html = "<!DOCTYPE html>
<html lang=""en"">
<head>
<meta charset=""UTF-8"">
<meta name=""viewport"" content=""width=device-width, initial-scale=1"">
<title>ColdBox Performance Report — #ts#</title>
<link href=""https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"" rel=""stylesheet"">
<script src=""https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js""></script>
<style>
  body { font-family: system-ui, -apple-system, sans-serif; background: ##f8f9fa; }
  .card { box-shadow: 0 1px 4px rgba(0,0,0,.08); border: none; margin-bottom: 1.5rem; }
  .card-header { font-weight: 600; background: ##343a40; color: ##fff; border-radius: .5rem .5rem 0 0 !important; }
  canvas { max-height: 350px; }
  .delta-better { color: ##198754; font-weight: 600; }
  .delta-worse  { color: ##dc3545; font-weight: 600; }
</style>
</head>
<body>
<div class=""container-fluid py-4"">

  <div class=""d-flex align-items-center mb-4 gap-3"">
    <h1 class=""mb-0"">ColdBox Performance Report</h1>
    <span class=""badge bg-secondary fs-6"">#ts#</span>
  </div>

  <div class=""row g-3 mb-4"">
    <div class=""col-auto""><span class=""badge bg-dark fs-6"">Iterations: #r.iterations#</span></div>
    <div class=""col-auto""><span class=""badge bg-dark fs-6"">Warmup: #r.warmup#</span></div>
    <div class=""col-auto""><span class=""badge bg-dark fs-6"">Throughput: #r.throughputSecs#s</span></div>
    <div class=""col-auto""><span class=""badge bg-dark fs-6"">Cold Start: #r.coldStartRun#</span></div>
  </div>

  <!-- Legend -->
  <div class=""mb-4"">
    #legendHTML#
  </div>

  <!-- Cold Start -->
  #r.coldStartRun ? '<div class=""card""><div class=""card-header"">Engine Cold Start (No Bytecode Cache)</div><div class=""card-body"">' & coldStartHTML & '</div></div>' : ''#

  <!-- Bootstrap -->
  <div class=""card"">
    <div class=""card-header"">ColdBox App Bootstrap Time (ms)</div>
    <div class=""card-body"">
      <div class=""row""><div class=""col-lg-6""><canvas id=""chartBootstrap""></canvas></div><div class=""col-lg-6 mt-3 mt-lg-0"">#bootstrapTableHTML#</div></div>
    </div>
  </div>

  <!-- Throughput -->
  <div class=""card"">
    <div class=""card-header"">Throughput — Sequential RPS (Health Check, #r.throughputSecs#s)</div>
    <div class=""card-body"">
      <div class=""row""><div class=""col-lg-6""><canvas id=""chartThroughput""></canvas></div><div class=""col-lg-6 mt-3 mt-lg-0"">#throughputTableHTML#</div></div>
    </div>
  </div>

  <!-- Scenarios -->
  <div class=""card"">
    <div class=""card-header"">Scenario Latency</div>
    <div class=""card-body"">
      <div id=""scenarioCharts"" class=""row mb-4""></div>
      #scenarioTablesHTML#
    </div>
  </div>

</div>
<script>
const LABELS = #serializeJSON(engineNames)#;

const BOOT_SERIES = #serializeJSON(bootstrapSeries)#;
const RPS_SERIES  = #serializeJSON(rpsSeries)#;
const VERSION_META = #serializeJSON( versionList.reduce( function( acc, v ){ acc[v] = { label: variables.VERSIONS[v].shortLabel, color: versionColors[v] }; return acc }, {} ) )#;

const SCENARIO_CHARTS = [#scenarioCharts#];

function barChart( id, title, labels, datasets ) {
  const ctx = document.getElementById( id );
  if ( !ctx ) return;
  new Chart( ctx, {
    type: 'bar',
    data: { labels, datasets },
    options: {
      responsive: true,
      plugins: { legend: { position: 'top' }, title: { display: true, text: title } },
      scales: { y: { beginAtZero: true } }
    }
  } );
}

function seriesToDatasets( seriesObj ) {
  return Object.keys( seriesObj ).map( key => ( {
    label: VERSION_META[ key ] ? VERSION_META[ key ].label : key,
    data: seriesObj[ key ],
    backgroundColor: VERSION_META[ key ] ? VERSION_META[ key ].color : 'rgba(100,100,100,0.7)'
  } ) );
}

barChart( 'chartBootstrap', 'App Bootstrap Time (ms)', LABELS, seriesToDatasets( BOOT_SERIES ) );
barChart( 'chartThroughput', 'Requests Per Second', LABELS, seriesToDatasets( RPS_SERIES ) );

const scContainer = document.getElementById( 'scenarioCharts' );
SCENARIO_CHARTS.forEach( ( cfg, i ) => {
  const col = document.createElement( 'div' );
  col.className = 'col-lg-6 mb-4';
  col.innerHTML = '<canvas id=""' + cfg.id + '""></canvas>';
  scContainer.appendChild( col );
  barChart( cfg.id, cfg.title, cfg.labels, cfg.datasets );
} );
</script>
</body>
</html>"

		fileWrite( arguments.filePath, html )
	}

	// ══════════════════════════════════════════════════════════════════════════
	// HELPERS
	// ══════════════════════════════════════════════════════════════════════════

	private string function formatDelta( required numeric be, required numeric stable ){
		if( arguments.stable == 0 ) return "-"
		var pct = round( ( ( arguments.be - arguments.stable ) / arguments.stable ) * 100 * 10 ) / 10
		return ( pct < 0 ) ? "#pct#% ✓" : "+#pct#%"
	}

	private string function deltaMs( required numeric be, required numeric stable ){
		var diff = arguments.be - arguments.stable
		return ( diff < 0 ) ? "#diff#ms ✓" : "+#diff#ms"
	}

	private string function formatDeltaHTML( required numeric be, required numeric stable ){
		if( arguments.stable == 0 ) return "<span>—</span>"
		var pct = round( ( ( arguments.be - arguments.stable ) / arguments.stable ) * 100 * 10 ) / 10
		var cls = ( pct < 0 ) ? "delta-better" : "delta-worse"
		var pfx = ( pct < 0 ) ? "" : "+"
		return "<span class=""#cls#"">#pfx##pct#%</span>"
	}

	private void function logMsg( required string msg ){
		systemOutput( arguments.msg, true )
	}

}
