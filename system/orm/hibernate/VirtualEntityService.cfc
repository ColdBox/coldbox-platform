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
    setQueryCacheRegion( 'ORMService.defaultCache' );
    setUseQueryCaching( false );
	setEventHandling( false );
    return this;
}

----------------------------------------------------------------------->
*/
component extends="coldbox.system.orm.hibernate.BaseORMService" accessors="true"{

	/**
	* The entityName property for this "version" of the Virtual Service
	*/
	property name="entityName" type="string";


/* ----------------------------------- DEPENDENCIES ------------------------------ */



/* ----------------------------------- CONSTRUCTOR ------------------------------ */

	/**
	* Constructor
	*/
	VirtualEntityService function init(required string entityname, 
										string queryCacheRegion, 
										boolean useQueryCaching,
										boolean eventHandling){

		// init parent
		super.init(argumentCollection=arguments);
		
		// Set the local entity to be used in this virtual entity service
		setEntityName(arguments.entityName);
		
		return this;
	}


/* ----------------------------------- PUBLIC ------------------------------ */


	any function list(struct criteria=structnew(),
					  string sortOrder="",
					  numeric offset=0,
					  numeric max=0,
					  numeric timeout=0,
					  boolean ignoreCase=false,
					  boolean asQuery=true){

		arguments.entityName = this.getEntityName();
		var results = super.list(argumentCollection=arguments);
		return results;
	}

	any function findWhere(required struct criteria){
		return super.findWhere(this.getEntityName(), arguments.criteria);
	}

	array function findAllWhere(required struct criteria){
		return super.findAllWhere(this.getEntityName(), arguments.criteria);
	}

	any function new(){
		arguments.entityName = this.getEntityName();
		return super.new(argumentCollection=arguments);
	}

	boolean function exists(required any id) {
		arguments.entityName = this.getEntityName();
		return super.exists(argumentCollection=arguments);
	}

	any function get(required any id) {
		arguments.entityName = this.getEntityName();
		return super.get(argumentCollection=arguments);
	}

	array function getAll(any id) {
		arguments.entityName = this.getEntityName();
		return super.getAll(argumentCollection=arguments);
	}

	numeric function deleteAll(boolean flush=false){
		arguments.entityName = this.getEntityName();
		return super.deleteAll(arguments.entityName,arguments.flush);
	}
	
	boolean function deleteByID(required any id, boolean flush=false){
		arguments.entityName = this.getEntityName();
		return super.deleteByID(argumentCollection=arguments);
	}

	numeric function deleteWhere(){
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

	string function getKey(){
		return super.getKey(this.getEntityName());
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
					  		 		  boolean asQuery=true){
		arguments.entityName = this.getEntityName();
		return super.criteriaQuery(argumentCollection=arguments);
	}
	
	numeric function criteriaCount(array criteria=ArrayNew(1)){
		return super.criteriaCount(this.getEntityName(), arguments.criteria);
	}
}