/**********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

@Author Luis Majano
@Description A cool annotation based Transaction Builder for model objects and handlers.
	This interceptor will inspect objects for the 'transactional' annotation and if found,
	it will wrap it in a transaction safe hibernate transaction.
	
Properties:
- generationPath : A CF include path where stubs will be generated. This will be then
			       expanded and used for includes.  You can use virtual RAM file system or not.
- metadataCacheReload : A boolean flag that auto-reloads the cached md on CFCs that are inspected for transaction annotations.
**/
component extends="coldbox.system.Interceptor"{

	void function configure(){
		var tempDir =  "/coldbox/system/testing/stubs";
		
		instance.system 	= createObject("java", "java.lang.System");
		instance.uuid 		= createobject("java", "java.util.UUID");
		instance.mdCache 	= {};
		
		// Check if gen path set?
		if( NOT propertyExists("generationPath") ){
			setProperty("generationPath", tempDir);
		}
		// Cleanup of paths.
		if( right(getProperty("generationPath"),1) neq "/" ){
			setProperty("generationPath", getProperty("generationPath") & "/");
		}
		// Setup Expanded generation path
		instance.expandedGenerationPath = expandPath(getProperty("generationPath"));
		// MD Cache Reload
		if( NOT propertyExists("metadataCacheReload") ){
			setProperty("metadataCacheReload",false);
		}
	}
	
	void function afterHandlerCreation(event,interceptData){
		adviseBuilder(arguments.interceptData.oHandler);
	}
	
	void function afterInstanceCreation(event,interceptData){
		adviseBuilder(arguments.interceptData.target);
	}

	////////////////////////////////////// AOP METHODS //////////////////////////////////////////////
	
	/**
	* Build the advise based on the pointcuts found via annotations
	* @target THe target to advise on transactional jointpoints
	*/
	private void function adviseBuilder(target){
		var idCode 	= instance.system.identityHashCode(arguments.target);
			
		// MD Cache Reload
		if( getProperty("metadataCacheReload") ){
			instance.mdCache = {};
		}
		
		// Check if target inspected already
		if ( NOT structKeyExists(instance.mdCache, idCode) ){
			// lock it for AOP inspection and weaving
			lock type="exclusive" name="TransactionAspect.AOPBuilder.#idCode#" timeout="20" throwontimeout="true"{
				if( NOT structKeyExists(instance.mdCache, idCode) ){
					// Discovery process
					discoverMetadata(arguments.target, getMetadata(arguments.target));
					// Save processing done
					instance.mdCache[idCode] = true;
				} 
			}
		}
		else if( log.canDebug() ){
			log.debug("Target (#getMetadata(arguments.target).name#) inspected already, skipping it");
		}
	}
	
	/**
	* Discover the transactional metadata on the target
	* @target The target object to inspect
	* @metadata The metadata to inspect
	* @discoveredFunctions the recursive struct of discovered functions
	*/
	private void function discoverMetadata(target, metadata, discoveredFunctions=structnew()){
		// check if there are functions, else exit
		if( NOT structKeyExists(arguments.metadata,"functions") ){
			return;
		}
		// Get Function info
		var functions	= arguments.metadata.functions;
		var fncLen 		= arrayLen(functions);
		
		for(var x=1; x lte fncLen; x++){
			//Check annotation and discovered struct
			if( structKeyExists(functions[x],"transactional") AND NOT structKeyExists(arguments.discoveredFunctions, functions[x].name) ){
				// decorate target with AOP capabilities, if not already
				decorateAOPTarget(arguments.target);
				// Build the the AOP advisor with the function pointcut
				weaveAdvise(arguments.target, functions[x].name, functions[x]);
				// Mark it processed for recursion processing
				arguments.discoveredFunctions[ functions[x].name ] = true;
			}
		}
		
		// Discover inheritance? Recursion
		if( structKeyExists(arguments.metadata,"extends") ){
			discoverMetadata(arguments.target, arguments.metadata.extends, arguments.discoveredFunctions);
		}
	}
	
	/**
	* Weave an advise on a pointcut jointpoint
	* @target The target to weave on
	* @jointpoint The jointpoint to advise
	* @jointpointMD The metadata information about the jointpoint
	*/
	private void function weaveAdvise(target, jointpoint, jointpointMD){
		var udfOut 		= createObject("java","java.lang.StringBuffer").init('');
		var genPath 	= instance.expandedGenerationPath;
		var tmpFile 	= instance.uuid.randomUUID().toString() & ".cfm";
		var lb			= "#chr(13)##chr(10)#";
		var fncMD 		= arguments.jointpointMD;
		
		// Check if the target jointpoint has not been processed already
		if( NOT structKeyExists(arguments.target.$aop_targets, arguments.jointpoint) ){
			// MD Defaults
			if( NOT structKeyExists(fncMD,"access") ){ fncMD.access = "public"; }
			if( NOT structKeyExists(fncMD,"output") ){ fncMD.output = false; }
			if( NOT structKeyExists(fncMD,"returntype") ){ fncMD.returntype = "any"; }
			
			// Create Method Signature
			if( fncMD.access eq "public" ){
				udfOut.append('<cfset this["#arguments.jointpoint#"] = #arguments.jointpoint#>#lb#');
			}
			udfOut.append('
			<cfset variables["#arguments.jointpoint#"] = #arguments.jointpoint#>
			<cffunction name="#arguments.jointpoint#" access="#fncMD.access#" output="#fncMD.output#" returntype="#fncMD.returntype#" hint="ColdBox AOP just rulez!">
			
			<cfreturn this.$aop_transaction("#arguments.jointpoint#",arguments)>
			
			</cffunction>
			');
			
			// Write it out to generation space
			writeAspect(genPath & tmpFile, udfOUt.toString());
		
			try{
				// Remove and Save jointpoint in method lookup
				arguments.target.$aop_targets[arguments.jointpoint] = arguments.target[arguments.jointpoint];
				// Remove the old method
				arguments.target.$aop_remove(arguments.jointpoint);
				// Mix In Aspect weaved already
				arguments.target.$aop_include(getProperty("generationPath") & tmpFile);
				// Remove Temp Aspect from disk
				removeAspect(genPath & tmpFile);	
				// debug info
				if( log.canDebug() ){
					log.debug("Target (#getMetadata(arguments.target).name#) weaved with new (#arguments.jointpoint#) method.");
				}			
			}
			catch(Any e){
				// Remove Stub, just in case.
				removeAspect(genPath & tmpFile);
				// log it
				log.error("Exception mixing in AOP aspect: #e.message# #e.detail#", e);
				// throw the exception
				$throw("Exception mixing in AOP aspect",e.message & e.detail & e.stacktrace,"TransactionAspect.MixinException");
			}	
		}		
	}
	
	/**
	* Decorate an AOP target with the basics of AOP decoration
	* @target The target to decorate with AOP capabilities
	*/
	private void function decorateAOPTarget(target){
		// check if target already enabled for AOP methods
		if( NOT structKeyExists(arguments.target,"$aop_enabled") ){
			// Create targets struct for method lookups
			arguments.target.$aop_targets = {};
			// Mix in the include pointer
			arguments.target.$aop_include = variables.$aop_include;
			// Mix in the remove command
			arguments.target.$aop_remove = variables.$aop_remove;
			// Mix in the transaction invoker
			arguments.target.$aop_transaction = variables.$aop_transaction;
			// Finalize decorations
			arguments.target.$aop_enabled = true;
			// Log it if possible
			if( log.canDebug() ){
				log.debug("Target AOP decorated: #getMetaData(arguments.target).name#.");
			}
		}
	}

	////////////////////////////////////////// AOP INJECTED METHODS /////////////////////////////////////////////
	
	/**
	* The AOP transactioned invoker via hibernate
	* @jointpoint The jointpoint to execute
	* @jpArguments The arguments passed to the jointpoint
	*/
	private void function $aop_transaction(jointpoint, jpArguments){
		var tx 			= ORMGetSession().beginTransaction();
		var udfPointer	= this.$aop_targets[arguments.jointpoint];
		
		// Are we already in a transaction?
		if( structKeyExists(request,"cbox_aop_transaction") ){
			// debug?
			if( log.canDebug() ){ log.debug("Call to #arguments.jointpoint# already transactioned, just executing it"); }
			// Just execute and return;
			return udfPointer(argumentCollection=arguments.jpArguments);
		}
		
		// Else, transaction safe call
		try{
			// debug?
			if( log.canDebug() ){ log.debug("Call to #arguments.jointpoint# is now transaction and begins execution"); }
			// mark transaction began
			request["cbox_aop_transaction"] = true;
			// Call method
			results = udfPointer(argumentCollection=arguments.jpArguments);
			// commit transaction
			tx.commit();
		}
		catch(Any e){
			// remove pointer
			structDelete(request,"cbox_aop_transaction");
			// Log Error
			log.error("An exception ocurred in the AOPed transaction: #e.message# #e.detail#",e);
			// rollback
			if(tx.wasCommitted()){ tx.rollback(); }
			//throw it
			throw(e);
		}		
		// remove pointer, out of transaction now.
		structDelete(request,"cbox_aop_transaction");
		// Results? If found, return them.
		if( NOT isNull(results) ){ return results; }
	}
	
	/**
	* Mix in a template on an injected target
	*/
	private void function $aop_include(templatePath){
		include arguments.templatePath;
	}
	
	/**
	* Remove a method on an injected target
	*/
	private void function $aop_remove(methodName){
		structDelete(this,arguments.methodName);
		structDelete(variables,arguments.methodName);
	}
		
	////////////////////////////////////////// AOP UTILITY METHODS /////////////////////////////////////////////
	
	private void function writeAspect(genPath, code){
		fileWrite(arguments.genPath, arguments.code);
	}
	
	private void function removeAspect(filePath){
		if( fileExists(arguments.filePath) ){
			fileDelete( arguments.filePath );
		}
	}
	
}