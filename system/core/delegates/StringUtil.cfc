/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A delegate for string manipulation and operations
 */
component singleton {

	variables.NEW_LINE = chr( 13 ) & chr( 10 );
	variables.TAB      = chr( 9 );

	/**
	 * Format an incoming sql string to a pretty version
	 *
	 * @target The target sql to prettify
	 *
	 * @return The prettified sql
	 */
	function prettySql( string target = "" ){
		var keywords = [
			"ALTER TABLE",
			"CREATE TABLE",
			"DELETE",
			"DROP TABLE",
			"FROM",
			"GROUP BY",
			"HAVING",
			"INSERT INTO",
			"LIMIT",
			"ORDER BY",
			"OFFSET",
			"SELECT",
			"UNION",
			"UPDATE",
			"WHERE"
		];
		var indentedKeywords = [
			"FULL JOIN",
			"INNER JOIN",
			"JOIN",
			"LEFT JOIN",
			"OUTER JOIN"
		];
		var indent = "  ";

		return arguments.target
			.listToArray( variables.NEW_LINE )
			.map( ( item ) => item.trim() )
			// comma spacing
			.map( ( item ) => item.reReplace(
				"\s*(?![^()]*\))(,)\s*",
				",#variables.NEW_LINE##indent#",
				"all"
			) )
			// Parenthesis spacing
			.map( ( item ) => item.reReplace( "\((\w)", "( \1", "all" ) )
			.map( ( item ) => item.reReplace( "(\w)\)", "\1 )", "all" ) )
			// Keyword spacing
			.map( ( item ) => {
				return item.reReplacenocase(
					"(\s)*(#keywords.toList( "|" )#)(\s)+",
					"#variables.NEW_LINE#\2#variables.NEW_LINE##indent#",
					"all"
				)
			} )
			// Indented keyword spacing
			.map( ( item ) => {
				return item.reReplacenocase(
					"(#indentedKeywords.toList( "|" )#)",
					"#variables.NEW_LINE##indent#\1",
					"all"
				)
			} )
			.toList( variables.NEW_LINE );
	}

	/**
	 * Slugify a string for URL Safety
	 *
	 * @str       Target to slugify
	 * @maxLength The maximum number of characters for the slug
	 * @allow     a regex safe list of additional characters to allow
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
	 * Convert a string to camel case using a functional approach.
	 *
	 * @target The string to convert to camel case.
	 *
	 * @return The string in camel case.
	 */
	function camelCase( required target ){
		return arguments.target
			.replace( "_", " ", "all" )
			.replace( "-", " ", "all" )
			.listToArray( " " )
			.filter( ( word ) => len( trim( arguments.word ) ) > 0 )
			.map( ( word, index ) => {
				return ( arguments.index === 1 ) ? lCase( arguments.word ) : _ucFirst( arguments.word );
			} )
			.toList( "" );
	}

	/**
	 * Create a headline from a string delimited by casing, hyphens, or underscores into a space delimited string with each word's first letter capitalized:
	 *
	 * @target The string to convert to a headline.
	 */
	function headline( required target ){
		return snakeCase( arguments.target )
			.replace( "_", " ", "all" )
			.replace( "-", " ", "all" )
			.listToArray( " " )
			.filter( ( word ) => len( trim( arguments.word ) ) > 0 )
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
		if ( len( arguments.target ) == 1 ) {
			return uCase( arguments.target );
		}
		return server.keyExists( "lucee" ) ? ucFirst( arguments.target ) : uCase( left( arguments.target, 1 ) ) & right(
			arguments.target,
			len( arguments.target ) - 1
		);
	}

	/**
	 * Lowercase the first letter of the string
	 *
	 * @target The incoming string
	 */
	function lcFirst( required target ){
		return lCase( left( arguments.target, 1 ) ) & right( arguments.target, len( arguments.target ) - 1 );
	}

	/**
	 * Create kebab-case from a string.
	 *
	 * @target The string to convert to kebab-case.
	 *
	 * @return The kebab-case string.
	 */
	function kebabCase( required target ){
		return arguments.target
			.replaceAll( "[^A-Za-z0-9']+", " " )
			.listToArray( " " )
			.map( ( word ) => lCase( word ) )
			.toList( "-" );
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
