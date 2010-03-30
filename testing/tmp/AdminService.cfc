/**
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/10/2007
Description :
	The ColdBox Admin data service
----------------------------------------------------------------------->
*/
component autowire="true" name="Model" cache="true" cacheTimeout="0"{

/* ----------------------------------- CONSTRUCTOR ------------------------------ */
	
	//dependencies
	property name="AdminGateway"    type="model" scope="instance";
	property name="MetadataService" type="model" scope="instance";

	instance = {};
	/**
	* constructor
	*/
	AdminService function init(){
		return this;
	}

/* ----------------------------------- PUBLIC ------------------------------ */

	/**
	* Get an entity's listing by lots of goodies
	*/
	any function list(required entityName, 
					   struct criteria=structnew(), 
					   string sortString='',
					   numeric offset=0,
					   numeric maxResults=0,
					   boolean asQuery=true){
		var options = {};
		
		// Check options
		if( arguments.offset neq 0 ){
			options.offset = arguments.offset;
		}
		if( arguments.maxresults neq 0 ){
			options.maxresults = arguments.maxresults;
		}
		
		// Get listing
		var results = entityLoad(arguments.entityName, arguments.criteria, arguments.sortString, options);
		
		// Objects or Query?
		if( arguments.asQuery ){
			results = entityToQuery(results);
		}
		
		return results;
	}
	
	/**
	* search an entity based on properties and returns an JQgridFormatted struct
	*/	
	 public struct function doSearch(required string entityName,
									string filterField ='',
									string filterCondition ='',
									string filterValue = '',
									string sortOrder='',
									string sortColumn='',
									numeric maxResults = 10,
									numeric page = 1,
									boolean asQuery = true)
	 	output="false"
	{
		var rtnStruct = {page = arguments.page, total = 0, Records = 0, rows = []};
		var map = {};
			
		//check if the provided EntityName and FieldColumn are valid and get back the Case Sensitive mapping
		if (getMetaDataService().isValidEntityName(arguments.Entityname)){
			map.EntityName = getMetaDataService().getEntityName(arguments.EntityName);
			
			if ( len(arguments.filterField) > 0 and getMetaDataService().isValidEntityProperty(arguments.EntityName,arguments.filterField))
				map.filterField = getMetaDataService().getEntityPropertyName(arguments.EntityName,arguments.filterField);
				
			if ( len(arguments.sortColumn) > 0 and getMetaDataService().isValidEntityProperty(arguments.EntityName,arguments.sortColumn))
				map.sortColumn = getMetaDataService().getEntityPropertyName(arguments.EntityName,arguments.sortColumn);
					
			if (arguments.page == 1){
				map.offset = 0;
			}
			else if (arguments.page > 0){
				map.offset = ((arguments.page - 1) * arguments.maxResults);
			}
			
			map.sortOrder = arguments.sortOrder;
			map.filterCondition = arguments.filterCondition;
			map.filterValue = arguments.filterValue;
									
			rtnStruct.Records = getAdminGateway().getSearchCountByQuery(argumentCollection = map);
			if (rtnStruct.Records > 0){
				rtnStruct.rows =  JQgridFormat(getAdminGateway().searchByQuery(argumentCollection = map));
				rtnStruct.Total = Ceiling(rtnStruct.Records/arguments.maxResults);
			}	
		}			
		return rtnStruct;		
	}	
	
	
	/** 
    * Get a new entity object
    */
	any function new(required string entityName){
		return entityNew(arguments.entityName);
	}
	
	/** 
    * Get an entity with or without PK id's, but if not found, it will return a new entity.
	* the id argument can be a simple value or a structure for composite keys
    */
	any function get(required entityName,any id="") {
		// Check if PK sent, else return new entity
		if( isSimpleValue(arguments.id) and NOT len(arguments.id) ){
			return new(arguments.entityName);
		}
		// Retrieve by ID
		return entityLoadByPK(arguments.entityName, arguments.id);
	}
	
	/** 
    * Get an entity by criteria
    */
	any function getByCriteria(required entityName,required struct criteria) {
		// Retrieve by Criteria
		return entityLoad(arguments.entityName, arguments.criteria, true);
	}
	
	/** 
    * Delete an entity
	* @transactional true
    */
	void function delete(required any entityName, required any id){
		//load the object first
		var lookupObject = get(argumentcollection  = arguments);
		
		// WORK
		entityDelete(lookupObject);
	}

	/** 
    * Save an entity using hibernate transactions
	* @transactional true
    */
	void function save(required any entity){
		// WORK
		entitySave(arguments.entity);
	}
	
	
	/** 
    * evict an entity from session, the id can be a string or structure for the primary key
    */
	void function evict(required string entityName,any id){
		if( structKeyExists(arguments,"id") )
			ORMEvictEntity(arguments.entityName,arguments.id);
		else
			ORMEvictEntity(arguments.entityName);
	}
	
	/******************************* private methods ************************************/
	
	/** 
    * Format an Query object into JQGRiDFormat understantable Array
    */	
	private array function JQgridFormat(required query QueryObject){
		var rows = [];
		for(var i =1; i <= arguments.QueryObject.recordcount; i++){
			rows[i] = {};
			for (var j = 1; j <=listlen(arguments.QueryObject.columnList); j++ ){
				rows[i][listgetat(arguments.QueryObject.columnList,j)] = arguments.QueryObject[listgetat(arguments.QueryObject.columnList,j)][i];
			}
		}
		return rows;		
	}
	/** 
    * returns the AdminGateway
    */	
	private any function getAdminGateway(){
		return instance.AdminGateway;
	}
	/** 
    * returns the MetaDataService
    */	
	private any function getMetaDataService(){
		return instance.MetaDataService;
	}	
	
}