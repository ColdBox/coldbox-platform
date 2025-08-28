/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Generic Hibernate Event Handler that ties to the ColdBox proxy for ColdBox Operations.
 * This is just a base class you can inherit from to give you access to your ColdBox
 * Application and the CF9 ORM event handler methods. Then you just need to
 * use a la carte.
 *
 * We also execute interception points that match the ORM events so you can eaisly
 * chain ORM interceptions.
 *
 */
component extends="coldbox.system.remote.ColdboxProxy" implements="orm.IEventHandler" {

	/**
	 * preLoad called by hibernate which in turn announces a coldbox interception: ORMPreLoad
	 */
	public void function preLoad( any entity ){
		announce( "ORMPreLoad", { entity : arguments.entity } );
	}

	/**
	 * postLoad called by hibernate which in turn announces a coldbox interception: ORMPostLoad
	 */
	public void function postLoad( any entity ){
		var sTime = getTickCount();

		var args = { entity : arguments.entity, entityName : "" };

		// Short-cut discovery via ActiveEntity
		if ( structKeyExists( arguments.entity, "getEntityName" ) ) {
			args.entityName = arguments.entity.getEntityName();
		} else {
			// it must be in session.
			args.entityName = ormGetSession().getEntityName( arguments.entity );
		}

		processEntityInjection( args.entityName, args.entity );

		announce( "ORMPostLoad", args );

		//systemOutput( "==> orm:postLoad:#getTickCount() - sTime#", true );
	}

	/**
	 * postDelete called by hibernate which in turn announces a coldbox interception: ORMPostDelete
	 */
	public void function postDelete( any entity ){
		announce( "ORMPostDelete", { entity : arguments.entity } );
	}

	/**
	 * preDelete called by hibernate which in turn announces a coldbox interception: ORMPreDelete
	 */
	public void function preDelete( any entity ){
		announce( "ORMPreDelete", { entity : arguments.entity } );
	}

	/**
	 * preUpdate called by hibernate which in turn announces a coldbox interception: ORMPreUpdate
	 */
	public void function preUpdate( any entity, Struct oldData = {} ){
		announce( "ORMPreUpdate", { entity : arguments.entity, oldData : arguments.oldData } );
	}

	/**
	 * postUpdate called by hibernate which in turn announces a coldbox interception: ORMPostUpdate
	 */
	public void function postUpdate( any entity ){
		announce( "ORMPostUpdate", { entity : arguments.entity } );
	}

	/**
	 * preInsert called by hibernate which in turn announces a coldbox interception: ORMPreInsert
	 */
	public void function preInsert( any entity ){
		announce( "ORMPreInsert", { entity : arguments.entity } );
	}

	/**
	 * postInsert called by hibernate which in turn announces a coldbox interception: ORMPostInsert
	 */
	public void function postInsert( any entity ){
		announce( "ORMPostInsert", { entity : arguments.entity } );
	}

	/**
	 * preSave called by ColdBox Base service before save() calls
	 */
	public void function preSave( any entity ){
		announce( "ORMPreSave", { entity : arguments.entity } );
	}

	/**
	 * postSave called by ColdBox Base service after transaction commit or rollback via the save() method
	 */
	public void function postSave( any entity ){
		announce( "ORMPostSave", { entity : arguments.entity } );
	}

	/**
	 * Called before the session is flushed.
	 */
	public void function preFlush( any entities ){
		announce( "ORMPreFlush", { entities : arguments.entities } );
	}

	/**
	 * Called after the session is flushed.
	 */
	public void function postFlush( any entities ){
		announce( "ORMPostFlush", { entities : arguments.entities } );
	}

	/**
	 * postNew called by ColdBox which in turn announces a coldbox interception: ORMPostNew
	 */
	public void function postNew( any entity, any entityName ){
		var args = { entity : arguments.entity, entityName : "" };

		// Do we have an incoming name
		if ( !isNull( arguments.entityName ) && len( arguments.entityName ) ) {
			args.entityName = arguments.entityName;
		}

		// If we don't have the entity name, then look it up
		if ( !len( args.entityName ) ) {
			// Short-cut discovery via ActiveEntity
			if ( structKeyExists( arguments.entity, "getEntityName" ) ) {
				args.entityName = arguments.entity.getEntityName();
			} else {
				// Long Discovery
				var md          = getMetadata( arguments.entity );
				args.entityName = ( md.keyExists( "entityName" ) ? md.entityName : listLast( md.name, "." ) );
			}
		}

		// Process the announcement
		announce( "ORMPostNew", args );
	}

	/**
	 * Get the system Event Manager
	 */
	public any function getEventManager(){
		return getWireBox().getEventManager();
	}

	/**
	 * process entity injection
	 *
	 * @entityName the entity to process, we use hash codes to identify builders
	 * @entity     The entity object
	 *
	 * @return The processed entity
	 */
	public function processEntityInjection( required entityName, required entity ){
		// Process DI
		getWireBox().autowire( target = arguments.entity, targetID = "ORMEntity-#arguments.entityName#" );
		return arguments.entity;
	}

}
