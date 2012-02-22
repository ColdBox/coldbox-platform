/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Description :

This Active Entity object allows you to enhance your ORM entities with virtual service methods
and make it follow more of an Active Record pattern, but not really :)

It just allows you to operate on entity and related entity objects much much more easily.


----------------------------------------------------------------------->
Available Annotations:
-active_queryCaching=boolean (false)
-active_queryCacheRegion=string 
-active_eventHandling=boolean (true)
-active_useTransactions=boolean (true)
-active_asQuery=boolean(true)
*/
component extends="coldbox.system.orm.hibernate.VirtualEntityService" accessors="true"{
	
	/**
	* Active Entity Constructor, if you override it, make sure you call super.init()
	*/
	function init(){
		var md 		= getMetadata( this );
		var args 	= {};
		
		// find entity name on md?
		if( structKeyExists(md,"entityName") ){
			args.entityName = md.entityName;
		}
		// else default to entity CFC name
		else{
			args.entityName = listLast( md.name, "." );
		}
		// query caching
		if( structKeyExists(md,"active_queryCaching") ){
			args.useQueryCaching = md["active_queryCaching"]; 
		}
		// queryCacheRegion
		if( structKeyExists(md,"active_queryCaching") ){
			args.queryCacheRegion = md["active_queryCacheRegion"]; 
		}
		// eventHandling
		if( structKeyExists(md,"active_eventHandling") ){
			args.eventHandling = md["active_eventHandling"]; 
		}
		// useTransactions
		if( structKeyExists(md,"active_useTransactions") ){
			args.useTransactions = md["active_useTransactions"]; 
		}
		// defaultAsQuery
		if( structKeyExists(md,"active_defaultAsQuery") ){
			args.defaultAsQuery = md["active_defaultAsQuery"]; 
		}
		// datasource
		args.datasource = new coldbox.system.orm.hibernate.util.ORMUtilFactory().getORMUtil().getEntityDatasource( this );
		
		// init the super class with our own arguments
		super.init(argumentCollection=args);
		
		return this;
	}
	
}