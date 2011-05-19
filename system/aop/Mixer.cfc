<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I am a WireBox listener that provides you with AOP capabilities in your
	objects.
	
	Decoration
	$wbAOPMixed:boolean(false) 	- If an object is already mixed with AOP capabilities
	$wbAOPMethods:struct		- A collection of proxied structures and their related interceptors 
----------------------------------------------------------------------->
<cfcomponent output="false" hint="I am a WireBox listener that provides you with AOP capabilities in your objects">
	
<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- configure --->    
    <cffunction name="configure" output="false" access="public" returntype="any" hint="Constructor">    
    	<cfargument name="injector" 	type="any" required="true" hint="The injector I am linked to"/>
    	<cfargument name="properties"	type="any" required="true" hint="Listener properties">
    	<cfscript>
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
				// aspect dictionary
				aspectDictionary = createObject("java","java.util.concurrent.ConcurrentHashMap").init(),
				// system
				system 	= createObject("java", "java.lang.System"),
				// uuid helper
				uuid 	= createobject("java", "java.util.UUID")
		
			};
			
			// Default Generation Path?
			if( NOT structKeyExists(instance.properties,"generationPath") ){
				instance.properties.generationPath = expandPath("/coldbox/system/ioc/aop/tmp");
			}
			
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- afterInstanceCreation --->    
    <cffunction name="afterInstanceCreation" output="false" access="public" returntype="any">    
    	<cfargument name="interceptData">
		<cfscript>
			var mapping 		= arguments.interceptData.mapping;
			var target 			= arguments.interceptData.target;
			var mappingName 	= lcase(mapping.getName());
			var idCode			= instance.system.identityHashCode( target );
			
			// check if target already mixed, if so just return;
			if( structKeyExists(target,"$wbAOPMixed") ){ return; }
			
			// Check if mapping is in aspect dictionary
			if( NOT structKeyExists(instance.aspectDictionary, mappingName ) ){
				// check the target and register the matching information
				buildAspectDictionary( target, mapping, idCode );
			}
			
			// If the class matches for AOP according to aspect dictionary, lets AOPfy it! Else ignore
			if( structCount( instance.aspectDictionary[mappingName] ) ){
				AOPBuilder(target=target, mapping=mapping, dictionary=instance.aspectDictionary[mappingName], idCode=idCode);
			}			
		</cfscript>	
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- buildAspectDictionary --->    
    <cffunction name="buildAspectDictionary" output="false" access="private" returntype="any" hint="Build an aspect dictionary for incoming target objects">    
    	<cfargument name="target" 	type="any" required="true" hint="The incoming target"/>
    	<cfargument name="mapping" 	type="any" required="true" hint="The incoming target mapping"/>
    	<cfargument name="idCode" 	type="any" required="true" hint="The incoming target identifier"/>
    	
    	<cfset var aspectBindings 	= instance.binder.getAspectBindings()>
		<cfset var bindingsLen 		= arrayLen(aspectBindings)>
		<cfset var x			 	= 1>
    	
    	<!--- Lock --->
    	<cflock name="aop.aspectDictionary.id.#arguments.idCode#" type="exclusive" timeout="30" throwontimeout="true">
		<cfscript>
			// check again, double lock
			if( NOT structKeyExists(instance.aspectDictionary, lcase(arguments.mapping.getName()) ) ){
				// Discover matching for the class via all aspect bindings
				for(x=1; x lte bindingsLen; x++){
				
					
				}// end for aspects			
			} // end if in dictioanry	
		</cfscript>
		</cflock> 
    	   
    </cffunction>

	<!--- AOPBuilder --->    
    <cffunction name="AOPBuilder" output="false" access="private" returntype="any" hint="Build and weave all necessary advices on an object">    
    	<cfargument name="target" 		type="any" required="true" hint="The incoming target"/>
    	<cfargument name="mapping" 		type="any" required="true" hint="The incoming target mapping"/>
    	<cfargument name="dictionary" 	type="any" required="true" hint="The target aspect dictionary"/>
    	<cfargument name="idCode" 		type="any" required="true" hint="The incoming target identifier"/>
    	
    	<cfset var key  = "">
    	
    	<!--- Lock --->
    	<cflock name="aop.weaveAdvice.id.#arguments.idCode#" type="exclusive" timeout="30" throwOnTimeout="true">
		<cfscript>
			// check if weaved already
			if( structKeyExists(arguments.target,"$wbAOPMixed") ){ return; }		
			
			// decorate target with AOP capabilities
			decorateAOPTarget(arguments.target,arguments.mapping);
			
			// iterate through dictionary and weave in the advices into the pointcuts
			for(key in arguments.dictionary){
				// Build the the AOP advisor with the function pointcut
				weaveAdvise(target=arguments.target, mapping=arguments.mapping, jointPoint=key, aspects=arguments.dictionary[key]);
			}	
			
			// finalize AOP
			arguments.target.$wbAOPMixed = true;
			if( instance.log.canDebug() ){
				instance.log.debug("AOP weaving finalized for: #arguments.mapping.getName()#");
			}	
		</cfscript>
		</cflock> 
    	  
    </cffunction>
    
    <!--- weaveAdvise --->    
    <cffunction name="weaveAdvise" output="false" access="private" returntype="any" hint="Weave an advise into a jointpoint">    
    	<cfargument name="target" 		type="any" required="true" hint="The incoming target"/>
    	<cfargument name="mapping" 		type="any" required="true" hint="The incoming target mapping"/>
    	<cfargument name="jointPoint" 	type="any" required="true" hint="The jointpoint to proxy"/>
		<cfargument name="aspects" 		type="any" required="true" hint="The aspects to weave into the jointpoint"/>
    	<cfscript>
			var udfOut 		= createObject("java","java.lang.StringBuffer").init('');
			var tmpFile 	= instance.properties.generationPath & instance.uuid.randomUUID().toString() & ".cfm";
			var lb			= "#chr(13)##chr(10)#";
			var fncMD		= "";
			
			// Check if the target jointpoint has not been processed already
			if( NOT structKeyExists(arguments.target.$wbAOPTargets, arguments.jointpoint) ){
				
				// Get function metadata to generate it exactly as it was proxied
				fncMD =	arguments.target.$wbAOPGetJointPointMD( arguments.jointPoint );
				
				// MD proxy Defaults
				if( NOT structKeyExists(fncMD,"access") ){ fncMD.access = "public"; }
				if( NOT structKeyExists(fncMD,"output") ){ fncMD.output = false; }
				if( NOT structKeyExists(fncMD,"returntype") ){ fncMD.returntype = "any"; }
				
				// Create Original Method Proxy Signature
				if( fncMD.access eq "public" ){
					udfOut.append('<cfset this["#arguments.jointpoint#"] = #arguments.jointpoint#>#lb#');
				}
				udfOut.append('
				<cfset variables["#arguments.jointpoint#"] = #arguments.jointpoint#>
				<cffunction name="#arguments.jointpoint#" access="#fncMD.access#" output="#fncMD.output#" returntype="#fncMD.returntype#" hint="WireBox AOP just rulez!">
					<cfscript>
						// create new method invocation for this execution
						var invocation = createObject("component","coldbox.system.aop.MethodInvocation").init(method="#arguments.jointPoint#",
																											 args=arguments,
																											 target=this,
																											 interceptors=this.$wbAOPTargets["#arguments.jointPoint#"].interceptors);	
						// execute and return
						return invocation.proceed();
					</cfscript>					
				</cffunction>
				');
				
				try{
					// Write it out to the generation space
					writeAspect(tmpFile, udfOUt.toString());
					// Save jointpoint in method targets alongside the interceptors
					arguments.target.$wbAOPTargets[arguments.jointpoint] = {
						udfPointer 	 = arguments.target[arguments.jointpoint],
						interceptors = buildInterceptors( arguments.aspects )
					};
					// Remove the old method to proxy it
					arguments.target.$wbAOPRemove(arguments.jointpoint);
					// Mix In generated aspect
					arguments.target.$wbAOPInclude( tmpFile );
					// Remove Temp Aspect from disk
					removeAspect(tmpFile);	
					// debug info
					if( instance.log.canDebug() ){
						instance.log.debug("Target (#arguments.mapping.getName()#) weaved with new (#arguments.jointpoint#) method and with the following aspects: #arguments.aspects.toString()#");
					}			
				}
				catch(Any e){
					// Remove Stub, just in case.
					removeAspect( tmpFile );
					// log it
					if( instance.log.canError() ){
						instance.log.error("Exception mixing in AOP aspect for (#arguments.mapping.getName()#): #e.message# #e.detail#", e);
					}
					// throw the exception
					throwIt("Exception mixing in AOP aspect for (#arguments.mapping.getName()#)",e.message & e.detail & e.stacktrace,"WireBox.aop.Mixer.MixinException");
				}	
			}			
    	</cfscript>    
    </cffunction>
    
    <!--- buildInterceptors --->    
    <cffunction name="buildInterceptors" output="false" access="private" returntype="any" hint="Build out interceptors according to their aspect names">    
    	<cfargument name="aspects" 	type="any" required="true" hint="The aspects array to construct"/>
    	<cfscript>
			var x 				= 1;
			var interceptors 	= [];
			
			// Get aspects from injector and add to our interceptor array
			for(x=1; x lte arrayLen(arguments.aspects); x++){
				arrayAppend( interceptors, instance.injector.getInstance( arguments.aspects[x] ) );
			}
			
			return interceptors;		    
    	</cfscript>    
    </cffunction>
    
    <!--- decorateAOPTarget --->    
    <cffunction name="decorateAOPTarget" output="false" access="private" returntype="any" hint="Decorate a target with AOP capabilities">    
    	<cfargument name="target" 		type="any" required="true" hint="The incoming target"/>
    	<cfargument name="mapping" 		type="any" required="true" hint="The incoming target mapping"/>
    	<cfscript>
			// Create targets struct for method proxing
			arguments.target.$wbAOPTargets = {};
			// Mix in the include command
			arguments.target.$wbAOPInclude = variables.$wbAOPInclude;
			// Mix in the remove command
			arguments.target.$wbAOPRemove = variables.$wbAOPRemove;
			// Mix in the MD retriever
			arguments.target.$wbAOPGetJointPointMD = variables.$wbAOPGetJointPointMD;
			// Mix in new log object for AOP information and debugging
			arguments.target.$wbAOPLog = instance.injector.getLogBox().getLogger(arguments.target);
			// Log it if possible
			if( instance.log.canDebug() ){
				instance.log.debug("Target AOP decorated: #arguments.mapping.getName()#");
			}		    
    	</cfscript>    
    </cffunction>    
    
<!------------------------------------------- AOP UTILITY MIXINS ------------------------------------------>
    
    <!--- $wbAOPInclude --->    
    <cffunction name="$wbAOPInclude" output="false" access="private" returntype="any" hint="Mix in a template on an injected target">    
    	<cfargument name="templatePath" type="any" required="true" hint="The template to mix in"/>
    	<cfinclude template="#arguments.templatePath#" >   
    </cffunction>
    
    <!--- $wbAOPRemove --->    
    <cffunction name="$wbAOPRemove" output="false" access="private" returntype="any" hint="Remove a method from this target mixin">    
    	<cfargument name="methodName" type="any" required="true" hint="The method to poof away!"/>
    	<cfscript>
			structDelete(this,arguments.methodName);
			structDelete(variables,arguments.methodName);    
    	</cfscript>    
    </cffunction>
    
    <!--- $wbAOPGetJointPointMD --->    
    <cffunction name="$wbAOPGetJointPointMD" output="false" access="private" returntype="any" hint="Get a jointpoint's metadata for proxying">    
    	<cfargument name="methodName" type="any" required="true" hint="The method to target!"/>
    	<cfscript>
			return getMetadata(variables[arguments.methodName]);    
    	</cfscript>    
    </cffunction>
    
<!------------------------------------------- AOP Utility Methods ------------------------------------------>
	
	<!--- throw it --->
	<cffunction name="throwit" access="private" hint="Facade for cfthrow" output="false">
		<cfargument name="message" 	required="true">
		<cfargument name="detail" 	required="false" default="">
		<cfargument name="type"  	required="false" default="Framework">
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
	<!--- writeAspect --->    
    <cffunction name="writeAspect" output="false" access="private" returntype="any" hint="Write an aspect to disk">    
    	<cfargument name="genPath"	required="True">
		<cfargument name="code"		required="True">
    	<cfscript>	    
			fileWrite(arguments.genPath, arguments.code);
    	</cfscript>    
    </cffunction>
	
	<!--- writeAspect --->    
    <cffunction name="removeAspect" output="false" access="private" returntype="any" hint="Remove an aspect from disk">    
    	<cfargument name="filePath"	required="True">
		<cfscript>	    
			if( fileExists(arguments.filePath) ){
				fileDelete( arguments.filePath );
			}
    	</cfscript>    
	</cffunction>

</cfcomponent>