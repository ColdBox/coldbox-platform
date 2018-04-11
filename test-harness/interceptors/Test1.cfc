/**
* I am a new interceptor
*/
component extends="coldbox.system.Interceptor"{

	void function configure(){

	}

	function preProcess( event, interceptData, rc, prc ){
		// Placed here for testing purposes
		flash.put( "name", "luis" );
	}

	void function onCustomState(event,struct interceptData, rc ){
		var threadName = createObject("java","java.lang.Thread").currentThread().getThreadGroup().getName();
		sleep(1000);
		log.info( "Executing onCustomState on Test1 by #threadName#" );
	}

	void function postProcess(event, interceptData) asyncPriority="high" async{
		var threadName = createObject("java","java.lang.Thread").currentThread().getThreadGroup().getName();
		log.info( "---> I am executing in a different thread (#threadName#)! Booya!" );
	}



}
