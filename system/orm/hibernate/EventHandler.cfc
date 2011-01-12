/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	Generic Hibernate Event Handler that ties to the ColdBox proxy for ColdBox Operations.
 	This is just a base class you can inherit from to give you access to your ColdBox
	Application and the CF9 ORM event handler methods. Then you just need to
	use a la carte.

	We also execute interception points that match the ORM events so you can eaisly
	chain ORM interceptions.

*/
component extends="coldbox.system.remote.ColdboxProxy" implements="CFIDE.orm.IEventHandler"{

	/**
	* postNew called by ColdBox which in turn announces a coldbox interception: ORMPostNew
	*/
	public void function postNew(any entity,any entityName){
		announceInterception("ORMPostNew",{entity = arguments.entity, entityName=arguments.entityName});
	}

	/**
	* preLoad called by hibernate which in turn announces a coldbox interception: ORMPreLoad
	*/
	public void function preLoad(any entity){
		announceInterception("ORMPreLoad",{entity = arguments.entity});
	}

	/**
	* postLoad called by hibernate which in turn announces a coldbox interception: ORMPostLoad
	*/
	public void function postLoad(any entity){
		announceInterception("ORMPostLoad",{entity=arguments.entity,entityName=ORMGetSession().getEntityName( arguments.entity )});
	}

	/**
	* postDelete called by hibernate which in turn announces a coldbox interception: ORMPostDelete
	*/
	public void function postDelete(any entity){
		announceInterception("ORMPostDelete", {entity=arguments.entity});
	}

	/**
	* preDelete called by hibernate which in turn announces a coldbox interception: ORMPreDelete
	*/
	public void function preDelete(any entity) {
		announceInterception("ORMPreDelete", {entity=arguments.entity});
	}

	/**
	* preUpdate called by hibernate which in turn announces a coldbox interception: ORMPreUpdate
	*/
	public void function preUpdate(any entity, Struct oldData){
		announceInterception("ORMPreUpdate", {entity=arguments.entity, oldData=arguments.oldData});
	}

	/**
	* postUpdate called by hibernate which in turn announces a coldbox interception: ORMPostUpdate
	*/
	public void function postUpdate(any entity){
		announceInterception("ORMPostUpdate", {entity=arguments.entity});
	}

	/**
	* preInsert called by hibernate which in turn announces a coldbox interception: ORMPreInsert
	*/
	public void function preInsert(any entity){
		announceInterception("ORMPreInsert", {entity=arguments.entity});
	}

	/**
	* postInsert called by hibernate which in turn announces a coldbox interception: ORMPostInsert
	*/
	public void function postInsert(any entity){
		announceInterception("ORMPostInsert", {entity=arguments.entity});
	}

	/**
	* preSave called by ColdBox Base service before save() calls
	*/
	public void function preSave(any entity){
		announceInterception("ORMPreSave", {entity=arguments.entity});
	}

	/**
	* postSave called by ColdBox Base service after transaction commit or rollback via the save() method
	*/
	public void function postSave(any entity){
		announceInterception("ORMPostSave", {entity=arguments.entity});
	}
}