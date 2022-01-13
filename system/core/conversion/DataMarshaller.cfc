/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Ability to serialize content to the output stream
 */
component accessors="true" singleton {

	// DI
	property name="xmlConverter"   inject="XMLConverter@coldbox";
	property name="requestService" inject="coldbox:requestService";

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

	/**
	 * Marshall data according to types or conventions on data objects
	 *
	 * @type             The type to marshal to. Valid values are JSON, XML, WDDX, PLAIN, HTML, TEXT
	 * @data             The data to marshall
	 * @encoding         The default character encoding to use, defaults to UTF-8
	 * @jsonCallback     Only needed when using JSONP, this is the callback to add to the JSON packet
	 * @jsonQueryFormat  JSON Only: This parameter can be a Boolean value that specifies how to serialize ColdFusion queries or a string with possible values row, column, or struct
	 * @xmlColumnList    XML Only: Choose which columns to inspect, by default it uses all the columns in the query, if using a query
	 * @xmlUseCDATA      XML Only: Use CDATA content for ALL values. The default is false
	 * @xmlListDelimiter XML Only: The delimiter in the list. Comma by default
	 * @xmlRootName      XML Only: The name of the initial root element of the XML packet
	 * @pdfArgs          All the PDF arguments to pass along to the CFDocument tag.
	 *
	 * @return Marshalled content according to type and arguments
	 *
	 * @throws InvalidMarshallingType - When an invalid rendering type is detected
	 */
	function marshallData(
		required type,
		required data,
		encoding            = "UTF-8",
		jsonCallback        = "",
		jsonQueryFormat     = true,
		xmlColumnList       = "",
		boolean xmlUseCDATA = false,
		xmlListDelimiter    = ",",
		xmlRootName         = "",
		struct pdfArgs      = {}
	){
		// Validation Types
		if ( !reFindNoCase( "^(JSON|JSONP|JSONT|WDDX|XML|PLAIN|HTML|TEXT|PDF)$", arguments.type ) ) {
			throw(
				message: "Invalid type",
				detail : "The type you sent: #arguments.type# is invalid. Valid types are JSON, JSONP, WDDX, XML, TEXT, PDF and PLAIN",
				type   : "InvalidMarshallingType"
			);
		}

		// Verify $renderdata Convention
		if ( isObject( arguments.data ) && structKeyExists( arguments.data, "$renderdata" ) ) {
			return arguments.data.$renderdata( argumentCollection = arguments );
		}

		// Render according to type
		var results = "";
		switch ( arguments.type ) {
			case "JSON":
			case "JSONP": {
				// marshall to JSON
				results = serializeJSON( arguments.data, arguments.jsonQueryFormat );
				// wrap results in callback function for JSONP
				if ( len( arguments.jsonCallback ) > 0 ) {
					results = "#arguments.jsonCallback#(#results#)";
				}

				break;
			}

			case "WDDX": {
				cfwddx(
					action = "cfml2wddx",
					input  = "#arguments.data#",
					output = "results"
				);
				break;
			}

			case "XML": {
				args.data      = arguments.data;
				args.encoding  = arguments.encoding;
				args.useCDATA  = arguments.xmlUseCDATA;
				args.delimiter = arguments.xmlListDelimiter;
				args.rootName  = arguments.xmlRootName;
				if ( len( trim( arguments.xmlColumnList ) ) ) {
					args.columnlist = arguments.xmlColumnList;
				}
				// Marshal to xml
				results = xmlConverter.toXML( argumentCollection = args );
				break;
			}

			case "PDF": {
				results = arguments.data;
				// We only process NON binary PDF data
				if ( !isBinary( arguments.data ) ) {
					pdfArgs.format = "PDF";
					pdfArgs.name   = "results";
					// Convert to PDF
					include "CFDocument.cfm";
				}
			}

			// Plaint TEXT, HTML, CUSTOM Data
			default: {
				results = arguments.data;
				break;
			}
		}

		return results;
	}

	/**
	 * Render content out using cfcontent
	 *
	 * @type     The content type to use for rendering
	 * @variable The variable to render the content from, could be null
	 * @encoding The page encoding
	 * @reset    Reset the content at the end or not
	 */
	function renderContent(
		required type,
		variable,
		encoding      = "UTF-8",
		boolean reset = false
	){
		// Verify incoming encoding or append it
		if ( !findNoCase( ";", arguments.type ) ) {
			arguments.type &= "; charset=#arguments.encoding#";
		}
		// Setup the output header
		variables.requestService.getContext().setHTTPHeader( name: "content-type", value: arguments.type );
		// Do we have an incoming variable to render?
		if ( !isNull( arguments.variable ) ) {
			cfcontent(
				type     = "#arguments.type#",
				variable = "#arguments.variable#",
				reset    = "#arguments.reset#"
			);
		} else {
			cfcontent( type = "#arguments.type#", reset = "#arguments.reset#" );
		}
		// Make sure no debugging output is enabled
		cfsetting( showdebugoutput = "false" );
	}

	/**
	 * Reset the cfcontent
	 */
	DataMarshaller function resetContent(){
		cfcontent( reset = true );
		return this;
	}

}
