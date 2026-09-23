/**
 * Records per-request timing into the PRC scope for debugging.
 */
component {

	void function configure(){
	}

	void function preProcess( event, data, rc, prc ){
		arguments.prc._perfStart = getTickCount()
	}

	void function postProcess( event, data, rc, prc ){
		if( arguments.prc.keyExists( "_perfStart" ) ){
			arguments.prc._perfElapsed = getTickCount() - arguments.prc._perfStart
		}
	}

}
