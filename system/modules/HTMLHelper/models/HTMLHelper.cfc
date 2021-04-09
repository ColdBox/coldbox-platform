/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A cool utility that helps you when working with HTML so it is less verbose, more consistency,
 * ORM data binding, auto escaping and much more.
 */
component
	extends  ="coldbox.system.FrameworkSupertype"
	accessors=true
	singleton
{

	/**
	 * Module Settings
	 */
	property name="settings";

	/**
	 * Constructor
	 *
	 * @controller The ColdBox Controller
	 * @controller.inject coldbox
	 */
	function init( required controller ){
		variables.controller = arguments.controller;
		variables.settings   = getModuleSettings( "htmlhelper" );

		// Used for elixir discovery paths
		variables.cachedPaths     = {};
		variables.elixirManifests = {};

		return this;
	}

	/**
	 * Generate a script tag with custom JS content
	 *
	 * @content The content to render out
	 * @sendToHeader Send to header or returned HTML content
	 */
	function addJSContent( required content, boolean sendToHeader = false ){
		var str = "<script>#arguments.content#</script>";
		if ( arguments.sendToHeader ) {
			$htmlhead( str );
		} else {
			return str;
		}
	}

	/**
	 * Generate a style tag with custom CSS content
	 *
	 * @content The content to render out
	 * @sendToHeader Send to header or returned HTML content
	 */
	function addStyleContent( required content, boolean sendToHeader = false ){
		var str = "<style type=""text/css"">#arguments.content#</style>";
		if ( arguments.sendToHeader ) {
			$htmlhead( str );
		} else {
			return str;
		}
	}

	/**
	 * Add a js/css asset(s) to the html head section. You can also pass in a list of assets via the
	 * asset argument to try to load all of them.	You can also make this method return the string
	 * that will be sent to the header instead.
	 *
	 * If the setings: htmlHelper_js_path exists, we will use it as a prefix for JS files (Deprecated by 5.2)
	 * If the setings: htmlhelper_css_path exists, we will use it as a prefix for CSS Files (Deprecated by 5.2)
	 *
	 * In 5.2 the HTML Helper is an internal module, to configure it levareage the `HTMLHelper` module settings.
	 *
	 * This method tracks assets in the PRC via the key: <strong>cbox_assets</strong>
	 *
	 * @asset The asset(s) to load, only js or css files. This can also be a comma delimited list.
	 * @sendToHeader Send to header or returned HTML content
	 * @async HTML5 JavaScript argument: Specifies that the script is executed asynchronously (only for external scripts)
	 * @defer HTML5 JavaScript argument: Specifies that the script is executed when the page has finished parsing (only for external scripts)
	 */
	function addAsset(
		required asset,
		boolean sendToHeader = true,
		boolean async        = false,
		boolean defer        = false
	){
		var sb    = createObject( "java", "java.lang.StringBuilder" ).init( "" );
		var event = controller.getRequestService().getContext();

		// Global location settings
		var jsPath  = getSetting( name = "htmlhelper_js_path", defaultValue = variables.settings.js_path );
		var cssPath = getSetting( name = "htmlhelper_css_path", defaultValue = variables.settings.css_path );

		// Async HTML5 attribute
		var asyncStr = "";
		if ( arguments.async ) {
			asyncStr = " async='async'";
		}
		// Defer HTML5 attribute
		var deferStr = "";
		if ( arguments.defer ) {
			deferStr = " defer='defer'";
		}

		// request assets storage
		event.paramPrivateValue( name = "cbox_assets", value = "" );

		arguments.asset
			.listToArray()
			.map( function( item ){
				return trim( item );
			} )
			.filter( function( item ){
				// Only lead if not loaded
				if ( !listFindNoCase( event.getPrivateValue( "cbox_assets" ), item ) ) {
					return true;
				}
				return false;
			} )
			.each( function( item ){
				// Load Asset
				if ( listLast( listFirst( listFirst( item, "##" ), "?" ), "." ) EQ "js" ) {
					sb.append(
						"<script src=""#jsPath##encodeForHTMLAttribute( item )#"" #asyncStr##deferStr#></script>"
					);
				} else {
					sb.append(
						"<link href=""#cssPath##encodeForHTMLAttribute( item )#"" type=""text/css"" rel=""stylesheet"" />"
					);
				}

				// Store It as Loaded
				event.setPrivateValue(
					name  = "cbox_assets",
					value = listAppend( event.getPrivateValue( "cbox_assets" ), item )
				);
			} );

		// Load it
		if ( arguments.sendToHeader && len( sb.toString() ) ) {
			$htmlhead( sb.toString() );
		} else {
			return sb.toString();
		}
	}

	/**
	 * Generate line breaks
	 * @count The number
	 */
	function br( numeric count = 1 ){
		return repeatString( "<br/>", arguments.count );
	}

	/**
	 * Generate non-breaking spaces
	 * @count The number
	 */
	function nbs( numeric count = 1 ){
		return repeatString( "&nbsp;", arguments.count );
	}

	/**
	 * Generate headers
	 * @content The content
	 * @size The size
	 */
	function heading( required content, numeric size = 1 ){
		return this.tag( "h#arguments.size#", arguments.content );
	}

	/**
	 * Generate tags
	 * @tag The tag to generate
	 * @content The content
	 * @data The data-{key} elements to add
	 * @excludes List of attributes to exclude from the tag generation
	 */
	function tag(
		required tag,
		content         = "",
		struct data     = {},
		string excludes = ""
	){
		// Prepare attribute Exclusions
		var excludeList = "tag,content";
		if ( arguments.excludes.len() ) {
			excludeList = excludeList.listAppend( arguments.excludes );
		}

		// Argument Cleanup
		arguments.delete( "excludes" );
		arguments.delete( "text" );

		// Prepare output
		var buffer = createObject( "java", "java.lang.StringBuilder" ).init( "<#arguments.tag#" );

		// append tag attributes
		flattenAttributes(
			target   = arguments,
			excludes = excludeList,
			buffer   = buffer
		);

		// Prepare content output
		if ( len( arguments.content ) ) {
			// Value Encoding
			if ( variables.settings.encodeValues ) {
				arguments.content = encodeForHTML( arguments.content );
			}
			// Output tag + content
			buffer.append( ">#arguments.content#</#arguments.tag#>" );
		} else {
			buffer.append( "></#arguments.tag#>" );
		}

		// Return HTML
		return buffer.toString();
	}

	/**
	 * Generate anchors
	 * @name The name of the anchor
	 * @text The text of the link
	 * @data The data-{key} elements to add
	 */
	function anchor( required name, text = "", struct data = {} ){
		// HTML 5 compat
		arguments.id      = arguments.name;
		arguments.tag     = "a";
		arguments.content = arguments.text;

		return this.tag( argumentCollection = arguments );
	}

	/**
	 * Create href tags, using the SES base URL or not
	 *
	 * @href Where to link to, this can be an action, absolute, etc If not set, we will create a link to the current executed event.
	 * @text The text of the link
	 * @queryString The query string to append, if needed.
	 * @title The title attribute
	 * @target The target of the href link
	 * @ssl If true, it will change http to https if found in the ses base url ONLY
	 * @noBaseURL Defaults to false. If you want to NOT append a request's ses or html base url, then set this to true
	 * @data A structure that will add data-{key} elements to the HTML control
	 */
	function href(
		href        = "",
		text        = "",
		queryString = "",
		title       = ""
		target      =""
		boolean ssl,
		boolean noBaseURL = false,
		struct data       = {}
	){
		var event = controller.getRequestService().getContext();

		// self-link?
		if ( NOT len( arguments.href ) ) {
			arguments.href = event.getCurrentEvent();
		}

		// Check if we have a base URL and if we need to build our link
		if ( arguments.noBaseURL eq FALSE and NOT find( "://", arguments.href ) ) {
			// Verify SSL Bit
			if ( isNull( arguments.ssl ) ) {
				arguments.ssl = event.isSSL();
			}
			// Build it
			arguments.href = event.buildLink(
				to          = arguments.href,
				ssl         = arguments.ssl,
				queryString = arguments.queryString
			);
		}

		// Setup Excludes + Tag
		arguments.tag      = "a";
		arguments.content  = arguments.text;
		arguments.excludes = "noBaseURL,queryString,ssl";

		return this.tag( argumentCollection = arguments );
	}

	/**
	 * Create link tags, using the SES base URL or not
	 *
	 * @href The href link to link to
	 * @rel The rel attribute
	 * @type The type attribute
	 * @title The title attribute
	 * @media The media attribute
	 * @noBaseURL Defaults to false. If you want to NOT append a request's ses or html base url then set this argument to true
	 * @charset The charset to add, defaults to utf-8
	 * @sendToHeader Send to the header via htmlhead by default, else it returns the content
	 * @data A structure that will add data-{key} elements to the HTML control
	 */
	function link(
		href                 = "",
		rel                  = "stylesheet",
		type                 = "text/css",
		title                = "",
		media                = "",
		boolean noBaseURL    = false,
		charset              = "UTF-8",
		boolean sendToHeader = false,
		struct data          = {}
	){
		// Check if we have a base URL
		arguments.href = prepareBaseLink( arguments.noBaseURL, arguments.href );

		// exclusions
		arguments.excludes = "noBaseURL";
		if ( arguments.rel == "canonical" ) {
			arguments.excludes &= ",type,title,media,charset";
		}

		// Setup Excludes + Tag
		arguments.tag = "link";
		var output    = this.tag( argumentCollection = arguments );
		// Output
		if ( arguments.sendToHeader ) {
			$htmlhead( output );
		} else {
			return output;
		}
	}

	/**
	 * Create image tags using the SES base URL or not
	 *
	 * @src The source URL to link to
	 * @alt The alt tag
	 * @class The class tag
	 * @width The width tag
	 * @height The height tag
	 * @title The title tag
	 * @rel The rel tag
	 * @name The name tag
	 * @noBaseURL Defaults to false. If you want to NOT append a request's ses or html base url then set this argument to true
	 * @data A structure that will add data-{key} elements to the HTML control
	 */
	function img(
		required src,
		alt               = "",
		class             = "",
		width             = "",
		height            = "",
		title             = "",
		rel               = "",
		name              = "",
		boolean noBaseURL = false,
		struct data       = {}
	){
		// ID Normalization
		normalizeID( arguments );
		// Check if we have a base URL
		arguments.src      = prepareBaseLink( arguments.noBaseURL, arguments.src );
		// Setup Excludes + Tag
		arguments.tag      = "img";
		arguments.excludes = "noBaseURL,";

		return this.tag( argumentCollection = arguments );
	}

	/**
	 * Create un-ordered lists according to passed in values and arguments, compressed HTML
	 *
	 * @values Array or list of values
	 * @column If the values is a query, this is the name of the column to get the data from to create the list
	 */
	function ul( required values, string column = "" ){
		arguments.tag = "ul";
		return toHTMLList( argumentCollection = arguments );
	}

	/**
	 * Create ordered lists according to passed in values and arguments, compressed HTML
	 *
	 * @values Array or list of values
	 * @column If the values is a query, this is the name of the column to get the data from to create the list
	 */
	function ol( required values, string column = "" ){
		arguments.tag = "ol";
		return toHTMLList( argumentCollection = arguments );
	}

	/**
	 * Convert a table out of data (either a query or array of structures or array of entities)
	 *
	 * @data The query, array of data
	 * @includes The columns to include
	 * @excludes The columns to exclude
	 * @name The name tag
	 */
	function table(
		required data,
		includes = "",
		excludes = "",
		name     = ""
	){
		var str   = createObject( "java", "java.lang.StringBuilder" ).init( "" );
		var attrs = "";
		var key   = "";

		// ID Normalization
		normalizeID( arguments );

		// Start Table
		str.append( "<table" );

		// flatten extra attributes via arguments
		flattenAttributes( arguments, "data,includes,excludes", str ).append( "><thead><tr>" );

		// Buffer Reference
		arguments.buffer = str;

		// Convert Query To Table Body
		if ( isQuery( arguments.data ) ) {
			queryToTable( argumentCollection = arguments );
		}
		// Convert Array to Table Body
		else if ( isArray( arguments.data ) and arrayLen( arguments.data ) ) {
			var firstMetadata = getMetadata( arguments.data[ 1 ] );
			// Check for array of ORM Object
			if (
				isObject( arguments.data[ 1 ] )
				AND
				structKeyExists( firstMetadata, "persistent" ) && firstMetadata.persistent
			) {
				arguments.data = entityToQuery( arguments.data );
				queryToTable( argumentCollection = arguments );
			}
			// Array of objects, discover properties via metadata
			else if ( isObject( arguments.data[ 1 ] ) ) {
				objectsToTable( argumentCollection = arguments );
			}
			// array of structs go here
			else {
				arrayToTable( argumentCollection = arguments );
			}
		}

		// Finalize table
		str.append( "</tbody></table>" );

		return str.toString();
	}

	/**
	 * Generate meta tags
	 *
	 * @name A name for the meta tag or an array of struct data to convert to meta tags.Keys [name,content,type]
	 * @content The content attribute
	 * @type Either ''name'' or ''equiv'' which produces http-equiv instead of the name
	 * @sendToHeader Send to the header via htmlhead by default, else it returns the content
	 * @property The property attribute
	 */
	function meta(
		required name,
		content              = "",
		type                 = "name",
		boolean sendToHeader = false,
		property             = ""
	){
		var buffer  = createObject( "java", "java.lang.StringBuilder" ).init( "" );
		var tmpType = "";

		// prep type
		if ( arguments.type eq "equiv" ) {
			arguments.type = "http-equiv";
		};

		// Array of structs or simple value
		if ( isSimpleValue( arguments.name ) ) {
			buffer.append(
				"<meta #arguments.type#=""#arguments.name#"" content=""#encodeForHTMLAttribute( arguments.content )#"" />"
			);
		}

		if ( isArray( arguments.name ) ) {
			for ( var x = 1; x lte arrayLen( arguments.name ); x = x + 1 ) {
				if ( NOT structKeyExists( arguments.name[ x ], "type" ) ) {
					arguments.name[ x ].type = "name";
				}
				if ( arguments.name[ x ].type eq "equiv" ) {
					arguments.name[ x ].type = "http-equiv";
				}
				if ( structKeyExists( arguments.name[ x ], "property" ) ) {
					buffer.append(
						"<meta property=#arguments.name[ x ].property# #arguments.name[ x ].type#=""#arguments.name[ x ].name#"" content=""#encodeForHTMLAttribute( arguments.name[ x ].content )#"" />"
					);
				} else {
					buffer.append(
						"<meta #arguments.name[ x ].type#=""#arguments.name[ x ].name#"" content=""#encodeForHTMLAttribute( arguments.name[ x ].content )#"" />"
					);
				}
			}
		}

		// Load it
		if ( arguments.sendToHeader ) {
			$htmlhead( buffer.toString() );
		} else {
			return buffer.toString();
		}
	}

	/**
	 * Render a doctype by type name: xhtml11,xhtml1-strict,xhtml-trans,xthml-frame,html5,html4-strict,html4-trans,html4-frame
	 *
	 * @docType The type to generate
	 */
	function docType( type = "html5" ){
		switch ( arguments.type ) {
			case "html5": {
				return "<!DOCTYPE html>";
			}
			case "xhtml11": {
				return "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.1//EN"" ""http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"">";
			}
			case "xhtml1-strict": {
				return "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">";
			}
			case "xhtml1-trans": {
				return "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">";
			}
			case "xhtml1-frame": {
				return "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Frameset//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"">";
			}
			case "html4-strict": {
				return "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01//EN"" ""http://www.w3.org/TR/html4/strict.dtd"">";
			}
			case "html4-trans": {
				return "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN"" ""http://www.w3.org/TR/html4/loose.dtd"">";
			}
			case "html4-frame": {
				return "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Frameset//EN"" ""http://www.w3.org/TR/html4/frameset.dtd"">";
			}
		}
	}

	/**
	 * Slugify a string for URL Safety
	 * @str Target to slugify
	 * @maxLength The maximum number of characters for the slug
	 * @allow a regex safe list of additional characters to allow
	 */
	function slugify(
		required str,
		numeric maxLength = 0,
		allow             = ""
	){
		// Cleanup and slugify the string
		var slug = lCase( trim( arguments.str ) );
		slug     = replaceList(
			slug,
			"#chr( 228 )#,#chr( 252 )#,#chr( 246 )#,#chr( 223 )#",
			"ae,ue,oe,ss"
		);
		slug = reReplace(
			slug,
			"[^a-z0-9-\s#arguments.allow#]",
			"",
			"all"
		);
		slug = trim( reReplace( slug, "[\s-]+", " ", "all" ) );
		slug = reReplace( slug, "\s", "-", "all" );

		// is there a max length restriction
		if ( arguments.maxlength ) {
			slug = left( slug, arguments.maxlength );
		}

		return slug;
	}

	/**
	 * Creates auto discovery links for RSS and ATOM feeds.
	 * @type Type of feed: RSS or ATOM or Custom Type
	 * @href Te href link to discover
	 * @rel The rel attribute
	 * @title The title attribute
	 * @data Struct for data-key elements
	 */
	function autoDiscoveryLink(
		type = "RSS",
		href,
		rel         = "alternate",
		title       = "",
		struct data = {}
	){
		var buffer = createObject( "java", "java.lang.StringBuilder" ).init( "<link" );

		// type: determination
		switch ( arguments.type ) {
			case "rss": {
				arguments.type = "application/rss+xml";
				break;
			}
			case "atom": {
				arguments.type = "application/atom+xml";
				break;
			}
			default: {
				arguments.type = arguments.type;
			}
		}

		// create link
		flattenAttributes( arguments, "", buffer ).append( "/>" );

		return buffer.toString();
	}

	/**
	 * HTML Video Tag
	 *
	 * @src The source URL or array or list of URL's to create video tags for
	 * @width The width tag
	 * @height The height tag
	 * @poster The URL of the image when video is unavailable
	 * @autoplay Whether or not to start playing the video as soon as it can
	 * @controls Whether or not to show controls on the video player
	 * @loop Whether or not to loop the video over and over again
	 * @preload If true, the video will be loaded at page load, and ready to run. Ignored if 'autoplay' is present
	 * @noBaseURL Defaults to false. If you want to NOT append a request's ses or html base url then set this argument to true
	 * @name The name tag
	 * @data A structure that will add data-{key} elements to the HTML control
	 */
	function video(
		required src,
		width             = "",
		height            = "",
		poster            = "",
		boolean autoplay  = "false",
		boolean controls  = "true",
		boolean loop      = "false",
		boolean preload   = "false",
		boolean noBaseURL = "false",
		name              = "",
		data              = {}
	){
		var video = createObject( "java", "java.lang.StringBuilder" ).init( "<video" );
		var x     = 1;

		// autoplay diff
		if ( arguments.autoplay ) {
			arguments.autoplay = "autoplay";
		} else {
			arguments.autoplay = "";
		}
		// controls diff
		if ( arguments.controls ) {
			arguments.controls = "controls";
		} else {
			arguments.controls = "";
		}
		// loop diff
		if ( arguments.loop ) {
			arguments.loop = "loop";
		} else {
			arguments.loop = "";
		}
		// preLoad diff
		if ( arguments.preLoad ) {
			arguments.preLoad = "preload";
		} else {
			arguments.preLoad = "";
		}

		// src array check
		if ( isSimpleValue( arguments.src ) ) {
			arguments.src = listToArray( arguments.src );
		}

		// ID Normalization
		normalizeID( arguments );

		// create video tag
		flattenAttributes( arguments, "noBaseURL,src", video );

		// Add single source
		if ( arrayLen( arguments.src ) eq 1 ) {
			arguments.src[ 1 ] = prepareBaseLink( arguments.noBaseURL, arguments.src[ 1 ] );
			video.append( " src=""#encodeForHTMLAttribute( arguments.src[ 1 ] )#"" />" );
			return video.toString();
		}

		// create source tags
		video.append( ">" );
		for ( x = 1; x lte arrayLen( arguments.src ); x++ ) {
			arguments.src[ x ] = prepareBaseLink( arguments.noBaseURL, arguments.src[ x ] );
			video.append( "<source src=""#encodeForHTMLAttribute( arguments.src[ x ] )#""/>" );
		}
		video.append( "</video>" );

		return video.toString();
	}

	/**
	 * HTML Audio Tag
	 *
	 * @src The source URL or array or list of URL's to create video tags for
	 * @autoplay Whether or not to start playing the video as soon as it can
	 * @controls Whether or not to show controls on the video player
	 * @loop Whether or not to loop the video over and over again
	 * @preload If true, the video will be loaded at page load, and ready to run. Ignored if 'autoplay' is present
	 * @noBaseURL Defaults to false. If you want to NOT append a request's ses or html base url then set this argument to true
	 * @name The name tag
	 * @data A structure that will add data-{key} elements to the HTML control
	 */
	function audio(
		required src,
		boolean autoplay  = "false",
		boolean controls  = "true",
		boolean loop      = "false",
		boolean preload   = "false",
		boolean noBaseURL = "false",
		name              = "",
		data              = {}
	){
		var audio = createObject( "java", "java.lang.StringBuilder" ).init( "<audio" );
		var x     = 1;

		// autoplay diff
		if ( arguments.autoplay ) {
			arguments.autoplay = "autoplay";
		} else {
			arguments.autoplay = "";
		}
		// controls diff
		if ( arguments.controls ) {
			arguments.controls = "controls";
		} else {
			arguments.controls = "";
		}
		// loop diff
		if ( arguments.loop ) {
			arguments.loop = "loop";
		} else {
			arguments.loop = "";
		}
		// preLoad diff
		if ( arguments.preLoad ) {
			arguments.preLoad = "preload";
		} else {
			arguments.preLoad = "";
		}

		// src array check
		if ( isSimpleValue( arguments.src ) ) {
			arguments.src = listToArray( arguments.src );
		}

		// ID Normalization
		normalizeID( arguments );

		// create video tag
		flattenAttributes( arguments, "noBaseURL,src", audio );

		// Add single source
		if ( arrayLen( arguments.src ) eq 1 ) {
			arguments.src[ 1 ] = prepareBaseLink( arguments.noBaseURL, arguments.src[ 1 ] );
			audio.append( " src=""#encodeForHTMLAttribute( arguments.src[ 1 ] )#"" />" );
			return audio.toString();
		}

		// create source tags
		audio.append( ">" );
		for ( x = 1; x lte arrayLen( arguments.src ); x++ ) {
			arguments.src[ x ] = prepareBaseLink( arguments.noBaseURL, arguments.src[ x ] );
			audio.append( "<source src=""#encodeForHTMLAttribute( arguments.src[ x ] )#""/>" );
		}
		audio.append( "</audio>" );

		return audio.toString();
	}

	/**
	 * HTML Canvas Tag
	 *
	 * @id The id of the canvas
	 * @width The width tag
	 * @height The height tag
	 * @data A structure that will add data-{key} elements to the HTML control
	 */
	function canvas(
		required id,
		width  = "",
		height = "",
		data   = {}
	){
		var canvas = createObject( "java", "java.lang.StringBuilder" ).init( "<canvas" );

		// create canvas tag
		flattenAttributes( arguments, "", canvas ).append( "></canvas>" );

		return canvas.toString();
	}

	/**
	 * Create cool form tags. Any extra argument will be passed as attributes to the form tag
	 *
	 * @action The event or route action to submit to.	This will be inflated using the request's base URL if not a full http URL. If empty, then it is a self-submitting form
	 * @name The name of the form tag
	 * @method The HTTP method of the form, defaults to POST
	 * @multipart Set the multipart encoding type on the form, defaults to false
	 * @ssl If true, it will change http to https if found in the ses base url ONLY, false will remove SSL
	 * @noBaseURL Defaults to false. If you want to NOT append a request's ses or html base url then set this argument to true
	 * @data A structure that will add data-{key} elements to the HTML control
	 */
	function startForm(
		string action     = "",
		string name       = "",
		string method     = "POST",
		boolean multipart = false,
		boolean ssl,
		boolean noBaseURL = false,
		struct data       = {}
	){
		var formBuffer    = createObject( "java", "java.lang.StringBuilder" ).init( "<form" );
		var event         = controller.getRequestService().getContext();
		var desiredMethod = "";

		// Browsers can't support all the HTTP verbs, so if we passed in something
		// besides GET or POST, we'll default to POST and save off
		// the desired method to spoof later.
		if ( arguments.method != "GET" AND arguments.method != "POST" ) {
			desiredMethod    = arguments.method;
			arguments.method = "POST";
		}

		// self-submitting?
		if ( NOT len( arguments.action ) ) {
			arguments.action = event.getCurrentEvent();
		}

		// Check if we have a base URL and if we need to build our link
		if ( arguments.noBaseURL eq FALSE and NOT find( "://", arguments.action ) ) {
			// Verify SSL Bit
			if ( isNull( arguments.ssl ) ) {
				arguments.ssl = event.isSSL();
			}
			// Build it
			arguments.action = event.buildLink( to = arguments.action, ssl = arguments.ssl );
		}

		// ID Normalization
		normalizeID( arguments );

		// Multipart Encoding Type
		if ( arguments.multipart ) {
			arguments.enctype = "multipart/form-data";
		} else {
			arguments.enctype = "";
		}

		// create tag
		flattenAttributes(
			arguments,
			"noBaseURL,ssl,multipart",
			formBuffer
		).append( ">" );

		// If we wanted to use PUT, PATCH, or DELETE, spoof the HTTP method
		// by including a hidden field in the form that ColdBox will look for.
		if ( len( desiredMethod ) ) {
			formBuffer.append( "<input type=""hidden"" name=""_method"" value=""#desiredMethod#"" />" );
		}

		return formBuffer.toString();
	}

	/**
	 * End a form
	 */
	function endForm(){
		return "</form>";
	}

	/**
	 * Build a field set with or without a legend
	 *
	 * @legend The legend to use
	 * @data A structure that will add data-{key} elements to the HTML control
	 */
	function startFieldSet( legend = "", struct data = {} ){
		var buffer = createObject( "java", "java.lang.StringBuilder" ).init( "<fieldset" );

		// fieldset attributes
		flattenAttributes( arguments, "legend", buffer ).append( ">" );

		// add Legend?
		if ( len( arguments.legend ) ) {
			if ( variables.settings.encodeValues ) {
				arguments.legend = encodeForHTML( arguments.legend );
			}
			buffer.append( "<legend>#arguments.legend#</legend>" );
		}

		return buffer.toString();
	}

	/**
	 * End a fieldset
	 */
	function endFieldSet(){
		return "</fieldset>";
	}

	/**
	 * Render a label tag. Remember that any extra arguments are passed as tag attributes
	 *
	 * @field The for who attribute
	 * @content The label content. If not passed the field is used
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @class The class to be applied to the label
	 * @labelMode 0 - Open and close the label tag with wrappers around it (default); 1 - Open the wrapper and the label but do not close them; 2- Output the content, close the label and the wrapper
	 */
	function label(
		required field,
		content             = "",
		struct labelAttrs   = {},
		wrapper             = "",
		struct wrapperAttrs = {},
		struct data         = {},
		class               = "",
		numeric labelMode   = 0
	){
		var buffer = createObject( "java", "java.lang.StringBuilder" ).init( "" );

		// get content
		if ( NOT len( content ) ) {
			arguments.content = makePretty( arguments.field );
		}
		arguments.for = arguments.field;

		if ( arguments.labelMode == 0 || arguments.labelMode == 1 ) {
			// wrapper?
			wrapTag(
				buffer = buffer,
				tag    = arguments.wrapper,
				end    = 0,
				attrs  = arguments.wrapperAttrs
			);

			// create label tag
			buffer.append( "<label" );
			flattenAttributes(
				arguments,
				"content,field,wrapper,labelMode,labelAttrs",
				buffer
			);
			flattenAttributes( target = arguments.labelAttrs, buffer = buffer ).append( ">" );
		}

		if ( labelMode == 0 || labelMode == 2 ) {
			if ( variables.settings.encodeValues ) {
				arguments.content = encodeForHTML( arguments.content );
			}
			buffer.append( "#arguments.content#</label>" );
			// wrapper?
			wrapTag(
				buffer = buffer,
				tag    = arguments.wrapper,
				end    = 1
			);
		}

		return buffer.toString();
	}

	/**
	 * Render out a textarea. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @cols The number of columns
	 * @rows The number of rows
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @readonly Readonly
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function textArea(
		name = "",
		numeric cols,
		numeric rows,
		value                    = "",
		boolean disabled         = false,
		boolean readonly         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		var buffer = createObject( "java", "java.lang.StringBuilder" ).init( "" );

		// ID Normalization
		normalizeID( arguments );
		// group wrapper?
		wrapTag(
			buffer,
			arguments.groupWrapper,
			0,
			arguments.groupWrapperAttrs
		);

		// label?
		if ( len( arguments.label ) ) {
			buffer.append(
				this.label(
					field        = arguments.id,
					content      = arguments.label,
					wrapper      = arguments.labelWrapper,
					wrapperAttrs = arguments.labelWrapperAttrs,
					class        = arguments.labelClass,
					labelMode    = ( arguments.inputInsideLabel ? 1 : 0 ),
					labelAttrs   = arguments.labelAttrs
				)
			);
		}

		// wrapper?
		wrapTag(
			buffer,
			arguments.wrapper,
			0,
			arguments.wrapperAttrs
		);

		// disabled fix
		if ( arguments.disabled ) {
			arguments.disabled = "disabled";
		} else {
			arguments.disabled = "";
		}
		// readonly fix
		if ( arguments.readonly ) {
			arguments.readonly = "readonly";
		} else {
			arguments.readonly = "";
		}

		// Entity Binding?
		bindValue( arguments );

		// create textarea
		buffer.append( "<textarea" );
		flattenAttributes(
			arguments,
			"value,label,wrapper,labelWrapper,groupWrapper,labelAttrs,labelClass,bind,bindProperty,inputInsideLabel",
			buffer
		).append(
			">#variables.settings.encodeValues ? encodeForHTML( arguments.value ) : arguments.value#</textarea>"
		);

		// wrapper?
		wrapTag( buffer, arguments.wrapper, 1 );
		// group wrapper?
		wrapTag( buffer, arguments.groupWrapper, 1 );

		return buffer.toString();
	}

	/**
	 * Render out a password field. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @readonly Readonly
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function passwordField(
		name                     = "",
		value                    = "",
		boolean disabled         = false,
		boolean readonly         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		arguments.type = "password";
		return inputField( argumentCollection = arguments );
	}

	/**
	 * Render out a URL field. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @readonly Readonly
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function urlField(
		name                     = "",
		value                    = "",
		boolean disabled         = false,
		boolean readonly         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		arguments.type = "url";
		return inputField( argumentCollection = arguments );
	}

	/**
	 * Render out an email field. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @readonly Readonly
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function emailField(
		name                     = "",
		value                    = "",
		boolean disabled         = false,
		boolean readonly         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		arguments.type = "email";
		return inputField( argumentCollection = arguments );
	}

	/**
	 * Render out a hidden field. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @readonly Readonly
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function hiddenField(
		name                     = "",
		value                    = "",
		boolean disabled         = false,
		boolean readonly         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		arguments.type = "hidden";
		return inputField( argumentCollection = arguments );
	}

	/**
	 * Render out a text field. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @readonly Readonly
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function textField(
		name                     = "",
		value                    = "",
		boolean disabled         = false,
		boolean readonly         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		arguments.type = "text";
		return inputField( argumentCollection = arguments );
	}

	/**
	 * Render out a file field. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @readonly Readonly
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function fileField(
		name                     = "",
		value                    = "",
		boolean disabled         = false,
		boolean readonly         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		arguments.type = "file";
		return inputField( argumentCollection = arguments );
	}

	/**
	 * Render out a checkbox field. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @checked Checked
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function checkbox(
		name                     = "",
		value                    = "true",
		boolean disabled         = false,
		boolean checked          = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		arguments.type = "checkbox";
		return inputField( argumentCollection = arguments );
	}

	/**
	 * Render out a radiobutton field. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @checked Checked
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function radioButton(
		name                     = "",
		value                    = "true",
		boolean disabled         = false,
		boolean checked          = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		arguments.type = "radio";
		return inputField( argumentCollection = arguments );
	}

	/**
	 * Render out a submit button. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function submitButton(
		name                     = "",
		value                    = "Submit",
		boolean disabled         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		arguments.type = "submit";
		return inputField( argumentCollection = arguments );
	}

	/**
	 * Render out a reset button. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function resetButton(
		name                     = "",
		value                    = "Reset",
		boolean disabled         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		arguments.type = "reset";
		return inputField( argumentCollection = arguments );
	}

	/**
	 * Render out a image button. Remember that any extra arguments are passed as tag attributes
	 *
	 * @src The image source
	 * @name The name of the textarea
	 * @disabled Disabled
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function imageButton(
		required src,
		name                     = "",
		boolean disabled         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		arguments.type = "image";
		return inputField( argumentCollection = arguments );
	}

	/**
	 * Render out an input field. Remember that any extra arguments are passed as tag attributes
	 *
	 * @type The type of input field to create, defaults to text
	 * @name The name of the textarea
	 * @value The value of the field
	 * @disabled Disabled
	 * @checked Checked
	 * @readOnly Read only
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function inputField(
		type                     = "text",
		name                     = "",
		value                    = "",
		boolean disabled         = false,
		boolean checked          = false,
		boolean readonly         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		var buffer      = createObject( "java", "java.lang.StringBuilder" ).init( "" );
		var excludeList = "label,wrapper,labelWrapper,groupWrapper,labelClass,labelAttrs,inputInsideLabel,bind,bindProperty";

		// ID Normalization
		normalizeID( arguments );

		// group wrapper?
		wrapTag(
			buffer,
			arguments.groupWrapper,
			0,
			arguments.groupWrapperAttrs
		);

		// label?
		if ( len( arguments.label ) ) {
			buffer.append(
				this.label(
					field        = arguments.id,
					content      = arguments.label,
					wrapper      = arguments.labelWrapper,
					wrapperAttrs = arguments.labelWrapperAttrs,
					class        = arguments.labelClass,
					labelMode    = ( arguments.inputInsideLabel ? 1 : 0 ),
					labelAttrs   = arguments.labelAttrs
				)
			);
		}
		// wrapper?
		wrapTag(
			buffer,
			arguments.wrapper,
			0,
			arguments.wrapperAttrs
		);

		// disabled fix
		if ( arguments.disabled ) {
			arguments.disabled = "disabled";
		} else {
			arguments.disabled = "";
		}
		// checked fix
		if ( arguments.checked ) {
			arguments.checked = "checked";
		} else {
			arguments.checked = "";
		}
		// readonly fix
		if ( arguments.readonly ) {
			arguments.readonly = "readonly";
		} else {
			arguments.readonly = "";
		}

		// binding?
		bindValue( arguments );

		// create textarea
		buffer.append( "<input" );
		flattenAttributes( arguments, excludeList, buffer ).append( "/>" );

		// wrapper?
		wrapTag( buffer, arguments.wrapper, 1 );

		// close label tag if inputInsideLabel
		if ( len( arguments.label ) && arguments.inputInsideLabel ) {
			buffer.append(
				this.label(
					field     = arguments.id,
					content   = arguments.label,
					wrapper   = arguments.labelWrapper,
					labelMode = 2
				)
			); // close the label tag if we have one opened
		}

		// group wrapper?
		wrapTag( buffer, arguments.groupWrapper, 1 );

		return buffer.toString();
	}

	/**
	 * Render out options.
	 *
	 * @values An array, list or query to build options for
	 * @column If using a query or array of objects the column to display as value and name
	 * @nameColumn If using a query or array of objects, the name column to display, if not passed defaults to the value column
	 * @selectedIndex selected index(s) if any. So either one or a list of indexes
	 * @selectedValue selected value(s) if any. So either one or a list of values
	 */
	function options(
		values,
		column        = "",
		nameColumn    = "",
		selectedIndex = 0,
		selectedValue = ""
	){
		var buffer    = createObject( "java", "java.lang.StringBuilder" ).init( "" );
		var val       = "";
		var nameVal   = "";
		var x         = 1;
		var qColumns  = "";
		var thisName  = "";
		var thisValue = "";

		// check if an array? So we can do array of objects check
		if ( isArray( arguments.values ) AND arrayLen( arguments.values ) ) {
			// Check first element for an object, if it is then convert to query
			if ( isObject( arguments.values[ 1 ] ) ) {
				arguments.values = entityToQuery( arguments.values );
			}
		}
		// is this a simple value, if so, inflate it
		if ( isSimpleValue( arguments.values ) ) {
			arguments.values = listToArray( arguments.values );
		}

		// setup local variables
		val     = arguments.values;
		nameVal = arguments.values;

		// query normalization?
		if ( isQuery( val ) ) {
			// check if column sent? Else select the first column
			if ( NOT len( arguments.column ) ) {
				// select the first one
				qColumns         = listToArray( arguments.values.columnList );
				arguments.column = qColumns[ 1 ];
			}
			// column for values
			val     = getColumnArray( arguments.values, arguments.column );
			nameVal = val;
			// name column values
			if ( len( arguments.nameColumn ) ) {
				nameVal = getColumnArray( arguments.values, arguments.nameColumn );
			}
		}

		// values
		for ( var x = 1; x lte arrayLen( val ); x++ ) {
			thisValue = val[ x ];
			thisName  = nameVal[ x ];

			// struct normalizing
			if ( isStruct( val[ x ] ) ) {
				thisName = "";

				// check for value?
				if ( structKeyExists( val[ x ], "value" ) ) {
					thisValue = val[ x ].value;
				}
				if ( structKeyExists( val[ x ], "name" ) ) {
					thisName = val[ x ].name;
				}

				// Check if we have a column to use for the default value
				if ( structKeyExists( val[ x ], arguments.column ) ) {
					thisValue = val[ x ][ column ];
				}

				// Do we have name column
				if ( len( arguments.nameColumn ) ) {
					if ( structKeyExists( val[ x ], arguments.nameColumn ) ) {
						thisName = val[ x ][ nameColumn ];
					}
				}

				// If thisName is still the default, use the content of thisValue as the name
				if ( thisName == "" ) {
					thisName = thisValue;
				}
			}

			// create option
			buffer.append( "<option value=""#thisValue#""" );

			// selected
			if ( listFindNoCase( arguments.selectedIndex, x ) ) {
				buffer.append( " selected=""selected""" );
			}
			// selected value
			if ( listFindNoCase( arguments.selectedValue, thisValue ) ) {
				buffer.append( " selected=""selected""" );
			}

			if ( variables.settings.encodeValues ) {
				thisName = encodeForHTML( thisName );
			}

			buffer.append( ">#thisName#</option>" );
		}

		return buffer.toString();
	}

	/**
	 * Render out a select tag. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the field
	 * @options The value for the options, usually by calling our options() method
	 * @column If using a query or array of objects the column to display as value and name
	 * @nameColumn If using a query or array of objects, the name column to display, if not passed defaults to the value column
	 * @selectedIndex selected index
	 * @selectedValue selected value if any
	 * @bind The entity binded to this control
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @disabled Disabled button or not?
	 * @multiple multiple button or not?
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @labelClass The class to be applied to the label
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function select(
		name                     = "",
		options                  = "",
		column                   = "",
		nameColumn               = "",
		selectedIndex            = 0,
		selectedValue            = "",
		bind                     = "",
		bindProperty             = "",
		boolean disabled         = false,
		boolean multiple         = false,
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelwrapper             = "",
		struct labelWrapperAttrs = {},
		struct data              = {},
		labelClass               = "",
		boolean inputInsideLabel = false
	){
		var buffer = createObject( "java", "java.lang.StringBuilder" ).init( "" );

		// ID Normalization
		normalizeID( arguments );

		// group wrapper?
		wrapTag(
			buffer,
			arguments.groupWrapper,
			0,
			arguments.groupWrapperAttrs
		);

		// label?
		if ( len( arguments.label ) ) {
			buffer.append(
				this.label(
					field        = arguments.id,
					content      = arguments.label,
					wrapper      = arguments.labelWrapper,
					wrapperAttrs = arguments.labelWrapperAttrs,
					class        = arguments.labelClass,
					labelAttrs   = arguments.labelAttrs
				)
			);
		}

		// wrapper?
		wrapTag(
			buffer,
			arguments.wrapper,
			0,
			arguments.wrapperAttrs
		);

		// disabled fix
		if ( arguments.disabled ) {
			arguments.disabled = "disabled";
		} else {
			arguments.disabled = "";
		}
		// multiple fix
		if ( arguments.multiple ) {
			arguments.multiple = "multiple";
		} else {
			arguments.multiple = "";
		}

		// create select
		buffer.append( "<select" );
		flattenAttributes(
			arguments,
			"options,column,nameColumn,selectedIndex,selectedValue,bind,bindProperty,label,labelAttrs,wrapper,labelWrapper,groupWrapper,labelClass,inputInsideLabel",
			buffer
		).append( ">" );

		// binding of option
		bindValue( arguments );
		if ( structKeyExists( arguments, "value" ) AND len( arguments.value ) ) {
			arguments.selectedValue = arguments.value;
		}

		// options, are they inflatted already or do we inflate
		if ( isSimpleValue( arguments.options ) AND findNoCase( "</option>", arguments.options ) ) {
			buffer.append( arguments.options );
		} else {
			buffer.append(
				this.options(
					arguments.options,
					arguments.column,
					arguments.nameColumn,
					arguments.selectedIndex,
					arguments.selectedValue
				)
			);
		}

		// finalize select
		buffer.append( "</select>" );

		// wrapper?
		wrapTag( buffer, arguments.wrapper, 1 );

		// close label tag if inputInsideLabel
		if ( len( arguments.label ) && arguments.inputInsideLabel ) {
			buffer.append(
				this.label(
					field     = arguments.id,
					content   = arguments.label,
					wrapper   = arguments.labelWrapper,
					labelMode = 2
				)
			); // close the label tag if we have one opened
		}

		// group wrapper?
		wrapTag( buffer, arguments.groupWrapper, 1 );

		return buffer.toString();
	}




	/**
	 * Render out a button. Remember that any extra arguments are passed as tag attributes
	 *
	 * @name The name of the textarea
	 * @value The value of the textarea
	 * @disabled Disabled
	 * @type The type of button to create: button, reset or submit
	 * @wrapper The wrapper tag to use around the tag. Empty by default
	 * @wrapperAttrs Attributes to add to the wrapper tag. Empty by default
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @label If Passed we will prepend a label tag
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @bind The entity binded to this control, the value comes by convention from the name attribute
	 * @bindProperty The property to use for the value, by convention we use the name attribute
	 * @data A structure that will add data-{key} elements to the HTML control
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function button(
		name                     = "",
		value                    = "",
		boolean disabled         = false,
		type                     = "button",
		wrapper                  = "",
		struct wrapperAttrs      = {},
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		label                    = "",
		struct labelAttrs        = {},
		labelWrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		bind                     = "",
		bindProperty             = "",
		struct data              = {},
		boolean inputInsideLabel = false
	){
		var buffer = createObject( "java", "java.lang.StringBuilder" ).init( "" );

		// ID Normalization
		normalizeID( arguments );

		// group wrapper?
		wrapTag(
			buffer,
			arguments.groupWrapper,
			0,
			arguments.groupWrapperAttrs
		);

		// label?
		if ( len( arguments.label ) ) {
			buffer.append(
				this.label(
					field        = arguments.id,
					content      = arguments.label,
					wrapper      = arguments.labelWrapper,
					wrapperAttrs = arguments.labelWrapperAttrs,
					class        = arguments.labelClass,
					labelMode    = ( arguments.inputInsideLabel ? 1 : 0 ),
					labelAttrs   = arguments.labelAttrs
				)
			);
		}

		// wrapper?
		wrapTag(
			buffer,
			arguments.wrapper,
			0,
			arguments.wrapperAttrs
		);

		// disabled fix
		if ( arguments.disabled ) {
			arguments.disabled = "disabled";
		} else {
			arguments.disabled = "";
		}

		// create textarea
		buffer.append( "<button" );
		flattenAttributes(
			arguments,
			"value,label,wrapper,labelWrapper,groupWrapper,labelClass,inputInsideLabel",
			buffer
		);

		if ( variables.settings.encodeValues ) {
			arguments.value = encodeForHTML( arguments.value );
		}

		buffer.append( ">#arguments.value#</button>" );

		// wrapper?
		wrapTag( buffer, arguments.wrapper, 1 );

		// close label tag if inputInsideLabel?
		if ( len( arguments.label ) && arguments.inputInsideLabel ) {
			buffer.append(
				this.label(
					field     = arguments.id,
					content   = arguments.label,
					wrapper   = arguments.labelWrapper,
					labelMode = 2
				)
			); // close the label tag if we have one opened
		}

		// group wrapper?
		wrapTag( buffer, arguments.groupWrapper, 1 );
		return buffer.toString();
	}

	/**
	 * Create fields based on entity properties and relationships
	 *
	 * @entity The entity binded to this control
	 * @groupWrapper The wrapper tag to use around the tag and label. Empty by default
	 * @groupWrapperAttrs Attributes to add to the group wrapper tag. Empty by default
	 * @fieldwrapper The wrapper tag to use around the field items. Empty by default
	 * @fieldWrapperAttrs Attributes to add to the field wrapper tag. Empty by default
	 * @labelAttrs Attributes to add to the label tag. Empty by default
	 * @labelwrapper The wrapper tag to use around the label items. Empty by default
	 * @labelWrapperAttrs Attributes to add to the label wrapper tag. Empty by default
	 * @labelClass The class to be applied to the label
	 * @textareas A list of property names that you want as textareas
	 * @booleanSelect If a boolean is detected a dropdown is generated, if false, then radio buttons
	 * @showRelations If true it will show relation tables for one to one and one to many
	 * @manytoone A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string]. Example: {criteria={productid=1},sortorder='Department desc'}
	 * @manytomany A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string,selectColumn='']. Example: {criteria={productid=1},sortorder='Department desc'}
	 * @inputInsideLabel If true, closes the label tag after the input tag and puts the label text after the input tag
	 */
	function entityFields(
		required entity,
		groupWrapper             = "",
		struct groupWrapperAttrs = {},
		fieldwrapper             = "",
		struct fieldWrapperAttrs = {},
		struct labelAttrs        = {},
		labelwrapper             = "",
		struct labelWrapperAttrs = {},
		labelClass               = "",
		textareas                = "",
		boolean booleanSelect    = true,
		boolean showRelations    = true,
		struct manytoone         = {},
		struct manytomany        = {},
		boolean inputInsideLabel = false
	){
		var buffer = createObject( "java", "java.lang.StringBuilder" ).init( "" );
		var md     = getMetadata( arguments.entity );
		var x      = 1;
		var y      = 1;
		var prop   = "";
		var args   = {};
		var loc    = {};

		// if no properties just return.
		if ( NOT structKeyExists( md, "properties" ) ) {
			return "";
		}

		// iterate properties array
		for ( x = 1; x lte arrayLen( md.properties ); x++ ) {
			prop = md.properties[ x ];

			// setup some defaults
			loc.persistent = true;
			loc.ormtype    = "string";
			loc.fieldType  = "column";
			loc.insert     = true;
			loc.update     = true;
			loc.formula    = "";
			loc.readonly   = false;
			if ( structKeyExists( prop, "persistent" ) ) {
				loc.persistent = prop.persistent;
			}
			if ( structKeyExists( prop, "ormtype" ) ) {
				loc.ormtype = prop.ormtype;
			}
			if ( structKeyExists( prop, "fieldType" ) ) {
				loc.fieldType = prop.fieldType;
			}
			if ( structKeyExists( prop, "insert" ) ) {
				loc.insert = prop.insert;
			}
			if ( structKeyExists( prop, "update" ) ) {
				loc.update = prop.update;
			}
			if ( structKeyExists( prop, "formula" ) ) {
				loc.formula = prop.formula;
			}
			if ( structKeyExists( prop, "readonly" ) ) {
				loc.readonly = prop.readonly;
			}

			// html 5 data items
			arguments[ "data-ormtype" ] = loc.ormtype;
			arguments[ "data-insert" ]  = loc.insert;
			arguments[ "data-update" ]  = loc.update;

			// continue on non-persistent ones or formulas or readonly
			loc.orm = ormGetSession();
			if (
				NOT loc.persistent OR len( loc.formula ) OR loc.readOnly OR
				( loc.orm.contains( arguments.entity ) AND NOT loc.update ) OR
				( NOT loc.orm.contains( arguments.entity ) AND NOT loc.insert )
			) {
				continue;
			}

			switch ( loc.fieldType ) {
				// primary key as hidden field
				case "id": {
					args = { name : prop.name, bind : arguments.entity };
					buffer.append( hiddenField( argumentCollection = args ) );
					break;
				}
				case "many-to-many": {
					// A new or persisted entity? If new, then skip out
					if ( NOT loc.orm.contains( arguments.entity ) OR NOT arguments.showRelations ) {
						break;
					}

					// prepare lookup args
					loc.criteria                = {};
					loc.sortorder               = "";
					loc.column                  = "";
					loc.nameColumn              = "";
					loc.selectColumn            = "";
					loc.values                  = [];
					loc.relArray                = [];
					arguments[ "data-ormtype" ] = "many-to-many";

					// is key found in manytoone arg
					if ( structKeyExists( arguments.manytomany, prop.name ) ) {
						if ( structKeyExists( arguments.manytomany[ prop.name ], "valueColumn" ) ) {
							loc.column = arguments.manytomany[ prop.name ].valueColumn;
						} else {
							throw(
								message = "The 'valueColumn' property is missing from the '#prop.name#' relationship data, which is mandatory",
								detail  = "A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string,selectColumn='']. Example: {criteria={productid=1},sortorder='Department desc'}",
								type    = "EntityFieldsInvalidRelationData"
							);
						}
						if ( structKeyExists( arguments.manytomany[ prop.name ], "nameColumn" ) ) {
							loc.nameColumn = arguments.manytomany[ prop.name ].nameColumn;
						} else {
							loc.nameColumn = arguments.manytomany[ prop.name ].valueColumn;
						}
						if ( structKeyExists( arguments.manytomany[ prop.name ], "criteria" ) ) {
							loc.criteria = arguments.manytomany[ prop.name ].criteria;
						}
						if ( structKeyExists( arguments.manytomany[ prop.name ], "sortorder" ) ) {
							loc.sortorder = arguments.manytomany[ prop.name ].sortorder;
						}
						if ( structKeyExists( arguments.manytomany[ prop.name ], "selectColumn" ) ) {
							loc.selectColumn = arguments.manytomany[ prop.name ].selectColumn;
						}
					} else {
						throw(
							message = "There is no many to many information for the '#prop.name#' relationship in the entityFields() arguments.  Please make sure you create one",
							detail  = "A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string,selectColumn='']. Example: {criteria={productid=1},sortorder='Department desc'}",
							type    = "EntityFieldsInvalidRelationData"
						);
					}

					// values should be an array of objects, so let's convert them
					loc.relArray = invoke( arguments.entity, "get#prop.name#" );

					if ( isNull( loc.relArray ) ) {
						loc.relArray = [];
					}
					if ( NOT len( loc.selectColumn ) AND arrayLen( loc.relArray ) ) {
						// if select column is empty, then select first property as select value, not perfect but hey better than nothing
						loc.selectColumn = getMetadata( loc.relArray[ 1 ] ).properties[ 1 ].name;
					}
					// iterate and select
					for ( y = 1; y lte arrayLen( loc.relArray ); y++ ) {
						loc.values.append( invoke( loc.relArray[ y ], "get#loc.selectColumn#" ) );
					}
					// generation args
					args = {
						name              : prop.name,
						options           : entityLoad( prop.cfc, loc.criteria, loc.sortorder ),
						column            : loc.column,
						nameColumn        : loc.nameColumn,
						multiple          : true,
						label             : prop.name,
						labelwrapper      : arguments.labelWrapper,
						labelWrapperAttrs : arguments.labelWrapperAttrs,
						labelClass        : arguments.labelClass,
						wrapper           : arguments.fieldwrapper,
						wrapperAttrs      : arguments.fieldWrapperAttrs,
						groupWrapper      : arguments.groupWrapper,
						groupWrapper      : arguments.groupWrapperAttrs,
						labelAttrs        : arguments.labelAttrs,
						inputInsideLabel  : arguments.inputInsideLabel,
						selectedValue     : arrayToList( loc.values )
					};
					structAppend( args, arguments );
					buffer.append( this.select( argumentCollection = args ) );
					break;
				}
				// one to many display
				case "one-to-many": {
					// A new or persisted entity? If new, then skip out
					if ( NOT loc.orm.contains( arguments.entity ) OR NOT arguments.showRelations ) {
						break;
					}
					arguments[ "data-ormtype" ] = "one-to-many";
					// We just show them as a nice table because we are not scaffolding, just display
					// values should be an array of objects, so let's convert them
					loc.relArray                = invoke( arguments.entity, "get#prop.name#" );
					if ( isNull( loc.relArray ) ) {
						loc.relArray = [];
					}

					// Label Generation
					args = {
						field            : prop.name,
						wrapper          : arguments.labelWrapper,
						class            : arguments.labelClass,
						inputInsideLabel : arguments.inputInsideLabel
					};
					structAppend( args, arguments );
					buffer.append( this.label( argumentCollection = args ) );

					// Table Generation
					if ( arrayLen( loc.relArray ) ) {
						args = { name : prop.name, data : loc.relArray };
						structAppend( args, arguments );
						buffer.append( this.table( argumentCollection = args ) );
					} else {
						buffer.append( "<p>None Found</p>" );
					}

					break;
				}
				// one to many display
				case "one-to-one": {
					// A new or persisted entity? If new, then skip out
					if ( NOT loc.orm.contains( arguments.entity ) OR NOT arguments.showRelations ) {
						break;
					}

					arguments[ "data-ormtype" ] = "one-to-one";
					// We just show them as a nice table because we are not scaffolding, just display
					// values should be an array of objects, so let's convert them
					loc.data                    = invoke( arguments.entity, "get#prop.name#" );
					if ( isNull( loc.data ) ) {
						loc.relArray = [];
					} else {
						loc.relArray = [ loc.data ];
					}

					// Label Generation
					args = {
						field            : prop.name,
						wrapper          : arguments.labelWrapper,
						class            : arguments.labelClass,
						inputInsideLabel : arguments.inputInsideLabel
					};
					structAppend( args, arguments );
					buffer.append( this.label( argumentCollection = args ) );

					// Table Generation
					if ( arrayLen( loc.relArray ) ) {
						args = { name : prop.name, data : loc.relArray };
						structAppend( args, arguments );
						buffer.append( this.table( argumentCollection = args ) );
					} else {
						buffer.append( "<p>None Found</p>" );
					}
					break;
				}
				// many to one
				case "many-to-one": {
					// A new or persisted entity? If new, then skip out
					if ( NOT loc.orm.contains( arguments.entity ) OR NOT arguments.showRelations ) {
						break;
					}
					arguments[ "data-ormtype" ] = "many-to-one";
					// prepare lookup args
					loc.criteria                = {};
					loc.sortorder               = "";
					loc.column                  = "";
					loc.nameColumn              = "";
					// is key found in manytoone arg
					if ( structKeyExists( arguments.manytoone, prop.name ) ) {
						// Verify the valueColumn which is mandatory
						if ( structKeyExists( arguments.manytoone[ prop.name ], "valueColumn" ) ) {
							loc.column = arguments.manytoone[ prop.name ].valueColumn;
						} else {
							throw(
								message = "The 'valueColumn' property is missing from the '#prop.name#' relationship data, which is mandatory",
								detail  = "A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string]. Example: {criteria={productid=1},sortorder='Department desc'}",
								type    = "EntityFieldsInvalidRelationData"
							);
						}
						if ( structKeyExists( arguments.manytoone[ prop.name ], "nameColumn" ) ) {
							loc.nameColumn = arguments.manytoone[ prop.name ].nameColumn;
						} else {
							loc.nameColumn = arguments.manytoone[ prop.name ].valueColumn;
						}
						if ( structKeyExists( arguments.manytoone[ prop.name ], "criteria" ) ) {
							loc.criteria = arguments.manytoone[ prop.name ].criteria;
						}
						if ( structKeyExists( arguments.manytoone[ prop.name ], "sortorder" ) ) {
							loc.sortorder = arguments.manytoone[ prop.name ].sortorder;
						}
					} else {
						throw(
							message = "There is no many to one information for the '#prop.name#' relationship in the entityFields() arguments.  Please make sure you create one",
							detail  = "A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string]. Example: {criteria={productid=1},sortorder='Department desc'}",
							type    = "EntityFieldsInvalidRelationData"
						);
					}
					// generation args
					args = {
						name              : prop.name,
						options           : entityLoad( prop.cfc, loc.criteria, loc.sortorder ),
						column            : loc.column,
						nameColumn        : loc.nameColumn,
						label             : prop.name,
						bind              : arguments.entity,
						labelwrapper      : arguments.labelWrapper,
						labelWrapperAttrs : arguments.labelWrapperAttrs,
						labelClass        : arguments.labelClass,
						wrapper           : arguments.fieldwrapper,
						wrapperAttrs      : arguments.fieldWrapperAttrs,
						groupWrapper      : arguments.groupWrapper,
						groupWrapperAttrs : arguments.groupWrapperAttrs,
						inputInsideLabel  : arguments.inputInsideLabel
					};
					structAppend( args, arguments );
					buffer.append( this.select( argumentCollection = args ) );
					break;
				}
				// columns
				case "column": {
					// booleans?
					if ( structKeyExists( prop, "ormtype" ) and prop.ormtype eq "boolean" ) {
						// boolean select or radio buttons
						if ( arguments.booleanSelect ) {
							args = {
								name              : prop.name,
								options           : [ true, false ],
								label             : prop.name,
								bind              : arguments.entity,
								labelwrapper      : arguments.labelWrapper,
								labelWrapperAttrs : arguments.labelWrapperAttrs,
								labelClass        : arguments.labelClass,
								wrapper           : arguments.fieldwrapper,
								wrapperAttrs      : arguments.fieldWrapperAttrs,
								groupWrapper      : arguments.groupWrapper,
								groupWrapperAttrs : arguments.groupWrapperAttrs,
								inputInsideLabel  : arguments.inputInsideLabel
							};
							structAppend( args, arguments );
							buffer.append( this.select( argumentCollection = args ) );
						} else {
							args = {
								name              : prop.name,
								value             : "true",
								label             : "True",
								bind              : arguments.entity,
								labelwrapper      : arguments.labelWrapper,
								labelWrapperAttrs : arguments.labelWrapperAttrs,
								labelClass        : arguments.labelClass,
								groupWrapper      : arguments.groupWrapper,
								groupWrapperAttrs : arguments.groupWrapperAttrs,
								wrapper           : arguments.fieldWrapper,
								wrapperAttrs      : arguments.fieldWrapperAttrs,
								inputInsideLabel  : arguments.inputInsideLabel
							};
							structAppend( args, arguments );
							buffer.append( this.radioButton( argumentCollection = args ) );
							args.value = "false";
							args.label = "false";
							buffer.append( this.radioButton( argumentCollection = args ) );
						}
						continue;
					}
					// text args
					args = {
						name              : prop.name,
						label             : prop.name,
						bind              : arguments.entity,
						labelwrapper      : arguments.labelWrapper,
						labelWrapperAttrs : arguments.labelWrapperAttrs,
						labelClass        : arguments.labelClass,
						wrapper           : arguments.fieldwrapper,
						wrapperAttrs      : arguments.fieldWrapperAttrs,
						groupWrapper      : arguments.groupWrapper,
						groupWrapperAttrs : arguments.groupWrapperAttrs,
						inputInsideLabel  : arguments.inputInsideLabel
					};
					structAppend( args, arguments );
					// text and textarea fields
					if ( len( arguments.textareas ) AND listFindNoCase( arguments.textareas, prop.name ) ) {
						buffer.append( this.textarea( argumentCollection = args ) );
					} else {
						buffer.append( this.textfield( argumentCollection = args ) );
					}
				}
				// end case column
			}
			// end switch
		}
		// end for loop

		return buffer.toString();
	}

	/**
	 * Adds the versioned path for an asset to the view using ColdBox Elixir
	 *
	 * @fileName The asset path to find relative to the includes convention directory
	 * @buildDirectory The build directory inside the includes convention directory
	 * @sendToHeader Send to the header via htmlhead by default, else it returns the content
	 * @async HTML5 JavaScript argument: Specifies that the script is executed asynchronously (only for external scripts)
	 * @defer HTML5 JavaScript argument: Specifies that the script is executed when the page has finished parsing (only for external scripts)
	 * @version The elixir version to use, defaults to 3
	 * @manifestRoot The root location in relative from the webroot where the `rev-manifest.json` file exists
	 */
	function elixir(
		required fileName,
		buildDirectory       = "build",
		boolean sendToHeader = true,
		boolean async        = false,
		boolean defer        = false,
		numeric version      = 3,
		manifestRoot         = ""
	){
		return addAsset(
			elixirPath(
				fileName       = arguments.fileName,
				buildDirectory = arguments.buildDirectory,
				version        = arguments.version,
				manifestRoot   = arguments.manifestRoot
			),
			arguments.sendToHeader,
			arguments.async,
			arguments.defer
		);
	}

	/**
	 * Adds the versioned path for an asset to the view using ColdBox Elixir
	 *
	 * @fileName The asset path to find relative to the `includes` convention directory
	 * @useModuleRoot If true, use the module root as the root of the file path
	 * @version The elixir version algorithm to use, version 3 is the latest
	 * @manifestRoot The root location in relative from the webroot where the `rev-manifest.json` file exists
	 */
	function elixirPath(
		required fileName,
		boolean useModuleRoot = false,
		numeric version       = 3,
		manifestRoot          = ""
	){
		// Incoming Cleanup
		arguments.fileName = reReplace( arguments.fileName, "^//?", "" );

		// In local discovery cache?
		if ( variables.cachedPaths.keyExists( arguments.filename ) ) {
			return variables.cachedPaths[ arguments.filename ];
		}

		// Prepare state checks
		var includesLocation    = controller.getColdBoxSetting( "IncludesConvention" );
		var event               = getRequestContext();
		arguments.currentModule = event.getCurrentModule();

		// Get the manifest location
		var manifestPath = discoverElixirManifest( argumentCollection = arguments );

		// Calculate mapping for the asset in question
		var mapping = ( arguments.useModuleRoot && len( arguments.currentModule ) ) ? event.getModuleRoot() : controller.getSetting(
			"appMapping"
		);

		// Calculat href for asset delivery via Browser
		if ( mapping.len() ) {
			var href = "/#mapping#/#includesLocation#/#arguments.fileName#";
		} else {
			var href = "/#includesLocation#/#arguments.fileName#";
		}
		var key = reReplace( href, "^//?", "" );

		// Only read, parse and store once the manifest
		if ( !variables.elixirManifests.keyExists( "elixirManifest-#hash( manifestPath )#" ) ) {
			lock
				name          ="load-elixir-manifest-#hash( manifestPath )#"
				type          ="exclusive"
				timeout       ="20"
				throwOnTimeout="true" {
				if ( !variables.elixirManifests.keyExists( "elixirManifest-#hash( manifestPath )#" ) ) {
					var contents = fileRead( manifestPath );
					if ( isJSON( contents ) ) {
						variables.elixirManifests[ hash( manifestPath ) ] = deserializeJSON( contents );
					} else {
						variables.elixirManifests[ hash( manifestPath ) ] = {};
					}
				}
			}
		}

		// Is the key in the manifest?
		var manifestDirectory = variables.elixirManifests[ hash( manifestPath ) ];
		if ( !structKeyExists( manifestDirectory, key ) ) {
			variables.cachedPaths[ arguments.fileName ] = arguments.fileName;
			return href;
		}
		variables.cachedPaths[ arguments.fileName ] = manifestDirectory[ key ];
		return "#manifestDirectory[ key ]#";
	}

	/**
	 * Discover the elixir manifest for this request using the following lookups:
	 *
	 * - Override
	 * - Module Root
	 * - App Root
	 *
	 * @currentModule Are we in a module call or not
	 * @useModuleRoot Are we using a module root?
	 * @version The elixir version
	 * @manifestRoot Are we customizing the root
	 */
	function discoverElixirManifest(
		string currentModule  = "",
		boolean useModuleRoot = false,
		numeric version       = 3,
		manifestRoot          = ""
	){
		// Do we have a manifest override? Just return it
		if ( len( arguments.manifestRoot ) ) {
			return controller.locateFilePath( "#arguments.manifestRoot#/rev-manifest.json" );
		}

		// Use the module if requested and if it exists, else fall back on app root
		if ( arguments.useModuleRoot && len( arguments.currentModule ) ) {
			var manifestPath = controller.getSetting( "modules" ).find( arguments.currentModule ).path &
			"/" &
			controller.getColdBoxSetting( "IncludesConvention" ) &
			"/rev-manifest.json";
			if ( fileExists( manifestPath ) ) {
				return manifestPath;
			}
		}

		// Use App Root Path
		return controller.getSetting( "applicationPath" ) &
		controller.getColdBoxSetting( "IncludesConvention" ) &
		"/rev-manifest.json";
	}


	/******************************************** PRIVATE ********************************************/

	/**
	 * Convert a table out of an array of objects
	 *
	 * @data The array to convert into a table
	 * @includes The columns to include
	 * @excludes The columns to exclude
	 * @buffer The output buffer
	 */
	function objectsToTable(
		required data,
		string includes = "",
		string excludes = "",
		required buffer
	){
		var str   = arguments.buffer;
		var attrs = "";
		var x     = 1;
		var y     = 1;
		var key   = "";

		// Metadata
		var firstMetadata = {};
		if ( !isNull( arguments.data[ 1 ] ) ) {
			firstMetadata = getMetadata( arguments.data[ 1 ] );
		}
		// All properties
		var properties     = structKeyExists( firstMetadata, "properties" ) ? firstMetadata.properties : [];
		// Filtered properties
		var showProperties = properties.filter( function( item ){
			return ( passIncludeExclude( item.name, includes, excludes ) );
		} );

		// Show Headers
		showProperties.each( function( item ){
			if ( variables.settings.encodeValues ) {
				item.name = encodeForHTML( item.name );
			}
			buffer.append( "<th>#item.name#</th>" );
		} );

		buffer.append( "</tr></thead><tbody>" );

		arguments.data.each( function( thisRow ){
			buffer.append( "<tr>" );

			showProperties.each( function( thisProperty ){
				var thisValue = invoke( thisRow, "get#thisProperty.name#" );
				if ( variables.settings.encodeValues ) {
					thisValue = encodeForHTML( thisValue );
				}
				buffer.append( "<td>#thisValue#</td>" );
			} );

			buffer.append( "</tr>" );
		} );

		return this;
	}

	/**
	 * Convert a table out of an array of structs
	 *
	 * @data The array to convert into a table
	 * @includes The columns to include
	 * @excludes The columns to exclude
	 * @buffer The output buffer
	 */
	function arrayToTable(
		required data,
		string includes = "",
		string excludes = "",
		required buffer
	){
		// Guess columns from first struct found
		var thisData = ( isNull( data[ 1 ] ) ? structNew() : data[ 1 ] );

		var columns = structKeyArray( thisData ).filter( function( item ){
			return ( passIncludeExclude( item, includes, excludes ) );
		} );

		// print out headers
		columns.each( function( item ){
			if ( variables.settings.encodeValues ) {
				item = encodeForHTML( item );
			}
			buffer.append( "<th>#item#</th>" );
		} );

		buffer.append( "</tr></thead><tbody>" );

		// Present each record in the data array
		arguments.data.each( function( thisRow ){
			buffer.append( "<tr>" );

			// Only show the right columns
			columns.each( function( thisColumn ){
				var thisValue = thisRow[ thisColumn ];
				if ( variables.settings.encodeValues ) {
					thisValue = encodeForHTML( thisValue );
				}
				buffer.append( "<td>#thisValue#</td>" );
			} );

			buffer.append( "</tr>" );
		} );

		return this;
	}

	/**
	 * Convert a table out of a query, usually the header tag has already printed
	 *
	 * @data The query to convert into a table
	 * @includes The columns to include
	 * @excludes The columns to exclude
	 * @buffer The output buffer
	 */
	function queryToTable(
		required data,
		string includes = "",
		string excludes = "",
		required buffer
	){
		var columns = listToArray( arguments.data.columnList ).filter( function( item ){
			return ( passIncludeExclude( item, includes, excludes ) );
		} );

		// Render Headers
		columns.each( function( item ){
			if ( variables.settings.encodeValues ) {
				item = encodeForHTML( item );
			}
			buffer.append( "<th>#item#</th>" );
		} );

		arguments.buffer.append( "</tr></thead><tbody>" );


		// Render Body from query
		for ( var thisRow in arguments.data ) {
			arguments.buffer.append( "<tr>" );

			columns.each( function( item ){
				var thisValue = thisRow[ item ];
				if ( variables.settings.encodeValues ) {
					thisValue = encodeForHTML( thisValue );
				}
				buffer.append( "<td>#thisValue#</td>" );
			} );

			arguments.buffer.append( "</tr>" );
		}

		return this;
	}

	/**
	 * Convert a sent in tag type to an HTML list
	 *
	 * @tag The list tag type
	 * @values An array or list of values
	 * @column If the values is a query, this is the name of the column to get the data from to create the list
	 * @data A structure that will add data-{key} elements to the HTML control
	 */
	function toHtmlList(
		required tag,
		required values,
		column      = "",
		struct data = {}
	){
		var val    = arguments.values;
		var x      = 1;
		var buffer = createObject( "java", "java.lang.StringBuilder" ).init( "" );
		var br     = chr( 13 );
		var args   = "";

		// list or array or query?
		if ( isSimpleValue( val ) ) {
			val = listToArray( val );
		}
		if ( isQuery( val ) ) {
			val = getColumnArray( val, arguments.column );
		}

		// start tag
		buffer.append( "<#arguments.tag#" );

		// flatten extra attributes via arguments
		flattenAttributes( arguments, "tag,values,column", buffer ).append( ">" );

		// values
		for ( var thisValue in val ) {
			if ( isArray( thisValue ) ) {
				buffer.append( toHTMLList( arguments.tag, thisValue, arguments.column ) );
			} else {
				buffer.append( this.tag( tag = "li", content = thisValue ) );
			}
		}

		buffer.append( "</#arguments.tag#>" );

		return buffer.toString();
	}

	/**
	 * Bind entity values
	 *
	 * @args The argument structures
	 */
	private function bindValue( required args ){
		// binding?
		if ( isObject( arguments.args.bind ) ) {
			// do we have a bindProperty, else default it from the name
			if ( NOT len( arguments.args.bindProperty ) ) {
				// check if name exists else throw exception
				if ( NOT structKeyExists( arguments.args, "name" ) OR NOT len( arguments.args.name ) ) {
					throw(
						type    = "HTMLHelper.NameBindingException",
						message = "The 'name' argument was not passed and no binding property was passed, so we can't bind dude!"
					);
				}

				// bind name property
				arguments.args.bindProperty = arguments.args.name;
			}

			// entity value
			var entityValue = invoke( arguments.args.bind, "get#arguments.args.bindProperty#" );

			if ( isNull( local.entityValue ) ) {
				entityValue = "";
			}

			// Verify if the value is an entity, if it is, then use the 'column' to retrieve the value
			if ( isObject( entityValue ) ) {
				entityValue = invoke( entityValue, "get#arguments.args.column#" );
			}

			// If radio or checkbox button, check it
			if (
				structKeyExists( arguments.args, "type" ) AND listFindNoCase(
					"radio,checkbox",
					arguments.args.type
				)
			) {
				// is incoming value eq to property value with boolean aspects
				if (
					structKeyExists( arguments.args, "value" ) and
					isBoolean( arguments.args.value ) and
					yesNoFormat( arguments.args.value ) EQ yesNoFormat( entityValue )
				) {
					arguments.args.checked = true;
				}
				// else with no boolean evals
				else if ( structKeyExists( arguments.args, "value" ) and arguments.args.value EQ entityValue ) {
					arguments.args.checked = true;
				}
			} else {
				// If there is no incoming value, then bind it
				arguments.args.value = entityValue;
			}
		}

		return this;
	}

	/**
	 * Normalize ID with name arguments
	 *
	 * @args The argument structures
	 */
	private function normalizeID( required args ){
		if (
			structKeyExists( arguments.args, "name" ) AND
			len( arguments.args.name ) AND
			NOT structKeyExists( arguments.args, "id" )
		) {
			arguments.args.id = arguments.args.name;
		}
		return this;
	}

	/**
	 * Wrap a tag in the buffer
	 *
	 * @buffer The output buffer
	 * @tag The tag to wrap with
	 * @end Start or end of tag
	 * @attrs The attributes of the tag
	 *
	 */
	private function wrapTag(
		required buffer,
		required tag,
		boolean end = false,
		struct attrs
	){
		// Only do if we have length
		if ( len( arguments.tag ) ) {
			// Starting or ending?
			if ( arguments.end ) {
				arguments.buffer.append( "</#listFirst( arguments.tag, " " )#>" );
			} else {
				arguments.buffer.append( "<#arguments.tag#" );
				if ( !isNull( arguments.attrs ) ) {
					for ( var attr in structKeyArray( arguments.attrs ) ) {
						arguments.buffer.append( " " & attr & "=""" & structFind( arguments.attrs, attr ) & """" );
					}
				}
				arguments.buffer.append( ">" );
			}
		}

		return this;
	}

	/**
	 * Make pretty text
	 * @text Target
	 */
	private string function makePretty( required text ){
		return uCase( left( arguments.text, 1 ) ) & removeChars(
			lCase( replace( arguments.text, "_", " " ) ),
			1,
			1
		);
	}

	/**
	 * Prepare a base link
	 * @noBaseURL Indicator for building
	 * @src The source target
	 */
	private string function prepareBaseLink( boolean noBaseURL = false, src ){
		var baseURL = replaceNoCase(
			controller
				.getRequestService()
				.getContext()
				.getSESbaseURL(),
			"index.cfm",
			""
		);
		// return if base is eempty
		if ( NOT len( baseURL ) ) {
			return arguments.src;
		}

		// Check if we have a base URL
		if ( arguments.noBaseURL eq FALSE and NOT find( "://", arguments.src ) ) {
			arguments.src = baseURL & "/" & arguments.src;
		}

		return arguments.src;
	}

	/**
	 * checks if a list include exclude check passes
	 *
	 * @value The target
	 * @includes The includes list
	 * @excludes The excludes list
	 */
	private boolean function passIncludeExclude( required value, includes = "", excludes = "" ){
		var disp = true;
		// Include List?
		if ( len( arguments.includes ) AND NOT listFindNoCase( arguments.includes, arguments.value ) ) {
			disp = false;
		}
		// Exclude List?
		if ( len( arguments.excludes ) AND listFindNoCase( arguments.excludes, arguments.value ) ) {
			disp = false;
		}
		return disp;
	}

	/**
	 * flatten a struct of attributes to strings and returns the incoming buffer
	 *
	 * @target The target
	 * @excludes The excludes list
	 * @buffer The buffer object
	 */
	private function flattenAttributes(
		required struct target,
		excludes = "",
		required buffer
	){
		// global exclusions
		arguments.excludes &= ",fieldWrapper,labelWrapper,wrapperAttrs,fieldWrapperAttrs,labelWrapperAttrs,groupWrapperAttrs,entity,booleanSelect,textareas,manytoone,onetomany,sendToHeader,bind,inputInsideLabel,labelAttrs";

		for ( var key in arguments.target ) {
			// Excludes
			if ( len( arguments.excludes ) AND listFindNoCase( arguments.excludes, key ) ) {
				continue;
			}

			// Normal Keys
			if (
				structKeyExists( arguments.target, key ) AND isSimpleValue( arguments.target[ key ] ) AND len(
					arguments.target[ key ]
				)
			) {
				arguments.buffer.append(
					" #lCase( key )#=""#encodeForHTMLAttribute( arguments.target[ key ] )#"""
				);
			}

			// data keys
			if ( isStruct( arguments.target[ key ] ) ) {
				for ( var dataKey in arguments.target[ key ] ) {
					if (
						isSimpleValue( arguments.target[ key ][ dataKey ] ) AND len(
							arguments.target[ key ][ dataKey ]
						)
					) {
						arguments.buffer.append(
							" #lCase( key )#-#lCase( dataKey )#=""#encodeForHTMLAttribute( arguments.target[ key ][ datakey ] )#"""
						);
					}
				}
			}
		}

		return arguments.buffer;
	}

	/**
	 * Intercepts any XX() call to the helper, meaning rendering ANY type of tag.
	 * The first positional argument will be treated as the content of the tag or you can use
	 * the <code>content</code> argument directly:
	 *
	 * <pre>
	 * #html.myWidget( 'is Awesome' )# -> <mywidget>is Awesome</mywidget>
	 *
	 * #html.contacts( class='bold', content='My Contacts' )# -> <contacts class='bold'>My Contacts</contacts>
	 * </pre>
	 */
	function onMissingMethod( missingMethodName, missingMethodArguments ){
		arguments.missingMethodArguments.tag = arguments.missingMethodName;

		// Positional Content
		if ( structKeyExists( arguments.missingMethodArguments, 1 ) ) {
			arguments.missingMethodArguments.content = arguments.missingMethodArguments.1;
			structDelete( arguments.missingMethodArguments, 1 );
		}

		// Return tag
		return tag( argumentCollection = arguments.missingMethodArguments );
	}

	/**
	 * Returns an array of values from the query and column
	 *
	 * @qry The target query
	 * @columnName The column name to use
	 */
	private array function getColumnArray( required qry, required columnName ){
		var results = [];

		// Done this way as ACF is so iconsistent
		for ( var thisRow in arguments.qry ) {
			results.append( thisRow[ arguments.columnName ] );
		}

		return results;
	}

	/**
	 * Facade to CFML htmlHead
	 */
	private function $htmlHead( required content ){
		cfhtmlhead( text = "#arguments.content#" );
		return this;
	}

}
