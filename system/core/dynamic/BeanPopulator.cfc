<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	This is a bean populator that binds different types of data to a bean.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is a bean populator that binds different types of data to a bean.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="BeanPopulator" hint="Constructor">
    	<cfscript>
			mixerUtil = createObject("component","coldbox.system.core.dynamic.MixerUtil").init();

			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- populateFromJSON --->
	<cffunction name="populateFromJSON" access="public" returntype="any" hint="Populate a named or instantiated bean from a json string" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  	type="any" 		hint="The target to populate">
		<cfargument name="JSONString"   	required="true" 	type="string" 	hint="The JSON string to populate the object with. It has to be valid JSON and also a structure with name-key value pairs. ">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" 	type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" 	type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" 	type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" 	type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" 	type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" 	type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<!--- ************************************************************* --->
		<cfscript>
			// Inflate JSON
			arguments.memento = deserializeJSON( arguments.JSONString );

			// populate and return
			return populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate from XML--->
	<cffunction name="populateFromXML" access="public" returntype="any" hint="Populate a named or instantiated bean from an XML packet" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  	type="any" 		hint="The target to populate">
		<cfargument name="xml"   			required="true" 	type="any" 		hint="The XML string or packet">
		<cfargument name="root"   			required="false" 	type="string"  default=""  hint="The XML root element to start from">
		<cfargument name="scope" 			required="false" 	type="string"  default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" 	type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" 	type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false"	type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" 	type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" 	type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" 	type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<!--- ************************************************************* --->
		<cfscript>
			var key				= "";
			var childElements 	= "";
			var	x				= 1;

			// determine XML
			if( isSimpleValue(arguments.xml) ){
				arguments.xml = xmlParse( arguments.xml );
			}

			// check root
			if( NOT len(arguments.root) ){
				arguments.root = "XMLRoot";
			}

			// check children
			if( NOT structKeyExists(arguments.xml[arguments.root],"XMLChildren") ){
				return;
			}

			// prepare memento
			arguments.memento = structnew();

			// iterate and build struct of data
			childElements = arguments.xml[arguments.root].XMLChildren;
			for(x=1; x lte arrayLen(childElements); x=x+1){
				arguments.memento[ childElements[x].XMLName ] = trim(childElements[x].XMLText);
			}

			return populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate from Query --->
	<cffunction name="populateFromQuery" access="public" returntype="Any" hint="Populate a named or instantiated bean from query" output="false">
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  type="any" 	hint="The target to populate">
		<cfargument name="qry"       		required="true"  type="query"   hint="The query to popluate the bean object with">
		<cfargument name="rowNumber" 		required="false" type="Numeric" hint="The query row number to use for population" default="1">
		<cfargument name="scope" 			required="false" type="string"  default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string" 	default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string" 	default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<!--- ************************************************************* --->
		<cfscript>
			//by default to take values from first row of the query
			var row = arguments.RowNumber;
			//columns array
			var cols = listToArray(arguments.qry.columnList);
			var i   = 1;

			arguments.memento = structnew();

			//build the struct from the query row
			for(i = 1; i lte arraylen(cols); i = i + 1){
				arguments.memento[cols[i]] = arguments.qry[cols[i]][row];
			}

			//populate bean and return
			return populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate an object using a query, but, only specific columns in the query. --->
	<cffunction name="populateFromQueryWithPrefix" output=false
		hint="Populates an Object using only specific columns from a query. Useful for performing a query with joins that needs to populate multiple objects.">
		<cfargument name="target"  			required="true"  	type="any" 	 	hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="qry"       		required="true"  	type="query"   	hint="The query to popluate the bean object with">
		<cfargument name="rowNumber" 		required="false" 	type="Numeric" 	hint="The query row number to use for population" default="1">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" 	type="boolean" 	default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" 	type="string"  	default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" 	type="string"  	default="" hint="A list of keys to exclude in the population">
		<cfargument name="prefix"  			required="true" 	type="string"  	hint="The prefix used to filter, Example: 'user_' would apply to the following columns: 'user_id' and 'user_name' but not 'address_id'.">
		<cfargument name="ignoreEmpty" 		required="false" 	type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" 	type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" 	type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<cfscript>
			// Create a struct including only those keys that match the prefix.
			//by default to take values from first row of the query
			var row 			= arguments.rowNumber;
			var cols 			= listToArray(arguments.qry.columnList);
			var i   			= 1;
			var n				= arrayLen(cols);
			var prefixLength 	= len(arguments.prefix);
			var trueColumnName 	= "";

			arguments.memento = structNew();

			//build the struct from the query row
			for(i = 1; i LTE n; i = i + 1){
				if ( left(cols[i], prefixLength) EQ arguments.prefix ) {
					trueColumnName = right(cols[i], len(cols[i]) - prefixLength);
					arguments.memento[trueColumnName] = arguments.qry[cols[i]][row];
				}
			}

			//populate bean and return
			return populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!---Populate from a struct with prefix --->
	<cffunction name="populateFromStructWithPrefix" access="public" returntype="any" hint="Populate a named or instantiated bean from a structure" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  type="any" 	hint="The target to populate">
		<cfargument name="memento"  		required="true"  type="struct" 	hint="The structure to populate the object with.">
		<cfargument name="scope" 			required="false" type="string"  hint="Use scope injection instead of setters population."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<cfargument name="prefix"               required="true"  type="string"  hint="The prefix used to filter, Example: 'user' would apply to the following formfield: 'user_id' and 'user_name' but not 'address_id'.">
        <!--- ************************************************************* --->
		<cfscript>
			var key 			= "";
			var newMemento 		= structNew();
			var prefixLength 	= len( arguments.prefix );
			var trueName		= "";

			//build the struct from the query row
			for( key in arguments.memento ){
				// only add prefixed keys
				if ( left( key, prefixLength ) EQ arguments.prefix ) {
					trueName = right( key, len( key ) - prefixLength );
					newMemento[ trueName ] = arguments.memento[ key ];
				}
			}

			// override memento
			arguments.memento = newMemento;

			//populate bean and return
			return populateFromStruct( argumentCollection=arguments );
		</cfscript>
	</cffunction>

	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromStruct" access="public" returntype="any" hint="Populate a named or instantiated bean from a structure" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  type="any" 	hint="The target to populate">
		<cfargument name="memento"  		required="true"  type="struct" 	hint="The structure to populate the object with.">
		<cfargument name="scope" 			required="false" type="string"  hint="Use scope injection instead of setters population."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<!--- ************************************************************* --->
		<cfscript>
			var beanInstance = arguments.target;
			var key = "";
			var pop = true;
			var scopeInjection = false;
			var udfCall = "";
			var args = "";
			var nullValue = false;
			var propertyValue = "";
			var relationalMeta = "";

			try{

				// Determine Method of population
				if( structKeyExists(arguments,"scope") and len(trim(arguments.scope)) neq 0 ){
					scopeInjection = true;
					mixerUtil.start( beanInstance );
				}

				// If composing relationships, get target metadata
				if( arguments.composeRelationships ) {
					relationalMeta = getRelationshipMetaData( arguments.target );
				}

				// Populate Bean
				for(key in arguments.memento){
					// init population flag
					pop = true;
					// init nullValue flag and shortcut to property value
					// conditional with StructKeyExist, to prevent language issues with Null value checking of struct keys in ACF
					if ( structKeyExists( arguments.memento, key) ){
						nullValue = false;
						propertyValue = arguments.memento[ key ];

					} else {
						nullValue = true;
						propertyValue = JavaCast( "null", "" );
					}

					// Include List?
					if( len(arguments.include) AND NOT listFindNoCase(arguments.include,key) ){
						pop = false;
					}
					// Exclude List?
					if( len(arguments.exclude) AND listFindNoCase(arguments.exclude,key) ){
						pop = false;
					}
					// Ignore Empty? Check added for real Null value
					if( arguments.ignoreEmpty and not IsNull(propertyValue) and isSimpleValue(arguments.memento[key]) and not len( trim( arguments.memento[key] ) ) ){
						pop = false;
					}

					// Pop?
					if( pop ){
						// Scope Injection?
						if( scopeInjection ){
							beanInstance.populatePropertyMixin(propertyName=key,propertyValue=propertyValue,scope=arguments.scope);
						}
						// Check if setter exists, evaluate is used, so it can call on java/groovy objects
						else if( structKeyExists( beanInstance, "set" & key ) or arguments.trustedSetter ){
							// top-level null settings
							if( arguments.nullEmptyInclude == "*" ) {
								nullValue = true;
							}
							if( arguments.nullEmptyExclude == "*" ) {
								nullValue = false;
							}
							// Is property in empty-to-null include list?
							if( ( len( arguments.nullEmptyInclude ) && listFindNoCase( arguments.nullEmptyInclude, key ) ) ) {
								nullValue = true;
							}
							// Is property in empty-to-null exclude list, or is exclude list "*"?
							if( ( len( arguments.nullEmptyExclude ) AND listFindNoCase( arguments.nullEmptyExclude, key ) ) ){
								nullValue = false;
							}
							// Is value nullable (e.g., simple, empty string)? If so, set null...
							// short circuit evealuaton of IsNull added, so it won't break IsSimpleValue with Real null values. Real nulls are already set.
							if( !IsNull(propertyValue) && isSimpleValue( propertyValue ) && !len( trim( propertyValue ) ) && nullValue ) {
								propertyValue = JavaCast( "null", "" );
							}

							// If property isn't null, try to compose the relationship
							if( !isNull( propertyValue ) && composeRelationships && structKeyExists( relationalMeta, key ) ) {
								// get valid, known entity name list
								var validEntityNames = structKeyList( ORMGetSessionFactory().getAllClassMetadata() );
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
								if( listFindNoCase( validEntityNames, key ) ) {
									targetEntityName = key;
								}
								// 2.) attempt match on CFC metadata
								else if( listFindNoCase( validEntityNames, listLast( relationalMeta[ key ].cfc, "." ) ) ) {
									targetEntityName = listLast( relationalMeta[ key ].cfc, "." );
								}
								// 3.) component lookup
								else {
									try {
										targetEntityName = getComponentMetaData( relationalMeta[ key ].cfc ).entityName;
									}
									catch( any e ) {
										throw(type="BeanPopulator.PopulateBeanException",
							  			  message="Error populating bean #getMetaData(beanInstance).name# relationship of #key#. The component #relationalMeta[ key ].cfc# could not be found.",
							  			  detail="#e.Detail#<br>#e.message#<br>#e.tagContext.toString()#");
									}

								}
								// if targetEntityName was successfully found
								if( len( targetEntityName) ) {
									// array or struct type (one-to-many, many-to-many)
									if( listContainsNoCase( "one-to-many,many-to-many", relationalMeta[ key ].fieldtype ) ) {
										// Support straight-up lists and convert to array
    									if( isSimpleValue( propertyValue ) ) {
    										propertyValue = listToArray( propertyValue );
    									}
										var relType = structKeyExists( relationalMeta[ key ], "type" ) && relationalMeta[ key ].type != "any" ? relationalMeta[ key ].type : 'array';
										var manyMap = reltype=="struct" ? {} : [];
										// loop over array
										for( var relValue in propertyValue ) {
											// for type of array
											if( relType=="array" ) {
												// add composed relationship to array
												arrayAppend( manyMap, EntityLoadByPK( targetEntityName, relValue ) );
											}
											// for type of struct
											else {
												// make sure structKeyColumn is defined in meta
												if( structKeyExists( relationalMeta[ key ], "structKeyColumn" ) ) {
													// load the value
													var item = EntityLoadByPK( targetEntityName, relValue );
													var structKeyColumn = relationalMeta[ key ].structKeyColumn;
													var keyValue = "";
													// try to get struct key value from entity
													if( !isNull( item ) ) {
														try {
															keyValue = evaluate("item.get#structKeyColumn#()");
														}
														catch( Any e ) {
															throw(type="BeanPopulator.PopulateBeanException",
                    							  			  message="Error populating bean #getMetaData(beanInstance).name# relationship of #key#. The structKeyColumn #structKeyColumn# could not be resolved.",
                    							  			  detail="#e.Detail#<br>#e.message#<br>#e.tagContext.toString()#");
														}
													}
													// if the structKeyColumn value was found...
													if( len( keyValue ) ) {
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
										if( isSimpleValue( propertyValue ) && trim( propertyValue ) != "" ) {
											propertyValue = EntityLoadByPK( targetEntityName, propertyValue );
										}
									}
								} // if target entity name found
							}
							// Populate the property as a null value
							if( isNull( propertyValue ) ) {
								// Finally...set the value
								evaluate( "beanInstance.set#key#( JavaCast( 'null', '' ) )" );
							}
							// Populate the property as the value obtained whether simple or related
							else {
								evaluate( "beanInstance.set#key#( propertyValue )" );
							}

						} // end if setter or scope injection
					}// end if prop ignored

				}//end for loop
				return beanInstance;
			}
			catch( Any e ){
				if( isNull( propertyValue ) ) {
					arguments.keyTypeAsString = "NULL";
				}
				else if ( isObject( propertyValue ) OR isCustomFunction( propertyValue )){
					arguments.keyTypeAsString = getMetaData( propertyValue ).name;
				}
				else{
		        	arguments.keyTypeAsString = propertyValue.getClass().toString();
				}
				throw(type="BeanPopulator.PopulateBeanException",
					  message="Error populating bean #getMetaData(beanInstance).name# with argument #key# of type #arguments.keyTypeAsString#.",
					  detail="#e.Detail#<br>#e.message#<br>#e.tagContext.toString()#");
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>
	<cffunction name="getRelationshipMetaData" access="private" output="false" returntype="Struct" hint="Prepares a structure of target relational meta data">
		<cfargument name="target" required="true" type="any" />
		<cfscript>
			var meta = {};
			// get array of properties
			var stopRecursions= [ "lucee.Component", "railo.Component", "WEB-INF.cftags.component" ];
			var properties = getUtil().getInheritedMetaData( arguments.target, stopRecursions ).properties; 

			// loop over properties
			for( var i = 1; i <= arrayLen( properties ); i++ ) {
				var property = properties[ i ];
				// if property has a name, a fieldtype, and is not the ID, add to maps
				if( structKeyExists( property, "fieldtype" ) &&
					structKeyExists( property, "name" ) &&
					!listFindNoCase( "id,column", property.fieldtype ) ) {
					meta[ property.name ] = property;
				}
			}
			return meta;
		</cfscript>
	</cffunction>

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

</cfcomponent>