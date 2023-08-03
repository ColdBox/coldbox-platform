/**
 * The main ColdBox utility library.
 */
component {

	/****************************************************************
	 * SERVER/USER/CFML ENGINE HELPERS *
	 ****************************************************************/

	private function getEngineMappingHelper(){
		// Lazy load the helper
		if ( isNull( variables.engineMappingHelper ) ) {
			// Detect server
			if ( listFindNoCase( "Lucee", server.coldfusion.productname ) ) {
				variables.engineMappingHelper = new LuceeMappingHelper();
			} else {
				variables.engineMappingHelper = new CFMappingHelper();
			}
		}
		return variables.engineMappingHelper;
	}

	/**
	 * Add a path to the application's custom tag path
	 *
	 * @path The absolute path to the directory containing tags
	 */
	Util function addCustomTagPath( required path ){
		getEngineMappingHelper().addCustomTagPath( arguments.path );
		return this;
	}

	/**
	 * Add a CFML Mapping to the running engine
	 *
	 * @name     The name of the mapping
	 * @path     The path of the mapping
	 * @mappings A struct of mappings to incorporate instead of one-offs
	 */
	Util function addMapping( string name, string path, struct mappings ){
		var engineMappingHelper = getEngineMappingHelper();

		if ( !isNull( arguments.mappings ) ) {
			engineMappingHelper.addMappings( arguments.mappings );
		} else {
			// Add / registration
			if ( left( arguments.name, 1 ) != "/" ) {
				arguments.name = "/#arguments.name#";
			}

			// Add mapping
			engineMappingHelper.addMapping( arguments.name, arguments.path );
		}

		return this;
	}

	/**
	 * Check if you are in cfthread or not for any CFML Engine
	 *
	 * @path The file target
	 */
	boolean function inThread(){
		var engine = "ADOBE";

		if ( server.coldfusion.productname eq "Lucee" ) {
			engine = "LUCEE";
		}

		switch ( engine ) {
			case "ADOBE": {
				if (
					findNoCase(
						"cfthread",
						createObject( "java", "java.lang.Thread" )
							.currentThread()
							.getThreadGroup()
							.getName()
					)
				) {
					return true;
				}
				break;
			}
			case "LUCEE": {
				return isInThread();
			}
		}
		return false;
	}

	/**
	 * Get the hostname of the executing machine.
	 */
	function discoverInetHost(){
		try {
			return getInetAddress().getLocalHost().getHostName();
		} catch ( any e ) {
			return cgi.SERVER_NAME;
		}
	}

	/**
	 * Get the server IP Address
	 */
	string function getServerIp(){
		try {
			return getInetAddress().getLocalHost().getHostAddress();
		} catch ( any e ) {
			return "0.0.0.0";
		}
	}

	/**
	 * Get the Java InetAddress object
	 *
	 * @return java.net.InetAddress
	 */
	private function getInetAddress(){
		if ( isNull( variables.inetAddress ) ) {
			variables.inetAddress = createObject( "java", "java.net.InetAddress" );
		}
		return variables.inetAddress;
	}

	/****************************************************************
	 * CONVERSTION METHODS *
	 ****************************************************************/

	/**
	 * Convert an array to struct argument notation
	 *
	 * @target The array to convert
	 */
	struct function arrayToStruct( required array target ){
		return arguments.target.reduce( function( result, item, index ){
			arguments.result[ arguments.index ] = arguments.item;
			return arguments.result;
		}, {} );
	}

	/****************************************************************
	 * FILE HELPERS *
	 ****************************************************************/

	/**
	 * Get the last modified date of a file
	 *
	 * @filename The file target
	 */
	function fileLastModified( required filename ){
		return getFileInfo( getAbsolutePath( arguments.filename ) ).lastModified;
	}

	/**
	 * Rip the extension of a filename.
	 *
	 * @filename The file target
	 */
	function ripExtension( required filename ){
		return reReplace( arguments.filename, "\.[^.]*$", "" );
	}

	/**
	 * Turn any system path, either relative or absolute, into a fully qualified one
	 *
	 * @path The file target
	 */
	function getAbsolutePath( required path ){
		if ( fileExists( arguments.path ) ) {
			return arguments.path;
		}
		return expandPath( arguments.path );
	}

	/****************************************************************
	 * STRING HELPERS *
	 ****************************************************************/

	/**
	 * Format an incoming json string to a pretty version
	 *
	 * @target The target json to prettify
	 *
	 * @return The prettified json
	 */
	string function prettyJson( string target = "" ){
		var newLine = chr( 13 ) & chr( 10 );
		var tab     = chr( 9 );
		var padding = 0;
		return arguments.target
			.reReplace(
				"([\{|\}|\[|\]|\(|\)|,])",
				"\1#newLine#",
				"all"
			)
			.reReplace( "(\]|\})#newLine#", "#newLine#\1", "all" )
			.listToArray( newLine )
			.map( ( token ) => {
				if ( token.reFind( "[\}|\)|\]]" ) && padding > 0 ) {
					padding--;
				};
				var newToken = repeatString( tab, padding ) & token.trim();
				if ( token.reFind( "[\{|\(|\[]" ) ) {
					padding++;
				};
				return newToken;
			} )
			.toList( newLine );
	}

	/**
	 * Opinionated method that serializes json in a more digetstible way:
	 * - queries as array of structs
	 * - no dumb secure prefixes
	 * And it also prettifies the output
	 *
	 * @obj The object to be serialized and prettified
	 */
	string function toPrettyJson( required any obj ){
		return prettyJson( toJson( arguments.obj ) );
	}

	/**
	 * Opinionated method that serializes json in a more digetstible way:
	 * - queries as array of structs
	 * - no dumb secure prefixes
	 *
	 * @obj The object to be serialized
	 */
	string function toJson( required any obj ){
		// https://cfdocs.org/serializejson
		// We default to "struct" serialization for queries.  The CFML defaults are dumb and just nasty!
		return serializeJSON(
			arguments.obj,
			"struct",
			listFindNoCase( "Lucee", server.coldfusion.productname ) ? "utf-8" : false
		);
	}

	/**
	 * PlaceHolder Replacer for strings containing <code>${}</code> patterns
	 *
	 * @str      The string target
	 * @settings The structure of settings to use in the replacements
	 *
	 * @return The string with the replacements
	 */
	function placeHolderReplacer( required str, required settings ){
		var returnString = arguments.str;
		var regex        = "\$\{([0-9a-z\-\.\_]+)\}";
		var lookup       = 0;
		var varName      = 0;
		var varValue     = 0;

		// Loop and Replace
		while ( true ) {
			// Search For Pattern
			var lookup = reFindNoCase( regex, returnString, 1, true );
			// Found?
			if ( lookup.pos[ 1 ] ) {
				// Get Variable Name From Pattern
				var varName  = mid( returnString, lookup.pos[ 2 ], lookup.len[ 2 ] );
				var varValue = "VAR_NOT_FOUND";

				// Lookup Value
				if ( structKeyExists( arguments.settings, varname ) ) {
					varValue = arguments.settings[ varname ];
				}
				// Lookup Nested Value
				else if ( isDefined( "arguments.settings.#varName#" ) ) {
					varValue = structFindKey( arguments.settings, varName )[ 1 ].value;
				}
				// Remove PlaceHolder Entirely
				returnString = removeChars( returnString, lookup.pos[ 1 ], lookup.len[ 1 ] );
				// Insert Var Value
				returnString = insert( varValue, returnString, lookup.pos[ 1 ] - 1 );
			} else {
				break;
			}
		}

		return returnString;
	}

	/**
	 * Get the mixer utility
	 *
	 * @return coldbox.system.core.dynamic.MixerUtil
	 */
	function getMixerUtil(){
		if ( isNull( variables.mixerUtil ) ) {
			variables.mixerUtil = new coldbox.system.core.dynamic.MixerUtil();
		}
		return variables.mixerUtil;
	}

	/****************************************************************
	 * COLDBOX TAXONOMY Methods *
	 ****************************************************************/

	/**
	 * Checks if an object is of the passed in family type
	 *
	 * @family The family to covert it to: handler, interceptor
	 * @target The target object
	 */
	boolean function isFamilyType( required family, required target ){
		var familyPath = "";

		switch ( arguments.family ) {
			case "handler": {
				familyPath = "coldbox.system.EventHandler";
				break;
			}
			case "interceptor": {
				familyPath = "coldbox.system.Interceptor";
				break;
			}
			default: {
				throw( "Invalid family sent #arguments.family#" );
			}
		}

		return isInstanceOf( arguments.target, familyPath );
	}

	/**
	 * Decorate an object as a ColdBox Family object
	 *
	 * @family The family to convert it to
	 * @target The target object
	 *
	 * @return The same target object
	 */
	function convertToColdBox( required family, required target ){
		var familyPath = "";

		switch ( arguments.family ) {
			case "handler": {
				familyPath = "coldbox.system.EventHandler";
				break;
			}
			case "interceptor": {
				familyPath = "coldbox.system.Interceptor";
				break;
			}
			default: {
				throw( "Invalid family sent #arguments.family#" );
			}
		}

		// Mix it up baby
		arguments.target.$injectUDF = getMixerUtil().injectMixin;

		// Create base family object
		var baseObject = createObject( "component", familyPath );

		// Check if init already exists?
		if ( structKeyExists( arguments.target, "init" ) ) {
			arguments.target.$cbInit = baseObject.init;
		}

		// Mix in methods
		for ( var key in baseObject ) {
			// If handler has overridden method, then don't override it with mixin, simulated inheritance
			if ( NOT structKeyExists( arguments.target, key ) ) {
				arguments.target.$injectUDF( key, baseObject[ key ] );
			}
		}

		// Mix in fake super class
		arguments.target.$super = baseObject;

		return arguments.target;
	}

	/**
	 * Should we stop recursion or not due to class name found: Boolean
	 *
	 * @className      The class name to check
	 * @stopRecursions An array of classes to stop processing for during inheritance trails
	 */
	private boolean function stopClassRecursion( required classname, required stopRecursions ){
		// Try to find a match
		for ( var thisClass in arguments.stopRecursions ) {
			if ( compareNoCase( thisClass, arguments.classname ) eq 0 ) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Returns a single-level metadata struct that includes all items inhereited from extending classes.
	 *
	 * @component      The component instance or path to get the metadata from
	 * @stopRecursions An array of classes to stop processing for during inheritance trails
	 * @md             A structure containing a copy of the metadata for this level of recursion.
	 *
	 * @return struct of metadata
	 */
	function getInheritedMetaData(
		required component,
		array stopRecursions = [],
		struct md            = {}
	){
		var loc = {};

		// First time through, get metaData of component by path or instance
		if ( arguments.md.isEmpty() ) {
			arguments.md = (
				isObject( arguments.component ) ? getMetadata( arguments.component ) : getComponentMetadata(
					arguments.component
				)
			);
		}

		// If it has a parent, stop and calculate it first, unless of course, we've reached a class we shouldn't recurse into.
		if (
			structKeyExists( arguments.md, "extends" ) &&
			arguments.md.type eq "component" &&
			stopClassRecursion( md.extends.name, arguments.stopRecursions ) EQ FALSE
		) {
			loc.parent = getInheritedMetaData(
				component      = arguments.component,
				stopRecursions = arguments.stopRecursions,
				md             = arguments.md.extends
			);
			// If we're at the end of the line, it's time to start working backwards so start with an empty struct to hold our condensesd metadata.
		} else {
			loc.parent = { "inheritanceTrail" : [] };
		}

		// Override ourselves into parent
		for ( var thisKey in arguments.md ) {
			// https://luceeserver.atlassian.net/browse/LDEV-4421
			if ( arrayContains( [ "sub", "subname" ], thisKey ) ) {
				continue;
			}
			// Functions and properties are an array of structs keyed on name, so I can treat them the same
			if ( listFindNoCase( "functions,properties", thisKey ) ) {
				if ( !structKeyExists( loc.parent, thisKey ) ) {
					loc.parent[ thisKey ] = [];
				}

				// For each function/property in me...
				for ( var thisItem in arguments.md[ thisKey ] ) {
					loc.parentItemCounter = 0;
					loc.foundInParent     = false;
					// ...Look for an item of the same name in my parent...
					for ( var thisParentItem in loc.parent[ thisKey ] ) {
						loc.parentItemCounter++;
						// ...And override it
						if ( compareNoCase( thisItem.name, thisParentItem.name ) eq 0 ) {
							loc.parent[ thisKey ][ loc.parentItemCounter ] = thisItem;
							loc.foundInParent                              = true;
							break;
						}
					}
					// ..Or add it
					if ( not loc.foundInParent ) {
						arrayAppend( loc.parent[ thisKey ], thisItem );
					}
				}
			}
			// Add in anything that's not inheritance or implementation
			else if ( NOT listFindNoCase( "extends,implements", thisKey ) ) {
				loc.parent[ thisKey ] = arguments.md[ thisKey ];
			}
		}

		// Store away the inheritance trail
		arrayPrepend( loc.parent.inheritanceTrail, loc.parent.name );

		// Return our results
		return loc.parent;
	}

	/**
	 * Get the Hibernate version string from Hibernate or Hibernate bundle version
	 */
	public string function getHibernateVersion(){
		var version = createObject( "java", "org.hibernate.Version" );

		if ( version.getVersionString() != "[WORKING]" ) {
			return version.getVersionString();
		} else {
			// Due to the insanity of a broken `MANIFEST.MF` in the Lucee Hibernate bundle, we need to pull the `Bundle-Version` instead
			return version
				.getClass()
				.getClassLoader()
				.getBundle()
				.getVersion()
				.toString();
		}
	}

	/**
	 **************************************************************************************************************
	 * DEPRECATED FUNCTIONS
	 * TODO: REMOVE BY V8
	 * **************************************************************************************************************
	 */

	/**
	 * @deprecated Refactor to use the Env Delegate: coldbox.system.core.delegates.Env
	 */
	function getSystemSetting( required key, defaultValue ){
		return new coldbox.system.core.delegates.Env().getSystemSetting( argumentCollection = arguments );
	}

	/**
	 * @deprecated Refactor to use the Env Delegate: coldbox.system.core.delegates.Env
	 */
	function getSystemProperty( required key, defaultValue ){
		return new coldbox.system.core.delegates.Env().getSystemProperty( argumentCollection = arguments );
	}

	/**
	 * @deprecated Refactor to use the Env Delegate: coldbox.system.core.delegates.Env
	 */
	function getEnv( required key, defaultValue ){
		return new coldbox.system.core.delegates.Env().getEnv( argumentCollection = arguments );
	}

}
