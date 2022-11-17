component{

	function configure(){
		return {
			// This flag enables/disables the tracking of request data to our storage facilities
			// To disable all tracking, turn this master key off
			enabled          : false,
			// This setting controls if you will activate the debugger for visualizations ONLY
			// The debugger will still track requests even in non debug mode.
			debugMode        : controller.getSetting( name = "environment", defaultValue = "production" ) == "development",
			// The URL password to use to activate it on demand
			debugPassword    : "cb:null",
			// This flag enables/disables the end of request debugger panel docked to the bottem of the page.
			// If you disable i, then the only way to visualize the debugger is via the `/cbdebugger` endpoint
			requestPanelDock : true,
			// Request Tracker Options
			requestTracker   : {
				// Store the request profilers in heap memory or in cachebox, default is cachebox
				storage                      : "cachebox",
				// Which cache region to store the profilers in
				cacheName                    : "template",
				// Track all cbdebugger events, by default this is off, turn on, when actually profiling yourself :) How Meta!
				trackDebuggerEvents          : false,
				// Expand by default the tracker panel or not
				expanded                     : false,
				// Slow request threshold in milliseconds, if execution time is above it, we mark those transactions as red
				slowExecutionThreshold       : 1000,
				// How many tracking profilers to keep in stack
				maxProfilers                 : 50,
				// If enabled, the debugger will monitor the creation time of CFC objects via WireBox
				profileWireBoxObjectCreation : false,
				// Profile model objects annotated with the `profile` annotation
				profileObjects               : false,
				// If enabled, will trace the results of any methods that are being profiled
				traceObjectResults           : false,
				// Profile Custom or Core interception points
				profileInterceptions         : false,
				// By default all interception events are excluded, you must include what you want to profile
				includedInterceptions        : [],
				// Control the execution timers
				executionTimers              : {
					expanded           : true,
					// Slow transaction timers in milliseconds, if execution time of the timer is above it, we mark it
					slowTimerThreshold : 250
				},
				// Control the coldbox info reporting
				coldboxInfo : { expanded : false },
				// Control the http request reporting
				httpRequest : {
					expanded        : false,
					// If enabled, we will profile HTTP Body content, disabled by default as it contains lots of data
					profileHTTPBody : false
				}
			},
			// ColdBox Tracer Appender Messages
			tracers     : { enabled : true, expanded : false },
			// Request Collections Reporting
			collections : {
				// Enable tracking
				enabled      : false,
				// Expanded panel or not
				expanded     : false,
				// How many rows to dump for object collections
				maxQueryRows : 50,
				// How many levels to output on dumps for objects
				maxDumpTop   : 5
			},
			// CacheBox Reporting
			cachebox : { enabled : false, expanded : false },
			// Modules Reporting
			modules  : { enabled : false, expanded : false },
			// Quick and QB Reporting
			qb       : {
				enabled   : false,
				expanded  : false,
				// Log the binding parameters
				logParams : true
			},
			// cborm Reporting
			cborm : {
				enabled   : false,
				expanded  : false,
				// Log the binding parameters
				logParams : true
			},
			// Adobe ColdFusion SQL Collector
			acfSql : { enabled : false, expanded : false, logParams : true },
			// Async Manager Reporting
			async  : { enabled : true, expanded : false }
		};
	}

}
