/**
 * ColdBox Performance Analysis Suite
 *
 * Compares bleeding-edge (BE) vs stable ColdBox 8.1 across four CFML engines:
 *   BoxLang, BoxLang-CFML, Adobe CF 2025, Lucee 7
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
 *   box task run tests/perf-harness/PerformanceSuite.cfc versions=be iterations=100 coldStart=false
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

	variables.SCENARIOS = [
		{
			id          : "health",
			name        : "Health Check",
			description : "Minimal ColdBox lifecycle — no DI, no view, text response",
			bePath      : "/tests/perf-harness/be-app/index.cfm?event=Main.health",
			stablePath  : "/tests/perf-harness/stable-app/index.cfm?event=Main.health"
		},
		{
			id          : "view",
			name        : "Simple View",
			description : "View rendering + layout pipeline",
			bePath      : "/tests/perf-harness/be-app/index.cfm?event=Main.index",
			stablePath  : "/tests/perf-harness/stable-app/index.cfm?event=Main.index"
		},
		{
			id          : "api",
			name        : "JSON API",
			description : "WireBox DI + JSON serialization via renderData",
			bePath      : "/tests/perf-harness/be-app/index.cfm?event=Api.list",
			stablePath  : "/tests/perf-harness/stable-app/index.cfm?event=Api.list"
		},
		{
			id          : "complex",
			name        : "Complex View",
			description : "Multiple model injections + view with data loops",
			bePath      : "/tests/perf-harness/be-app/index.cfm?event=Main.complex",
			stablePath  : "/tests/perf-harness/stable-app/index.cfm?event=Main.complex"
		},
		{
			id          : "module",
			name        : "Module Request",
			description : "Full HMVC module routing + module-scoped DI",
			bePath      : "/tests/perf-harness/be-app/index.cfm?event=perf-module%3AItems.index",
			stablePath  : "/tests/perf-harness/stable-app/index.cfm?event=perf-module%3AItems.index"
		}
	]

	// ══════════════════════════════════════════════════════════════════════════
	// ENTRY POINT
	// ══════════════════════════════════════════════════════════════════════════

	/**
	 * Run the full performance analysis suite.
	 *
	 * @engines       Comma-separated engine IDs or "all". Options: boxlang, boxlang-cfml, adobe-2025, lucee-7
	 * @versions      Comma-separated versions to test. Options: be, stable
	 * @iterations    Number of warm requests per scenario for latency measurement
	 * @warmup        Number of warmup requests to discard before measuring
	 * @throughputSecs Seconds to run the sequential throughput test per version
	 * @coldStart     Whether to measure cold start (requires server restart)
	 * @generateReport Whether to produce HTML + Markdown reports in reports/
	 */
	function run(
		string  engines        = "all",
		string  versions       = "be,stable",
		numeric iterations     = 50,
		numeric warmup         = 10,
		numeric throughputSecs = 10,
		boolean coldStart      = true,
		boolean generateReport = true
	){
		log( "" )
		log( "╔═══════════════════════════════════════════════════════════════╗" )
		log( "║           ColdBox Performance Analysis Suite                  ║" )
		log( "╚═══════════════════════════════════════════════════════════════╝" )
		log( "" )
		log( "  Repo root  : #variables.REPO_ROOT#" )
		log( "  Engines    : #arguments.engines#" )
		log( "  Versions   : #arguments.versions#" )
		log( "  Iterations : #arguments.iterations#" )
		log( "  Warmup     : #arguments.warmup#" )
		log( "  Cold start : #arguments.coldStart#" )
		log( "" )

		var engineList  = parseEngineList( arguments.engines )
		var versionList = listToArray( arguments.versions )

		// Ensure stable ColdBox is installed before tests begin
		if( versionList.findNoCase( "stable" ) ){
			ensureStableColdBox()
		}

		var results = {
			generated     : now(),
			iterations    : arguments.iterations,
			warmup        : arguments.warmup,
			throughputSecs: arguments.throughputSecs,
			coldStartRun  : arguments.coldStart,
			engines       : {}
		}

		// ── Main test loop ────────────────────────────────────────────────────
		for( var engineId in engineList ){
			var engine = variables.ENGINES[ engineId ]
			results.engines[ engineId ] = { name: engine.name, versions: {} }

			log( "" )
			log( "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" )
			log( "  Engine: #engine.name#" )
			log( "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" )

			for( var version in versionList ){
				log( "" )
				log( "  ▶ Version: #version#" )

				var vData = {
					version      : version,
					coldStart    : {},
					appBootstrap : {},
					scenarios    : {},
					throughput   : {}
				}

				// 1. Cold start — stop server, wipe class cache, restart, time first response
				if( arguments.coldStart ){
					log( "    → Measuring cold start (server restart + cache clear)..." )
					vData.coldStart = measureColdStart( engine, version )
					log( "      Cold start: #vData.coldStart.totalMs#ms (server up in #vData.coldStart.serverStartMs#ms, first response in #vData.coldStart.firstResponseMs#ms)" )
				}

				// 2. Ensure server is running (may already be up from cold start)
				if( !arguments.coldStart ){
					log( "    → Starting server..." )
					startServer( engine )
					var healthUrl = variables.BASE_URL & ( version == "be" ? variables.SCENARIOS[ 1 ].bePath : variables.SCENARIOS[ 1 ].stablePath )
					if( !waitForServer( healthUrl, 120 ) ){
						log( "    ✗ Server did not start in time — skipping #engine.name# #version#" )
						continue
					}
				}

				// 3. App bootstrap (re-init ColdBox, time first request)
				log( "    → Measuring app bootstrap time..." )
				vData.appBootstrap = measureAppBootstrap( version )
				log( "      Bootstrap: #vData.appBootstrap.ms#ms" )

				// 4. Warmup
				log( "    → Warming up (#arguments.warmup# requests)..." )
				var warmupUrl = variables.BASE_URL & ( version == "be" ? variables.SCENARIOS[ 1 ].bePath : variables.SCENARIOS[ 1 ].stablePath )
				for( var w = 1; w <= arguments.warmup; w++ ){
					try { cfhttp( url=warmupUrl, method="GET", timeout=15, result="wr" ) } catch( any e ){}
				}

				// 5. Per-scenario latency
				for( var scenario in variables.SCENARIOS ){
					var scenarioUrl = variables.BASE_URL & ( version == "be" ? scenario.bePath : scenario.stablePath )
					log( "    → Scenario [#scenario.name#] (#arguments.iterations# req)..." )
					vData.scenarios[ scenario.id ] = measureScenario( scenarioUrl, arguments.iterations )
					var s = vData.scenarios[ scenario.id ]
					log( "      avg=#s.avg#ms  p95=#s.p95#ms  p99=#s.p99#ms  errors=#s.errors#" )
				}

				// 6. Throughput (sequential)
				var tUrl = variables.BASE_URL & ( version == "be" ? variables.SCENARIOS[ 1 ].bePath : variables.SCENARIOS[ 1 ].stablePath )
				log( "    → Throughput (#arguments.throughputSecs#s sequential)..." )
				vData.throughput = measureThroughput( tUrl, arguments.throughputSecs )
				log( "      #vData.throughput.rps# RPS (#vData.throughput.totalRequests# requests)" )

				results.engines[ engineId ].versions[ version ] = vData

				// Stop server after each version test to avoid port conflicts
				log( "    → Stopping server..." )
				stopServer( engine )
				sleep( 2000 )
			}
		}

		// ── Generate reports ──────────────────────────────────────────────────
		if( arguments.generateReport ){
			log( "" )
			log( "  Generating reports..." )
			var ts       = dateTimeFormat( results.generated, "yyyymmdd_HHnnss" )
			var mdPath   = variables.REPORT_DIR & "perf-report-#ts#.md"
			var htmlPath = variables.REPORT_DIR & "perf-report-#ts#.html"
			generateMarkdownReport( results, mdPath )
			generateHTMLReport( results, htmlPath )
			log( "  ✓ Markdown : #mdPath#" )
			log( "  ✓ HTML     : #htmlPath#" )
		}

		log( "" )
		log( "  ✓ Performance analysis complete!" )
		log( "" )
	}

	// ══════════════════════════════════════════════════════════════════════════
	// SETUP
	// ══════════════════════════════════════════════════════════════════════════

	private array function parseEngineList( required string engines ){
		if( arguments.engines == "all" ) return variables.ENGINES.keyArray()
		return listToArray( arguments.engines )
	}

	private void function ensureStableColdBox(){
		var stableDir  = variables.TASK_DIR & "stable-app/"
		var coldboxDir = stableDir & "coldbox/"
		if( directoryExists( coldboxDir ) ){
			log( "  ✓ Stable ColdBox already installed at #coldboxDir#" )
			return
		}
		log( "  Installing ColdBox stable 8.1.x into stable-app/..." )
		try {
			command( "cd '#stableDir#'" ).run()
			command( "install" ).run()
			command( "cd '#variables.REPO_ROOT#'" ).run()
			log( "  ✓ Stable ColdBox installed." )
		} catch( any e ){
			log( "  ✗ Could not install stable ColdBox: #e.message#. Skipping stable version." )
		}
	}

	// ══════════════════════════════════════════════════════════════════════════
	// SERVER MANAGEMENT
	// ══════════════════════════════════════════════════════════════════════════

	private void function startServer( required struct engine ){
		try {
			command( "server start" )
				.params( serverConfigFile=arguments.engine.serverConfig )
				.flag( "force" )
				.run()
		} catch( any e ){
			log( "  ✗ Server start error: #e.message#" )
		}
	}

	private void function stopServer( required struct engine ){
		try {
			command( "server stop" )
				.params( name=arguments.engine.serverName )
				.flag( "force" )
				.run()
		} catch( any e ){
			// Server may not be running — ignore
		}
	}

	private boolean function waitForServer( required string healthUrl, numeric timeout=120 ){
		var deadline = getTickCount() + ( arguments.timeout * 1000 )
		while( getTickCount() < deadline ){
			try {
				cfhttp( url=arguments.healthUrl, method="GET", timeout=5, result="probe" )
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
					log( "      Cleared: #fullPath#" )
				} catch( any e ){
					log( "      Warning — could not clear #fullPath#: #e.message#" )
				}
			}
		}
	}

	// ══════════════════════════════════════════════════════════════════════════
	// MEASUREMENT
	// ══════════════════════════════════════════════════════════════════════════

	private struct function measureColdStart( required struct engine, required string version ){
		var healthPath = ( arguments.version == "be" ) ? variables.SCENARIOS[ 1 ].bePath : variables.SCENARIOS[ 1 ].stablePath
		var healthUrl  = variables.BASE_URL & healthPath

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
				cfhttp( url=healthUrl, method="GET", timeout=10, result="cr" )
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
		var healthPath = ( arguments.version == "be" ) ? variables.SCENARIOS[ 1 ].bePath : variables.SCENARIOS[ 1 ].stablePath
		var reinitUrl  = variables.BASE_URL & healthPath & "&bsReinit=1"
		var healthUrl  = variables.BASE_URL & healthPath

		// Trigger ColdBox re-initialization
		try {
			cfhttp( url=reinitUrl, method="GET", timeout=30, result="ri" )
		} catch( any e ){}

		sleep( 500 )

		// Time the first post-reinit request (full bootstrap cost)
		var start = getTickCount()
		try {
			cfhttp( url=healthUrl, method="GET", timeout=30, result="br" )
		} catch( any e ){}

		return { ms: getTickCount() - start }
	}

	private struct function measureScenario( required string url, required numeric count ){
		var times  = []
		var errors = 0

		for( var i = 1; i <= arguments.count; i++ ){
			var start = getTickCount()
			try {
				cfhttp( url=arguments.url, method="GET", timeout=30, result="sr" )
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
				cfhttp( url=arguments.url, method="GET", timeout=10, result="tr" )
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
		var md = []
		var r  = arguments.results
		var ts = dateTimeFormat( r.generated, "yyyy-mm-dd HH:nn:ss" )

		md.append( "# ColdBox Performance Analysis Report" )
		md.append( "" )
		md.append( "Generated: #ts# | Iterations: #r.iterations# | Warmup: #r.warmup# | Cold Start: #r.coldStartRun#" )
		md.append( "" )

		// ── Cold Start Table ──────────────────────────────────────────────────
		if( r.coldStartRun ){
			md.append( "## Engine Cold Start (First Request, No Bytecode Cache)" )
			md.append( "" )
			md.append( "| Engine | Version | Server Start (ms) | First Response (ms) | Total (ms) |" )
			md.append( "|--------|---------|:-----------------:|:-------------------:|:----------:|" )
			for( var engineId in r.engines ){
				var eng = r.engines[ engineId ]
				for( var ver in eng.versions ){
					var vd = eng.versions[ ver ]
					if( !vd.coldStart.isEmpty() && vd.coldStart.success ){
						md.append( "| #eng.name# | #ver# | #vd.coldStart.serverStartMs# | #vd.coldStart.firstResponseMs# | #vd.coldStart.totalMs# |" )
					}
				}
			}
			md.append( "" )
		}

		// ── App Bootstrap Table ───────────────────────────────────────────────
		md.append( "## ColdBox App Bootstrap Time (Re-init)" )
		md.append( "" )
		md.append( "| Engine | BE (ms) | Stable (ms) | Delta |" )
		md.append( "|--------|:-------:|:-----------:|:-----:|" )
		for( var engineId in r.engines ){
			var eng    = r.engines[ engineId ]
			var beMs   = eng.versions.keyExists( "be" )     ? eng.versions.be.appBootstrap.ms     : "-"
			var stMs   = eng.versions.keyExists( "stable" ) ? eng.versions.stable.appBootstrap.ms : "-"
			var delta  = ( isNumeric( beMs ) && isNumeric( stMs ) && stMs > 0 ) ? formatDelta( beMs, stMs ) : "-"
			md.append( "| #eng.name# | #beMs# | #stMs# | #delta# |" )
		}
		md.append( "" )

		// ── Scenario Latency Tables ───────────────────────────────────────────
		md.append( "## Warm Request Latency by Scenario" )
		md.append( "" )
		md.append( "> All times in milliseconds. Delta shows BE change vs Stable (negative = BE faster)." )
		md.append( "" )

		for( var scenario in variables.SCENARIOS ){
			md.append( "### #scenario.name#" )
			md.append( "" )
			md.append( "_#scenario.description#_" )
			md.append( "" )
			md.append( "| Engine | Version | Min | Avg | P95 | P99 | Max | Errors |" )
			md.append( "|--------|---------|:---:|:---:|:---:|:---:|:---:|:------:|" )

			for( var engineId in r.engines ){
				var eng = r.engines[ engineId ]
				for( var ver in eng.versions ){
					var vd = eng.versions[ ver ]
					if( vd.scenarios.keyExists( scenario.id ) ){
						var s = vd.scenarios[ scenario.id ]
						md.append( "| #eng.name# | #ver# | #s.min# | #s.avg# | #s.p95# | #s.p99# | #s.max# | #s.errors# (#s.errorPct#%%) |" )
					}
				}
			}

			// Delta row (BE vs stable per engine)
			for( var engineId in r.engines ){
				var eng = r.engines[ engineId ]
				if( eng.versions.keyExists( "be" ) && eng.versions.keyExists( "stable" ) ){
					var beS = eng.versions.be.scenarios[ scenario.id ]     ?: {}
					var stS = eng.versions.stable.scenarios[ scenario.id ] ?: {}
					if( !beS.isEmpty() && !stS.isEmpty() ){
						md.append( "| **#eng.name# Δ** | be vs stable | #deltaMs(beS.min,stS.min)# | #deltaMs(beS.avg,stS.avg)# | #deltaMs(beS.p95,stS.p95)# | #deltaMs(beS.p99,stS.p99)# | #deltaMs(beS.max,stS.max)# | — |" )
					}
				}
			}
			md.append( "" )
		}

		// ── Throughput Table ──────────────────────────────────────────────────
		md.append( "## Throughput (Sequential RPS on Health Check, #r.throughputSecs#s)" )
		md.append( "" )
		md.append( "| Engine | BE RPS | Stable RPS | Delta | BE Requests | Stable Requests |" )
		md.append( "|--------|:------:|:----------:|:-----:|:-----------:|:---------------:|" )
		for( var engineId in r.engines ){
			var eng  = r.engines[ engineId ]
			var beT  = eng.versions.keyExists( "be" )     ? eng.versions.be.throughput     : {}
			var stT  = eng.versions.keyExists( "stable" ) ? eng.versions.stable.throughput : {}
			var beRps  = !beT.isEmpty() ? beT.rps             : "-"
			var stRps  = !stT.isEmpty() ? stT.rps             : "-"
			var beReqs = !beT.isEmpty() ? beT.totalRequests    : "-"
			var stReqs = !stT.isEmpty() ? stT.totalRequests    : "-"
			var delta  = ( isNumeric( beRps ) && isNumeric( stRps ) && stRps > 0 ) ? formatDelta( beRps, stRps ) : "-"
			md.append( "| #eng.name# | #beRps# | #stRps# | #delta# | #beReqs# | #stReqs# |" )
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
		var r    = arguments.results
		var ts   = dateTimeFormat( r.generated, "yyyy-mm-dd HH:nn:ss" )
		var json = serializeJSON( r )

		// Build engine labels and colour-coded bars
		var engineNames = []
		for( var eid in r.engines ) engineNames.append( r.engines[ eid ].name )

		var beBootstrap     = []
		var stableBootstrap = []
		var beColdStart     = []
		var stableColdStart = []
		var beRPS           = []
		var stableRPS       = []
		for( var eid in r.engines ){
			var eng = r.engines[ eid ]
			beBootstrap.append(     eng.versions.keyExists( "be" )     && eng.versions.be.appBootstrap.keyExists("ms")         ? eng.versions.be.appBootstrap.ms             : 0 )
			stableBootstrap.append( eng.versions.keyExists( "stable" ) && eng.versions.stable.appBootstrap.keyExists("ms")     ? eng.versions.stable.appBootstrap.ms         : 0 )
			beColdStart.append(     eng.versions.keyExists( "be" )     && !eng.versions.be.coldStart.isEmpty()                 ? eng.versions.be.coldStart.totalMs            : 0 )
			stableColdStart.append( eng.versions.keyExists( "stable" ) && !eng.versions.stable.coldStart.isEmpty()             ? eng.versions.stable.coldStart.totalMs        : 0 )
			beRPS.append(           eng.versions.keyExists( "be" )     && !eng.versions.be.throughput.isEmpty()                ? eng.versions.be.throughput.rps               : 0 )
			stableRPS.append(       eng.versions.keyExists( "stable" ) && !eng.versions.stable.throughput.isEmpty()            ? eng.versions.stable.throughput.rps           : 0 )
		}

		// Build per-scenario chart data
		var scenarioCharts = ""
		var scenarioTablesHTML = ""
		var sidx = 0
		for( var scenario in variables.SCENARIOS ){
			sidx++
			var beAvgs     = []
			var stableAvgs = []
			var beP95s     = []
			var stableP95s = []
			for( var eid in r.engines ){
				var eng = r.engines[ eid ]
				var beS  = ( eng.versions.keyExists("be")     && eng.versions.be.scenarios.keyExists(scenario.id) )     ? eng.versions.be.scenarios[ scenario.id ]     : {}
				var stS  = ( eng.versions.keyExists("stable") && eng.versions.stable.scenarios.keyExists(scenario.id) ) ? eng.versions.stable.scenarios[ scenario.id ] : {}
				beAvgs.append(     !beS.isEmpty()  ? beS.avg  : 0 )
				stableAvgs.append( !stS.isEmpty()  ? stS.avg  : 0 )
				beP95s.append(     !beS.isEmpty()  ? beS.p95  : 0 )
				stableP95s.append( !stS.isEmpty()  ? stS.p95  : 0 )
			}

			scenarioCharts &= "
			{
				id: 'chart_scenario_#sidx#',
				title: '#jsStringFormat(scenario.name)# — Avg Response Time (ms)',
				labels: #serializeJSON(engineNames)#,
				datasets: [
					{ label: 'BE Avg', data: #serializeJSON(beAvgs)#, backgroundColor: 'rgba(59,130,246,0.7)' },
					{ label: 'Stable Avg', data: #serializeJSON(stableAvgs)#, backgroundColor: 'rgba(168,85,247,0.7)' },
					{ label: 'BE P95', data: #serializeJSON(beP95s)#, backgroundColor: 'rgba(59,130,246,0.3)' },
					{ label: 'Stable P95', data: #serializeJSON(stableP95s)#, backgroundColor: 'rgba(168,85,247,0.3)' }
				]
			},"

			// Table
			scenarioTablesHTML &= "<h4 class=""mt-4"">#scenario.name# <small class=""text-muted fs-6"">— #scenario.description#</small></h4>"
			scenarioTablesHTML &= "<div class=""table-responsive""><table class=""table table-sm table-hover table-bordered""><thead class=""table-dark""><tr>"
			scenarioTablesHTML &= "<th>Engine</th><th>Version</th><th>Min</th><th>Avg</th><th>P95</th><th>P99</th><th>Max</th><th>Errors</th></tr></thead><tbody>"
			for( var eid in r.engines ){
				var eng = r.engines[ eid ]
				for( var ver in eng.versions ){
					var vd = eng.versions[ ver ]
					if( vd.scenarios.keyExists( scenario.id ) ){
						var s   = vd.scenarios[ scenario.id ]
						var cls = ( ver == "be" ) ? "table-primary" : "table-light"
						scenarioTablesHTML &= "<tr class=""#cls#""><td>#eng.name#</td><td><span class=""badge #(ver=='be'?'bg-primary':'bg-secondary')#"">#ver#</span></td>"
						scenarioTablesHTML &= "<td>#s.min#</td><td><strong>#s.avg#</strong></td><td>#s.p95#</td><td>#s.p99#</td><td>#s.max#</td><td>#s.errors# (#s.errorPct#%%)</td></tr>"
					}
				}
			}
			scenarioTablesHTML &= "</tbody></table></div>"
		}

		// Build cold-start table HTML
		var coldStartHTML = ""
		if( r.coldStartRun ){
			coldStartHTML = "<div class=""table-responsive""><table class=""table table-sm table-hover table-bordered""><thead class=""table-dark""><tr><th>Engine</th><th>Version</th><th>Server Start (ms)</th><th>First Response (ms)</th><th>Total (ms)</th></tr></thead><tbody>"
			for( var eid in r.engines ){
				var eng = r.engines[ eid ]
				for( var ver in eng.versions ){
					var vd  = eng.versions[ ver ]
					var cls = ( ver == "be" ) ? "table-primary" : "table-light"
					if( !vd.coldStart.isEmpty() && vd.coldStart.success ){
						coldStartHTML &= "<tr class=""#cls#""><td>#eng.name#</td><td><span class=""badge #(ver=='be'?'bg-primary':'bg-secondary')#"">#ver#</span></td>"
						coldStartHTML &= "<td>#vd.coldStart.serverStartMs#</td><td>#vd.coldStart.firstResponseMs#</td><td><strong>#vd.coldStart.totalMs#</strong></td></tr>"
					}
				}
			}
			coldStartHTML &= "</tbody></table></div>"
		}

		// Bootstrap table HTML
		var bootstrapTableHTML = "<div class=""table-responsive""><table class=""table table-sm table-hover table-bordered""><thead class=""table-dark""><tr><th>Engine</th><th>BE (ms)</th><th>Stable (ms)</th><th>Delta</th></tr></thead><tbody>"
		for( var eid in r.engines ){
			var eng  = r.engines[ eid ]
			var beMs = eng.versions.keyExists("be")     ? eng.versions.be.appBootstrap.ms     : "-"
			var stMs = eng.versions.keyExists("stable") ? eng.versions.stable.appBootstrap.ms : "-"
			var delt = ( isNumeric(beMs) && isNumeric(stMs) && stMs > 0 ) ? formatDeltaHTML(beMs, stMs) : "<span>—</span>"
			bootstrapTableHTML &= "<tr><td>#eng.name#</td><td>#beMs#</td><td>#stMs#</td><td>#delt#</td></tr>"
		}
		bootstrapTableHTML &= "</tbody></table></div>"

		// Throughput table HTML
		var throughputTableHTML = "<div class=""table-responsive""><table class=""table table-sm table-hover table-bordered""><thead class=""table-dark""><tr><th>Engine</th><th>BE RPS</th><th>Stable RPS</th><th>Delta</th><th>BE Requests</th><th>Stable Requests</th></tr></thead><tbody>"
		for( var eid in r.engines ){
			var eng    = r.engines[ eid ]
			var beT    = eng.versions.keyExists("be")     ? eng.versions.be.throughput     : {}
			var stT    = eng.versions.keyExists("stable") ? eng.versions.stable.throughput : {}
			var beRps2 = !beT.isEmpty() ? beT.rps          : "-"
			var stRps2 = !stT.isEmpty() ? stT.rps          : "-"
			var delt   = ( isNumeric(beRps2) && isNumeric(stRps2) && stRps2 > 0 ) ? formatDeltaHTML(beRps2, stRps2) : "<span>—</span>"
			throughputTableHTML &= "<tr><td>#eng.name#</td><td>#beRps2#</td><td>#stRps2#</td><td>#delt#</td><td>#(!beT.isEmpty()?beT.totalRequests:'-')#</td><td>#(!stT.isEmpty()?stT.totalRequests:'-')#</td></tr>"
		}
		throughputTableHTML &= "</tbody></table></div>"

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
  .card-header { font-weight: 600; background: ##343a40; color: #fff; border-radius: .5rem .5rem 0 0 !important; }
  canvas { max-height: 350px; }
  .badge-be { background: ##0d6efd; } .badge-stable { background: ##6f42c1; }
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
    <span class=""badge bg-primary me-2"">BE</span> Bleeding edge (development branch) &nbsp;
    <span class=""badge bg-secondary me-2"">Stable</span> ColdBox 8.1.x
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
const LABELS       = #serializeJSON(engineNames)#;
const BE_BOOT      = #serializeJSON(beBootstrap)#;
const STABLE_BOOT  = #serializeJSON(stableBootstrap)#;
const BE_RPS       = #serializeJSON(beRPS)#;
const STABLE_RPS   = #serializeJSON(stableRPS)#;
const BE_COLD      = #serializeJSON(beColdStart)#;
const STABLE_COLD  = #serializeJSON(stableColdStart)#;

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

barChart( 'chartBootstrap', 'App Bootstrap Time (ms)', LABELS, [
  { label: 'BE',     data: BE_BOOT,     backgroundColor: 'rgba(13,110,253,0.7)'  },
  { label: 'Stable', data: STABLE_BOOT, backgroundColor: 'rgba(111,66,193,0.7)' }
] );

barChart( 'chartThroughput', 'Requests Per Second', LABELS, [
  { label: 'BE',     data: BE_RPS,     backgroundColor: 'rgba(13,110,253,0.7)'  },
  { label: 'Stable', data: STABLE_RPS, backgroundColor: 'rgba(111,66,193,0.7)' }
] );

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
		return ( pct < 0 ) ? "#pct#%% ✓" : "+#pct#%%"
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
		return "<span class=""#cls#"">#pfx##pct#%%</span>"
	}

	private void function log( required string msg ){
		try {
			print.line( arguments.msg )
		} catch( any e ){
			systemOutput( arguments.msg, true )
		}
	}

}
