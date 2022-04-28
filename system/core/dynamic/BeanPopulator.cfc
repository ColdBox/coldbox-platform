/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This is a bean populator that binds different types of data to a bean.
 */
component {

	/**
	 * Constructor
	 */
	function init(){
		variables.mixerUtil = new coldbox.system.core.dynamic.MixerUtil();
		variables.util      = new coldbox.system.core.util.Util();
		return this;
	}

	/**
	 * Populate a named or instantiated instance from a Json string
	 *
	 * @target               The target to populate
	 * @JSONString           The JSON string to populate the object with. It has to be valid JSON and also a structure with name-key value pairs.
	 * @scope                Use scope injection instead of setters population. Ex: scope=variables.instance.
	 * @trustedSetter        If set to true, the setter method will be called even if it does not exist in the bean
	 * @include              A list of keys to include in the population
	 * @exclude              A list of keys to exclude in the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from memento
	 *
	 * @return The target populated with the packet
	 */
	function populateFromJson(
		required target,
		required string JSONString,
		string scope                 = "",
		boolean trustedSetter        = false,
		string include               = "",
		string exclude               = "",
		boolean ignoreEmpty          = false,
		string nullEmptyInclude      = "",
		string nullEmptyExclude      = "",
		boolean composeRelationships = false
	){
		// Inflate JSON
		arguments.memento = deserializeJSON( arguments.JSONString );

		// populate and return
		return populateFromStruct( argumentCollection = arguments );
	}

	/**
	 * Populate a named or instantiated instance from an XML Packet
	 *
	 * @target               The target to populate
	 * @xml                  The XML string or packet to populate the target with
	 * @root                 The XML root element to start from, else defaults to XMLRoot
	 * @scope                Use scope injection instead of setters population. Ex: scope=variables.instance.
	 * @trustedSetter        If set to true, the setter method will be called even if it does not exist in the bean
	 * @include              A list of keys to include in the population
	 * @exclude              A list of keys to exclude in the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from memento
	 *
	 * @return The target populated with the packet
	 */
	function populateFromXML(
		required target,
		required xml,
		string root                  = "",
		string scope                 = "",
		boolean trustedSetter        = false,
		string include               = "",
		string exclude               = "",
		boolean ignoreEmpty          = false,
		string nullEmptyInclude      = "",
		string nullEmptyExclude      = "",
		boolean composeRelationships = false
	){
		// determine XML object or string?
		if ( isSimpleValue( arguments.xml ) ) {
			arguments.xml = xmlParse( arguments.xml );
		}

		// check root else default to XMLRoot
		if ( NOT len( arguments.root ) ) {
			arguments.root = "XMLRoot";
		}

		// check children else don't do anything, we can't populate
		if ( NOT structKeyExists( arguments.xml[ arguments.root ], "XMLChildren" ) ) {
			return;
		}

		arguments.memento = {};
		// Have to do it this way as ACF11 parsing sucks on structs and member functions
		var xmlRoot       = arguments.xml[ arguments.root ];
		// Populate memento from XML
		xmlRoot.XMLChildren.each( function( item ){
			memento[ item.XMLName ] = trim( item.XMLText );
		} );

		return populateFromStruct( argumentCollection = arguments );
	}

	/**
	 * Populate a named or instantiated instance from a Query object
	 *
	 * @target               The target to populate
	 * @qry                  The query to populate the object with
	 * @rowNumber            The row number to use for population, defaults to 1
	 * @scope                Use scope injection instead of setters population. Ex: scope=variables.instance.
	 * @trustedSetter        If set to true, the setter method will be called even if it does not exist in the bean
	 * @include              A list of keys to include in the population
	 * @exclude              A list of keys to exclude in the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from memento
	 *
	 * @return The target populated with the packet
	 */
	function populateFromQuery(
		required target,
		required query qry,
		numeric rowNumber            = "1",
		string scope                 = "",
		boolean trustedSetter        = false,
		string include               = "",
		string exclude               = "",
		boolean ignoreEmpty          = false,
		string nullEmptyInclude      = "",
		string nullEmptyExclude      = "",
		boolean composeRelationships = false
	){
		if ( arguments.qry.recordcount >= arguments.rowNumber ) {
			arguments.memento = structNew();
			listToArray( arguments.qry.columnList ).each( function( item ){
				memento[ item ] = qry[ item ][ rowNumber ];
			} );

			// populate bean and return
			return populateFromStruct( argumentCollection = arguments );
		} else {
			return target;
		}
	}

	/**
	 * Populate a named or instantiated instance from a Query object using a column prefix
	 *
	 * @target               The target to populate
	 * @qry                  The query to populate the object with
	 * @prefix               The prefix used to filter, Example: 'user_' would apply to the following columns: 'user_id' and 'user_name' but not 'address_id'.
	 * @rowNumber            The row number to use for population, defaults to 1
	 * @scope                Use scope injection instead of setters population. Ex: scope=variables.instance.
	 * @trustedSetter        If set to true, the setter method will be called even if it does not exist in the bean
	 * @include              A list of keys to include in the population
	 * @exclude              A list of keys to exclude in the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from memento
	 *
	 * @return The target populated with the packet
	 */
	function populateFromQueryWithPrefix(
		required target,
		required query qry,
		required string prefix,
		numeric rowNumber            = "1",
		string scope                 = "",
		boolean trustedSetter        = false,
		string include               = "",
		string exclude               = "",
		boolean ignoreEmpty          = false,
		string nullEmptyInclude      = "",
		string nullEmptyExclude      = "",
		boolean composeRelationships = false
	){
		var prefixLength = len( arguments.prefix );

		arguments.memento = structNew();
		listToArray( arguments.qry.columnList )
			.filter( function( item ){
				return ( left( item, prefixLength ) == prefix );
			} )
			.each( function( item ){
				var trueColumnName        = item.replaceNocase( prefix, "" );
				memento[ trueColumnName ] = qry[ item ][ rowNumber ];
			} );

		// populate bean and return
		return populateFromStruct( argumentCollection = arguments );
	}

	/**
	 * Populate a named or instantiated instance from a struct object using a key prefix
	 *
	 * @target               The target to populate
	 * @memento              The structure to populate the target with
	 * @prefix               The prefix used to filter, Example: 'user_' would apply to the following columns: 'user_id' and 'user_name' but not 'address_id'.
	 * @scope                Use scope injection instead of setters population. Ex: scope=variables.instance.
	 * @trustedSetter        If set to true, the setter method will be called even if it does not exist in the bean
	 * @include              A list of keys to include in the population
	 * @exclude              A list of keys to exclude in the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from memento
	 *
	 * @return The target populated with the packet
	 */
	function populateFromStructWithPrefix(
		required target,
		required struct memento,
		required string prefix,
		string scope                 = "",
		boolean trustedSetter        = false,
		string include               = "",
		string exclude               = "",
		boolean ignoreEmpty          = false,
		string nullEmptyInclude      = "",
		string nullEmptyExclude      = "",
		boolean composeRelationships = false
	){
		var prefixLength = len( arguments.prefix );
		var newMemento   = {};

		arguments.memento
			.filter( function( key, value ){
				return ( left( key, prefixLength ) == prefix );
			} )
			.each( function( key, value ){
				newMemento[ key.replaceNoCase( prefix, "" ) ] = value;
			} );

		// populate bean and return
		arguments.memento = newMemento;
		return populateFromStruct( argumentCollection = arguments );
	}

	/**
	 * Populate a named or instantiated instance from a struct object using a key prefix
	 *
	 * @target               The target to populate
	 * @memento              The structure to populate the target with
	 * @scope                Use scope injection instead of setters population. Ex: scope=variables.instance.
	 * @trustedSetter        If set to true, the setter method will be called even if it does not exist in the bean
	 * @include              A list of keys to include in the population
	 * @exclude              A list of keys to exclude in the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from memento
	 *
	 * @return The target populated with the packet
	 */
	function populateFromStruct(
		required target,
		required struct memento,
		string scope                 = "",
		boolean trustedSetter        = false,
		string include               = "",
		string exclude               = "",
		boolean ignoreEmpty          = false,
		string nullEmptyInclude      = "",
		string nullEmptyExclude      = "",
		boolean composeRelationships = false
	){
		var beanInstance   = arguments.target;
		var key            = "";
		var pop            = true;
		var scopeInjection = false;
		var udfCall        = "";
		var args           = "";
		var nullValue      = false;
		var propertyValue  = "";
		var relationalMeta = "";

		try {
			// Determine Method of population
			if ( structKeyExists( arguments, "scope" ) and len( trim( arguments.scope ) ) neq 0 ) {
				scopeInjection = true;
				mixerUtil.start( beanInstance );
			}

			// If composing relationships, get target metadata
			if ( arguments.composeRelationships ) {
				relationalMeta = getRelationshipMetaData( arguments.target );
			}

			// Populate Bean
			for ( key in arguments.memento ) {
				// init population flag
				pop = true;
				// init nullValue flag and shortcut to property value
				// conditional with StructKeyExist, to prevent language issues with Null value checking of struct keys in ACF
				if ( structKeyExists( arguments.memento, key ) ) {
					nullValue     = false;
					propertyValue = arguments.memento[ key ];
				} else {
					nullValue     = true;
					propertyValue = javacast( "null", "" );
				}

				// Include List?
				if ( len( arguments.include ) AND NOT listFindNoCase( arguments.include, key ) ) {
					pop = false;
				}
				// Exclude List?
				if ( len( arguments.exclude ) AND listFindNoCase( arguments.exclude, key ) ) {
					pop = false;
				}
				// Ignore Empty? Check added for real Null value
				if (
					arguments.ignoreEmpty and not isNull( local.propertyValue ) and isSimpleValue(
						arguments.memento[ key ]
					) and not len( trim( arguments.memento[ key ] ) )
				) {
					pop = false;
				}

				// Pop?
				if ( pop ) {
					// Scope Injection?
					if ( scopeInjection ) {
						beanInstance.injectPropertyMixin(
							propertyName  = key,
							propertyValue = propertyValue,
							scope         = arguments.scope
						);
					}
					// Check if setter exists, evaluate is used, so it can call on java/groovy objects
					else if ( structKeyExists( beanInstance, "set" & key ) or arguments.trustedSetter ) {
						// top-level null settings
						if ( arguments.nullEmptyInclude == "*" ) {
							nullValue = true;
						}
						if ( arguments.nullEmptyExclude == "*" ) {
							nullValue = false;
						}
						// Is property in empty-to-null include list?
						if (
							(
								len( arguments.nullEmptyInclude ) && listFindNoCase(
									arguments.nullEmptyInclude,
									key
								)
							)
						) {
							nullValue = true;
						}
						// Is property in empty-to-null exclude list, or is exclude list "*"?
						if (
							(
								len( arguments.nullEmptyExclude ) AND listFindNoCase(
									arguments.nullEmptyExclude,
									key
								)
							)
						) {
							nullValue = false;
						}
						// Is value nullable (e.g., simple, empty string)? If so, set null...
						// short circuit evaluation of IsNull added, so it won't break IsSimpleValue with Real null values. Real nulls are already set.
						if (
							!isNull( local.propertyValue ) && isSimpleValue( propertyValue ) && !len(
								trim( propertyValue )
							) && nullValue
						) {
							propertyValue = javacast( "null", "" );
						}

						var getEntityMap = function(){
							if ( listFirst( variables.util.getHibernateVersion(), "." ) >= 5 ) {
								// Double array functions to convert from native java to cf java
								return arrayToList( ormGetSessionFactory().getMetaModel().getAllEntityNames() ).listToArray();
							} else {
								// Hibernate v4 and older
								return structKeyArray( ormGetSessionFactory().getAllClassMetadata() );
							}
						};

						// If property isn't null, try to compose the relationship
						if (
							!isNull( local.propertyValue ) && composeRelationships && structKeyExists(
								relationalMeta,
								key
							)
						) {
							// get valid, known entity name list
							var validEntityNames = getEntityMap();
							var targetEntityName = "";
							/**
							 * The only info we know about the relationships are the property names and the cfcs
							 * CFC setting can be relative, so can't assume that component lookup will work
							 * APPROACH
							 * 1.) Easy: If property name of relationship is a valid entity name, use that
							 * 2.) Harder: If property name is not a valid entity name (e.g., one-to-many, many-to-many), use cfc name
							 * 3.) Nuclear: If neither above works, try by component meta data lookup. Won't work if using relative paths!!!!
							 */

							// 1.) name match
							if ( validEntityNames.findNoCase( key ) ) {
								targetEntityName = key;
							}
							// 2.) attempt match on CFC metadata
							else if ( validEntityNames.findNoCase( listLast( relationalMeta[ key ].cfc, "." ) ) ) {
								targetEntityName = listLast( relationalMeta[ key ].cfc, "." );
							}
							// 3.) component lookup
							else {
								try {
									targetEntityName = getComponentMetadata( relationalMeta[ key ].cfc ).entityName;
								} catch ( any e ) {
									throw(
										type    = "BeanPopulator.PopulateBeanException",
										message = "Error populating bean #getMetadata( beanInstance ).name# relationship of #key#. The component #relationalMeta[ key ].cfc# could not be found.",
										detail  = "#e.Detail#<br>#e.message#<br>#e.tagContext.toString()#"
									);
								}
							}
							// if targetEntityName was successfully found
							if ( len( targetEntityName ) ) {
								// array or struct type (one-to-many, many-to-many)
								if (
									listContainsNoCase(
										"one-to-many,many-to-many",
										relationalMeta[ key ].fieldtype
									)
								) {
									// Support straight-up lists and convert to array
									if ( isSimpleValue( propertyValue ) ) {
										propertyValue = listToArray( propertyValue );
									}
									var relType = structKeyExists( relationalMeta[ key ], "type" ) && relationalMeta[
										key
									].type != "any" ? relationalMeta[ key ].type : "array";
									var manyMap = reltype == "struct" ? {} : [];
									// loop over array
									for ( var relValue in propertyValue ) {
										// for type of array
										if ( relType == "array" ) {
											// add composed relationship to array
											arrayAppend( manyMap, entityLoadByPK( targetEntityName, relValue ) );
										}
										// for type of struct
										else {
											// make sure structKeyColumn is defined in meta
											if ( structKeyExists( relationalMeta[ key ], "structKeyColumn" ) ) {
												// load the value
												var item            = entityLoadByPK( targetEntityName, relValue );
												var structKeyColumn = relationalMeta[ key ].structKeyColumn;
												var keyValue        = "";
												// try to get struct key value from entity
												if ( !isNull( local.item ) ) {
													try {
														keyValue = invoke( item, "get#structKeyColumn#" );
													} catch ( Any e ) {
														throw(
															type    = "BeanPopulator.PopulateBeanException",
															message = "Error populating bean #getMetadata( beanInstance ).name# relationship of #key#. The structKeyColumn #structKeyColumn# could not be resolved.",
															detail  = "#e.Detail#<br>#e.message#<br>#e.tagContext.toString()#"
														);
													}
												}
												// if the structKeyColumn value was found...
												if ( len( keyValue ) ) {
													manyMap[ keyValue ] = item;
												}
											}
										}
									}
									// set main property value to the full array of entities
									propertyValue = manyMap;
								}
								// otherwise, simple value; load relationship (one-to-one, many-to-one)
								else {
									if ( isSimpleValue( propertyValue ) && trim( propertyValue ) != "" ) {
										propertyValue = entityLoadByPK( targetEntityName, propertyValue );
									}
								}
							}
							// if target entity name found
						}
						// Populate the property as a null value
						if ( isNull( local.propertyValue ) ) {
							// Finally...set the value
							invoke(
								beanInstance,
								"set#key#",
								[ javacast( "null", "" ) ]
							);
						}
						// Populate the property as the value obtained whether simple or related
						else {
							invoke( beanInstance, "set#key#", [ propertyValue ] );
						}
					}
					// end if setter or scope injection
				}
				// end if prop ignored
			}
			// end for loop
			return beanInstance;
		} catch ( Any e ) {
			if ( isNull( local.propertyValue ) ) {
				arguments.keyTypeAsString = "NULL";
			} else if ( isObject( propertyValue ) OR isCustomFunction( propertyValue ) ) {
				arguments.keyTypeAsString = getMetadata( propertyValue ).name;
			} else {
				arguments.keyTypeAsString = propertyValue.getClass().toString();
			}
			throw(
				type    = "BeanPopulator.PopulateBeanException",
				message = "Error populating bean #getMetadata( beanInstance ).name# with argument #key# of type #arguments.keyTypeAsString#.",
				detail  = "#e.Detail#<br>#e.message#<br>#e.tagContext.toString()#"
			);
		}
	}

	/**
	 * Prepares a structure of target relational meta data
	 *
	 * @target The target to work on
	 */
	private struct function getRelationshipMetaData( required target ){
		var meta           = {};
		// get array of properties
		var stopRecursions = [ "lucee.Component", "WEB-INF.cftags.component" ];
		// Collect property metadata
		variables.util
			.getInheritedMetaData( arguments.target, stopRecursions )
			.properties
			.filter( function( item ){
				return (
					item.keyExists( "fieldType" ) &&
					item.keyExists( "name" ) &&
					!listFindNoCase( "id,column", item.fieldtype )
				);
			} )
			.each( function( item ){
				meta[ item.name ] = item;
			} );

		return meta;
	}

}
