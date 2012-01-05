/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author      :	Luis Majano & Mike McKellip
Description :

A simple factory to return the right ORM utility according to CFML engine

----------------------------------------------------------------------->
*/
import coldbox.system.orm.hibernate.util.*;

component{
	
	public any function getORMUtil() {
		switch( getPlatform() ) {
			case "ColdFusion Server":
				return new CFORMUtil();
				break;
			default:
				return new ORMUtil();
		}
	}
	
	private string function getPlatform() {
		return server.coldfusion.productname;
	}

}