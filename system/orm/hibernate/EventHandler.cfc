/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	Generic Hibernate Event Handler that ties to the ColdBox proxy for ColdBox Operations.
 	This is just a base class you can inherit from to give you access to your ColdBox
	Application and the CF9 ORM event handler methods. Then you just need to
	use a la carte.
	
@output false
*/
component extends="coldbox.system.remote.ColdboxProxy" implements="CFIDE.orm.IEventHandler"{
	
	public void function preInsert(any entity){
	}

	public void function postLoad(any entity){
	}

	public void function postDelete(any entity){
	}

	public void function preLoad(any entity){
	}

	public void function preDelete(any entity) {
	}

	public void function preUpdate(any entity, Struct oldData){
	}

	public void function postUpdate(any entity){
	}

	public void function postInsert(any entity){
	}
}