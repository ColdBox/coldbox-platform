component implements="coldbox.system.orm.hibernate.util.IORMUtil" output="false"
{
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
 		return application.getApplicationSettings().datasource;
 	}

}