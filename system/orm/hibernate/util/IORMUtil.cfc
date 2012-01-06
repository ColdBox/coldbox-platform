/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author      :	Luis Majano & Mike McKellip
Description :

The base interface for retreieveing the right CF ORM session for CFML engines
that do not support multiple dsn's yet.

Once they do, these implementations will disappear.

----------------------------------------------------------------------->
*/
interface {
	public void		function flush(string datasource);
	public any  	function getSession(string datasource);
	public any  	function getSessionFactory(string datasource);
	public void 	function clearSession(string datasource);
	public void 	function closeSession(string datasource);
	public void 	function evictQueries(string cachename, string datasource);
	public string	function getEntityDatasource(required entity);
	public string	function getDefaultDatasource();
}