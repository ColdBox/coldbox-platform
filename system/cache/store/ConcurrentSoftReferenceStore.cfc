/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano
 *
 * I am a concurrent soft reference object store. In other words, I am fancy!
 * This store is case-sensitive
 */
component extends="coldbox.system.cache.store.ConcurrentStore" accessors=true{

	/**
	 * The reverse lookup map for soft references
	 */
	property name="softRefKeymap";

	/**
	 * The Java soft reference queue used for reaps
	 */
	property name="referenceQueue";

	/**
	 * Constructor
	 *
	 * @cacheProvider The associated cache provider as coldbox.system.cache.providers.ICacheProvider
	 * @cacheprovider.doc_generic coldbox.system.cache.providers.ICacheProvider
	 */
	function init( required cacheProvider ){
		// Super size me
		super.init( arguments.cacheProvider );

		// Override Fields
		variables.indexer.setFields( variables.indexer.getFields() & ",isSoftReference" );

		// Prepare soft reference lookup maps
		variables.softRefKeyMap	 	= createObject( "java", "java.util.concurrent.ConcurrentHashMap" ).init();
		variables.referenceQueue  	= createObject( "java", "java.lang.ref.ReferenceQueue" ).init();

		return this;
	}

	/**
	 * Clear all the elements in the store
	 */
	void function clearAll(){
		super.clearAll();
		variables.softRefKeyMap.clear();
	}

	/**
	 * Reap the storage, clean it from old stuff
	 */
	void function reap(){
		lock
			name="ConcurrentSoftReferenceStore.reap.#variables.storeID#"
			type="exclusive"
			timeout="20"{

			// Init Ref Key Vars
			var collected = variables.referenceQueue.poll();

			// Let's reap the garbage collected soft references
			while( !isNull( local.collected ) ){

				// Clean if it still exists
				if( softRefLookup( collected ) ){

					// expire it
					expireObject( getSoftRefKey( collected ) );

					// GC Collection Hit
					variables.cacheProvider.getStats().gcHit();
				}

				// Poll Again
				collected = variables.referenceQueue.poll();
			}
		}
	}

	/**
	 * Check if an object is in cache
	 *
	 * @objectKey The key to lookup
	 *
	 * @return boolean
	 */
	function lookup( required objectKey ){
		// check existence via super, if not found, check as it might be a soft reference
		if( NOT super.lookup( arguments.objectKey ) ){
			return false;
		}

		// get quiet to test it as it might be a soft reference
		if( isNull( getQuiet( arguments.objectKey ) ) ){
			return false;
		}

		// if we get here, it is found
		return true;
	}

	/**
	 * Get an object from cache. If its a soft reference object it might return a `null` value.
	 *
	 * @objectKey The key to retrieve
	 */
	function get( required objectKey ){
		// Get via concurrent store
		var target = super.get( arguments.objectKey );
		if( !isNull( local.target ) ){

			// Validate if SR or normal object
			if( isInstanceOf( target, "java.lang.ref.SoftReference" ) ){
				return target.get();
			}

			return target;
		}
	}

	/**
	 * Get an object from cache. If its a soft reference object it might return a null value
	 *
	 * @objectKey The key to retrieve
	 */
	function getQuiet( required objectKey ){
		// Get via concurrent store
		var target = super.getQuiet( arguments.objectKey );
		if( !isNull( local.target ) ){

			// Validate if SR or normal object
			if( isInstanceOf( target, "java.lang.ref.SoftReference" ) ){
				return target.get();
			}

			return target;
		}
	}

	/**
	 * Sets an object in the storage
	 *
	 * @objectKey The object key"
	 * @object The object to save"
	 * @timeout Timeout in minutes"
	 * @lastAccessTimeout Idle Timeout in minutes"
	 * @extras A map of extra name-value pairs"
	 */
	void function set(
		required objectKey,
		required object,
		timeout="",
		lastAccessTimeout="",
		extras={}
	){
		var target 	= 0;
		var isSR	= ( arguments.timeout GT 0 );

		// Check for eternal object
		if( isSR ){
			// Cache as soft reference not an eternal object
			target = createSoftReference( arguments.objectKey, arguments.object );
		} else {
			target = arguments.object;
		}

		// Store it
		super.set(
			objectKey         = arguments.objectKey,
			object            = target,
			timeout           = arguments.timeout,
			lastAccessTimeout = arguments.lastAccessTimeout,
			extras            = arguments.extras
		);

		// Set extra md in indexer
		variables.indexer.setObjectMetadataProperty( arguments.objectKey, "isSoftReference", isSR );
	}

	/**
	 * Clears an object from the storage pool
	 *
	 * @objectKey The object key to clear
	 */
	function clear( required objectKey ){
		// Check if it exists
		if( NOT variables.pool.containsKey( arguments.objectKey ) ){
			return false;
		}

		// Is this a soft reference?
		var softRef = variables.pool.get( arguments.objectKey );

		// Removal of Soft Ref Lookup
		if( !isNull( local.softRef ) && variables.indexer.getObjectMetadataProperty( arguments.objectKey, "isSoftReference" ) ){
			variables.softRefKeyMap.remove( softRef.hashCode() );
		}

		return super.clear( arguments.objectKey );
	}

	/****************************************************************************************/
	/*							EXTENSION METHODS 											*/
	/****************************************************************************************/

	/**
	 * See if the soft reference is in the reference key map
	 *
	 * @softRef The soft reference to verify
	 */
	boolean function softRefLookup( required softRef ){
		return variables.softRefKeyMap.containsKey( "hc-#arguments.softRef.hashCode()#" );
	}

	/**
	 * Get the soft reference's key from the soft reference lookback map
	 *
	 * @softRef The soft reference to check
	 *
	 * @return The object key it points to
	 */
	function getSoftRefKey( required softRef ){
		return variables.softRefKeyMap.get( "hc-#arguments.softRef.hashCode()#" );
	}

	/**
	 * Create SR, register cached object and reference
	 *
	 * @objectKey The value of the key to store
	 * @target The target to wrap
	 *
	 * @return A java soft reference `java.lang.ref.SoftReference`
	 */
	private function createSoftReference( required objectKey, required target ){
		// Create Soft Reference Wrapper and register with Queue
		var softRef = createObject( "java", "java.lang.ref.SoftReference" )
			.init( arguments.target, variables.referenceQueue );

		// Create Reverse Mapping, using CF approach or ACF blows up.
		variables.softRefKeyMap.put( "hc-#softRef.hashCode()#", arguments.objectKey );

		return softRef;
	}

}