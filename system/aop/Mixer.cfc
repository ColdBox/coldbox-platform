/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* I am a WireBox listener that provides you with AOP capabilities in your objects.
*
* Listener Properties:
*	- generationPath:path	- The include path used for code generation
*	- dictionaryReload:boolean(false) - The flag to always reload aspect dictionary discover information, great for development
*/
component accessors="true"{

	/**
	* WireBox
	*/
	property name="injector";
	/**
	* WireBox Binder
	*/
	property name="binder";
	/**
	* Logging class
	*/
	property name="log";
	/**
	* Listener properties
	*/
	property name="properties";
	/**
	* Class matching dictionary
	*/
	property name="classMatchDictionary";
	/**
	* Java System
	*/
	property name="system";
	/**
	* Java UUID Helper
	*/
	property name="uuid";
	/**
	* Mixer utility object
	*/
	property name="mixerUtil";
	/**
	* Class identity
	*/
	property name="classID";

	/**
	* Listener constructor
	* @injector
	* @properties
	*/
	function configure( required injector, required properties ){
		// injector reference
		variables.injector 				= arguments.injector;
		// Binder Reference
		variables.binder				= arguments.injector.getBinder();
		// local logger
		variables.log 					= arguments.injector.getLogBox().getLogger( this );
		// listener properties
		variables.properties 			= arguments.properties;
		// class matcher dictionary
		variables.classMatchDictionary 	= createObject( "java", "java.util.concurrent.ConcurrentHashMap" ).init();
		// system
		variables.system 				= createObject( "java", "java.lang.System" );
		// uuid helper
		variables.uuid 					= createobject( "java", "java.util.UUID" );
		// mixer util
		variables.mixerUtil 			= new coldbox.system.aop.MixerUtil();
		// class id code
		variables.classID 				= variables.system.identityHashCode( this );

		// Default Generation Path?
		if( NOT structKeyExists( variables.properties, "generationPath" ) ){
			variables.properties.generationPath = "/coldbox/system/aop/tmp";
		}

		// Check if we can write to generation path
		if( !getFileInfo( expandPath(variables.properties.generationPath) ).canWrite ){
			throw( message="The AOP generation directory: '#variables.properties.generationPath#' is not writable, cannot continue." );
		}

		// Class Dictionary Reload
		if( NOT structKeyExists( variables.properties, "classMatchReload" ) ){
			variables.properties.classMatchReload = false;
		}

		return this;
	}

	/**
	* Executes our AOP mixer after variabless are created and autowired
	*/
	function afterInstanceAutowire( required interceptData ){
		var mapping 	= arguments.interceptData.mapping;
		var target 		= arguments.interceptData.target;

		// check if target already mixed, if so just return, nothing else to do or if the  mapping is an aspect
		if( structKeyExists( target, "$wbAOPMixed" ) OR mapping.isAspect() ){ return; }

		// Setup variables
		var mappingName = lcase( mapping.getName() );
		var idCode		= variables.system.identityHashCode( target );

		// Check if incoming mapping name is already class matched?
		if( NOT structKeyExists( variables.classMatchDictionary, mappingName ) ){
			// Register this incoming mapping for class aspect matching
			buildClassMatchDictionary( target, mapping, idCode );
		}

		// Now, we check if we have any aspects to apply to this class according to class matchers
		if( arrayLen( variables.classMatchDictionary[ mappingName ] ) ){
			AOPBuilder(
				target 		= target,
				mapping 	= mapping,
				dictionary 	= variables.classMatchDictionary[ mappingName ],
				idCode 		= idCode
			);
		}
	}

	/**
	* Build an aspect dictionary for incoming target objects
	* @target The incoming target
	* @mapping The incoming target mapping
	* @idCode The incoming target identifier
	*
	*/
	private function buildClassMatchDictionary( required target, required mapping, required idCode ){
		var aspectBindings 	= variables.binder.getAspectBindings();
		var bindingsLen 	= arrayLen( aspectBindings );
		var mappingName		= lcase( arguments.mapping.getName() );
		var matchedAspects	= [];

    	lock name="aop.#variables.classID#.cmd.for.#arguments.idCode#" type="exclusive" timeout="30" throwontimeout="true"{
			// check again, double lock
			if( NOT structKeyExists( variables.classMatchDictionary, mappingName ) ){

				// Discover matching for the class via all aspect bindings
				for( var x=1; x LTE bindingsLen; x++ ){

					// class match? If so, add to dictionary of matched aspects
					if( aspectBindings[ x ].classes.matchClass( arguments.target, arguments.mapping ) ){
						arrayAppend( matchedAspects, aspectBindings[ x ] );
					}

				}// end for discovery

				// Log
				if( variables.log.canDebug() ){
					variables.log.debug( "Aspect class matching dictionary built for mapping: #mappingName#, aspects: #matchedAspects.toString()#" );
				}

				// Store matched dictionary
				variables.classMatchDictionary[ mappingName ] = matchedAspects;

			} // end if in dictionary
		} // end lock
	}

	/**
	* Build and weave all necessary advices on an object via method matching
	* @target The incoming target
	* @mapping The incoming target mapping
	* @dictionary The target aspect dictionary
	* @idCode The incoming target identifier
	*
	*/
	private function AOPBuilder(
		required target,
		required mapping,
		required dictionary,
		required idCode
	){
		lock name="aop.#variables.classID#.weaveAdvice.id.#arguments.idCode#" type="exclusive" timeout="30" throwOnTimeout="true"{
			// check if weaved already
			if( structKeyExists( arguments.target, "$wbAOPMixed" ) ){ return; }

			// decorate target with AOP capabilities
			decorateAOPTarget( arguments.target, arguments.mapping );

			// Process methods via metadata and apply aspects if they match
			processTargetMethods(
				target 		= arguments.target,
				mapping 	= arguments.mapping,
				metadata 	= arguments.mapping.getObjectMetadata(),
				dictionary 	= arguments.dictionary
			);

			// finalize AOP
			arguments.target.$wbAOPMixed = true;
		}
	}

	/**
	* Process target methods for AOP weaving
	* @target The incoming target
	* @mapping The incoming target mapping
	* @metadata The incoming target metadata
	* @dictionary The target aspect dictionary
	*
	*/
	private function processTargetMethods(
		required target,
		required mapping,
		required metadata,
		required dictionary
	){
		// check if there are functions, else exit
		if( NOT structKeyExists( arguments.metadata, "functions" ) ){
			return;
		}

		// Get Function info
		var functions	= arguments.metadata.functions;
		var fncLen 		= arrayLen( functions );

		for( var x=1; x LTE fncLen; x++ ){

			// check if function already proxied, if so, skip it
			if( structKeyExists( arguments.target.$wbAOPTargets, functions[ x ].name ) ){ continue; }

			// init matched aspects to weave
			var matchedMethodAspects = [];

			// function not proxied yet, let's iterate over aspects and see if we can match
			for( var y=1; y LTE arrayLen( arguments.dictionary ); y++){
				// does the jointpoint match against aspect methods
				if( arguments.dictionary[ y ].methods.matchMethod( functions[ x ] ) ){
					matchedMethodAspects.addAll( arguments.dictionary[ y ].aspects );
					// Debug Info
					if ( variables.log.canDebug() ){
						variables.log.debug( "Target: (#arguments.mapping.getName()#) Method:(#functions[ x ].name#) matches aspects #arguments.dictionary[ y ].aspects.toString()#" );
					}
				}
			}

			// Build the the AOP advisor with the function pointcut and matched aspects?
			if( arrayLen( matchedMethodAspects ) ){
				weaveAdvice(
					target 		= arguments.target,
					mapping 	= arguments.mapping,
					jointpoint 	= functions[ x ].name,
					jointPointMD= functions[ x ],
					aspects 	= matchedMethodAspects
				);
			}

		}

		// Discover inheritance? Recursion
		if( structKeyExists( arguments.metadata, "extends" ) ){
			processTargetMethods(
				target 		= arguments.target,
				mapping 	= arguments.mapping,
				metadata 	= arguments.metadata.extends,
				dictionary 	= arguments.dictionary
			);
		}
	}

	/**
	* Weave an advise into a jointpoint
	* @target The incoming target
	* @mapping The incoming target mapping
	* @jointPoint The jointpoint to proxy
	* @jointPointMD The jointpoint metdata to proxy
	* @aspects The aspects to weave into the jointpoint
	*
	*/
	private function weaveAdvice(
		required target,
		required mapping,
		required jointPoint,
		required jointPointMD,
		required aspects
	){
		var udfOut 			= createObject( "java","java.lang.StringBuilder" ).init( '' );
		var tmpFile 		= variables.properties.generationPath & "/" & variables.uuid.randomUUID().toString() & ".cfm";
		var expandedFile 	= expandPath( tmpFile );
		var lb				= "#chr(13)##chr(10)#";
		var fncMD			= {
			name = "", access = "public", output="false", returnType = "any"
		};
		var mappingName 	= arguments.mapping.getName();
		var mdJSON			= urlEncodedFormat( serializeJSON( arguments.jointPointMD ) );

		// MD proxy Defaults
		fncMD.name = arguments.jointPointMD.name;
		if( structKeyExists( arguments.jointPointMD, "access" ) ){ fncMD.access = arguments.jointPointMD.access; }
		if( structKeyExists( arguments.jointPointMD, "output" ) ){ fncMD.output = arguments.jointPointMD.output; }
		if( structKeyExists( arguments.jointPointMD, "returntype" ) ){ fncMD.returntype = arguments.jointPointMD.returnType; }

		// Create Original Method Proxy Signature
		if( fncMD.access eq "public" ){
			udfOut.append( '<cfset this["#arguments.jointpoint#"] = variables["#arguments.jointpoint#"]>#lb#' );
		}
		var thisFNC = '
		<:cffunction name="#arguments.jointpoint#" access="#fncMD.access#" output="#fncMD.output#" returntype="#fncMD.returntype#" hint="WireBox AOP just rulez!">
			<cfscript>
				// create new method invocation for this execution
				var invocation = createObject("component","coldbox.system.aop.MethodInvocation").init(
					method 			= "#arguments.jointPoint#",
					args 			= arguments,
					methodMetadata 	= "#mdJSON#",
					target 			= this,
					targetName 		= "#mappingName#",
					targetMapping 	= this.$wbAOPTargetMapping,
					interceptors 	= this.$wbAOPTargets["#arguments.jointPoint#"].interceptors
				);
				// execute and return
				return invocation.proceed();
			</cfscript>
		<:/cffunction>
		';
		// Do : replacement, due to inline compilation avoidances
		thisFNC = replace( thisFNC, "<:", "<", "all" );
		udfOut.append( thisFNC );

		try{
			// Write it out to the generation space
			variables.mixerUtil.writeAspect( expandedFile, udfOUt.toString() );
			// Save jointpoint in method targets alongside the interceptors
			arguments.target.$wbAOPStoreJointPoint( arguments.jointpoint, buildInterceptors( arguments.aspects) );
			// Remove the old method to proxy it
			arguments.target.$wbAOPRemove( arguments.jointpoint );
			// Mix In generated aspect
			arguments.target.$wbAOPInclude( tmpFile );
			// Remove Temp Aspect from disk
			variables.mixerUtil.removeAspect( expandedFile );
			// debug info
			if( variables.log.canDebug() ){
				variables.log.debug( "Target (#mappingName#) weaved with new (#arguments.jointpoint#) method and with the following aspects: #arguments.aspects.toString()#" );
			}
		} catch(Any e){
			// Remove Stub, just in case.
			variables.mixerUtil.removeAspect( expandedFile );
			// log it
			if( variables.log.canError() ){
				variables.log.error("Exception mixing in AOP aspect for (#mappingName#): #e.message# #e.detail#", e);
			}
			// throw the exception
			throw(
				message = "Exception mixing in AOP aspect for (#mappingName#)",
				detail  = e.message & e.detail & e.stacktrace,
				type 	= "WireBox.aop.Mixer.MixinException"
			);
		}
	}

    /**
	* Build out interceptors according to their aspect names
	* @aspects The aspects to construct
	*
	*/
	private array function buildInterceptors( required aspects ){
		var interceptors = [];

		// Get aspects from injector and add to our interceptor array
		for( var x=1; x lte arrayLen( arguments.aspects ); x++){
			arrayAppend( interceptors, variables.injector.getInstance( arguments.aspects[ x ] ) );
		}

		return interceptors;
	}

	/**
	* Decorate a target with AOP capabilities
	* @target The incoming target
	* @mapping The incoming target mapping
	*
	*/
	private function decorateAOPTarget( required target, required mapping ){
		// Create targets struct for method proxing
		arguments.target.$wbAOPTargets 			= {};
		// Mix in the include command
		arguments.target.$wbAOPInclude 			= variables.mixerUtil.$wbAOPInclude;
		// Mix in the remove command
		arguments.target.$wbAOPRemove 			= variables.mixerUtil.$wbAOPRemove;
		// Mix in store point information
		arguments.target.$wbAOPStoreJointPoint 	= variables.mixerUtil.$wbAOPStoreJointPoint;
		// Mix in method proxy execution
		arguments.target.$wbAOPInvokeProxy 		= variables.mixerUtil.$wbAOPInvokeProxy;
		// Mix in target mapping for quick references
		arguments.target.$wbAOPTargetMapping 	= arguments.mapping;
		// Log it if possible
		if( variables.log.canDebug() ){
			variables.log.debug( "AOP Decoration finalized for Mapping: #arguments.mapping.getName()#" );
		}
	}

}