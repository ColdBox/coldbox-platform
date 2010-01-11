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
@injector false
@injectorSetterInjection false
@injectorStopRecursion ''
@injectorInclude ''
@injectorExclude ''
@output false
*/
component extends="coldbox.system.remote.ColdboxProxy" implements="CFIDE.orm.IEventHandler"{
	
	public void function preLoad(any entity){
	}

	/**
	* @hint Whenever entities are loaded I get fired and can do some funky ColdBox wiring
	*/
	public void function postLoad(any entity){
		var md = getMetadata(this);
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
				getPlugin("BeanFactory").autowire(target=arguments.entity,
					   							  useSetterInjection=md.injectorSetterInjection,
											      stopRecursion=md.injectorStopRecursion);
			}
		}// end if injecting
	}

	public void function postDelete(any entity){
	}

	public void function preDelete(any entity) {
	}

	public void function preUpdate(any entity, Struct oldData){
	}

	public void function postUpdate(any entity){
	}
	
	public void function preInsert(any entity){
	}
	
	public void function postInsert(any entity){
	}
	
}