<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 		: Luis Majano
Date     		: April 20, 2009
Description		: 
	A mock generator
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The guy in charge of creating mocks">

	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="MockGenerator" hint="Constructor">
		<cfargument name="mockBox" required="true"/>
		<cfargument name="removeStubs" required="false" default="true" hint="Always remove stubs unless we are debugging"/>
		<cfscript>
			instance.lb 			= "#chr(13)##chr(10)#";
			instance.mockBox 		= arguments.mockBox;
			instance.removeStubs 	= arguments.removeStubs;
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- generate --->
	<cffunction name="generate" output="false" access="public" returntype="string" hint="Generate a mock method and return the generated path">
		<!--- ************************************************************* --->
		<cfargument name="method" 				type="string" 	required="true" 	hint="The method you want to mock or spy on"/>
		<cfargument name="returns" 				type="any" 		required="false" 	hint="The results it must return, if not passed it returns void or you will have to do the mockResults() chain"/>
		<cfargument name="preserveReturnType" 	type="boolean" 	required="true" 	default="true" hint="If false, the mock will make the returntype of the method equal to ANY"/>
		<cfargument name="throwException" 		type="boolean" 	required="false" 	default="false" hint="If you want the method call to throw an exception"/>
		<cfargument name="throwType" 	  		type="string" 	required="false" 	default="" hint="The type of the exception to throw"/>
		<cfargument name="throwDetail" 	  		type="string" 	required="false" 	default="" hint="The detail of the exception to throw"/>
		<cfargument name="throwMessage"	  		type="string" 	required="false" 	default="" hint="The message of the exception to throw"/>
		<cfargument name="metadata" 	  		type="any" 		required="true" 	default="" hint="The function metadata"/>
		<cfargument name="targetObject"	  		type="any" 		required="true" 	hint="The target object to mix in"/>
		<cfargument name="callLogging" 	  		type="boolean" 	required="false" 	default="false" hint="Will add the machinery to also log the incoming arguments to each subsequent calls to this method"/>
		<cfargument name="preserveArguments" 	type="boolean" 	required="false" 	default="false" hint="If true, argument signatures are kept, else they are ignored. If true, BEWARE with $args() matching as default values and missing arguments need to be passed too."/>
		<!--- ************************************************************* --->
		<cfscript>
			var udfOut = CreateObject("java","java.lang.StringBuffer").init('');
			var genPath = ExpandPath( instance.mockBox.getGenerationPath() );
			var tmpFile = createUUID() & ".cfm";
			var fncMD = arguments.metadata;
			
			// Create Method Signature
			udfOut.append('
			<cfset this[ "#arguments.method#" ] = variables[ "#arguments.method#" ]> 
			<cffunction name="#arguments.method#" access="#fncMD.access#" output="#fncMD.output#" returntype="#fncMD.returntype#">#instance.lb#');
			
			// Create Arguments Signature
			if( structKeyExists( fncMD, "parameters" ) AND arguments.preserveArguments ){
			for( var x=1; x lte arrayLen( fncMD.parameters ); x++ ){
				udfOut.append( '<cfargument');
				for( var argKey in fncMD.parameters[ x ] ){
					udfOut.append( ' #lcase( argKey )#="#fncMD.parameters[ x ][ argKey ]#"');
				}
				udfOut.append('>#instance.lb#');
			}
			}
			
			// Continue Method Generation
			udfOut.append('
			<cfset var results = this._mockResults>
			<cfset var resultsKey = "#arguments.method#">
			<cfset var resultsCounter = 0>
			<cfset var internalCounter = 0>
			<cfset var resultsLen = 0>
			<cfset var argsHashKey = resultsKey & "|" & this.mockBox.normalizeArguments(arguments)>
			
			<!--- If Method & argument Hash Results, switch the results struct --->
			<cfif structKeyExists(this._mockArgResults,argsHashKey)>
				<cfset results = this._mockArgResults>
				<cfset resultsKey = argsHashKey>
			</cfif>
			
			<!--- Get the statemachine counter --->
			<cfset resultsLen = arrayLen(results[resultsKey])>
			
			<!--- Log the Method Call --->
			<cfset this._mockMethodCallCounters[listFirst(resultsKey,"|")] = this._mockMethodCallCounters[listFirst(resultsKey,"|")] + 1>
			
			<!--- Get the CallCounter Reference --->
			<cfset internalCounter = this._mockMethodCallCounters[listFirst(resultsKey,"|")]>
			');
			
			// Call Logging argument or Global Flag
			if( arguments.callLogging OR arguments.targetObject._mockCallLoggingActive  ){
				udfOut.append('<cfset arrayAppend(this._mockCallLoggers["#arguments.method#"], arguments)>#instance.lb#');
			}
			
			// Exceptions? To Throw
			if( arguments.throwException ){
				udfOut.append('<cfthrow type="#arguments.throwType#" message="#arguments.throwMessage#" detail="#arguments.throwDetail#" />#instance.lb#');
			}			
			// Returns Something according to metadata?
			if ( fncMD["returntype"] neq "void" ){
				/* Results Recyling Code, basically, state machine code */
				udfOut.append('
				<cfif resultsLen neq 0>
					<cfif internalCounter gt resultsLen>
						<cfset resultsCounter = internalCounter - ( resultsLen*fix( (internalCounter-1)/resultsLen ) )>
						<cfreturn results[resultsKey][resultsCounter]>
					<cfelse>
						<cfreturn results[resultsKey][internalCounter]>
					</cfif>
				</cfif>
				');			
			}
			udfOut.append('</cffunction>');
			
			// Write it out
			writeStub(genPath & tmpFile, udfOUt.toString());
		
			// Mix In Stub
			try{
				arguments.targetObject.$include = variables.$include;
				arguments.targetObject.$include( instance.mockBox.getGenerationPath() & tmpFile );
				structDelete(arguments.targetObject,"$include");
				// Remove Stub	
				removeStub(genPath & tmpFile);				
			}
			catch(Any e){
				// Remove Stub
				removeStub(genPath & tmpFile);
				rethrowit( e );
			}			
		</cfscript>
	</cffunction>
	
	<!--- writeStub --->
	<cffunction name="writeStub" output="false" access="public" returntype="void" hint="Write a method generator stub">
		<cfargument name="genPath" 	type="string" required="true"/>
		<cfargument name="code" 	type="string" required="true"/>
		
		<cffile action="write" file="#arguments.genPath#" output="#arguments.code#">
		
	</cffunction>

	<!--- removeStub --->
	<cffunction name="removeStub" output="false" access="public" returntype="boolean" hint="Remove a method generator stub">
		<cfargument name="genPath" type="string" required="true"/>
		
		<cfif fileExists(arguments.genPath) and instance.removeStubs>
			<cffile action="delete" file="#arguments.genPath#">
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
	<!--- generateCFC --->    
    <cffunction name="generateCFC" output="false" access="public" returntype="any" hint="Generate CFC's according to specs">    
		<cfargument name="extends" 		type="string" required="false" default="" hint="The class the CFC should extend"/>
		<cfargument name="implements" 	type="string" required="false" default="" hint="The class(es) the CFC should implement"/>
    	<cfscript>	 
			var udfOut 	= createObject("java","java.lang.StringBuffer").init('');
			var genPath = expandPath( instance.mockBox.getGenerationPath() );
			var tmpFile = createUUID() & ".cfc";
			var cfcPath = replace( instance.mockBox.getGenerationPath(), "/", ".", "all" ) & listFirst( tmpFile, "." );
			var oStub	= "";
			var local 	= {};
			
			// Create CFC Signature
			udfOut.append('<cfcomponent output="false" hint="A MockBox awesome Component"');
			// extends
			if( len( trim( arguments.extends ) ) ){
				udfOut.append(' extends="#arguments.extends#"');
			}
			// implements
			if( len( trim( arguments.implements ) ) ){
				udfOut.append(' implements="#arguments.implements#"');
			}
			
			// close tag
			udfOut.append('>#instance.lb#');
			   
			// iterate over implementations
			for( local.x=1; local.x lte listLen( arguments.implements ); local.x++ ){
				// generate interface methods
				generateMethodsFromMD( udfOut, getComponentMetadata( listGetAt( arguments.implements, x) ) );
			}
			
			// close it
			udfOut.append('</cfcomponent>');
			
			// Write it out
			writeStub( genPath & tmpFile, udfOUt.toString() );
		
			try{
				// create stub + clean first . if found.
				cfcPath = reReplace( cfcPath, "^\.", "" );
				oStub = createObject( "component", cfcPath );
				// Remove Stub	
				removeStub(genPath & tmpFile);
				// Return it
				return oStub;				
			}
			catch(Any e){
				// Remove Stub
				removeStub( genPath & tmpFile );
				rethrowit( e );
			}	
    	</cfscript>    
    </cffunction>
    
    <!--- generateMethodsFromMD --->    
    <cffunction name="generateMethodsFromMD" output="false" access="private" returntype="any" hint="Generates methods from functions metadata">    
    	<cfargument name="buffer" 	type="any" required="true" hint="The string buffer to append stuff to"/>
		<cfargument name="md" 		type="any" required="true" hint="The metadata to generate"/>
    	<cfscript>	  
			var local 	= {};
			var udfOut  = arguments.buffer;
			
			// local functions if they exist
			local.oMD = [];
			if( structKeyExists( arguments.md, "functions" ) ){
				local.oMD = arguments.md.functions;
			}
			
			// iterate and create functions
			for( local.x = 1; local.x lte arrayLen( local.oMD ); local.x++ ){
				// start function tag
				udfOut.append('<cffunction');
				
				// iterate over the values of the function
				for( local.fncKey in local.oMD[ x ] ){
					// Do Simple values only
					if( NOT local.fncKey eq "parameters" ){
						udfOut.append(' #lcase( local.fncKey )#="#local.oMD[ x ][ local.fncKey ]#"');
					}
				}
				// close function start tag
				udfOut.append('>#instance.lb#');
				
				// Do parameters if they exist
				for( local.y=1; local.y lte arrayLen( local.oMD[ x ].parameters ); local.y++ ){
					// start argument
					udfOut.append('<cfargument');
					// do attributes
					for( local.fncKey in local.oMD[ x ].parameters[ y ] ){
						udfOut.append(' #lcase( local.fncKey )#="#local.oMD[ x ].parameters[ y ][ local.fncKey ]#"');
					}
					// close argument
					udfOut.append('>#instance.lb#');
				} 
				
				// close full function
				udfOut.append("</cffunction>#instance.lb#");
			}
			
			// Check extends and recurse
			if( structKeyExists( arguments.md, "extends") ){
				generateMethodsFromMD( udfOut, arguments.md.extends );
			}
    	</cfscript>    
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- $include --->
	<cffunction name="$include" output="false" access="private" returntype="void" hint="Mix in a template">
		<cfargument name="templatePath" type="string" required="true"/>
		<cfinclude template="#arguments.templatePath#">
	</cffunction>
	
		<!--- rethrowit --->
	<cffunction name="rethrowit" access="private" returntype="void" hint="Rethrow an exception" output="false" >
		<cfargument name="throwObject" required="true" hint="The exception object">
		<cfthrow object="#arguments.throwObject#">
	</cffunction>
</cfcomponent>