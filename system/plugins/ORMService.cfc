/**
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Description :

This makes it a nice ORMService plugin

----------------------------------------------------------------------->
*/
component extends="coldbox.system.orm.hibernate.BaseORMService" singleton{

	/**
	* Constructor
	*/
	ORMService function init(){
		super.init();
		
		setpluginName("ORM Service");
		setpluginVersion("1.0");
		setpluginDescription("This is a generic ORM Service helper for Hibernate");
		setpluginAuthor("Luis Majano");
		setpluginAuthorURL("http://www.coldbox.org");
		
		return this;
	}

}