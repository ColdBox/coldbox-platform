/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Invokes the BoxLang `SSE()` BIF on behalf of the request context.
 *
 * This exists for one reason: name resolution. `RequestContext` exposes an `sse()` method whose
 * signature matches the BIF's named arguments, so an unqualified `SSE( callback : ..., cors : ... )`
 * call from inside that component resolves back to the component's own method and recurses until
 * the stack blows. Isolating the BIF call in a component that has no colliding member makes the
 * resolution unambiguous.
 *
 * BoxLang only - the BIF does not exist on CFML engines. Callers are expected to have already
 * verified the runtime.
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component singleton {

	/**
	 * Open a Server-Sent Events stream.
	 *
	 * @callback          A closure/lambda receiving the raw BoxLang emitter
	 * @keepAliveInterval Milliseconds between automatic keep-alive comments. 0 disables.
	 * @retry             Client reconnect hint in milliseconds. 0 omits the field.
	 * @cors              CORS origin. `*` for all, empty for none.
	 *
	 * @return SSEStreamer
	 */
	function stream(
		required any callback,
		numeric keepAliveInterval = 0,
		numeric retry             = 0,
		string cors               = ""
	){
		SSE(
			callback         : arguments.callback,
			keepAliveInterval: arguments.keepAliveInterval,
			retry            : arguments.retry,
			cors             : arguments.cors
		);

		return this;
	}

}
