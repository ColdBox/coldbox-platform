/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This object is in charge of populating objects with incoming data like structs, queries, json and more.
 * It can also populate ORM relationships and respect metadata in objects that can dictate population.
 */
component accessors="true" singleton {

	// DI
	property name="mixerUtil" inject="coldbox.system.core.dynamic.MixerUtil";
	property name="util"      inject="coldbox.system.core.util.Util";

	// Properties
	property name="ormEntityMap";
	property name="entityMetadataMap";

	/**
	 * Constructor
	 */
	function init(){
		flushMetadataCaches();
		return this;
	}

	/**
	 * Recreate the metadata caches for orm and entity metadata lookups
	 */
	function flushMetadataCaches(){
		variables.ormEntityMap      = [];
		variables.entityMetadataMap = createObject( "java", "java.util.concurrent.ConcurrentHashMap" ).init();
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
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
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
		boolean composeRelationships = false,
		boolean ignoreTargetLists    = false
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
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
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
		boolean composeRelationships = false,
		boolean ignoreTargetLists    = false
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
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
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
		boolean composeRelationships = false,
		boolean ignoreTargetLists    = false
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
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
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
		boolean composeRelationships = false,
		boolean ignoreTargetLists    = false
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
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
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
		boolean composeRelationships = false,
		boolean ignoreTargetLists    = false
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
	 * @include              A list of keys to include in the population, if not all keys are populated
	 * @exclude              A list of keys to exclude in the population, if not nothing is excluded
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from memento
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
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
		boolean composeRelationships = false,
		boolean ignoreTargetLists    = false
	){
		var scopeInjection = false;
		var propertyName   = "";

		try {
			// Scope injection detection
			if ( !isNull( arguments.scope ) and len( trim( arguments.scope ) ) neq 0 ) {
				scopeInjection = true;
				variables.mixerUtil.start( arguments.target );
			}

			// Discover relationships
			var relationalMeta = arguments.composeRelationships ? getRelationshipMetaData( arguments.target ) : {};

			// Populate Bean
			for ( var key in arguments.memento ) {
				// Init population variables
				var pop           = true;
				var propertyValue = "";
				var nullValue     = false;
				propertyName      = key;

				// conditional with StructKeyExist, to prevent language issues with Null value checking of struct keys in ACF
				if ( structKeyExists( arguments.memento, key ) ) {
					propertyValue = arguments.memento[ key ];
				} else {
					nullValue     = true;
					propertyValue = javacast( "null", "" );
				}

				// Incorporate Target Population Metadata only if not ignored.
				// We usually ignore when we are using this with ORMs to do all column populations
				// this.population = { include : "", exclude : ""  }
				if ( !arguments.ignoreTargetLists ) {
					param arguments.target.population         = {};
					param arguments.target.population.include = [];
					param arguments.target.population.exclude = [];
					arguments.include                         = arguments.include.listAppend(
						arguments.target.population.include.toList()
					);
					arguments.exclude = arguments.exclude.listAppend(
						arguments.target.population.exclude.toList()
					);
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

				// Are we allowed to populate or not
				if ( !pop ) {
					continue;
				}

				// Null Empty Include/Exclude Lists
				// If a value is an empty string, then we will coerce it to null
				if ( arguments.nullEmptyInclude == "*" ) {
					nullValue = true;
				}
				if ( arguments.nullEmptyExclude == "*" ) {
					nullValue = false;
				}
				// Is property in empty-to-null include list?
				if ( ( len( arguments.nullEmptyInclude ) && listFindNoCase( arguments.nullEmptyInclude, key ) ) ) {
					nullValue = true;
				}
				// Is property in empty-to-null exclude list, or is exclude list "*"?
				if ( ( len( arguments.nullEmptyExclude ) AND listFindNoCase( arguments.nullEmptyExclude, key ) ) ) {
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

				// Is this a composable property?
				if (
					!isNull( propertyValue ) && arguments.composeRelationships && structKeyExists(
						relationalMeta.properties,
						key
					)
				) {
					propertyValue = composeProperty(
						key           : key,
						relationalMeta: relationalMeta,
						target        : arguments.target,
						propertyValue : propertyValue
					);
				}

				// Scope Injection
				if ( scopeInjection ) {
					arguments.target.injectPropertyMixin(
						propertyName  = key,
						propertyValue = isNull( propertyValue ) ? javacast( "null", "" ) : propertyValue,
						scope         = arguments.scope
					);
					continue;
				}

				// Setter Injection
				if ( structKeyExists( arguments.target, "set" & key ) or arguments.trustedSetter ) {
					invoke(
						arguments.target,
						"set#key#",
						[ isNull( propertyValue ) ? javacast( "null", "" ) : propertyValue ]
					);
				}
				// end if setter or scope injection
			}
			// end of all memento keys
			return arguments.target;
		} catch ( Any e ) {
			if ( isNull( local.propertyValue ) ) {
				arguments.keyTypeAsString = "NULL";
			} else if ( isObject( propertyValue ) OR isCustomFunction( propertyValue ) ) {
				arguments.keyTypeAsString = getMetadata( propertyValue ).name;
			} else {
				arguments.keyTypeAsString = propertyValue.getClass().toString();
			}
			throw(
				type    = "ObjectPopulator.PopulateObjectException",
				message = "Error populating bean #getMetadata( arguments.target ).name# with argument #propertyName# of type #arguments.keyTypeAsString#.",
				detail  = "#e.Detail#<br>#e.message#<br>#e.tagContext.toString()#"
			);
		}
	}

	/**
	 * Compose a related property
	 *
	 * @key            The incoming population key
	 * @relationalMeta The relational metadata being used for population
	 * @target         The target object
	 * @propertyValue  The property value to compose from
	 *
	 * @return The composed property or null if not found
	 */
	private function composeProperty(
		required key,
		required relationalMeta,
		required target,
		required propertyValue
	){
		var targetEntityName = discoverEntityName( argumentCollection = arguments );
		if ( len( targetEntityName ) ) {
			// array or struct type (one-to-many, many-to-many)
			if (
				listContainsNoCase(
					"one-to-many,many-to-many",
					arguments.relationalMeta.properties[ arguments.key ].fieldtype
				)
			) {
				// Support straight-up lists and convert to array
				if ( isSimpleValue( arguments.propertyValue ) ) {
					arguments.propertyValue = listToArray( arguments.propertyValue );
				}
				var relType = structKeyExists( arguments.relationalMeta.properties[ arguments.key ], "type" ) && arguments.relationalMeta.properties[
					key
				].type != "any" ? arguments.relationalMeta.properties[ arguments.key ].type : "array";
				var manyMap = reltype == "struct" ? {} : [];
				// loop over array
				for ( var relValue in arguments.propertyValue ) {
					// for type of array
					if ( relType == "array" ) {
						arrayAppend( manyMap, entityLoadByPK( targetEntityName, relValue ) );
					}
					// for type of struct
					else {
						// make sure structKeyColumn is defined in meta
						if ( structKeyExists( arguments.relationalMeta.properties[ key ], "structKeyColumn" ) ) {
							// load the value
							var item            = entityLoadByPK( targetEntityName, relValue );
							var structKeyColumn = arguments.relationalMeta.properties[ arguments.key ].structKeyColumn;
							var keyValue        = "";
							// try to get struct key value from entity
							if ( !isNull( local.item ) ) {
								try {
									keyValue = invoke( item, "get#structKeyColumn#" );
								} catch ( Any e ) {
									throw(
										type    = "ObjectPopulator.PopulateObjectException",
										message = "Error populating bean #getMetadata( arguments.target ).name# relationship of #arguments.key#. The structKeyColumn #structKeyColumn# could not be resolved.",
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

				arguments.propertyValue = manyMap;
			}
			// otherwise, simple value; load relationship (one-to-one, many-to-one)
			else {
				if ( isSimpleValue( arguments.propertyValue ) && trim( arguments.propertyValue ) != "" ) {
					arguments.propertyValue = entityLoadByPK( targetEntityName, arguments.propertyValue );
				}
			}
		}
		return arguments.propertyValue;
	}

	/**
	 * Discover the actual entity name for an orm relationship
	 *
	 * @key            The incoming population key
	 * @relationalMeta The relational metadata being used for population
	 * @target         The target object
	 *
	 * @return The discovered ORM Entity name or if not, then an empty string
	 */
	private string function discoverEntityName(
		required key,
		required relationalMeta,
		required target
	){
		var validEntityNames = getORMEntityMap();
		var targetEntityName = "";
		/**
		 * The only info we know about the relationships are the property names and the cfcs
		 * CFC setting can be relative, so can't assume that component lookup will work
		 * APPROACH
		 * 1.) Easy: If property name of relationship is a valid entity name, use that: ex: setRole() and Role is the entity name
		 * 2.) Harder: Use the `cfc` attribute on the property (e.g., one-to-many, many-to-many)
		 * 3.) Nuclear: If neither above works, try by component meta data lookup. Won't work if using relative paths!!!!
		 */

		// 1.) name match
		if ( validEntityNames.findNoCase( arguments.key ) ) {
			targetEntityName = arguments.key;
		}
		// 2.) attempt match on CFC metadata on the property:
		// property name="role" cfc="security.Role"
		else if (
			validEntityNames.findNoCase(
				listLast( arguments.relationalMeta.properties[ arguments.key ].cfc, "." )
			)
		) {
			targetEntityName = listLast( arguments.relationalMeta.properties[ key ].cfc, "." );
		}
		// 3.) component lookup
		else {
			try {
				targetEntityName = getComponentMetadata( arguments.relationalMeta.properties[ key ].cfc ).entityName;
			} catch ( any e ) {
				throw(
					type    = "ObjectPopulator.PopulateObjectException",
					message = "Error populating object #getMetadata( arguments.target ).name# relationship of #arguments.key#. The component #arguments.relationalMeta.properties[ arguments.key ].cfc# could not be found.",
					detail  = "#e.Detail#<br>#e.message#"
				);
			}
		}
		return targetEntityName;
	}

	/**
	 * Get the ORM entity map for the application
	 */
	private array function getORMEntityMap(){
		if ( variables.ormEntityMap.isEmpty() ) {
			if ( listFirst( variables.util.getHibernateVersion(), "." ) >= 5 ) {
				// Double array functions to convert from native java to cf java
				variables.ormEntityMap = arrayToList( ormGetSessionFactory().getMetaModel().getAllEntityNames() ).listToArray();
			} else {
				// Hibernate v4 and older
				variables.ormEntityMap = structKeyArray( ormGetSessionFactory().getAllClassMetadata() );
			}
		}

		return variables.ormEntityMap;
	}


	/**
	 * Prepares a structure of target relational metadata
	 *
	 * @target The target to work on
	 *
	 * @return The metadata map of composable properties keyed by entity name: { cfc, path, entityname, persistent, properties }
	 */
	private struct function getRelationshipMetaData( required target ){
		var targetName = getTargetName( arguments.target );
		if ( variables.entityMetadataMap.containsKey( targetName ) ) {
			return variables.entityMetadataMap.get( targetName );
		}

		// get array of properties
		var stopRecursions = [ "lucee.Component", "WEB-INF.cftags.component" ];
		var md             = variables.util.getInheritedMetaData( arguments.target, stopRecursions );
		var results        = {
			"cfc"        : md.name,
			"path"       : md.path,
			"entityName" : md.keyExists( "entityName" ) ? md.entityName : listLast( md.name, "." ),
			"persistent" : md.keyExists( "persistent" ) ? md.persistent : false,
			"properties" : {}
		};

		// Collect property metadata
		results.properties = md.properties
			// Only relationships, no id's or columns
			.filter( function( item ){
				return (
					arguments.item.keyExists( "name" ) &&
					arguments.item.keyExists( "fieldType" ) &&
					!listFindNoCase( "id,column", arguments.item.fieldtype )
				);
			} )
			.reduce( function( result, item ){
				result[ arguments.item.name ] = arguments.item;
				return result;
			}, {} );

		variables.entityMetadataMap.put( targetName, results );
		return results;
	}

	/**
	 * Convenience method to get name from target CFC (Entity)
	 *
	 * @target The target to work on
	 */
	private string function getTargetName( required any target ){
		// Short-cut discovery via ActiveEntity
		if ( structKeyExists( arguments.target, "getEntityName" ) ) {
			return arguments.target.getEntityName();
		}

		// Try Hibernate Discovery
		try {
			return ormGetSession().getEntityName( arguments.target );
		} catch ( org.hibernate.TransientObjectException e ) {
			// This was a transient and not in session
		}

		// Long - Discovery

		return getMetadata( arguments.target ).name;
	}

}
