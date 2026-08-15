/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A ColdBox decorator over the BoxLang SSE emitter.
 *
 * The raw emitter produced by the BoxLang `SSE()` BIF knows nothing about ColdBox, so it
 * cannot render views or marshall data through the framework. This decorator delegates the
 * four native methods (`send`, `comment`, `close`, `isClosed`) and layers on the
 * ColdBox-aware helpers.
 *
 * It also absorbs the `if( !emitter.isClosed() )` guard that the raw emitter forces around
 * every single call: once the client disconnects, every send here becomes a silent no-op so
 * a dropped connection ends the stream instead of throwing.
 *
 * Wire formatting - splitting multi-line payloads across repeated `data:` lines, event ids,
 * retry fields - is the BIF's responsibility. This decorator only normalizes line endings so
 * views authored on Windows do not emit stray carriage returns into the stream.
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component accessors="true" {

	/**
	 * The raw BoxLang SSE emitter we decorate
	 */
	property name="emitter";

	/**
	 * ColdBox Controller
	 */
	property name="controller";

	/**
	 * How many frames we have sent on this stream
	 */
	property name="sentCount" type="numeric";

	/**
	 * Constructor
	 *
	 * @emitter    The raw BoxLang emitter handed to us by the SSE() BIF
	 * @controller The ColdBox controller
	 */
	function init( required emitter, required controller ){
		variables.emitter    = arguments.emitter
		variables.controller = arguments.controller
		variables.sentCount  = 0
		return this
	}

	/****************************************************************
	 * Delegated to the BoxLang emitter *
	 ****************************************************************/

	/**
	 * Has the client disconnected?
	 */
	boolean function isClosed(){
		return variables.emitter.isClosed()
	}

	/**
	 * Is the stream still open? Inverse of isClosed(), reads better in loops.
	 *
	 * <pre>
	 * while( emitter.isOpen() ){ ... }
	 * </pre>
	 */
	boolean function isOpen(){
		return !isClosed()
	}

	/**
	 * Send a frame down the stream. A no-op once the client has disconnected.
	 *
	 * Complex data is serialized to JSON by BoxLang. Simple values are sent as-is with
	 * line endings normalized.
	 *
	 * @data  The payload. Simple or complex.
	 * @event The SSE event name. Omitted from the frame when empty.
	 * @id    The SSE event id. Omitted from the frame when empty.
	 *
	 * @return SSEEmitter
	 */
	function send( required any data, string event = "", string id = "" ){
		if ( isClosed() ) {
			return this
		}

		var payload = isSimpleValue( arguments.data ) ? normalizeNewlines( arguments.data ) : arguments.data

		// Only pass through what was actually provided, so we never emit empty event/id fields
		if ( len( arguments.event ) && len( arguments.id ) ) {
			variables.emitter.send( payload, arguments.event, arguments.id )
		} else if ( len( arguments.event ) ) {
			variables.emitter.send( payload, arguments.event )
		} else {
			variables.emitter.send( payload )
		}

		variables.sentCount++

		return this
	}

	/**
	 * Send an SSE comment line. Useful for manual keep-alives and for nudging proxies.
	 *
	 * @text The comment text
	 *
	 * @return SSEEmitter
	 */
	function comment( required string text ){
		if ( isClosed() ) {
			return this
		}
		variables.emitter.comment( arguments.text )
		return this
	}

	/**
	 * Gracefully close the stream. Safe to call more than once.
	 *
	 * @return SSEEmitter
	 */
	function close(){
		if ( isClosed() ) {
			return this
		}
		variables.emitter.close()
		return this
	}

	/****************************************************************
	 * ColdBox additions *
	 ****************************************************************/

	/**
	 * Render a ColdBox view and push the markup as a single frame.
	 *
	 * This is the HTMX / live fragment path. Rendering goes through the standard
	 * `Renderer`, so module lookup, view caching and the pre/post view interception
	 * points all behave exactly as they do in a normal request.
	 *
	 * <pre>
	 * emitter.sendView( view = "posts/_card", args = { post : post }, event = "newPost" )
	 * </pre>
	 *
	 * @view   The view to render
	 * @args   Arguments to pass into the view, available as `args`
	 * @layout Optional layout to wrap the view in. Layout-less by default - SSE frames
	 *         are usually fragments, not pages.
	 * @module The module to render the view from explicitly
	 * @event  The SSE event name
	 * @id     The SSE event id
	 *
	 * @return SSEEmitter
	 */
	function sendView(
		required string view,
		struct args   = {},
		string layout = "",
		string module = "",
		string event  = "",
		string id     = ""
	){
		if ( isClosed() ) {
			return this
		}

		var content = len( arguments.layout ) ? variables.controller
			.getRenderer()
			.layout(
				layout = arguments.layout,
				view   = arguments.view,
				module = arguments.module,
				args   = arguments.args
			) : variables.controller
			.getRenderer()
			.view(
				view   = arguments.view,
				args   = arguments.args,
				module = arguments.module
			)

		return send( content, arguments.event, arguments.id )
	}

	/**
	 * Render a ColdBox layout and push the markup as a single frame. Use when a frame needs
	 * a fully wrapped document rather than a bare fragment.
	 *
	 * @layout The layout to render
	 * @view   Optional view to render inside the layout
	 * @args   Arguments to pass into the view
	 * @module The module to render the layout from explicitly
	 * @event  The SSE event name
	 * @id     The SSE event id
	 *
	 * @return SSEEmitter
	 */
	function sendLayout(
		required string layout,
		string view   = "",
		struct args   = {},
		string module = "",
		string event  = "",
		string id     = ""
	){
		if ( isClosed() ) {
			return this
		}

		var content = variables.controller
			.getRenderer()
			.layout(
				layout = arguments.layout,
				view   = arguments.view,
				module = arguments.module,
				args   = arguments.args
			)

		return send( content, arguments.event, arguments.id )
	}

	/**
	 * Marshall data through the ColdBox DataMarshaller and push it as a frame.
	 *
	 * Use this over `send()` when you need a format other than JSON, or when the data
	 * object implements the `$renderdata()` convention.
	 *
	 * @data  The data to marshall
	 * @type  The marshalling type: json, xml, wddx, plain, text, html
	 * @event The SSE event name
	 * @id    The SSE event id
	 *
	 * @return SSEEmitter
	 */
	function sendData(
		required any data,
		string type  = "json",
		string event = "",
		string id    = ""
	){
		if ( isClosed() ) {
			return this
		}

		var content = variables.controller
			.getDataMarshaller()
			.marshallData( type = arguments.type, data = arguments.data )

		return send( content, arguments.event, arguments.id )
	}

	/**
	 * Send a conventional error frame: `event: error` carrying `{ error, code }`.
	 *
	 * @message The error message
	 * @code    An optional application error code
	 *
	 * @return SSEEmitter
	 */
	function sendError( required string message, string code = "" ){
		return send( { "error" : arguments.message, "code" : arguments.code }, "error" )
	}

	/**
	 * Conditionally send a frame. Sugar so streaming loops do not have to nest ifs.
	 *
	 * @condition Only send when true
	 * @data      The payload
	 * @event     The SSE event name
	 * @id        The SSE event id
	 *
	 * @return SSEEmitter
	 */
	function sendIf(
		required boolean condition,
		required any data,
		string event = "",
		string id    = ""
	){
		if ( !arguments.condition ) {
			return this
		}
		return send( arguments.data, arguments.event, arguments.id )
	}

	/**
	 * Send a manual keep-alive comment to hold idle proxies open.
	 *
	 * @return SSEEmitter
	 */
	function heartbeat(){
		return comment( "keep-alive" )
	}

	/****************************************************************
	 * Private *
	 ****************************************************************/

	/**
	 * Normalize CRLF and bare CR to LF.
	 *
	 * Rendered views frequently carry Windows line endings. The SSE wire format is
	 * LF delimited, so leaving CRs in place produces stray carriage returns inside the
	 * payload the client receives.
	 *
	 * @content The content to normalize
	 */
	private string function normalizeNewlines( required string content ){
		return arguments.content.reReplace( "\r\n?", chr( 10 ), "all" )
	}

}
