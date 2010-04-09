/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author      :	Curt Gratz
Description :

This is an Abstract Entity Service that extends the Coldbox BaseORMService to
provide easy access to creating concrete services that extend the BaseORMService
For example, if you want a UserService, you can either create an object based
off this object if no additional functionality is need

UserService=CreateObject("component", "coldbox.system.orm.hibernate.AbstractORMService").init("User");

Another example would be if you need a concrete UserService so you can provide
additional functionality or override one of the available methods you could
just do something like this you could just extend this service and setup your
init something like this.

UserService function init(){
    // setup properties
    setEntityName('User');
    setQueryCacheRegion( 'ORMService.defaultCache' );
    setUseQueryCaching( false );
    return this;
}

----------------------------------------------------------------------->
*/
component extends="coldbox.system.orm.hibernate.BaseORMService" accessors="true"{

	/**
	* The entityName property for this "version" of the AbstractORMService
	*/
	property name="entityName" type="string";


/* ----------------------------------- DEPENDENCIES ------------------------------ */



/* ----------------------------------- CONSTRUCTOR ------------------------------ */

	/**
	* Constructor
	*/
	AbstractEntityService function init(required string entityname, string queryCacheRegion, boolean useQueryCaching){

		// init parent
		super.init(argumentCollection=arguments);
		// Set the local entity to be used in this virtual abstract entity service
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
		results = super.list(argumentCollection=arguments);
		return results;
	}

	any function findWhere(){
		arguments.entityName = this.getEntityName();
		return super.findWhere(argumentCollection=arguments);
	}

	array function findAllWhere(){
		arguments.entityName = this.getEntityName();
		return super.findAllWhere(argumentCollection=arguments);
	}

	any function new(){
		return super.new(this.getEntityName());
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

	boolean function deleteByID(required any id, boolean flush=false){
		arguments.entityName = this.getEntityName();
		return super.deleteByID(argumentCollection=arguments);
	}

	numeric function deleteWhere(required string entityName){
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
}