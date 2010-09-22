<!-----------------------------------------------------------------------********************************************************************************Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corpwww.coldbox.org | www.luismajano.com | www.ortussolutions.com********************************************************************************Author 	 :	Luis MajanoDescription :	A static utility of util methods-----------------------------------------------------------------------><cfcomponent hint="This is a Utilities CFC" output="false" cache="true"><!------------------------------------------- CONSTRUCTOR ------------------------------------------->	<cffunction name="init" access="public" returntype="Utilities" output="false">		<cfscript>						setpluginName("Utilities Plugin");			setpluginVersion("1.1");			setpluginDescription("This plugin provides various file/system/java utilities");			setpluginAuthor("Luis Majano, Sana Ullah");			setpluginAuthorURL("http://www.coldbox.org");						return this;		</cfscript>	</cffunction><!------------------------------------------- UTILITY METHODS ------------------------------------------->	<!--- queryStringToStruct --->	<cffunction name="queryStringToStruct" output="false" returntype="struct" hint="Converts a querystring into a struct of name value pairs">		<cfargument name="qs" type="string" required="true" default="" hint="The query string"/>		<cfscript>			var i 		 = 1;			var results  = structnew();			var thisVal  = "";						// If conventions found, continue parsing			for(i=1; i lte listLen(arguments.qs,"&"); i=i+1){				thisVal = listGetAt(arguments.qs,i,"&");				// Parse it out				results[ getToken(thisVal,1,"=") ] = getToken(thisVal,2,"=");			}//end loop over pairs					return results;		</cfscript>	</cffunction>	<!--- isCFUUID --->	<cffunction name="isCFUUID" output="false" returntype="boolean" hint="Checks if a passed string is a valid UUID.">		<cfargument name="inStr" type="string" required="true" />		<cfreturn reFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", inStr) />	</cffunction>	<!--- isSSL --->	<cffunction name="isSSL" output="false" returntype="boolean" hint="Tells you if you are in SSL mode or not.">		<cfscript>			if( isBoolean(cgi.server_port_secure) and cgi.server_port_secure ){				return true;			}			else{				return false;			}		</cfscript>	</cffunction>	<!--- sleeper --->	<cffunction name="sleeper" access="public" returntype="void" output="false" hint="Make the main thread of execution sleep for X amount of seconds.">		<cfargument name="milliseconds" type="numeric" required="yes" hint="Milliseconds to sleep">		<cfset CreateObject("java", "java.lang.Thread").sleep(arguments.milliseconds)>	</cffunction>	<!--- placeHolderReplacer --->	<cffunction name="placeHolderReplacer" access="public" returntype="any" hint="PlaceHolder Replacer for strings containing ${} patterns" output="false" >		<!---************************************************************************************************ --->		<cfargument name="str" 		required="true" type="any" hint="The string variable to look for replacements">		<cfargument name="settings" required="true" type="any" hint="The structure of settings to use in replacing">		<!---************************************************************************************************ --->		<cfscript>			var returnString = arguments.str;			var regex = "\$\{([0-9a-z\-\.\_]+)\}";			var lookup = 0;			var varName = 0;			var varValue = 0;			/* Loop and Replace */			while(true){				/* Search For Pattern */				lookup = reFindNocase(regex,returnString,1,true);					/* Found? */				if( lookup.pos[1] ){					/* Get Variable Name From Pattern */					varName = mid(returnString,lookup.pos[2],lookup.len[2]);					/* Lookup Value */					if( structKeyExists(arguments.settings,varname) ){						varValue = arguments.settings[varname];					}					else if( isDefined("arguments.settings.#varName#") ){						varValue = Evaluate("arguments.settings.#varName#");					}					else{						varValue = "VAR_NOT_FOUND";					}					/* Remove PlaceHolder Entirely */					returnString = removeChars(returnString, lookup.pos[1], lookup.len[1]);					/* Insert Var Value */					returnString = insert(varValue, returnString, lookup.pos[1]-1);				}				else{					break;				}				}			/* Return Parsed String. */			return returnString;		</cfscript>	</cffunction>		<!--- _serialize --->	<cffunction name="_serialize" access="public" returntype="string" output="false" hint="Serialize complex objects that implement serializable. Returns a binary string.">		<!--- ************************************************************* --->		<cfargument name="complexObject" type="any" required="true" hint="Any coldfusion primative data type and if cf8 componetns."/>        <!--- ************************************************************* --->		<cfscript>			var converter = createObject("component","coldbox.system.core.conversion.ObjectMarshaller").init();					return converter.serializeObject(arguments.complexObject);        </cfscript>    </cffunction>      	<!--- _serializeToFile --->    <cffunction name="_serializeToFile" access="public" returntype="void" output="false" hint="Serialize complex objects that implement serializable, into a file.">		<!--- ************************************************************* --->		<cfargument name="complexObject" type="any" required="true" hint="Any coldfusion primative data type and if cf8 componetns."/>        <cfargument name="fileDestination" required="true" type="string" hint="The absolute path to the destination file to write to">        <!--- ************************************************************* --->		<cfscript>        	var converter = createObject("component","coldbox.system.core.conversion.ObjectMarshaller").init();					return converter.serializeObject(arguments.complexObject,arguments.fileDestination);        </cfscript>    </cffunction>        <!--- _deserialize --->    <cffunction name="_deserialize" access="public" returntype="Any" output="false" hint="Deserialize a byte array">        <!--- ************************************************************* --->		<cfargument name="binaryString" type="string" required="true" hint="The byte array string to deserialize"/>        <!--- ************************************************************* --->		<cfscript>			var converter = createObject("component","coldbox.system.core.conversion.ObjectMarshaller").init();					return converter.deserializeObject(arguments.binaryString);        </cfscript>    </cffunction>        <!--- _deserializeFromFile --->    <cffunction name="_deserializeFromFile" access="public" returntype="Any" output="false" hint="Deserialize a byte array from a file">        <!--- ************************************************************* --->		<cfargument name="fileSource" required="true" type="string" hint="The absolute path to the source file to deserialize">        <!--- ************************************************************* --->		<cfscript>			var converter = createObject("component","coldbox.system.core.conversion.ObjectMarshaller").init();					return converter.deserializeObject(filepath=arguments.fileSource);        </cfscript>    </cffunction>      <!--- marshallData --->   <cffunction name="marshallData" access="public" returntype="any" hint="Marshall data according to type" output="false" >   		<!--- ******************************************************************************** --->		<cfargument name="type" 		required="true" type="string" hint="The type to marshal to. Valid values are JSON, XML, WDDX, PLAIN, HTML, TEXT">  		<cfargument name="data" 		required="true" type="any" 	  hint="The data to marshal">   		<cfargument name="encoding" 	required="false" type="string" default="utf-8" hint="The default character encoding to use"/>		<!--- ************************************************************* --->		<cfargument name="jsonCase" 		type="string"   required="false" default="lower" hint="JSON Only: Whether to use lower or upper case translations in the JSON transformation. Lower is default"/>		<cfargument name="jsonQueryFormat" 	type="string" 	required="false" default="query" hint="JSON Only: query or array" />		<!--- ************************************************************* --->		<cfargument name="xmlColumnList"    type="string"   required="false" default="" hint="XML Only: Choose which columns to inspect, by default it uses all the columns in the query, if using a query">		<cfargument name="xmlUseCDATA"  	type="boolean"  required="false" default="false" hint="XML Only: Use CDATA content for ALL values. The default is false">		<cfargument name="xmlListDelimiter" type="string"   required="false" default="," hint="XML Only: The delimiter in the list. Comma by default">		<cfargument name="xmlRootName"      type="string"   required="false" default="" hint="XML Only: The name of the initial root element of the XML packet">		<!--- ******************************************************************************** --->		<cfset var results = "">   		<cfset var args = structnew()>   				<!--- Validate Type --->		<cfif not reFindNocase("^(JSON|PLAIN|XML|WDDX|TEXT|HTML)$",arguments.type)>			<cfthrow message="Invalid type" detail="The type you sent: #arguments.type# is invalid. Valid types are JSON, WDDX, XML and PLAIN" type="Utilities.InvalidType">		</cfif>					<!--- Switch on types --->		<cfswitch expression="#arguments.type#">						<!--- JSON --->			<cfcase value="JSON">				<cfscript>				args.queryKeyCase 	= arguments.jsonCase;				args.keyCase 		= arguments.jsonCase;				args.data 			= arguments.data;				args.queryFormat	= arguments.jsonQueryFormat;				// marshal to JSON				results 			= getPlugin("JSON").encode(argumentCollection=args);				</cfscript>				</cfcase>							<!--- WDDX --->			<cfcase value="WDDX">				<cfwddx action="cfml2wddx" input="#arguments.data#" output="results">			</cfcase>							<!--- XML --->			<cfcase value="XML">				<cfscript>				args.data = arguments.data;				args.encoding = arguments.encoding;				args.useCDATA = arguments.xmlUseCDATA;				args.delimiter = arguments.xmlListDelimiter;				args.rootName = arguments.xmlRootName;				if( len(trim(arguments.xmlColumnList)) ){ args.columnlist = arguments.xmlColumnList; }				// Marshal to xml				results = getPlugin("XMLConverter").toXML(argumentCollection=args);				</cfscript>			</cfcase>							<!--- Plain, html --->			<cfdefaultCase>				<cfset results = arguments.data>			</cfdefaultCase>		</cfswitch>				<!--- Return Marshalled data --->			<cfreturn results>   </cffunction></cfcomponent>