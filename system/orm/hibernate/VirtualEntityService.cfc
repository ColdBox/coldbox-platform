/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author      :	Curt Gratz & Luis Majano
Description :

This is a Virtual Entity Service that extends the Coldbox BaseORMService to
provide easy access to creating virtual services that extend the BaseORMService

For example, if you want a UserService, you can either create an object based
off this object if no additional functionality is needed like this:

UserService=CreateObject("component", "coldbox.system.orm.hibernate.VirtualEntityService").init("User");

You can also use this virtual service as a template object and extend and override as needed.

import coldbox.system.orm.hibernate.*;
component extends="VirtualEntityService"
UserService function init(){
    // setup properties
    setEntityName('User');
    setQueryCacheRegion( "#arguments.entityName#.defaultVSCache" );
    setUseQueryCaching( false );
	setEventHandling( false );
	setDefaultAsQuery( true );
    return this;
}

*/
component extends="coldbox.system.orm.hibernate.BaseORMService" accessors="true"{

	/**
	* The entityName property for this "version" of the Virtual Service
	*/
	property name="entityName" type="string";
	
	/**
	* The datasource property for this "version" of the Virtual Service
	*/
	property name="datasource" type="string";

	/************************************** CONSTRUCTOR *********************************************/

	VirtualEntityService function init(required string entityname, 
										string queryCacheRegion, 
										boolean useQueryCaching,
										boolean eventHandling,
										boolean useTransactions,
										boolean defaultAsQuery,
										string datasource){
		// create cache region
		if( !structKeyExists(arguments,"queryCacheRegion") ){
			arguments.queryCacheRegion = "#arguments.entityName#.defaultVSCache";
		}

		// init parent
		super.init(argumentCollection=arguments);
		
		// Set the local entity to be used in this virtual entity service
		setEntityName( arguments.entityName );
		
		// Set the datasource of the local entity to be used in this virtual entity service
		// Only if not passed
		if( !StructKeyExists(arguments, "datasource") ){
			setDatasource( orm.getEntityDatasource( arguments.entityName ) );
		}
		else{
			setDatasource( arguments.datasource );
		}
		
		return this;
	}

	/************************************** PUBLIC *********************************************/

	any function executeQuery(required string query,
							   any params=structnew(),
							   numeric offset=0,
					  		   numeric max=0,
					  		   numeric timeout=0,
						       boolean ignorecase=false,
						       boolean asQuery=getDefaultAsQuery(),
						       boolean unique=false){
						       	   
		arguments.datasource = this.getDatasource();
		return super.executeQuery(argumentCollection=arguments);				       	   
	}

	any function list(struct criteria=structnew(),
					  string sortOrder="",
					  numeric offset=0,
					  numeric max=0,
					  numeric timeout=0,
					  boolean ignoreCase=false,
					  boolean asQuery=getDefaultAsQuery()){

		arguments.entityName = this.getEntityName();
		var results = super.list(argumentCollection=arguments);
		return results;
	}

	any function findWhere(required struct criteria){
		return super.findWhere(this.getEntityName(), arguments.criteria);
	}

	array function findAllWhere(required struct criteria, string sortOrder=""){
		return super.findAllWhere(this.getEntityName(), arguments.criteria, arguments.sortOrder);
	}

	any function new(struct properties=structnew(), boolean composeRelationships=true, nullEmptyInclude="", nullEmptyExclude="", boolean ignoreEmpty=false, include="", exclude=""){
		arguments.entityName = this.getEntityName();
		return super.new(argumentCollection=arguments);
	}

	boolean function exists(required any id) {
		arguments.entityName = this.getEntityName();
		return super.exists(argumentCollection=arguments);
	}

	any function get(required any id,boolean returnNew=true) {
		arguments.entityName = this.getEntityName();
		return super.get(argumentCollection=arguments);
	}

	array function getAll(any id,string sortOrder="") {
		arguments.entityName = this.getEntityName();
		return super.getAll(argumentCollection=arguments);
	}

	numeric function deleteAll(boolean flush=false,boolean transactional=getUseTransactions()){
		arguments.entityName = this.getEntityName();
		return super.deleteAll(arguments.entityName,arguments.flush);
	}
	
	boolean function deleteByID(required any id, boolean flush=false,boolean transactional=getUseTransactions()){
		arguments.entityName = this.getEntityName();
		return super.deleteByID(argumentCollection=arguments);
	}
	
	any function deleteByQuery(required string query, any params, numeric max=0, numeric offset=0, boolean flush=false, boolean transactional=getUseTransactions() ){
		arguments.datasource = this.getDatasource();
		return super.deleteByQuery(argumentCollection=arguments);
	}

	numeric function deleteWhere(boolean transactional=getUseTransactions()){
		arguments.entityName = this.getEntityName();
		return super.deleteWhere(argumentCollection=arguments);
	}

	numeric function count(string where="", any params=structNew()){
		arguments.entityName = this.getEntityName();
		return super.count(argumentCollection=arguments);
	}

	numeric function countWhere(){
		arguments.entityName = this.getEntityName();
		return super.countWhere(argumentCollection=arguments);
	}

	void function evict(string collectionName, any id){
		arguments.entityName = this.getEntityName();
		super.evict(argumentCollection=arguments);
	}
	
	any function clear(string datasource=this.getDatasource()){
		return super.clear(argumentCollection=arguments);
	}
	
	boolean function isSessionDirty(string datasource=this.getDatasource()){
		arguments.datasource = this.getDatasource();
		return super.isSessionDirty(argumentCollection=arguments);
	}
	
	struct function getSessionStatistics(string datasource=this.getDatasource()){
		arguments.datasource = this.getDatasource();
		return super.getSessionStatistics(argumentCollection=arguments);
	}

	string function getKey(){
		return super.getKey( this.getEntityName() );
	}

	array function getPropertyNames(){
		return super.getPropertyNames(this.getEntityName());
	}

	string function getTableName(){
		return super.getTableName(this.getEntityName());
	}
	
	any function criteriaQuery(array criteria=ArrayNew(1),
					  		 		  string sortOrder="",
					  		 		  numeric offset=0,
					  				  numeric max=0,
					  		 		  numeric timeout=0,
					  		 		  boolean ignoreCase=false,
					  		 		  boolean asQuery=getDefaultAsQuery()){
		arguments.entityName = this.getEntityName();
		return super.criteriaQuery(argumentCollection=arguments);
	}
	
	numeric function criteriaCount(array criteria=ArrayNew(1)){
		return super.criteriaCount(this.getEntityName(), arguments.criteria);
	}
	
	any function newCriteria(boolean useQueryCaching=false, string queryCacheRegion=""){
		
		arguments.entityName = this.getEntityName();
		return super.newCriteria(argumentCollection=arguments);
	}
	
	/**
	* Coverts an ID, list of ID's, or array of ID's values to the proper java type
	* The method returns a coverted array of ID's
	*/
	any function convertIDValueToJavaType(required id){
		arguments.entityName = this.getEntityName();
		return super.convertIDValueToJavaType(argumentCollection=arguments);
	}
	
	/**
	* Coverts a value to the correct javaType for the property passed in
	* The method returns the value in the proper Java Type
	*/
	any function convertValueToJavaType(required propertyName, required value){
		arguments.entityName = this.getEntityName();
		return super.convertValueToJavaType(argumentCollection=arguments);
	}
	
	/**
	* A nice onMissingMethod template to create awesome dynamic methods based on a virtual service
	*/
	any function onMissingMethod(string missingMethodName, struct missingMethodArguments){
		// Add the entity name
		arguments.missingMethodArguments.entityName = this.getEntityName();
		return super.onMissingMethod(argumentCollection=arguments);
	}
}