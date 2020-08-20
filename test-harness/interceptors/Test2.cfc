/**
 * I am a new interceptor
 */
component {

	void function configure(){
	}

	void function onCustomState( event, struct data, rc ){
		var threadName = createObject( "java", "java.lang.Thread" )
			.currentThread()
			.getThreadGroup()
			.getName();
		sleep( 2500 );
		log.info( "Executing onCustomState on Test2 by #threadname#" );
	}

}
