/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Description :

This Active Entity object allows you to enhance your ORM entities with virtual service methods
and make it follow more of an Active Record pattern, but not really :)

It just allows you to operate on entity and related entity objects much much more easily.

*/
component extends="coldbox.system.orm.hibernate.VirtualEntityService" accessors="true"{
	
	/**
	* Active Entity Constructor, if you override it, make sure you call super.init()
	* @queryCacheRegion.hint The query cache region to use if not we will use one for you
	* @useQueryCaching.hint Enable query caching for this entity or not, defaults to false
	* @eventHandling.hint Enable event handling for new() and save() operations, defaults to true
	* @useTransactions.hint Enable transactions for all major operations, defaults to true
	* @defaultAsQuery.hint What should be the default return type query or arrays for list opertions, defaults to true
	*/
	function init(string queryCacheRegion, boolean useQueryCaching,	boolean eventHandling, boolean useTransactions,	boolean defaultAsQuery){
		var md 		= getMetadata( this );
		
		// find entity name on md?
		if( structKeyExists(md,"entityName") ){
			arguments.entityName = md.entityName;
		}
		// else default to entity CFC name
		else{
			arguments.entityName = listLast( md.name, "." );
		}
		// query cache region just in case
		if( !structKeyExists(arguments,"queryCacheRegion") ){
			arguments.queryCacheRegion = "#arguments.entityName#.activeEntityCache";
		}
		// datasource
		arguments.datasource = new coldbox.system.orm.hibernate.util.ORMUtilFactory().getORMUtil().getEntityDatasource( this );
		
		// init the super class with our own arguments
		super.init(argumentCollection=arguments);
		
		return this;
	}
	
}