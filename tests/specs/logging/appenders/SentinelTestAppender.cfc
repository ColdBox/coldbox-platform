/**
 * Test appender for verifying the sentinel ROOT logger fix.
 * Overrides onRegistration() to call getRootLogger() — this simulates
 * the race condition where an appender triggers logger access during
 * LogBox.configure()'s registerAppender loop, before ROOT has been
 * fully re-inserted into the loggerRegistry.
 *
 * When the sentinel is in place, getRootLogger() returns the sentinel.
 * Without the fix, this throws KeyNotFoundException: ROOT.
 */
component extends="coldbox.system.logging.AbstractAppender" {

	/**
	 * Override onRegistration to access the root logger mid-configure.
	 * This reproduces the crash pattern: custom appenders (like Sentry)
	 * that pull DI/interceptors in their constructor, which eventually
	 * calls getRootLogger() while configure() is still mid-loop.
	 */
	function onRegistration(){
		// Access the root logger via the LogBox reference (set by registerAppender chain)
		// This would throw KeyNotFoundException without the sentinel fix
		variables.rootLoggerCheck = getLogBox().getRootLogger();
		return this;
	}

	/**
	 * Expose the captured root logger for assertions.
	 */
	function getCapturedRootLogger(){
		return variables.rootLoggerCheck;
	}

}
