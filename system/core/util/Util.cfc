<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author          :	Luis Majano
Description :
The main ColdBox utility library, it is built with tags to allow for dumb ACF10 compatibility
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The main ColdBox utility library filled with lots of nice goodies.">
	<cfscript>
	/**
	 * Builds the unique Session Key of a user request and returns it to you.
	 */
	string function getSessionIdentifier(){
		// Check jsession id First
		if ( isDefined( "session" ) and structKeyExists( session, "sessionid" ) ) {
			return session.sessionid;
		}
		// Check normal cfid and cftoken in cookie
		else if ( structKeyExists( cookie, "CFID" ) AND structKeyExists( cookie, "CFTOKEN" ) ) {
			return hash( cookie.cfid & cookie.cftoken );
		}
		// Check normal cfid and cftoken in URL
		else if ( structKeyExists( URL, "CFID" ) AND structKeyExists( URL, "CFTOKEN" ) ) {
			return hash( URL.cfid & URL.cftoken );
		}
		// check session URL Token
		else if ( isDefined( "session" ) and structKeyExists( session, "URLToken" ) ) {
			return session.URLToken;
		} else {
			throw(
				message = "Cannot find a jsessionid, URLToken or cfid/cftoken in any scope. Please verify",
				type    = "UniqueKeyException"
			);
		}
	}
	</cfscript>

	<!--- getMixerUtil --->
	<cffunction
		name       ="getMixerUtil"
		output     ="false"
		access     ="public"
		returntype ="any"
		hint       ="Get the mixer utility"
		doc_generic="coldbox.system.core.dynamic.MixerUtil"
	>
		<cfscript>
		if ( structKeyExists( variables, "mixerUtil" ) ) {
			return variables.mixerUtil;
		}
		variables.mixerUtil = new coldbox.system.core.dynamic.MixerUtil();
		return variables.mixerUtil;
		</cfscript>
	</cffunction>

	<!--- arrayToStruct --->
	<cffunction
		name      ="arrayToStruct"
		output    ="false"
		access    ="public"
		returntype="struct"
		hint      ="Convert an array to struct argument notation"
	>
		<cfargument name="in" type="array" required="true" hint="The array to convert"/>
		<cfscript>
		return arguments.in.reduce( function( result, item, index ){
			var target = {};
			if ( !isNull( arguments.result ) ) {
				target = arguments.result;
			}
			target[ arguments.index ] = arguments.item;
			return target;
		} );
		</cfscript>
	</cffunction>

	<!--- fileLastModified --->
	<cffunction
		name      ="fileLastModified"
		access    ="public"
		returntype="string"
		output    ="false"
		hint      ="Get the last modified date of a file"
	>
		<cfargument name="filename" required="true">
		<cfscript>
		return getFileInfo( getAbsolutePath( arguments.filename ) ).lastModified;
		</cfscript>
	</cffunction>

	<!--- ripExtension --->
	<cffunction
		name      ="ripExtension"
		access    ="public"
		returntype="string"
		output    ="false"
		hint      ="Rip the extension of a filename."
	>
		<cfargument name="filename" required="true">
		<cfreturn reReplace( arguments.filename, "\.[^.]*$", "" )>
	</cffunction>

	<!--- getAbsolutePath --->
	<cffunction
		name      ="getAbsolutePath"
		access    ="public"
		output    ="false"
		returntype="string"
		hint      ="Turn any system path, either relative or absolute, into a fully qualified one"
	>
		<cfargument name="path" required="true">
		<cfscript>
		if ( fileExists( arguments.path ) ) {
			return arguments.path;
		}
		return expandPath( arguments.path );
		</cfscript>
	</cffunction>

	<!--- inThread --->
	<cffunction
		name      ="inThread"
		output    ="false"
		access    ="public"
		returntype="boolean"
		hint      ="Check if you are in cfthread or not for any CFML Engine"
	>
		<cfscript>
		var engine = "ADOBE";

		if ( server.coldfusion.productname eq "Lucee" ) {
			engine = "LUCEE";
		}

		switch ( engine ) {
			case "ADOBE": {
				if (
					findNoCase(
						"cfthread",
						createObject( "java", "java.lang.Thread" )
							.currentThread()
							.getThreadGroup()
							.getName()
					)
				) {
					return true;
				}
				break;
			}
			case "LUCEE": {
				var version = listFirst( server.lucee.version, "." );

				if ( version == 5 ) {
					return isInThread();
				}

				if (
					findNoCase(
						"cfthread",
						createObject( "java", "java.lang.Thread" )
							.currentThread()
							.getThreadGroup()
							.getName()
					)
				) {
					return true;
				}
				break;
			}
		}
		// end switch statement.

		return false;
		</cfscript>
	</cffunction>

	<!--- placeHolderReplacer --->
	<cffunction
		name      ="placeHolderReplacer"
		access    ="public"
		returntype="any"
		hint      ="PlaceHolder Replacer for strings containing ${} patterns"
		output    ="false"
	>
		<cfargument name="str" required="true" hint="The string variable to look for replacements">
		<cfargument name="settings" required="true" hint="The structure of settings to use in replacing">
		<cfscript>
		var returnString = arguments.str;
		var regex        = "\$\{([0-9a-z\-\.\_]+)\}";
		var lookup       = 0;
		var varName      = 0;
		var varValue     = 0;

		// Loop and Replace
		while ( true ) {
			// Search For Pattern
			var lookup = reFindNoCase( regex, returnString, 1, true );
			// Found?
			if ( lookup.pos[ 1 ] ) {
				// Get Variable Name From Pattern
				var varName = mid(
					returnString,
					lookup.pos[ 2 ],
					lookup.len[ 2 ]
				);
				var varValue = "VAR_NOT_FOUND";

				// Lookup Value
				if ( structKeyExists( arguments.settings, varname ) ) {
					varValue = arguments.settings[ varname ];
				}
				// Lookup Nested Value
				else if ( isDefined( "arguments.settings.#varName#" ) ) {
					varValue = structFindKey( arguments.settings, varName )[ 1 ].value;
				}
				// Remove PlaceHolder Entirely
				returnString = removeChars(
					returnString,
					lookup.pos[ 1 ],
					lookup.len[ 1 ]
				);
				// Insert Var Value
				returnString = insert(
					varValue,
					returnString,
					lookup.pos[ 1 ] - 1
				);
			} else {
				break;
			}
		}

		return returnString;
		</cfscript>
	</cffunction>

	<!--- getSystemSetting --->
	<cffunction
		name      ="getSystemSetting"
		output    ="false"
		access    ="public"
		returntype="any"
		hint      ="Retrieve a Java System property or env value by name. It looks at properties first then environment variables"
	>
		<cfargument name="key" required="true" type="string" hint="The name of the setting to look up."/>
		<cfargument
			name    ="defaultValue"
			required="false"
			hint    ="The default value to use if the key does not exist in the system properties or the env"
		/>
		<cfscript>
		var value = getJavaSystem().getProperty( arguments.key );
		if ( !isNull( local.value ) ) {
			return value;
		}

		value = getJavaSystem().getEnv( arguments.key );
		if ( !isNull( local.value ) ) {
			return value;
		}

		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}

		throw(
			type    = "SystemSettingNotFound",
			message = "Could not find a Java System property or Env setting with key [#arguments.key#]."
		);
		</cfscript>
	</cffunction>

	<!--- getSystemProperty --->
	<cffunction
		name      ="getSystemProperty"
		output    ="false"
		access    ="public"
		returntype="any"
		hint      ="Retrieve a Java System property value by name."
	>
		<cfargument name="key" required="true" type="string" hint="The name of the java property to look up."/>
		<cfargument
			name    ="defaultValue"
			required="false"
			hint    ="The default value to use if the key does not exist in the system properties"
		/>
		<cfscript>
		var value = getJavaSystem().getProperty( arguments.key );
		if ( !isNull( local.value ) ) {
			return value;
		}

		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}

		throw(
			type    = "SystemSettingNotFound",
			message = "Could not find a Java System property with key [#arguments.key#]."
		);
		</cfscript>
	</cffunction>

	<!--- getEnv --->
	<cffunction
		name      ="getEnv"
		output    ="false"
		access    ="public"
		returntype="any"
		hint      ="Retrieve a Java System environment value by name."
	>
		<cfargument name="key" required="true" type="string" hint="The name of the environment variable to look up."/>
		<cfargument
			name    ="defaultValue"
			required="false"
			hint    ="The default value to use if the key does not exist in the env"
		/>
		<cfscript>
		var value = getJavaSystem().getEnv( arguments.key );
		if ( !isNull( local.value ) ) {
			return value;
		}

		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}

		throw(
			type    = "SystemSettingNotFound",
			message = "Could not find a environment variable with key [#arguments.key#]."
		);
		</cfscript>
	</cffunction>

	<!--- getJavaSystem --->
	<cffunction
		name      ="getJavaSystem"
		output    ="false"
		access    ="public"
		returntype="any"
		hint      ="Retrieve an instance of Java System"
	>
		<cfscript>
		if ( !structKeyExists( variables, "javaSystem" ) ) {
			variables.javaSystem = createObject( "java", "java.lang.System" );
		}
		return variables.javaSystem;
		</cfscript>
	</cffunction>

	<!------------------------------------------- Taxonomy Utility Methods ------------------------------------------>

	<!--- isFamilyType --->
	<cffunction
		name      ="isFamilyType"
		output    ="false"
		access    ="public"
		returntype="boolean"
		hint      ="Checks if an object is of the passed in family type"
	>
		<cfargument name="family" required="true" hint="The family to covert it to: handler, interceptor"/>
		<cfargument name="target" required="true" hint="The target object"/>
		<cfscript>
		var familyPath = "";

		switch ( arguments.family ) {
			case "handler": {
				familyPath = "coldbox.system.EventHandler";
				break;
			}
			case "interceptor": {
				familyPath = "coldbox.system.Interceptor";
				break;
			}
			default: {
				throw( "Invalid family sent #arguments.family#" );
			}
		}

		return isInstanceOf( arguments.target, familyPath );
		</cfscript>
	</cffunction>

	<!--- convertToColdBox --->
	<cffunction
		name      ="convertToColdBox"
		output    ="false"
		access    ="public"
		returntype="void"
		hint      ="Decorate an object as a ColdBox Family object"
	>
		<cfargument name="family" required="true" hint="The family to covert it to: handler, interceptor"/>
		<cfargument name="target" required="true" hint="The target object"/>
		<cfscript>
		var familyPath = "";

		switch ( arguments.family ) {
			case "handler": {
				familyPath = "coldbox.system.EventHandler";
				break;
			}
			case "interceptor": {
				familyPath = "coldbox.system.Interceptor";
				break;
			}
			default: {
				throw( "Invalid family sent #arguments.family#" );
			}
		}

		// Mix it up baby
		arguments.target.$injectUDF = getMixerUtil().injectMixin;

		// Create base family object
		var baseObject = createObject( "component", familyPath );

		// Check if init already exists?
		if ( structKeyExists( arguments.target, "init" ) ) {
			arguments.target.$cbInit = baseObject.init;
		}

		// Mix in methods
		for ( var key in baseObject ) {
			// If handler has overriden method, then don't override it with mixin, simulated inheritance
			if ( NOT structKeyExists( arguments.target, key ) ) {
				arguments.target.$injectUDF( key, baseObject[ key ] );
			}
		}

		// Mix in fake super class
		arguments.target.$super = baseObject;
		</cfscript>
	</cffunction>

	<!--- getInheritedMetaData --->
	<cffunction
		name  ="getInheritedMetaData"
		output="false"
		hint  ="Returns a single-level metadata struct that includes all items inhereited from extending classes."
	>
		<cfargument name="component" type="any" required="true" hint="A component instance, or the path to one">
		<cfargument name="stopRecursions" default="#arrayNew( 1 )#" hint="An array of classes to stop recursion">
		<cfargument
			name   ="md"
			default="#structNew()#"
			hint   ="A structure containing a copy of the metadata for this level of recursion."
		>

		<cfset var loc = {}>

		<!--- First time through, get metaData of component. --->
		<cfif structIsEmpty( md )>
			<cfif isObject( component )>
				<cfset md = getMetadata( component )>
			<cfelse>
				<cfset md = getComponentMetadata( component )>
			</cfif>
		</cfif>

		<!---
			If it has a parent, stop and calculate it first, unless of course, we've reached a class we shouldn't recurse into.
		--->

		<cfif structKeyExists( md, "extends" ) AND
		md.type eq "component" AND
		stopClassRecursion( md.extends.name, arguments.stopRecursions ) EQ FALSE>
			<cfset loc.parent = getInheritedMetaData(
				component      = component,
				stopRecursions = stopRecursions,
				md             = md.extends
			)>
			<!---
				If we're at the end of the line, it's time to start working backwards so start with an empty struct to hold our condensesd metadata.
			--->
		<cfelse>
			<cfset loc.parent = {}>
			<cfset loc.parent.inheritancetrail = []>
		</cfif>

		<!--- Override ourselves into parent --->
		<cfloop collection="#md#" item="loc.key">
			<!--- Functions and properties are an array of structs keyed on name, so I can treat them the same --->
			<cfif listFindNoCase( "functions,properties", loc.key )>
				<cfif not structKeyExists( loc.parent, loc.key )>
					<cfset loc.parent[ loc.key ] = []>
				</cfif>
				<!--- For each function/property in me... --->
				<cfloop array="#md[ loc.key ]#" index="loc.item">
					<cfset loc.parentItemCounter = 0>
					<cfset loc.foundInParent = false>
					<!--- ...Look for an item of the same name in my parent... --->
					<cfloop array="#loc.parent[ loc.key ]#" index="loc.parentItem">
						<cfset loc.parentItemCounter++>
						<!--- ...And override it --->
						<cfif compareNoCase( loc.item.name, loc.parentItem.name ) eq 0>
							<cfset loc.parent[ loc.key ][ loc.parentItemCounter ] = loc.item>
							<cfset loc.foundInParent = true>
							<cfbreak>
						</cfif>
					</cfloop>
					<!--- ...Or add it --->
					<cfif not loc.foundInParent>
						<cfset arrayAppend( loc.parent[ loc.key ], loc.item )>
					</cfif>
				</cfloop>
			<cfelseif NOT listFindNoCase( "extends,implements", loc.key )>
				<cfset loc.parent[ loc.key ] = md[ loc.key ]>
			</cfif>
		</cfloop>
		<cfset arrayPrepend( loc.parent.inheritanceTrail, loc.parent.name )>
		<cfreturn loc.parent>
	</cffunction>

	<!--- stopClassRecursion --->
	<cffunction
		name       ="stopClassRecursion"
		access     ="private"
		returntype ="any"
		hint       ="Should we stop recursion or not due to class name found: Boolean"
		output     ="false"
		doc_generic="Boolean"
	>
		<cfargument name="classname" required="true" hint="The class name to check">
		<cfargument name="stopRecursions" required="true" hint="An array of classes to stop processing at"/>
		<cfscript>
		// Try to find a match
		for ( var thisClass in arguments.stopRecursions ) {
			if ( compareNoCase( thisClass, arguments.classname ) eq 0 ) {
				return true;
			}
		}
		return false;
		</cfscript>
	</cffunction>

	<!--- addMapping --->
	<cffunction name="addMapping" output="false" access="public" returntype="Util" hint="Add a CFML Mapping">
		<cfargument name="name" type="string" required="false" hint="The name of the mapping"/>
		<cfargument name="path" type="string" required="false" hint="The path to the mapping"/>
		<cfargument name="mappings" type="struct" required="false" hint="A struct of mappings">
		<cfscript>
		var mappingHelper = "";

		// Detect server
		if ( listFindNoCase( "Lucee", server.coldfusion.productname ) ) {
			mappingHelper = new LuceeMappingHelper();
		} else {
			mappingHelper = new CFMappingHelper();
		}

		if ( !isNull( arguments.mappings ) ) {
			mappingHelper.addMappings( arguments.mappings );
		} else {
			// Add / registration
			if ( left( arguments.name, 1 ) != "/" ) {
				arguments.name = "/#arguments.name#";
			}

			// Add mapping
			mappingHelper.addMapping( arguments.name, arguments.path );
		}

		return this;
		</cfscript>
	</cffunction>
</cfcomponent>
