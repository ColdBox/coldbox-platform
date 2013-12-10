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
entity injection enabled for new entities, you will have to send them manually into wirebox for wiring like so:

wirebox.autowire( entity );

All loaded entities will be wired for you during the postLoad() ORM event handler.

This event handler will also announce WireBox events according to hibernate events, so you can
create WireBox listeners and perform certain actions on entities.  The announced events are:

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

This class requires that WireBox be in application scope in a key called 'wirebox'. You can
override this key by using a private variable in your own implementation.

To use:
1) In your Application.cfc orm settings point it directly to this file
   this.ormsettings.eventHandling = true;
   this.ormsettings.eventHandler  = "wirebox.system.orm.hibernate.WBEventHandler";
   
2) Create a CFC that inherits from "wirebox.system.orm.hibernate.WBEventHandler" and place it somewhere in your app.
   Add the orm settings in your Application.cfc
   this.ormsettings.eventHandling = true;
   this.ormsettings.eventHandler  = "model.EventHandler";

If you do the latter, you can use some extra functionality by using the following private variables.

// The scope key wirebox is located in application scope
scopeKey = "wirebox";

// Include list of ORM entities to include in the injection, if blank it includes all, which is the default
injectorInclude = "";

// Exclude list of ORM entities to exclude in the injection, if blank it includes none, which is the default
injectorExclude = "";

*/
component implements="CFIDE.orm.IEventHandler"{
	
	/**
	* The scope key to use
	*/
	variables.scopeKey = "wirebox";
	
	/**
	* Include list of ORM entities to include in the injection, if blank it includes all, which is the default
	*/
	variables.injectorInclude = "";
	
	/**
	* Exclude list of ORM entities to exclude in the injection, if blank it includes none, which is the default
	*/
	variables.injectorExclude = "";
	
	/**
	* postNew called by ColdBox which in turn announces a coldbox interception: ORMPostNew
	*/
	public void function postNew( entity, entityName ){
		var args = { entity = arguments.entity, entityName=arguments.entityName };
		processEntityInjection( args.entityName, args.entity );
		announceInterception( "ORMPostNew", args );
	}
	
	/**
	* preLoad called by hibernate which in turn announces a WireBox interception: ORMPreLoad
	*/
	public void function preLoad( entity ){
		announceInterception( "ORMPreLoad", { entity = arguments.entity } );
	}

	/**
	* postLoad called by hibernate which in turn announces a WireBox interception: ORMPostLoad
	*/
	public void function postLoad( entity ){
		var orm 		= getORMUtil();
		var datasource 	= orm.getEntityDatasource( arguments.entity );
		
		var args = { entity=arguments.entity, entityName=orm.getSession( datasource ).getEntityName( arguments.entity ) };
		processEntityInjection(args.entityName, args.entity);
		announceInterception( "ORMPostLoad",args);
	}

	/**
	* postDelete called by hibernate which in turn announces a WireBox interception: ORMPostDelete
	*/
	public void function postDelete( entity ){
		announceInterception( "ORMPostDelete", {entity=arguments.entity});
	}

	/**
	* preDelete called by hibernate which in turn announces a WireBox interception: ORMPreDelete
	*/
	public void function preDelete( entity ) {
		announceInterception( "ORMPreDelete", {entity=arguments.entity});
	}

	/**
	* preUpdate called by hibernate which in turn announces a WireBox interception: ORMPreUpdate
	*/
	public void function preUpdate( entity, struct oldData=structNew()){
		announceInterception( "ORMPreUpdate", {entity=arguments.entity, oldData=arguments.oldData});
	}

	/**
	* postUpdate called by hibernate which in turn announces a WireBox interception: ORMPostUpdate
	*/
	public void function postUpdate( entity ){
		announceInterception( "ORMPostUpdate", {entity=arguments.entity});
	}

	/**
	* preInsert called by hibernate which in turn announces a WireBox interception: ORMPreInsert
	*/
	public void function preInsert( entity ){
		announceInterception( "ORMPreInsert", {entity=arguments.entity});
	}

	/**
	* postInsert called by hibernate which in turn announces a WireBox interception: ORMPostInsert
	*/
	public void function postInsert( entity ){
		announceInterception( "ORMPostInsert", {entity=arguments.entity});
	}

	/**
	* preSave called by WireBox Base service before save() calls
	*/
	public void function preSave( entity ){
		announceInterception( "ORMPreSave", {entity=arguments.entity});
	}

	/**
	* postSave called by WireBox Base service after transaction commit or rollback via the save() method
	*/
	public void function postSave( entity ){
		announceInterception( "ORMPostSave", {entity=arguments.entity});
	}

	/**
	* Process a wirebox event
	*/
	public function announceInterception( required string state, data=structNew() ){
		// announce event
		getWireBox().getEventManager().processState( arguments.state, arguments.data );
	}

	/**
	* Get the system Event Manager
	*/
	public function getEventManager(){
		return getWireBox().getEventManager();
	}
	
	/************************************** PRIVATE *********************************************/
	
	/**
	* Get a reference to WireBox
	*/
	private function getWireBox(){
		return application[ scopeKey ];
	}
	
	/**
	* Process entity injection
	*/
	private function processEntityInjection(required entityName,required entity){
		
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