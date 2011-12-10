import coldbox.system.orm.hibernate.util.*;

component  output="false"
{
	
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