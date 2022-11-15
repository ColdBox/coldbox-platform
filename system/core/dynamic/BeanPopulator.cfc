/**
 * @deprecated DO NOT USE
 */
component extends="ObjectPopulator" {

	property name="log" inject="logBox:logger:{this}";

	function onDIComplete(){
		log.warn( "The BeanPopulator object has been deprecated. Please do not use!" );
	}

}
