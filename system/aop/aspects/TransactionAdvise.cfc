<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	01/11/2010
Description :
	A cool annotation based Transaction Builder for model objects and handlers.
	
Properties:
* generationPath : A cf include path where stubs will be generated. This will be then
			       expanded and used for includes.
--->
<cfcomponent extends="coldbox.system.Interceptor" output="false" hint="A cool annotation based Transaction Advice for model objects and handlers.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- configure --->
    <cffunction name="configure" output="false" access="public" returntype="void" hint="Configure the interceptor">
	    <cfscript>
			var tempDir =  "/coldbox/system/testing/stubs";
		
			instance.system = createObject("java", "java.lang.System");
			instance.uuid = createobject("java", "java.util.UUID");
			instance.mdCache = {};
			
			// Check if gen path set?
			if( NOT propertyExists("generationPath") ){
				setProperty("generationPath", tempDir);
			}
			// Cleanup of paths.
			if( right(getProperty("generationPath"),1) neq "/" ){
				setProperty("generationPath", getProperty("generationPath") & "/");
			}
			// MD Cache Reload
			if( NOT propertyExists("metadataCacheReload") ){
				setProperty("metadataCacheReload",false);
			}
			
		</cfscript>
	 </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>
	 
	 <!--- afterHandlerCreation --->
     <cffunction name="afterHandlerCreation" output="false" access="public" returntype="void">
     	<cfargument name="event">
     	<cfargument name="interceptData">
     	<cfscript>
     		var target = arguments.interceptData.oHandler;
			adviseBuilder(target);
		</cfscript>
     </cffunction>
	 
	 <!--- afterModelCreation --->
     <cffunction name="afterModelCreation" output="false" access="public" returntype="void">
     	<cfargument name="event">
     	<cfargument name="interceptData">
     	<cfscript>
     		var target = arguments.interceptData.oModel;
			adviseBuilder(target);
		</cfscript>
     </cffunction>
	 
	 <!--- adviseBuilder --->
     <cffunction name="adviseBuilder" output="false" access="public" returntype="void" hint="build the advise based on the pointcuts found via annotations">
     	<cfargument name="target" type="any" required="true" hint="The target to advise"/>
		<cfscript>
			// loop over functions
			var functions = "";
			var fncLen = "";
			var x = 1;
			var aopFound = false;
			var idCode = instance.system.identityHashCode(arguments.target);
			
			// MD Cache Reload
			if( getProperty("metadataCacheReload") ){
				instance.mdCache = {};
			}
			
			// Check if object already inspected for AOP capabilities
			if( structKeyExists(instance.mdCache, idCode ) AND instance.mdCache[idCode] eq false ){
				if( log.canLog(log.logLevels.DEBUG) ){
					log.debug("Target (#getMetadata(arguments.target).name#) inspected already.");
				}
				return;
			}
			
			// Get Function info
			functions = getMetadata(arguments.target).functions;
			fncLen = arrayLen(functions);
			for(x=1; x lte fncLen; x++){
				//Check annotation
				if( structKeyExists(functions[x],"transactional") ){
					aopFound = true;
					// decorate target with AOP capabilities, if not already
					decorateAOPTarget(arguments.target);
					// Build the the AOP advisor with the function
					weaveAdvise(arguments.target, functions[x].name);
				}
			}
			
			// Save aopFound in cache
			instance.mdCache[idCode] = aopFound; 
		</cfscript>
     </cffunction>
	 
	 <!--- weaveAdvise --->
     <cffunction name="weaveAdvise" output="false" access="public" returntype="void" hint="Weave an advise on a jointpoint">
     	<cfargument name="target" type="any" required="true" default="" hint="The target object"/>
	 	<cfargument name="jointpoint" type="any" required="true" default="" hint="The jointpoint to weave"/>
		
		<cfset var udfOut 		= CreateObject("java","java.lang.StringBuffer").init('')>
		<cfset var genPath 		= ExpandPath(getProperty("generationPath"))>
		<cfset var tmpFile 		= instance.uuid.randomUUID().toString() & ".cfm">
		<cfset var lb			= "#chr(13)##chr(10)#">
		<cfset var fncMD 		= getMetadata(arguments.target[arguments.jointpoint])>
		
		<cfif NOT structKeyExists(arguments.target.$aop_targets,arguments.jointpoint)>
		<cflock name="TransactionAdvisor.weaveAdvise.#instance.system.identityHashCode(arguments.target)#" throwontimeout="true" timeout="30">
		<cfscript> 
			if( NOT structKeyExists(arguments.target.$aop_targets,arguments.jointpoint) ){
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
				<cffunction name="#arguments.jointpoint#" access="#fncMD.access#" output="#fncMD.output#" returntype="#fncMD.returntype#">
				
				<cfreturn this.$aop_transaction("#arguments.jointpoint#",arguments)>
				
				</cffunction>
				');
				
				// Write it out
				writeAspect(genPath & tmpFile, udfOUt.toString());
			
				try{
					// Remove and Save jointpoint in method lookup
					arguments.target.$aop_targets[arguments.jointpoint] = arguments.target[arguments.jointpoint];
					arguments.target.$aop_remove(arguments.jointpoint);
					
					// Mix In Aspect
					arguments.target.$aop_include(getProperty("generationPath") & tmpFile);
					
					// Remove Temp Aspect	
					removeAspect(genPath & tmpFile);	
					
					if( log.canLog(log.logLevels.DEBUG) ){
						log.debug("Target (#getMetadata(arguments.target).name#) weaved with new (#arguments.jointpoint#) method.");
					}			
				}
				catch(Any e){
					// Remove Stub
					removeAspect(genPath & tmpFile);
					$throw("Exception mixing in AOP aspect",
							e.message & e.detail & e.stacktrace,
							"TransactionAdvise.MixinException");
				}	
			}				
		</cfscript>
		</cflock>
		</cfif>
     </cffunction>
	 
	 
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- decorateAOPTarget --->
     <cffunction name="decorateAOPTarget" output="false" access="private" returntype="void" hint="Decorate an AOP target with the basics of AOP decoration">
    	<cfargument name="target" type="any" required="true" hint="The target to advise"/>
		
		<cfif NOT structKeyExists(arguments.target,"$aop_enabled")>
		<cflock name="TransactionAdvisor.decorateTarget.#instance.system.identityHashCode(arguments.target)#" throwontimeout="true" timeout="30">
		<cfscript> 
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
				
				if( log.canLog(log.logLevels.DEBUG) ){
					log.debug("Target AOP decorated: #getMetaData(arguments.target).name#.");
				}
			}				
		</cfscript>
		</cflock>
		</cfif>
     </cffunction>
	 
	<!--- $aop_transaction --->
    <cffunction name="$aop_transaction" output="false" access="private" returntype="any" hint="The aop invoker">
     	<cfargument name="jointpoint" 		hint="The jointpoint to execute"/>
      	<cfargument name="jpArguments"   	hint="The arguments passed to the jointpoint" />
     	
		<cfset var udfPointer = "">
		<cfset var results = "">
     	
		<!--- get UDF Pointer --->
		<cfset udfPointer = this.$aop_targets[arguments.jointpoint]>
		
		<!--- Are we in transaction in the current request? --->	
		<cfif structKeyExists(request,"cbox_aop_transaction")>
			<!--- Just execute the method call --->
			<cfreturn udfPointer(argumentCollection=arguments.jpArguments)>
		<cfelse>
			<!--- Transaction Safe Call --->
			<cftry>
				<cftransaction>
					<cfset request["cbox_aop_transaction"] = true>
					<cfset results = udfPointer(argumentCollection=arguments.jpArguments)>
				</cftransaction>
				<cfcatch type="any">
					<cfset structDelete(request,"cbox_aop_transaction")>
					<cfrethrow>
				</cfcatch>
			</cftry>
			<cfset structDelete(request,"cbox_aop_transaction")>						
		</cfif>
		
		<!--- Return results if found --->
		<cfif isDefined("results")>
			<cfreturn results>
		</cfif>
     </cffunction>
	  
	<!--- $aop_include --->
	<cffunction name="$aop_include" output="false" access="private" returntype="void" hint="Mix in a template">
		<cfargument name="templatePath" type="string" required="true"/>
		<cfinclude template="#arguments.templatePath#">
	</cffunction>
	
	<!--- aop_remove --->
    <cffunction name="$aop_remove" output="false" access="private" returntype="void" hint="Remove a method">
    	<cfargument name="methodName"/>
		<cfset structDelete(this,arguments.methodName)>
		<cfset structDelete(variables,arguments.methodName)>
    </cffunction>

	<!--- writeAspect --->
	<cffunction name="writeAspect" output="false" access="private" returntype="void" hint="Write a method generator stub">
		<cfargument name="genPath" 	type="string" required="true"/>
		<cfargument name="code" 	type="string" required="true"/>
		
		<cffile action="write" file="#arguments.genPath#" output="#arguments.code#">
		
	</cffunction>

	<!--- removeAspect --->
	<cffunction name="removeAspect" output="false" access="private" returntype="boolean" hint="Remove a method generator stub">
		<cfargument name="genPath" type="string" required="true"/>
		
		<cfif fileExists(arguments.genPath)>
			<cffile action="delete" file="#arguments.genPath#">
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

</cfcomponent>