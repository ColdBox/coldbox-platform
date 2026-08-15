/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A recording stand-in for the raw BoxLang SSE emitter.
 *
 * The `SSE()` BIF needs a live web response to stream into, which does not exist under test.
 * This mock satisfies the same four-method contract the real emitter exposes - `send`,
 * `comment`, `close`, `isClosed` - while collecting everything in memory so specs can assert
 * on what a stream actually produced.
 *
 * Wrap it in an SSEEmitter exactly like the real thing:
 *
 * <pre>
 * var mock    = new coldbox.system.testing.mock.web.MockSSEEmitter()
 * var emitter = new coldbox.system.web.context.SSEEmitter( mock, getController() )
 * </pre>
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component accessors="true" {

	/**
	 * Every frame sent, in order: { data, event, id }
	 */
	property name="sentEvents" type="array";

	/**
	 * Every comment line sent, in order
	 */
	property name="comments" type="array";

	/**
	 * Has the stream been closed, either by the producer or by a simulated disconnect?
	 */
	property name="closed" type="boolean";

	/**
	 * Constructor
	 */
	function init(){
		variables.sentEvents = [];
		variables.comments   = [];
		variables.closed     = false;
		return this;
	}

	/**
	 * Record a frame. Mirrors the real emitter's optional event/id arguments.
	 *
	 * @data  The payload
	 * @event The SSE event name
	 * @id    The SSE event id
	 */
	function send(
		required any data,
		string event = "",
		string id    = ""
	){
		variables.sentEvents.append( {
			"data"  : arguments.data,
			"event" : arguments.event,
			"id"    : arguments.id
		} );
		return this;
	}

	/**
	 * Record a comment line
	 *
	 * @text The comment text
	 */
	function comment( required string text ){
		variables.comments.append( arguments.text );
		return this;
	}

	/**
	 * Close the stream
	 */
	function close(){
		variables.closed = true;
		return this;
	}

	/**
	 * Has the client gone away?
	 */
	boolean function isClosed(){
		return variables.closed;
	}

	/****************************************************************
	 * Test helpers *
	 ****************************************************************/

	/**
	 * Simulate the client disconnecting mid-stream.
	 *
	 * Use this to prove that streaming loops terminate and that further sends are dropped
	 * rather than throwing.
	 */
	function simulateDisconnect(){
		variables.closed = true;
		return this;
	}

	/**
	 * All frames carrying the given event name
	 *
	 * @event The SSE event name to filter by
	 */
	array function getEventsNamed( required string event ){
		return variables.sentEvents.filter( ( frame ) => frame.event == event );
	}

	/**
	 * The data payload of the first frame, or an empty string when nothing was sent
	 */
	any function getFirstData(){
		return variables.sentEvents.len() ? variables.sentEvents[ 1 ].data : "";
	}

	/**
	 * The data payload of the most recent frame, or an empty string when nothing was sent
	 */
	any function getLastData(){
		return variables.sentEvents.len() ? variables.sentEvents.last().data : "";
	}

	/**
	 * How many frames were sent
	 */
	numeric function getSentCount(){
		return variables.sentEvents.len();
	}

	/**
	 * Forget everything recorded so far, keeping the open/closed state
	 */
	function reset(){
		variables.sentEvents = [];
		variables.comments   = [];
		return this;
	}

}
