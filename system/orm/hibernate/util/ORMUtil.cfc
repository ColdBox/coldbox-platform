/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author      :	Luis Majano & Mike McKellip
Description :

This ORM utility implementation is for engines that do NOT support multiple dsn's

----------------------------------------------------------------------->
*/
component implements="coldbox.system.orm.hibernate.util.IORMUtil"{
			
	public void function flush(string datasource) {
		ORMFlush();
	}

	public any function getSession(string datasource) {
		return ORMGetSession();
	}
	
	public any function getSessionFactory(string datasource) {
		return ORMGetSessionFactory();
	}
	
	public void function clearSession(string datasource) {
		ORMClearSession();
	}
	
	public void function closeSession(string datasource) {
		ORMCloseSession();
	}
	
	public void function evictQueries(string cachename, string datasource) {
		if(StructKeyExists(arguments,"cachename"))
			ORMEvictQueries(arguments.cachename);
		else
			ORMEvictQueries();
	}
	
	/**
 	* Returns the datasource for a given entity
 	* @entity The entity reference. Can be passed as an object or as the entity name.
 	*/
 	public string function getEntityDatasource(required entity) {
 		return getDefaultDatasource();
 	}
 	
 	/**
	* Get the default application datasource
	*/
 	public string function getDefaultDatasource(){
 		var settings = application.getApplicationSettings();
 		// check orm settings first
 		if( structKeyExists( settings,"ormsettings") AND structKeyExists(settings.ormsettings,"datasource")){
 			return settings.ormsettings.datasource;
 		}
 		// else default to app datasource
 		return settings.datasource;
 	};

}