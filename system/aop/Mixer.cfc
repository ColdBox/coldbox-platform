{
/*-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I am a WireBox listener that provides you with AOP capabilities in your
	objects.

	Listener Properties:
	- generationPath:path	- The include path used for code generation
	- dictionaryReload:boolean(false) - The flag to always reload aspect dictionary discover information, great for development

-----------------------------------------------------------------------*/
component 
	hint = "I am a WireBox listener that provides you with AOP capabilities in your objects"
	output = false
{
	/*
	* @hint	Constructor
	* @output false
	* 
	* @injector.hint	The injector I am linked to
	* @properties.hint	AOP listener properties
	*/
	public any function configure(
		required any injector,
		required any properties
	){
		// instance data
		instance = {
			// injector reference
			injector 	= arguments.injector,
			// Binder Reference
			binder		= arguments.injector.getBinder(),
			// local logger
			log 		= arguments.injector.getLogBox().getLogger( this ),
			// listener properties
			properties 	= arguments.properties,
			// class matcher dictionary
			classMatchDictionary = createObject("java","java.util.concurrent.ConcurrentHashMap").init(),
			// system
			system 	= createObject("java", "java.lang.System"),
			// uuid helper
			uuid 	= createobject("java", "java.util.UUID"),
			// mixer util
			mixerUtil = createObject("component","coldbox.system.aop.MixerUtil").init()
		};

		// class id code
		instance.classID = instance.system.identityHashCode( this );

		// Default Generation Path?
		if( NOT structKeyExists(instance.properties,"generationPath") ){
			instance.properties.generationPath = "/coldbox/system/aop/tmp";
		}

		// Class Dictionary Reload
		if( NOT structKeyExists(instance.properties,"classMatchReload") ){
			instance.properties.classMatchReload = false;
		}

		return this;
	} // configure()

	/*
	* @hint		Get the class matcher dictionary
	* @output	false
	*/
	public any function getClassMatchDictionary(){
		return instance.classMatchDictionary;
	} // getClassMatchDictionary()

	/*
	* @hint		Executes our AOP mixer after instances are created and autowired
	* @output	false
	*/
	public any function afterInstanceAutowire( interceptData ){
		var mapping 		= arguments.interceptData.mapping;
		var target 			= arguments.interceptData.target;
		var mappingName 	= "";
		var idCode			= "";

		// check if target already mixed, if so just return, nothing else to do or if the  mapping is an aspect
		if( structKeyExists( target, "$wbAOPMixed" ) OR mapping.isAspect() ){ return; }

		// Setup variables
		mappingName = lcase( mapping.getName() );
		idCode		= instance.system.identityHashCode( target );

		// Check if incoming mapping name is already class matched?
		if( NOT structKeyExists( instance.classMatchDictionary, mappingName ) ){
			// Register this incoming mapping for class aspect matching
			buildClassMatchDictionary( target, mapping, idCode );
		}

		// Now, we check if we have any aspects to apply to this class according to class matchers
		if( arrayLen( instance.classMatchDictionary[mappingName] ) ){
			AOPBuilder( target=target, mapping=mapping, dictionary=instance.classMatchDictionary[ mappingName ], idCode=idCode);
		}
	} // afterInstanceAutowire()

	/*------------------------------------------- PRIVATE ------------------------------------------*/

	/*
	* @hint		Build an aspect dictionary for incoming target objects
	* @output	false
	*
	* target.hint	The incoming target
	* mapping.hint	The incoming target mapping
	* idCode.hint	The incoming target identifier
	*/
	private any function buildClassMatchDictionary(
		required any target,
		required any mapping,
		required any idCode
	){
		var aspectBindings 	= instance.binder.getAspectBindings();
		var bindingsLen 	= arrayLen( aspectBindings );
		var mappingName		= lcase( arguments.mapping.getName() );
		var x			 	= 1;
		var matchedAspects	= [];

    	lock
    		name           = "aop.#instance.classID#.classMatchDictionary.for.#arguments.idCode#"
    		type           = "exclusive"
    		timeout        = "30"
    		throwOnTimeout = true
    	{
			// check again, double lock
			if( NOT structKeyExists( instance.classMatchDictionary, mappingName ) ){

				// Discover matching for the class via all aspect bindings
				for( x=1; x LTE bindingsLen; x++){

					// class match? If so, add to dictionary of matched aspects
					if( aspectBindings[x].classes.matchClass( arguments.target, arguments.mapping )){
						arrayAppend( matchedAspects, aspectBindings[x] );
					}
				}// end for discovery

				if( instance.log.canDebug() ){ instance.log.debug( "Aspect class matching dictionary built for mapping: #mappingName#, aspects: #matchedAspects.toString()#"); }

				// Store matched dictionary
				instance.classMatchDictionary[ mappingName ] = matchedAspects;

			} // end if in dictionary
		} // lock
	} // buildClassMatchDictionary()

	/*
	* @hint		Build and weave all necessary advices on an object via method matching
	* @output	false
	*
	* target.hint		The incoming target
	* mapping.hint		The incoming target mapping
	* dictionary.hint	The target aspect dictionary
	* idCode.hint		The incoming target identifier
	*/
	private any function AOPBuilder(
		required any target,
		required any mapping,
		required any dictionary,
		required any idCode
	){
		lock
			name           = "aop.#instance.classID#.weaveAdvice.id.#arguments.idCode#"
			type           = "exclusive"
			timeout        = "30"
			throwOnTimeout = true
		{
			// check if weaved already
			if( structKeyExists( arguments.target, "$wbAOPMixed" ) ){ return; }
			// decorate target with AOP capabilities
			decorateAOPTarget( arguments.target,arguments.mapping );
			// Process methods via metadata and apply aspects if they match
			processTargetMethods( target=arguments.target, mapping=arguments.mapping, metadata=arguments.mapping.getObjectMetadata(), dictionary=arguments.dictionary );
			// finalize AOP
			arguments.target.$wbAOPMixed = true;
		} // lock
	} // AOPBuilder()

	/*
	* @hint		Process target methods for AOP weaving
	* @output	false
	*
	* target.hint		The incoming target
	* mapping.hint		The incoming target mapping
	* metadata.hint		The incoming target identifier
	* dictionary.hint	The target aspect dictionary
	*/
	private any function processTargetMethods(
		required any target,
		required any mapping,
		required any metadata,
		required any dictionary
	){
		var functions 				= "";
		var fncLen					= "";
		var x						= 1;
		var y						= 1;
		var matchedMethodAspects 	= "";

		// check if there are functions, else exit
		if( NOT structKeyExists(arguments.metadata,"functions") ){ return; }

		// Get Function info
		functions	= arguments.metadata.functions;
		fncLen 		= arrayLen( functions );

		for( x=1; x LTE fncLen; x++){
			// check if function already proxied, if so, skip it
			if( structKeyExists( arguments.target.$wbAOPTargets, functions[x].name ) ){ continue; }

			// init matched aspects to weave
			matchedMethodAspects = [];

			// function not proxied yet, let's iterate over aspects and see if we can match
			for( y=1; y LTE arrayLen( arguments.dictionary ); y++){
				// does the jointpoint match against aspect methods
				if( arguments.dictionary[y].methods.matchMethod( functions[x] ) ){
					matchedMethodAspects.addAll( arguments.dictionary[y].aspects );
					// Debug Info
					if ( instance.log.canDebug() ){
						instance.log.debug( "Target: (#arguments.mapping.getName()#) Method:(#functions[x].name#) matches aspects #arguments.dictionary[y].aspects.toString()#");
					}
				}
			} // for y

			// Build the the AOP advisor with the function pointcut and matched aspects?
			if( arrayLen( matchedMethodAspects ) ){
				weaveAdvice( target=arguments.target, mapping=arguments.mapping, jointpoint=functions[x].name, jointPointMD=functions[x], aspects=matchedMethodAspects );
			}

		} // for x

		// Discover inheritance? Recursion
		if( structKeyExists(arguments.metadata,"extends") ){
			processTargetMethods(arguments.target, arguments.mapping, arguments.metadata.extends, arguments.dictionary);
		}
	} //processTargetMethods()

	/*
	* @hint		Weave an advise into a jointpoint
	* @output	false
	*
	* target.hint		The incoming target
	* mapping.hint		The incoming target mapping
	* jointPoint.hint	The jointpoint to proxy
	* jointPointMD.hint	The jointpoint metadata to proxy
	* aspects.hint		The aspects to weave into the jointpoint
	*/
	private any function weaveAdvice(
		required any target,
		required any mapping,
		required any jointPoint,
		required any jointPointMD,
		required any aspects
	){
		var udfOut 			= createObject("java","java.lang.StringBuffer").init('');
		var tmpFile 		= instance.properties.generationPath & "/" & instance.uuid.randomUUID().toString() & ".cfm";
		var expandedFile 	= expandPath( tmpFile );
		var lb				= "#chr(13)##chr(10)#";
		var fncMD			= {
			name       = "",
			access     = "public",
			output     = "false",
			returnType = "any"
		};
		var mappingName 	= arguments.mapping.getName();
		var mdJSON			= urlEncodedFormat( serializeJSON( arguments.jointPointMD ) );

		// MD proxy Defaults
		fncMD.name = arguments.jointPointMD.name;
		if( structKeyExists(arguments.jointPointMD,"access") ){ fncMD.access = arguments.jointPointMD.access; }
		if( structKeyExists(arguments.jointPointMD,"output") ){ fncMD.output = arguments.jointPointMD.output; }
		if( structKeyExists(arguments.jointPointMD,"returntype") ){ fncMD.returntype = arguments.jointPointMD.returnType; }

		// Create Original Method Proxy Signature
		if( fncMD.access eq "public" ){
			udfOut.append('<cfset this["#arguments.jointpoint#"] = variables["#arguments.jointpoint#"]>#lb#');
		}
		udfOut.append('
		<cffunction name="#arguments.jointpoint#" access="#fncMD.access#" output="#fncMD.output#" returntype="#fncMD.returntype#" hint="WireBox AOP just rulez!">
			<cfscript>
				// create new method invocation for this execution
				var invocation = createObject("component","coldbox.system.aop.MethodInvocation").init(
					method         = "#arguments.jointPoint#",
					args           = arguments,
					methodMetadata = "#mdJSON#",
					target         = this,
					targetName     = "#mappingName#",
					targetMapping  = this.$wbAOPTargetMapping,
					interceptors   = this.$wbAOPTargets["#arguments.jointPoint#"].interceptors);
				// execute and return
				return invocation.proceed();
			</cfscript>
		</cffunction>
		');

		try{
			// Write it out to the generation space
			instance.mixerUtil.writeAspect( expandedFile, udfOUt.toString() );
			// Save jointpoint in method targets alongside the interceptors
			arguments.target.$wbAOPStoreJointPoint(arguments.jointpoint, buildInterceptors( arguments.aspects) );
			// Remove the old method to proxy it
			arguments.target.$wbAOPRemove(arguments.jointpoint);
			// Mix In generated aspect
			arguments.target.$wbAOPInclude( tmpFile );
			// Remove Temp Aspect from disk
			instance.mixerUtil.removeAspect( expandedFile );
			// debug info
			if( instance.log.canDebug() ){
				instance.log.debug("Target (#mappingName#) weaved with new (#arguments.jointpoint#) method and with the following aspects: #arguments.aspects.toString()#");
			}
		}
		catch( Any var e ) {
			// Remove Stub, just in case.
			instance.mixerUtil.removeAspect( expandedFile );
			// log it
			if( instance.log.canError() ){
				instance.log.error("Exception mixing in AOP aspect for (#mappingName#): #e.message# #e.detail#", e);
			}
			// throw the exception
			throw("Exception mixing in AOP aspect for (#mappingName#)",e.message & e.detail & e.stacktrace,"WireBox.aop.Mixer.MixinException");
		}
	} // weaveAdvice()

	/*
	* @hint		Build out interceptors according to their aspect names
	* @output	false
	*
	* aspects.hint		The aspects array to construct
	*/
	private any function buildInterceptors( required any aspects ){
		var x 				= 1;
		var interceptors 	= [];

		// Get aspects from injector and add to our interceptor array
		for( x=1; x lte arrayLen( arguments.aspects ); x++ ){
			arrayAppend( interceptors, instance.injector.getInstance( arguments.aspects[x] ) );
		}

		return interceptors;
	} // buildInterceptors()

	/*
	* @hint		Decorate a target with AOP capabilities
	* @output	false
	*
	* target.hint	The incoming target
	* mapping.hint	The incoming target mapping
	*/
	private any function decorateAOPTarget(
		required any target,
		required any mapping
	){
		// Create targets struct for method proxing
		arguments.target.$wbAOPTargets = {};
		// Mix in the include command
		arguments.target.$wbAOPInclude = instance.mixerUtil.$wbAOPInclude;
		// Mix in the remove command
		arguments.target.$wbAOPRemove = instance.mixerUtil.$wbAOPRemove;
		// Mix in store point information
		arguments.target.$wbAOPStoreJointPoint = instance.mixerUtil.$wbAOPStoreJointPoint;
		// Mix in method proxy execution
		arguments.target.$wbAOPInvokeProxy = instance.mixerUtil.$wbAOPInvokeProxy;
		// Mix in target mapping for quick references
		arguments.target.$wbAOPTargetMapping = arguments.mapping;
		// Log it if possible
		if( instance.log.canDebug() ){ instance.log.debug( "AOP Decoration finalized for Mapping: #arguments.mapping.getName()#" ); }
	} // decorateAOPTarget()
}