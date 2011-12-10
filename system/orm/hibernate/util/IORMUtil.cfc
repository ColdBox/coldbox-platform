interface {

	public void   function flush(string datasource);
	public any    function getSession(string datasource);
	public any    function getSessionFactory(string datasource);
	public void   function clearSession(string datasource);
	public void   function closeSession(string datasource);
	public void   function evictQueries(string cachename, string datasource);
	public string function getEntityDatasource(required entity);
}