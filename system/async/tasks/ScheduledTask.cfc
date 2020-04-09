component accessors="true"{

	/**
	 * The delay to use in the schedule execution
	 */
	property name="delay" type="numeric";

	/**
	 * The period of execution of the tasks in this schedule
	 */
	property name="period" type="numeric";

	/**
	 * The delay to use when using scheduleWithFixedDelay(), so tasks execute after this delay once completed
	 */
	property name="spacedDelay" type="numeric";

	/**
	 * The task to execute
	 */
	property name="task";

	/**
	 * The method to execute if any
	 */
	property name="method";

	/**
	 * Constructor
	 *
	 * @task
	 * @method
	 */
	ScheduledTask function init(
		required task,
		required executor,
		method="run"
	){
		variables.task = arguments.task;
		variables.executor = arguments.executor;
		variables.method = arguments.method;

		// Init Properties
		variables.period = 0;
		variables.delay = 0;
		variables.spacedDelay = 0;
		variables.timeUnit = variables.executor.$timeUnit.get();

		return this;
	}

	ScheduledFuture function start(){
		if( variables.spacedDelay > 0 ){
			return variables.executor.scheduleWithFixedDelay(
				task : variables.task,
				spacedDelay : variables.spacedDelay,
				delay : variables.delay,
				timeUnit : variables.timeUnit,
				method : variables.method
			);
		} else if( variables.period > 0 ){
			return variables.executor.scheduleAtFixedRate(
				task : variables.task,
				every : variables.period,
				delay : variables.delay,
				timeUnit : variables.timeUnit,
				method : variables.method
			);
		} else {
			return variables.executor.schedule(
				task : variables.task,
				delay : variables.delay,
				timeUnit : variables.timeUnit,
				method : variables.method
			);
		}
	}

	/**
	 * Set a delay in the running of the task that will be registered with this schedule
	 *
	 * @delay The delay that will be used before executing the task
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	Scheduledtask function delay( numeric delay, timeUnit = "milliseconds" ){
		variables.delay    = arguments.delay;
		variables.timeUnit = variables.executor.$timeUnit.get( arguments.timeUnit );
		return this;
	}

	/**
	 * Set the spaced delay between the executions of this scheduled task
	 *
	 * @delay The delay that will be used before executing the task
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	Scheduledtask function spacedDelay( numeric spacedDelay, timeUnit = "milliseconds" ){
		variables.spacedDelay    = arguments.spacedDelay;
		variables.timeUnit = variables.executor.$timeUnit.get( arguments.timeUnit );
		return this;
	}

	/**
	 * Set the period of execution for the schedule
	 *
	 * @period The period of execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	Scheduledtask function every( numeric period, timeUnit = "milliseconds" ){
		variables.period   = arguments.period;
		variables.timeUnit = variables.executor.$timeUnit.get( arguments.timeUnit );
		return this;
	}

	/**
	 * Set the time unit in days
	 */
	Scheduledtask function inDays(){
		variables.timeUnit = variables.executor.$timeUnit.get( "days" );
		return this;
	}

	/**
	 * Set the time unit in hours
	 */
	Scheduledtask function inHours(){
		variables.timeUnit = variables.executor.$timeUnit.get( "hours" );
		return this;
	}

	/**
	 * Set the time unit in microseconds
	 */
	Scheduledtask function inMicroseconds(){
		variables.timeUnit = variables.executor.$timeUnit.get( "microseconds" );
		return this;
	}

	/**
	 * Set the time unit in milliseconds
	 */
	Scheduledtask function inMilliseconds(){
		variables.timeUnit = variables.executor.$timeUnit.get( "milliseconds" );
		return this;
	}

	/**
	 * Set the time unit in minutes
	 */
	Scheduledtask function inMinutes(){
		variables.timeUnit = variables.executor.$timeUnit.get( "minutes" );
		return this;
	}

	/**
	 * Set the time unit in nanoseconds
	 */
	Scheduledtask function inNanoseconds(){
		variables.timeUnit = variables.executor.$timeUnit.get( "nanoseconds" );
		return this;
	}

	/**
	 * Set the time unit in seconds
	 */
	Scheduledtask function inSeconds(){
		variables.timeUnit = variables.executor.$timeUnit.get( "seconds" );
		return this;
	}
}