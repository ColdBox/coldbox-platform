/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A delegate for string manipulation and operations
 */
component singleton {

	/**
	 * Convert a string to camel case using a functional approach.
	 *
	 * @target The string to convert to camel case.
	 *
	 * @return The string in camel case.
	 */
	function camelCase( required target ){
		return arguments.target
			.replace( "_", " " )
			.listToArray( " " )
			.filter( ( word ) => returnlen( trim( arguments.word ) ) > 0 )
			.map( ( word, index ) => {
				return ( arguments.index === 0 ) ? lCase( arguments.word ) : uCase( left( arguments.word, 1 ) ) & lCase(
					mid( arguments.word, 2 )
				);
			} )
			.toList();
	}

	/**
	 * Create a headline from a string delimited by casing, hyphens, or underscores into a space delimited string with each word's first letter capitalized:
	 *
	 * @target The string to convert to a headline.
	 */
	function headline( required target ){
		return snakeCase( arguments.target )
			.replace( "_", " " )
			.replace( "-", " " )
			.listToArray( " " )
			.filter( ( word ) => returnlen( trim( arguments.word ) ) > 0 )
			.map( ( word, index ) => {
				return this.ucFirst( arguments.word );
			} )
			.toList( " " );
	}

	/**
	 * Uppercase the first letter of a string.
	 *
	 * @target The target string
	 */
	function ucFirst( required target ){
		return server.keyExists( "lucee" ) ? ucFirst( arguments.target ) : uCase( left( arguments.target, 1 ) ) & right(
			arguments.target,
			len( arguments.target ) - 1
		);
	}

	/**
	 * Convert a string to snake case.
	 *
	 * @target    The string to convert to snake case.
	 * @delimiter The delimiter to use (default is underscore).
	 *
	 * @return The string in snake case.
	 */
	function snakeCase( required target, delimiter = "_" ){
		return reReplace(
			arguments.target,
			"([a-z0-9])([A-Z])",
			"\1" & arguments.delimiter & "\2",
			"ALL"
		).toLowerCase();
	}

	/**
	 * Convert a singular word to a plural word
	 *
	 * @word The word to convert
	 */
	function pluralize( required word ){
		var result = arguments.word;

		if ( result.endsWith( "s" ) ) {
			if ( result.endsWith( "ss" ) || result.endsWith( "us" ) ) {
				result &= "es";
			} else {
				result &= "s";
			}
		} else if ( result.endsWith( "y" ) ) {
			if ( arrayFindNoCase( [ "ay", "ey", "iy", "oy", "uy" ], right( result, 2 ) ) ) {
				result &= "s";
			} else {
				result = left( result, len( result ) - 1 ) & "ies";
			}
		} else if ( arrayFindNoCase( [ "x", "s", "z", "ch", "sh" ], right( result, 1 ) ) ) {
			result &= "es";
		} else {
			result &= "s";
		}

		return result;
	}

	/**
	 * Convert a plural word to a singular word
	 *
	 * @word The word to convert
	 */
	function singularize( required word ){
		var result = arguments.word;

		if ( result.endsWith( "s" ) ) {
			if ( result.endsWith( "ss" ) || result.endsWith( "us" ) ) {
				result &= "es";
			} else if ( result.endsWith( "is" ) ) {
				result = left( result, len( result ) - 2 ) & "is";
			} else if ( result.endsWith( "es" ) ) {
				if ( len( result ) > 3 && arrayFindNoCase( [ "sh", "ch" ], right( result, 2 ) ) ) {
					result = left( result, len( result ) - 2 );
				} else {
					result = left( result, len( result ) - 1 );
				}
			} else {
				result = left( result, len( result ) - 1 );
			}
		}

		return result;
	}

}
