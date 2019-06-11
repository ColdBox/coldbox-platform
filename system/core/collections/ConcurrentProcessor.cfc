/**
 * This processor takes in a collection and can process its items in parallel according to many
 * options like maxThreads and if no more threads can be created by the CFML Engine.
 *
 * Please note this class is a <strong>Transient</strong> do not make it a singleton or bad things can happen
 */
component accessors="true"{

	/**
	 * Collection target
	 */
	property name="collection";

	/**
	 * Max threads to leverage
	 */
	property name="maxThreads" type="numeric" default="20";

	/**
	 * Thread priority to use
	 */
	property name="priority" type="string" default="normal";

	/**
	 * A collection of error logs where if a thread fails, the exception data will be stored here.
	 */
	property name="errorLogs" type="array";

	/**
	 * Init a parallel processor with the collection to process concurrently
	 *
	 * @target The target collection to proecss
	 * @maxThreads How many concurrent threads to use
	 * @priority The thread priority
	 */
	function init( target=[], numeric maxThreads=20, priority="normal" ){
		variables.collection 	= arguments.target;
		variables.maxThreads 	= arguments.maxThreads;
		variables.priority 		= arguments.priority;
		variables.util 		 	= new coldbox.system.core.util.Util();
		variables.uuidHelper 	= createobject( "java", "java.util.UUID" );
		variables.consumer 		= function(){};
		variables.errorLogs 	= [];

		return this;
	}

	/**
	 * Process each collection item via the consumer in a separate thread if it is allowed.
	 * Please note that this does not mutate the collection, it only porcess it
	 */
	ConcurrentProcessor function each( required consumer ){
		variables.consumer = arguments.consumer;

		if( isStruct( variables.collection ) ){
			return _eachStruct();
		} else if( isArray( variables.collection ) ){
			return _eachArray();
		} else {
			// Queries
			return _eachQuery();
		}
	}

	/******************************** PRIVATE PROCESSORS ********************************/

	/**
	 * Process an array
	 */
	private function _eachArray(){
		var threadList 	= [];

		for( var x = 1; x lte arrayLen( variables.collection ); x++ ){

			// Sync mode?
			if( variables.util.inThread() || threadList.len() > variables.maxThreads ){
				arguments.consumer( thisItem );
				continue;
			}

			var threadName = "$box_cp_#variables.uuidHelper.randomUUID()#";
			threadList.append( threadName );

			thread
				action="run"
				name="#threadName#"
				priority="#variables.priority#"
				threadName="#threadName#"
				index=x{
					try{
						variables.consumer(
							variables.collection[ attributes.index ]
						);
					}
					catch( any e ){
						variables.processError( e );
					}
				}
		} // end for loop

		// Wait for all threads to join
		thread action="join" name="#threadList.toList()#";

		return this;
	}

	/**
	 * Process a struct
	 */
	private function _eachStruct(){
		var threadList 	= [];

		for( var thisKey in variables.collection ){

			// Sync mode?
			if( variables.util.inThread() || threadList.len() > variables.maxThreads ){
				arguments.consumer( variables.collection[ thisKey ] );
				continue;
			}

			var threadName = "$box_cp_#variables.uuidHelper.randomUUID()#";
			threadList.append( threadName );

			thread
				action="run"
				name="#threadName#"
				priority="#variables.priority#"
				threadName="#threadName#"
				key=thisKey{
					try{
						variables.consumer(
							variables.collection[ attributes.key ]
						);
					}
					catch( any e ){
						variables.processError( e );
					}
				}
		} // end for loop

		// Wait for all threads to join
		thread action="join" name="#threadList.toList()#";

		return this;
	}

	/**
	 * Process a query
	 */
	private function _eachQuery(){
		var threadList 	= [];

		for( var x = 1; x lte variables.collection.recordCount; x++ ){

			// Sync mode?
			if( variables.util.inThread() || threadList.len() > variables.maxThreads ){
				arguments.consumer( thisItem );
				continue;
			}

			var threadName = "$box_cp_#variables.uuidHelper.randomUUID()#";
			threadList.append( threadName );

			thread
				action="run"
				name="#threadName#"
				priority="#variables.priority#"
				threadName="#threadName#"
				index=x{
					try{
						variables.consumer(
							variables.collection.getRow( attributes.index )
						);
					}
					catch( any e ){
						variables.processError( e );
					}
				}
		} // end for loop

		// Wait for all threads to join
		thread action="join" name="#threadList.toList()#";

		return this;
	}

	private function processError( required e ){
		var threadName = createObject( "java", "java.lang.Thread" ).currentThread().getName();
		var threadLog = "Error running thread (#threadName#): #arguments.e.message# #arguments.e.detail#";
		// Send them to console for debugging
		writeDump( var=threadLog, output="console" );
		writeDump( var=e.stackTrace, output="console" );
		// Send them to the error logs array
		variables.errorLogs.append( threadLog );
	}

}