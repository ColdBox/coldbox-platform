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
	 * Set a delay in the running of the task that will be registered with this schedule
	 *
	 * @delay The delay that will be used before executing the task
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 */
	function delay( numeric delay, timeUnit = "seconds" ){
		variables.delay    = arguments.delay;
		variables.timeUnit = this.jTimeUnit.get( arguments.timeUnit );
		return this;
	}

	/**
	 * Set the period of execution for the schedule
	 *
	 * @period The period of execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 */
	function every( numeric period, timeUnit = "seconds" ){
		variables.period   = arguments.period;
		variables.timeUnit = this.jTimeUnit.get( arguments.timeUnit );
		return this;
	}

	/**
	 * Set the time unit in days
	 */
	Executor function inDays(){
		variables.timeUnit = this.jTimeUnit.get( "days" );
		return this;
	}

	/**
	 * Set the time unit in hours
	 */
	Executor function inHours(){
		variables.timeUnit = this.jTimeUnit.get( "hours" );
		return this;
	}

	/**
	 * Set the time unit in microseconds
	 */
	Executor function inMicroseconds(){
		variables.timeUnit = this.jTimeUnit.get( "microseconds" );
		return this;
	}

	/**
	 * Set the time unit in milliseconds
	 */
	Executor function inMilliseconds(){
		variables.timeUnit = this.jTimeUnit.get( "milliseconds" );
		return this;
	}

	/**
	 * Set the time unit in minutes
	 */
	Executor function inMinutes(){
		variables.timeUnit = this.jTimeUnit.get( "minutes" );
		return this;
	}

	/**
	 * Set the time unit in nanoseconds
	 */
	Executor function inNanoseconds(){
		variables.timeUnit = this.jTimeUnit.get( "nanoseconds" );
		return this;
	}

	/**
	 * Set the time unit in seconds
	 */
	Executor function inSeconds(){
		variables.timeUnit = this.jTimeUnit.get( "seconds" );
		return this;
	}
}