/**
 * This is the ColdBox Executor class which connects your code to the Java
 * Scheduling services to execute tasks on.
 *
 * The native property models the injected Java executor which can be:
 * - Fixed
 * - Cached
 * - Single
 * - Scheduled
 */
component accessors="true" singleton {

	/**
	 * The human name of this executor
	 */
	property name="name";

	/**
	 * The created date time
	 * This is set when the executor is created
	 */
	property name="created" type="date";

	/**
	 * The last activity date time
	 * This happens when a task is submitted
	 */
	property name="lastActivity" type="date";

	/**
	 * Task submission count
	 */
	property
		name   ="taskSubmissionCount"
		type   ="numeric"
		default=0;

	/**
	 * The native Java executor class modeled in this executor
	 */
	property name="native";

	/**
	 * The default timeout the executor service will wait for all of it's tasks to shutdown.
	 * The default is 30 seconds. This number is in seconds.
	 */
	property
		name   ="shutdownTimeout"
		type   ="numeric"
		default="30";

	// Prepare the static time unit class
	this.$timeUnit = new coldbox.system.async.time.TimeUnit();

	variables.features = {
		"ScheduledThreadPoolExecutor" : {
			"pool"          : true,
			"taskMethods"   : true,
			"isTerminating" : true,
			"queue"         : true
		},
		"ThreadPoolExecutor" : {
			"pool"          : true,
			"taskMethods"   : true,
			"isTerminating" : true,
			"queue"         : true
		},
		"ForkJoinPool" : {
			"pool"          : false,
			"taskMethods"   : false,
			"isTerminating" : true,
			"queue"         : false
		},
		"ThreadPerTaskExecutor" : {
			"pool"          : false,
			"taskMethods"   : false,
			"isTerminating" : false,
			"queue"         : false
		}
	};

	variables.healthThresholds = {
		"poolUtilization"           : { "degraded" : 75, "critical" : 95 },
		"threadUtilization"         : { "degraded" : 75, "critical" : 95 },
		"queueUtilization"          : { "degraded" : 70, "critical" : 95 },
		"taskCompletionRate"        : { "degraded" : 50, "critical" : 25 },
		"inactivityMinutes"         : 30,
		"minimumTasksForCompletion" : 10
	};

	/**
	 * Constructor
	 *
	 * @name            The name of the executor
	 * @executor        The native executor class
	 * @debug           Add output debugging
	 * @loadAppContext  Load the CFML App contexts or not, disable if not used
	 * @shutdownTimeout The timeout in seconds to use when gracefully shutting down the executor. Defaults to 30 seconds.
	 */
	Executor function init(
		required name,
		required executor,
		boolean debug           = false,
		boolean loadAppContext  = true,
		numeric shutdownTimeout = 30
	){
		variables.name                = arguments.name;
		variables.native              = arguments.executor;
		variables.debug               = arguments.debug;
		variables.loadAppContext      = arguments.loadAppContext;
		variables.shutdownTimeout     = arguments.shutdownTimeout;
		variables.created             = now();
		variables.lastActivity        = variables.created;
		variables.taskSubmissionCount = 0;

		return this;
	}

	/****************************************************************
	 * Executor Submit Tasks *
	 ****************************************************************/

	/**
	 * Submit a task into the executor which can return a result if any.
	 * The result of this call is a ColdBox FutureTask from which you can monitor,
	 * cancel, or get the result of the  the executing task.
	 *
	 * @callable The callable closure/lambda/cfc to execute
	 * @method   The default method to execute if the runnable is a CFC, defaults to `run()`
	 *
	 * @return A ColdBox Future Task object
	 */
	FutureTask function submit( required callable, method = "run" ){
		var jCallable = createDynamicProxy(
			new coldbox.system.async.cbproxies.models.Callable(
				arguments.callable,
				arguments.method,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.concurrent.Callable" ]
		);

		// Update the last activity
		variables.lastActivity = now();
		variables.taskSubmissionCount++;

		// Send for execution
		return new coldbox.system.async.tasks.FutureTask( variables.native.submit( jCallable ) );
	}

	/****************************************************************
	 * Executor Utility Methods *
	 ****************************************************************/

	/**
	 * Checks if the executor has a feature based on the type and feature name.
	 *
	 * @feature The feature to check for, e.g., "hasPool", "hasTaskMethods", "hasIsTerminating"
	 *
	 * @return true if the feature exists for the type, false otherwise
	 */
	private boolean function hasFeature( required string feature ){
		var classType = variables.native.getClass().getSimpleName();
		if ( !variables.features.keyExists( classType ) ) {
			return false;
		}
		return variables.features[ classType ][ feature ];
	}

	/**
	 * Returns true if all tasks have completed following shut down.
	 */
	boolean function isTerminated(){
		return variables.native.isTerminated();
	}

	/**
	 * Returns true if this executor is in the process of terminating after shutdown() or shutdownNow() but has
	 * not completely terminated.
	 */
	boolean function isTerminating(){
		if ( hasFeature( "isTerminating" ) ) {
			return variables.native.isTerminating();
		}
		return false;
	}

	/**
	 * Returns true if this executor has been shut down.
	 */
	boolean function isShutdown(){
		return variables.native.isShutdown();
	}

	/**
	 * Check if executor is healthy (simple boolean check)
	 * Uses current stats to determine health
	 *
	 * @return boolean True if status is "healthy" or "idle"
	 */
	boolean function isHealthy(){
		var stats = getStats();
		return listFindNoCase( "healthy,idle", stats.healthStatus ) > 0;
	}

	/**
	 * Blocks until all tasks have completed execution after a shutdown request, or the timeout occurs, or
	 * the current thread is interrupted, whichever happens first.
	 *
	 * @timeout  The maximum time to wait
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 *
	 * @return true if all tasks have completed following shut down
	 *
	 * @throws InterruptedException - if interrupted while waiting
	 */
	boolean function awaitTermination( required numeric timeout, timeUnit = "seconds" ){
		return variables.native.awaitTermination(
			javacast( "long", arguments.timeout ),
			this.$timeUnit.get( arguments.timeUnit )
		);
	}

	/**
	 * Shuts down the executor in two phases, first by calling the shutdown() and rejecting all incoming tasks.
	 * Second, calling shutdownNow() aggressively if tasks did not shutdown on time to cancel any lingering tasks.
	 *
	 * @timeout The timeout in seconds to wait for the shutdown.  By default we use the default on the property shutdownTimeout (30s)
	 */
	Executor function shutdownAndAwaitTermination( numeric timeout = variables.shutdownTimeout ){
		var sTime = getTickCount();
		// Disable new tasks from being submitted
		shutdown();
		try {
			out( "Executor (#getName()#) shutdown executed, waiting for tasks to finalize..." );

			// Wait for tasks to terminate
			if ( !awaitTermination( arguments.timeout ) ) {
				out( "Executor tasks did not shutdown, forcibly shutting down executor (#getName()#)..." );

				// Cancel all tasks forcibly
				var taskList = shutdownNow();

				out( "Tasks waiting execution on executor (#getName()#) -> #taskList.toString()#" );

				// Wait again now forcibly
				if ( !awaitTermination( arguments.timeout ) ) {
					err( "Executor (#getName()#) did not terminate even gracefully :(" );
					return this;
				}
			}
			out( "Executor (#getName()#) shutdown completed in (#numberFormat( getTickCount() - sTime )#ms)" );
		}
		// Catch if exceptions or interrupted
		catch ( any e ) {
			out( "Executor (#getName()#) shutdown interrupted or exception thrown (#e.message & e.detail#) :)" );
			// force it down!
			shutdownNow();
			// Preserve interrupt status
			createObject( "java", "java.lang.Thread" ).currentThread().interrupt();
		}
		return this;
	}

	/**
	 * Initiates an orderly shutdown in which previously submitted tasks are executed, but no new tasks will be accepted.
	 * Invocation has no additional effect if already shut down.
	 *
	 * This method does not wait for previously submitted tasks to complete execution. Use awaitTermination to do that.
	 *
	 */
	Executor function shutdown(){
		variables.native.shutdown();
		return this;
	}

	/**
	 * Attempts to stop all actively executing tasks, halts the processing of
	 * waiting tasks, and returns a list of the tasks that were awaiting execution.
	 *
	 * This method does not wait for actively executing tasks to terminate. Use awaitTermination to do that.
	 *
	 * There are no guarantees beyond best-effort attempts to stop processing actively executing tasks.
	 * This implementation cancels tasks via Thread.interrupt(), so any task that fails to respond to interrupts may never
	 * terminate.
	 *
	 * @return list of tasks that never commenced execution
	 */
	any function shutdownNow(){
		return variables.native.shutdownNow();
	}

	/**
	 * Returns the task queue used by this executor.
	 * If the executor has no queue, an empty LinkedBlockingQueue is returned.
	 *
	 * @return A queue that holds the tasks submitted to this executor.
	 */
	any function getQueue(){
		return hasFeature( "queue" )
		 ? variables.native.getQueue()
		 : createObject( "java", "java.util.concurrent.LinkedBlockingQueue" ).init();
	}

	/**
	 * Returns the approximate number of threads that are actively executing tasks.
	 */
	numeric function getActiveCount(){
		return hasFeature( "taskMethods" ) ? variables.native.getActiveCount() : 0;
	}

	/**
	 * Returns the approximate total number of tasks that have ever been scheduled for execution.
	 */
	numeric function getTaskCount(){
		return hasFeature( "taskMethods" ) ? variables.native.getTaskCount() : 0;
	}

	/**
	 * Returns the approximate total number of tasks that have completed execution.
	 */
	numeric function getCompletedTaskCount(){
		return hasFeature( "taskMethods" ) ? variables.native.getCompletedTaskCount() : 0;
	}

	/**
	 * Returns the core number of threads.
	 */
	numeric function getCorePoolSize(){
		return hasFeature( "pool" ) ? variables.native.getCorePoolSize() : 0;
	}

	/**
	 * Returns the largest number of threads that have ever simultaneously been in the pool.
	 */
	numeric function getLargestPoolSize(){
		return hasFeature( "pool" ) ? variables.native.getLargestPoolSize() : 0;
	}

	/**
	 * Returns the maximum allowed number of threads.
	 */
	numeric function getMaximumPoolSize(){
		return hasFeature( "pool" ) ? variables.native.getMaximumPoolSize() : 0;
	}

	/**
	 * Returns the current number of threads in the pool.
	 */
	numeric function getPoolSize(){
		return hasFeature( "pool" ) ? variables.native.getPoolSize() : 0;
	}

	/**
	 * Our very own stats struct map to give you a holistic view of the schedule
	 * and it's executor
	 *
	 * @return struct of data about the executor and the schedule
	 */
	struct function getStats(){
		var uptimeSeconds = dateDiff( "s", variables.created, now() );
		var stats         = {
			"created"                   : dateTimeFormat( variables.created, "iso" ),
			"features"                  : variables.features[ variables.native.getClass().getSimpleName() ],
			"lastActivity"              : dateTimeFormat( variables.lastActivity, "iso" ),
			"lastActivityMinutesAgo"    : dateDiff( "n", variables.lastActivity, now() ),
			"lastActivitySecondsAgo"    : dateDiff( "s", variables.lastActivity, now() ),
			"name"                      : getName(),
			"thresholds"                : variables.healthThresholds,
			"type"                      : variables.native.getClass().getName(),
			"uptimeDays"                : dateDiff( "d", variables.created, now() ),
			"uptimeSeconds"             : uptimeSeconds,
			// Pool Stats
			"corePoolSize"              : 0,
			"largestPoolSize"           : 0,
			"maximumPoolSize"           : 0,
			"poolSize"                  : 0,
			"poolUtilization"           : 0,
			// Task Stats
			"activeCount"               : 0,
			"allowsCoreThreadTimeOut"   : false,
			"averageTasksPerMinute"     : uptimeSeconds > 0 ? ( variables.taskSubmissionCount / uptimeSeconds ) * 60 : 0,
			"averageTasksPerSecond"     : uptimeSeconds > 0 ? variables.taskSubmissionCount / uptimeSeconds : 0,
			"completedTaskCount"        : 0,
			"keepAliveTimeoutInSeconds" : 0,
			"taskCompletionRate"        : 0,
			"taskCount"                 : 0,
			"taskSubmissionCount"       : variables.taskSubmissionCount,
			"threadsUtilization"        : 0,
			// States
			"isShutdown"                : isShutdown(),
			"isTerminated"              : isTerminated(),
			"isTerminating"             : isTerminating(),
			// Queue Stats
			"queueCapacity"             : 0,
			"queueIsEmpty"              : 0,
			"queueIsFull"               : 0,
			"queueRemainingCapacity"    : 0,
			"queueSize"                 : 0,
			"queueType"                 : 0,
			"queueUtilization"          : 0,
			"healthStatus"              : "unknown",
			"healthReport"              : {}
		};

		// Pool Stats
		if ( hasFeature( "pool" ) ) {
			stats[ "corePoolSize" ]    = getCorePoolSize();
			stats[ "largestPoolSize" ] = getLargestPoolSize();
			stats[ "maximumPoolSize" ] = getMaximumPoolSize();
			stats[ "poolSize" ]        = getPoolSize();
			stats[ "poolUtilization" ] = getMaximumPoolSize() > 0 ? ( getPoolSize() / getMaximumPoolSize() ) * 100 : 0;
		}

		// Task Stats
		if ( hasFeature( "taskMethods" ) ) {
			stats[ "activeCount" ]               = getActiveCount();
			stats[ "allowsCoreThreadTimeOut" ]   = variables.native.allowsCoreThreadTimeOut();
			stats[ "completedTaskCount" ]        = getCompletedTaskCount();
			stats[ "keepAliveTimeoutInSeconds" ] = variables.native.getKeepAliveTime(
				this.$timeUnit.get( "seconds" )
			);
			stats[ "taskCompletionRate" ] = getTaskCount() > 0 ? ( getCompletedTaskCount() / getTaskCount() ) * 100 : 0;
			stats[ "taskCount" ]          = getTaskCount();
			stats[ "threadsUtilization" ] = getPoolSize() > 0 ? ( getActiveCount() / getPoolSize() ) * 100 : 0;
		}

		// Queue Stats
		if ( hasFeature( "queue" ) ) {
			stats[ "queueCapacity" ] = getQueue().size() + getQueue().remainingCapacity();
			stats[ "queueIsEmpty" ]  = getQueue().isEmpty();
			// Check unbounded queues
			stats[ "queueIsFull" ]   = stats.maximumPoolSize >= 2147483647
			 ? false
			 : ( getQueue().remainingCapacity() == 0 );
			stats[ "queueRemainingCapacity" ] = getQueue().remainingCapacity();
			stats[ "queueSize" ]              = getQueue().size();
			stats[ "queueType" ]              = getQueue().getClass().getSimpleName();
			stats[ "queueUtilization" ]       = stats.queueCapacity > 0 ? ( stats.queueSize / stats.queueCapacity ) * 100 : 0;
		}

		// Add health status to stats (this must come last after all stats are calculated)
		stats[ "healthStatus" ] = getHealthStatus( stats );
		stats[ "healthReport" ] = getHealthReport( stats );

		return stats;
	}

	/**
	 * This functions needs to use standard heuristics to determine a health status of the executor.
	 * It should return a value of "healthy", "degraded", "critical", "draining".
	 *
	 * @return string The health status of the executor
	 */
	private function getHealthStatus( required struct stats ){
		var thresholds     = variables.healthThresholds;
		var criticalIssues = [];
		var degradedIssues = [];

		// Shutdown/termination states (highest priority)
		if ( arguments.stats.isTerminated ) return "terminated";
		if ( arguments.stats.isShutdown ) return "shutdown";
		if ( arguments.stats.isTerminating ) return "draining";

		// Critical health issues
		if ( arguments.stats.queueIsFull ) {
			criticalIssues.append( "queue_full" );
		}

		if ( arguments.stats.poolUtilization > thresholds.poolUtilization.critical ) {
			criticalIssues.append( "pool_exhausted" );
		}

		if ( arguments.stats.threadsUtilization > thresholds.threadUtilization.critical ) {
			criticalIssues.append( "threads_exhausted" );
		}

		// Queue utilization critical
		if ( arguments.stats.queueUtilization > thresholds.queueUtilization.critical ) {
			criticalIssues.append( "queue_near_full" );
		}

		// Task completion rate critical
		if (
			arguments.stats.taskCount >= thresholds.minimumTasksForCompletion &&
			arguments.stats.taskCompletionRate < thresholds.taskCompletionRate.critical
		) {
			criticalIssues.append( "task_completion_critical" );
		}

		// Degraded health issues
		if ( arguments.stats.poolUtilization > thresholds.poolUtilization.degraded ) {
			degradedIssues.append( "high_pool_usage" );
		}

		if ( arguments.stats.threadsUtilization > thresholds.threadUtilization.degraded ) {
			degradedIssues.append( "high_thread_usage" );
		}

		// Queue utilization degraded
		if ( arguments.stats.queueUtilization > thresholds.queueUtilization.degraded ) {
			degradedIssues.append( "queue_backing_up" );
		}

		// Task completion rate degraded
		if (
			arguments.stats.taskCount >= thresholds.minimumTasksForCompletion &&
			arguments.stats.taskCompletionRate < thresholds.taskCompletionRate.degraded
		) {
			degradedIssues.append( "task_completion_degraded" );
		}

		// Check for idle state (no activity, no work)
		if (
			arguments.stats.lastActivityMinutesAgo > thresholds.inactivityMinutes &&
			arguments.stats.activeCount == 0 &&
			arguments.stats.queueSize == 0 &&
			!arguments.stats.isShutdown &&
			!arguments.stats.isTerminating
		) {
			return "idle";
		}

		// Return status based on issues found
		if ( criticalIssues.len() > 0 ) return "critical";
		if ( degradedIssues.len() > 0 ) return "degraded";

		return "healthy";
	}

	/**
	 * Provides a comprehensive health report with detailed analysis, issues, and recommendations
	 * Uses the provided stats to generate the report
	 *
	 * @stats struct The stats structure to analyze for health report
	 *
	 * @return struct Detailed health report
	 */
	struct function getHealthReport( required struct stats ){
		var status          = arguments.stats.healthStatus;
		var thresholds      = variables.healthThresholds;
		var issues          = [];
		var recommendations = [];
		var alerts          = [];

		// Analyze pool utilization
		if ( arguments.stats.poolUtilization > thresholds.poolUtilization.critical ) {
			issues.append( "Critical pool utilization: #numberFormat( arguments.stats.poolUtilization, "0.0" )#%" );
			recommendations.append( "Immediately increase maximum pool size or reduce workload" );
			alerts.append( {
				"level"  : "critical",
				"metric" : "poolUtilization",
				"value"  : arguments.stats.poolUtilization
			} );
		} else if ( arguments.stats.poolUtilization > thresholds.poolUtilization.degraded ) {
			issues.append( "High pool utilization: #numberFormat( arguments.stats.poolUtilization, "0.0" )#%" );
			recommendations.append( "Consider increasing maximum pool size" );
			alerts.append( {
				"level"  : "warning",
				"metric" : "poolUtilization",
				"value"  : arguments.stats.poolUtilization
			} );
		}

		// Analyze thread utilization
		if ( arguments.stats.threadsUtilization > thresholds.threadUtilization.critical ) {
			issues.append(
				"Critical thread utilization: #numberFormat( arguments.stats.threadsUtilization, "0.0" )#%"
			);
			recommendations.append( "All threads busy - consider increasing pool size or optimizing tasks" );
			alerts.append( {
				"level"  : "critical",
				"metric" : "threadsUtilization",
				"value"  : arguments.stats.threadsUtilization
			} );
		} else if ( arguments.stats.threadsUtilization > thresholds.threadUtilization.degraded ) {
			issues.append(
				"High thread utilization: #numberFormat( arguments.stats.threadsUtilization, "0.0" )#%"
			);
			recommendations.append( "Monitor thread usage patterns and consider capacity planning" );
			alerts.append( {
				"level"  : "warning",
				"metric" : "threadsUtilization",
				"value"  : arguments.stats.threadsUtilization
			} );
		}

		// Analyze queue health
		if ( arguments.stats.queueIsFull ) {
			issues.append( "Queue is full: #arguments.stats.queueSize#/#arguments.stats.queueCapacity# capacity" );
			recommendations.append( "Queue rejecting tasks - increase capacity or improve processing speed" );
			alerts.append( {
				"level"  : "critical",
				"metric" : "queueFull",
				"value"  : true
			} );
		} else if ( arguments.stats.queueUtilization > thresholds.queueUtilization.critical ) {
			issues.append(
				"Queue near capacity: #numberFormat( arguments.stats.queueUtilization, "0.0" )#% (#arguments.stats.queueSize#/#arguments.stats.queueCapacity#)"
			);
			recommendations.append( "Queue filling up - monitor for processing bottlenecks" );
			alerts.append( {
				"level"  : "critical",
				"metric" : "queueUtilization",
				"value"  : arguments.stats.queueUtilization
			} );
		} else if ( arguments.stats.queueUtilization > thresholds.queueUtilization.degraded ) {
			issues.append(
				"Queue utilization elevated: #numberFormat( arguments.stats.queueUtilization, "0.0" )#% (#arguments.stats.queueSize#/#arguments.stats.queueCapacity#)"
			);
			recommendations.append( "Monitor queue growth trends" );
			alerts.append( {
				"level"  : "warning",
				"metric" : "queueUtilization",
				"value"  : arguments.stats.queueUtilization
			} );
		}

		// Analyze task completion rates
		if ( arguments.stats.taskCount >= thresholds.minimumTasksForCompletion ) {
			if ( arguments.stats.taskCompletionRate < thresholds.taskCompletionRate.critical ) {
				issues.append(
					"Very low task completion rate: #numberFormat( arguments.stats.taskCompletionRate, "0.0" )#%"
				);
				recommendations.append( "Investigate task failures or performance issues" );
				alerts.append( {
					"level"  : "critical",
					"metric" : "taskCompletionRate",
					"value"  : arguments.stats.taskCompletionRate
				} );
			} else if ( arguments.stats.taskCompletionRate < thresholds.taskCompletionRate.degraded ) {
				issues.append(
					"Low task completion rate: #numberFormat( arguments.stats.taskCompletionRate, "0.0" )#%"
				);
				recommendations.append( "Monitor task success patterns" );
				alerts.append( {
					"level"  : "warning",
					"metric" : "taskCompletionRate",
					"value"  : arguments.stats.taskCompletionRate
				} );
			}
		}

		// Analyze activity patterns
		if ( status == "idle" ) {
			issues.append( "Executor idle for #arguments.stats.lastActivityMinutesAgo# minutes" );
			recommendations.append( "Verify if inactivity is expected or indicates a problem" );
		}

		// Performance insights
		var insights = [];
		if ( arguments.stats.averageTasksPerSecond > 0 ) {
			insights.append(
				"Processing rate: #numberFormat( arguments.stats.averageTasksPerSecond, "0.00" )# tasks/second"
			);
		}
		if ( arguments.stats.uptimeDays > 0 ) {
			insights.append( "Uptime: #arguments.stats.uptimeDays# days" );
		}

		// Resource efficiency analysis
		if ( arguments.stats.poolSize > 0 && arguments.stats.averageTasksPerSecond > 0 ) {
			var tasksPerThread = arguments.stats.averageTasksPerSecond / arguments.stats.poolSize;
			insights.append( "Efficiency: #numberFormat( tasksPerThread, "0.00" )# tasks/second per thread" );
		}

		return {
			"status"          : status,
			"summary"         : issues.len() == 0 ? "Executor operating normally" : "#issues.len()# issue#issues.len() == 1 ? "" : "s"# detected",
			"issues"          : issues,
			"recommendations" : recommendations,
			"alerts"          : alerts,
			"insights"        : insights,
			"lastChecked"     : dateTimeFormat( now(), "iso" )
		};
	}

	/**
	 * Utility to send output to the output stream
	 *
	 * @var Variable/Message to send
	 */
	Executor function out( required var ){
		createObject( "java", "java.lang.System" ).out.println( arguments.var.toString() );
		return this;
	}

	/**
	 * Utility to send to output to the error stream
	 *
	 * @var Variable/Message to send
	 */
	Executor function err( required var ){
		createObject( "java", "java.lang.System" ).err.println( arguments.var.toString() );
		return this;
	}

}
