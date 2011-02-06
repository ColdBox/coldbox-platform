<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	The main ColdBox utility library.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The main ColdBox utility library filled with lots of nice goodies.">
	
	<!--- getMixerUtil --->
    <cffunction name="getMixerUtil" output="false" access="public" returntype="any" hint="Get the mixer utility" colddoc:generic="coldbox.system.core.dynamic.MixerUtil">
    	<cfscript>
    		if( structKeyExists(variables, "mixerUtil") ){ return variables.mixerUtil; }
			variables.mixerUtil = createObject("component","coldbox.system.core.dynamic.MixerUtil").init();
			return variables.mixerUtil;
		</cfscript>
    </cffunction>
	
	<!--- arrayToStruct --->
	<cffunction name="arrayToStruct" output="false" access="public" returntype="struct" hint="Convert an array to struct argument notation">
		<cfargument name="in" type="array" required="true" hint="The array to convert"/>
		<cfscript>
			var results = structnew();
			var x       = 1;
			var inLen   = Arraylen(arguments.in);
			
			for(x=1; x lte inLen; x=x+1){
				results[x] = arguments.in[x];
			}
			
			return results;
		</cfscript>
	</cffunction>
	
	<!--- fileLastModified --->
	<cffunction name="fileLastModified" access="public" returntype="string" output="false" hint="Get the last modified date of a file">
		<cfargument name="filename" required="true">
		<cfscript>
		var objFile =  createObject("java","java.io.File").init(javaCast("string",arguments.filename));
		// Calculate adjustments fot timezone and daylightsavindtime
		var offset = ((getTimeZoneInfo().utcHourOffset)+1)*-3600;
		// Date is returned as number of seconds since 1-1-1970
		return dateAdd('s', (round(objFile.lastModified()/1000))+offset, CreateDateTime(1970, 1, 1, 0, 0, 0));
		</cfscript>
	</cffunction>
	
	<!--- ripExtension --->
	<cffunction name="ripExtension" access="public" returntype="string" output="false" hint="Rip the extension of a filename.">
		<cfargument name="filename" required="true">
		<cfreturn reReplace(arguments.filename,"\.[^.]*$","")>
	</cffunction>
	
	<!--- getAbsolutePath --->
	<cffunction name="getAbsolutePath" access="public" output="false" returntype="string" hint="Turn any system path, either relative or absolute, into a fully qualified one">
		<cfargument name="path" required="true">
		<cfscript>
			var fileObj = createObject("java","java.io.File").init(javaCast("String",arguments.path));
			if(fileObj.isAbsolute()){
				return arguments.path;
			}
			return expandPath(arguments.path);
		</cfscript>
	</cffunction>
	
	<!--- inThread --->
	<cffunction name="inThread" output="false" access="public" returntype="boolean" hint="Check if you are in cfthread or not for any CFML Engine">
		<cfscript>
			var engine = "ADOBE";
			
			if ( server.coldfusion.productname eq "Railo" ){ engine = "RAILO"; }
			if ( server.coldfusion.productname eq "BlueDragon" ){ engine = "BD"; }
			
			switch(engine){
				case "ADOBE"	: { 
					if( findNoCase("cfthread",createObject("java","java.lang.Thread").currentThread().getThreadGroup().getName()) ){
						return true;
					}
					break;
				}
				
				case "RAILO"	: { 
					return getPageContext().hasFamily(); 
				}
				
				case "BD"		: { 
					if( findNoCase("cfthread",createObject("java","java.lang.Thread").currentThread().getThreadGroup().getName()) ){
						return true;
					}
					break;
				}
			} //end switch statement.
			
			return false;
		</cfscript>
	</cffunction>

	<!--- placeHolderReplacer --->
	<cffunction name="placeHolderReplacer" access="public" returntype="any" hint="PlaceHolder Replacer for strings containing ${} patterns" output="false" >
		<cfargument name="str" 		required="true" hint="The string variable to look for replacements">
		<cfargument name="settings" required="true" hint="The structure of settings to use in replacing">
		<cfscript>
			var returnString = arguments.str;
			var regex = "\$\{([0-9a-z\-\.\_]+)\}";
			var lookup = 0;
			var varName = 0;
			var varValue = 0;
			// Loop and Replace 
			while(true){
				// Search For Pattern
				lookup = reFindNocase(regex,returnString,1,true);	
				// Found?
				if( lookup.pos[1] ){
					//Get Variable Name From Pattern
					varName = mid(returnString,lookup.pos[2],lookup.len[2]);
					varValue = "VAR_NOT_FOUND";
					
					// Lookup Value
					if( structKeyExists(arguments.settings,varname) ){
						varValue = arguments.settings[varname];
					}
					// Lookup Nested Value
					else if( isDefined("arguments.settings.#varName#") ){
						varValue = Evaluate("arguments.settings.#varName#");
					}
					// Remove PlaceHolder Entirely
					returnString = removeChars(returnString, lookup.pos[1], lookup.len[1]);
					// Insert Var Value
					returnString = insert(varValue, returnString, lookup.pos[1]-1);
				}
				else{
					break;
				}	
			}
			
			return returnString;
		</cfscript>
	</cffunction>
	
	<!--- throwInvalidHTTP --->
    <cffunction name="throwInvalidHTTP" output="false" access="public" returntype="void" hint="Throw an invalid HTTP exception">
    	<cfargument name="className" 	required="true" hint="The class producing the exception"/>
    	<cfargument name="detail"		required="true" hint="The throw detail argument to send out"/>
		<cfargument name="statusText" 	required="true" hint="Invalid exception status text"/>
		<cfargument name="statusCode" 	required="true" hint="The status code to send out."/>
		
		<cfheader statuscode="#arguments.statusCode#" statustext="#arguments.statusText#">
		<cfthrow type="#arguments.className#.#arguments.statusCode#"
			     errorcode="#arguments.statusCode#"
			     message="#arguments.statusText#"
				 detail="#arguments.detail#">

    </cffunction>
	
<!------------------------------------------- CF Facades ------------------------------------------>

	<!--- throw it --->
	<cffunction name="throwit" access="public" hint="Facade for cfthrow" output="false">
		<cfargument name="message" 	required="true">
		<cfargument name="detail" 	required="false" default="">
		<cfargument name="type"  	required="false" default="Framework">
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
	<!--- rethrowit --->
	<cffunction name="rethrowit" access="public" returntype="void" hint="Rethrow an exception" output="false" >
		<cfargument name="throwObject" required="true" hint="The exception object">
		<cfthrow object="#arguments.throwObject#">
	</cffunction>
		
	<!--- dump it --->
	<cffunction name="dumpit" access="public" hint="Facade for cfmx dump" returntype="void" output="true">
		<cfargument name="var" 		required="true">
		<cfargument name="isAbort"  type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#var#"><cfif arguments.isAbort><cfabort></cfif>
	</cffunction>
	
	<!--- abort it --->
	<cffunction name="abortit" access="public" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
	
	<!--- include it --->
	<cffunction name="includeit" access="public" hint="Facade for cfinclude" returntype="void" output="true">
		<cfargument name="template" required="true">
		<cfinclude template="#template#">
	</cffunction>

<!------------------------------------------- Taxonomy Utility Methods ------------------------------------------>
	
	<!--- isInstanceCheck --->
    <cffunction name="isInstanceCheck" output="false" access="public" returntype="boolean" hint="Checks if an object is of a certain type of family via inheritance">
    	<cfargument name="obj"    required="true" hint="The object to evaluate"/>
		<cfargument name="family" required="true" default="" hint="The family string to check"/>
    	<cfscript>
    		var md 			= "";
			var moreChecks  = true;
			
    		// Get cf7 nasty metadata, remove by 3.1
			md = getMetadata(arguments.obj);
			if( NOT structKeyExists(md, "extends") ){
				return false;
			}
			md = md.extends;
			
			while(moreChecks){
				// Check inheritance family?
				if( md.name eq arguments.family){
					return true;
				}
				// Else check further inheritance?
				else if ( structKeyExists(md, "extends") ){
					md = md.extends;
				}
				else{
					return false;
				}
			}
    		
			return false;
    	</cfscript>
    </cffunction>
	
	
	<!--- isFamilyType --->
    <cffunction name="isFamilyType" output="false" access="public" returntype="boolean" hint="Checks if an object is of the passed in family type">
    	<cfargument name="family" required="true" hint="The family to covert it to: handler, plugin, interceptor"/>
		<cfargument name="target" required="true" hint="The target object"/>
		<cfscript>
			var familyPath = "";
			
			switch(arguments.family){
				case "handler" 		: { familyPath = "coldbox.system.EventHandler"; break; }
				case "plugin" 		: { familyPath = "coldbox.system.Plugin"; break; }
				case "interceptor"  : { familyPath = "coldbox.system.Interceptor"; break; }
				default:{
					throwit('Invalid family sent #arguments.family#');
				}
			}
			
			if( structKeyExists(getFunctionList(), "isInstanceOf") ){
				return isInstanceOf(arguments.target,familyPath);
			}
			else{
				return isInstanceCheck(arguments.target,familyPath);
			}
		</cfscript>		
    </cffunction>
	
	<!--- convertToColdBox --->
    <cffunction name="convertToColdBox" output="false" access="public" returntype="void" hint="Decorate an object as a ColdBox Family object">
    	<cfargument name="family" required="true" hint="The family to covert it to: handler, plugin, interceptor"/>
		<cfargument name="target" required="true" hint="The target object"/>
		<cfscript>
			var baseObject = "";
			var familyPath = "";
			var key 	   = "";
			
			switch(arguments.family){
				case "handler" 		: { familyPath = "coldbox.system.EventHandler"; break; }
				case "plugin" 		: { familyPath = "coldbox.system.Plugin"; break; }
				case "interceptor"  : { familyPath = "coldbox.system.Interceptor"; break; }
				default:{
					throwit('Invalid family sent #arguments.family#');
				}
			}
			
			// Mix it up baby
			arguments.target.$injectUDF = getMixerUtil().injectMixin;
			
			// Create base family object
			baseObject = createObject("component",familyPath);
			
			// Check if init already exists?
			if( structKeyExists(arguments.target, "init") ){ arguments.target.$cbInit = baseObject.init;	}	
			
			// Mix in methods
			for(key in baseObject){
				// If handler has overriden method, then don't override it with mixin, simulated inheritance
				if( NOT structKeyExists(arguments.target, key) ){
					arguments.target.$injectUDF(key,baseObject[key]);
				}
			}
			
			// Mix in fake super class
			arguments.target.$super = baseObject;
		</cfscript>
    </cffunction>

</cfcomponent>