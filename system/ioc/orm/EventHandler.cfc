/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Description :

This class can be used directly or inherited from for more granular control of ORM injections.
This bridges Hibernate to WireBox so you can wire up ORM entities in your application. Please also
note that there is no way to intercept new() or entityNew() or createObject() calls done via 
ColdFusion and there is no preNew interception point exposed by ColdFusion.  So if you want ORM
entity injection enabled for new entities, you will have to send them manually into wirebox for wiring.

wirebox.autowire( entity );

All loaded entities will be wired for you during the postLoad() ORM event handler.

This event handler will also announce wirebox events according to hibernate events, so you can
create WireBox listeners and perform certain actions on entities:

- ORMPreLoad
- ORMPostLoad
- ORMPreDelete
- ORMPostDelete
- ORMPreUpdate
- ORMPostUpdate
- ORMPreInsert
- ORMPostInsert
- ORMPreSave
- ORMPostSave

This class requires that wirebox be in application scope in a key called 'wirebox'. You can
override this key by using an annotation called 'wirebox:scopeKey' in your own implementation.

To use:
1) In your Application.cfc orm settings point it directly to this file
   this.ormsettings.eventHandling = true;
   this.ormsettings.eventHandler  = "wirebox.system.ioc.orm.EventHandler";
   
2) Create a CFC that inherits from "wirebox.system.ioc.orm.EventHandler" and place it somewhere in your app.
   Add the orm settings in your Application.cfc
   this.ormsettings.eventHandling = true;
   this.ormsettings.eventHandler  = "model.EventHandler";
    
*/
component implements="CFIDE.orm.IEventHandler"{

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
		var orm 		= getORMUtil();
		var datasource 	= orm.getEntityDatasource( arguments.entity );
		
		var args = { entity=arguments.entity, entityName=orm.getSession( datasource ).getEntityName( arguments.entity ) };
		processEntityInjection(args.entityName, args.entity);
		announceInterception("ORMPostLoad",args);
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
	public void function preUpdate(any entity, struct oldData=structNew()){
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
	
	/**
	* process entity injection
	*/
	private function processEntityInjection(required entityName,required entity){
		var ormSettings		= getController().getSetting("orm").injection;
		var injectorInclude = ormSettings.include;
		var injectorExclude = ormSettings.exclude;
		
		// Enabled?
		if( NOT ormSettings.enabled ){
			return;
		}
		
		// Include,Exclude?
		if( (len(injectorInclude) AND listContainsNoCase(injectorInclude,entityName))
		    OR
			(len(injectorExclude) AND NOT listContainsNoCase(injectorExclude,entityName))
			OR 
			(NOT len(injectorInclude) AND NOT len(injectorExclude) ) ){
			
			// Process DI
			getWireBox().autowire(target=entity,targetID="ORMEntity-#entityName#");
		}	
	}
	
	/**
	* Get ORM Util
	*/
	private function getORMUtil() {
		return new coldbox.system.orm.hibernate.util.ORMUtilFactory().getORMUtil();
	}
}