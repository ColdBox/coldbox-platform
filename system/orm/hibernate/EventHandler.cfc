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
	
	We also fires several coldbox interceptors that match the ORM events prefixed by ORM within
	a ColdBox application, so it makes it super easy to chain ORM interceptions
@injector false
@injectorSetterInjection false
@injectorStopRecursion ''
@injectorInclude ''
@injectorExclude ''
@output false
*/
component extends="coldbox.system.remote.ColdboxProxy" implements="CFIDE.orm.IEventHandler"{
	
	/**
	* preLoad called by hibernate which in turn announces a coldbox interception: ORMPreLoad
	*/
	public void function preLoad(any entity){
		announceInterception("ORMPreLoad",{entity = arguments.entity});
	}

	/**
	* Whenever entities are loaded I get fired and can do some funky ColdBox wiring.
	* Also announces a coldbox interception: ORMPostLoad
	*/
	public void function postLoad(any entity){
		var md = getMetadata(this);
		// Verify metadata injections
		if( structKeyExists(md,"injector") and md.injector ){
			
			var entityName = listLast(getMetadata(arguments.entity).name,".");
			
			// Injector Defaults
			if( NOT structKeyExists(md,"injectorSetterInjection") ){	md.injectorSetterInjection = false; }
			if( NOT structKeyExists(md,"injectorStopRecursion") ){	md.injectorStopRecursion = ''; }
			if( NOT structKeyExists(md,"injectorInclude") ){	md.injectorInclude = ''; }
			if( NOT structKeyExists(md,"injectorExclude") ){	md.injectorExclude = ''; }
		
			// Include,Exclude?
			if( (len(md.injectorInclude) AND listContainsNoCase(md.injectorInclude,entityName))
			    OR
				(len(md.injectorExclude) AND NOT listContainsNoCase(md.injectorExclude,entityName))
				OR 
				(NOT len(md.injectorInclude) AND NOT len(md.injectorExclude) ) ){
				
				// Inject Entity
				autowire(arguments.entity,md.injectorSetterInjection,md.injectorStopRecursion);
			}
		}// end if injecting
		
		// Announce interception
		announceInterception("ORMPostLoad",{entity=arguments.entity});
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
	* Autowire entities based on arguments
	*/
	public void function autowire(required any entity, boolean useSetterInjection=false, string stopRecursion=""){
		// Inject Entity
		getPlugin("BeanFactory").autowire(target=arguments.entity,
			   							  useSetterInjection=arguments.useSetterInjection,
									      stopRecursion=arguments.stopRecursion);
	}
	
}