<cfscript>

/**
* Sorts an array of structures based on a key in the structures.
*
* @param aofS      Array of structures.
* @param key      Key to sort by.
* @param sortOrder      Order to sort by, asc or desc.
* @param sortType      Text, textnocase, or numeric.
* @param delim      Delimiter used for temporary data storage. Must not exist in data. Defaults to a period.
* @return Returns a sorted array.
* @author Nathan Dintenfass (nathan@changemedia.com)
* @version 1, December 10, 2001
*/
function arrayOfStructsSort(aOfS,key){
        //by default we'll use an ascending sort
        var sortOrder = "asc";
        //by default, we'll use a textnocase sort
        var sortType = "textnocase";
        //by default, use ascii character 30 as the delim
        var delim = ".";
        //make an array to hold the sort stuff
        var sortArray = arraynew(1);
        //make an array to return
        var returnArray = arraynew(1);
        //grab the number of elements in the array (used in the loops)
        var count = arrayLen(aOfS);
        //make a variable to use in the loop
        var ii = 1;
        //if there is a 3rd argument, set the sortOrder
        if(arraylen(arguments) GT 2)
            sortOrder = arguments[3];
        //if there is a 4th argument, set the sortType
        if(arraylen(arguments) GT 3)
            sortType = arguments[4];
        //if there is a 5th argument, set the delim
        if(arraylen(arguments) GT 4)
            delim = arguments[5];
        //loop over the array of structs, building the sortArray
        for(ii = 1; ii lte count; ii = ii + 1)
            sortArray[ii] = aOfS[ii][key] & delim & ii;
        //now sort the array
        arraySort(sortArray,sortType,sortOrder);
        //now build the return array
        for(ii = 1; ii lte count; ii = ii + 1)
            returnArray[ii] = aOfS[listLast(sortArray[ii],delim)];
        //return the array
        return returnArray;
}

out = createObject("java","java.lang.StringBuilder").init('');
tab = chr(9);
br  = chr(10);

out.append('{
    "scope": "meta.name.interpolated.hash - string, source.cfscript - source.sql - text.html.cfm - string - meta - comment, source.cfscript.embedded.cfml - string, source.sql, text",
    "completions":
    [
');

functions = {
	"FrameworkSuperType" = "coldbox.system.FrameworkSuperType",
	"EventHandler" = "coldbox.system.EventHandler",
	"Interceptor" = "coldbox.system.Interceptor",
	"BaseSpec" = "testbox.system.BaseSpec"
};

ignoreMethods = "init,configure";

fncIdx = 1;
for( key in functions ){

	md = getComponentMetaData( functions[key] );

	//out.append('#tab#// Functions for: #md.name# #br#');

	sortedFunctions = arrayOfStructsSort( md.functions, "name" );

	for(x=1; x lte arrayLen( sortedFunctions ); x++){
		if( NOT structKeyExists( sortedFunctions[x],"returntype") ){ sortedFunctions[x].returntype = "any"; }
		if( NOT structKeyExists( sortedFunctions[x],"hint") ){ sortedFunctions[x].hint = ""; }

		// ignoreMethods
		if( listFindNoCase(ignoreMethods, sortedFunctions[x].name) ){ continue; }

		out.append('#tab#{ "trigger": "#sortedFunctions[x].name#\tfn. (ColdBox #key#)", "contents": "#sortedFunctions[x].name#(');

		// Parameters
		for( y=1; y lte arrayLen( sortedFunctions[x].parameters ); y++){
			if(NOT structKeyExists(sortedFunctions[x].parameters[y],"required") ){	sortedFunctions[x].parameters[y].required = false;	}
			if(NOT structKeyExists(sortedFunctions[x].parameters[y],"hint") ){	sortedFunctions[x].parameters[y].hint = "";	}
			if(NOT structKeyExists(sortedFunctions[x].parameters[y],"type") ){	sortedFunctions[x].parameters[y].type = "any";	}


			out.append( ' #sortedFunctions[x].parameters[y].name#=' );

			if( listFindNoCase( "string", sortedFunctions[x].parameters[y].type ) ){
				out.append( '\"${#y#:}\"' );
			}
			else if( listFindNoCase( "boolean", sortedFunctions[x].parameters[y].type ) ){
				out.append( '${#y#:true,false}' );
			}
			else if( listFindNoCase( "struct", sortedFunctions[x].parameters[y].type ) ){
				out.append( '${#y#:{}}' );
			}
			else if( listFindNoCase( "array", sortedFunctions[x].parameters[y].type ) ){
				out.append( '${#y#:[]}' );
			}
			else{
				out.append( '${#y#:#sortedFunctions[x].parameters[y].type#}' );
			}

			if( y lt arrayLen( sortedFunctions[x].parameters ) ){
				out.append(',');
			}
			else{
				out.append(' ');
			}

			/**out.append('<parameter name="#md.functions[x].parameters[y].name#" required="#md.functions[x].parameters[y].required#" type="#md.functions[x].parameters[y].type#">
				<help><![CDATA[ #md.functions[x].parameters[y].hint# ]]></help>
			</parameter>
			');**/
		}

		out.append(')" }');

		if( x lt arrayLen( sortedFunctions ) OR fncIdx lt structCount( functions ) ){
			out.append(',#br#');
		}
		else{
			out.append(',#br#');
		}
	}

	//out.append('#tab#// END Functions for: #md.name# #br##br#');

	fncIdx++;
}

// ****************************** SCOPES ******************************************//
scopes = {
	"controller" = "coldbox.system.web.Controller",
	"event" = "coldbox.system.web.context.RequestContext",
	"flash" = "coldbox.system.web.flash.AbstractFlashScope",
	"log" = "coldbox.system.logging.Logger",
	"logbox" = "coldbox.system.logging.LogBox",
	"binder" = "coldbox.system.ioc.config.Binder",
	"wirebox" = "coldbox.system.ioc.Injector",
	"cachebox" = "coldbox.system.cache.CacheFactory",
	"html" = "coldbox.system.core.dynamic.HTMLHelper",
	"assert" = "testbox.system.Assertion"
};
fncIdx = 1;
for( key in scopes ){

	md = getComponentMetaData( scopes[ key ] );
	out.append('#tab#// Functions for Scope: #key# #br#');
	sortedFunctions = arrayOfStructsSort( md.functions, "name" );

	for(x=1; x lte arrayLen( sortedFunctions ); x++){
		if( NOT structKeyExists( sortedFunctions[x],"returntype") ){ sortedFunctions[x].returntype = "any"; }
		if( NOT structKeyExists( sortedFunctions[x],"hint") ){ sortedFunctions[x].hint = ""; }

		// ignoreMethods
		if( listFindNoCase(ignoreMethods, sortedFunctions[x].name) ){ continue; }
		
		fwName = ( findNoCase( "coldbox.system", md.path ) ? "ColdBox" : "TestBox" );
		triggerKey = key;
		if( left( key, 1 ) == "$" ){
			triggerKey = "\\#key#";
		}

		out.append('#tab#{ "trigger": "#triggerKey#.#sortedFunctions[x].name#\tfn. (#fwName# #key#)", "contents": "#key#.#sortedFunctions[x].name#(');

		// Parameters
		for( y=1; y lte arrayLen( sortedFunctions[x].parameters ); y++){
			if(NOT structKeyExists(sortedFunctions[x].parameters[y],"required") ){	sortedFunctions[x].parameters[y].required = false;	}
			if(NOT structKeyExists(sortedFunctions[x].parameters[y],"hint") ){	sortedFunctions[x].parameters[y].hint = "";	}
			if(NOT structKeyExists(sortedFunctions[x].parameters[y],"type") ){	sortedFunctions[x].parameters[y].type = "any";	}


			out.append( ' #sortedFunctions[x].parameters[y].name#=' );

			if( listFindNoCase( "string", sortedFunctions[x].parameters[y].type ) ){
				out.append( '\"${#y#:}\"' );
			}
			else if( listFindNoCase( "boolean", sortedFunctions[x].parameters[y].type ) ){
				out.append( '${#y#:true,false}' );
			}
			else if( listFindNoCase( "struct", sortedFunctions[x].parameters[y].type ) ){
				out.append( '${#y#:{}}' );
			}
			else if( listFindNoCase( "array", sortedFunctions[x].parameters[y].type ) ){
				out.append( '${#y#:[]}' );
			}
			else{
				out.append( '${#y#:#sortedFunctions[x].parameters[y].type#}' );
			}

			if( y lt arrayLen( sortedFunctions[x].parameters ) ){
				out.append(',');
			}
			else{
				out.append(' ');
			}

			/**out.append('<parameter name="#md.functions[x].parameters[y].name#" required="#md.functions[x].parameters[y].required#" type="#md.functions[x].parameters[y].type#">
				<help><![CDATA[ #md.functions[x].parameters[y].hint# ]]></help>
			</parameter>
			');**/
		}

		out.append(')" }');

		if( x lt arrayLen( sortedFunctions ) OR fncIdx lt structCount( scopes ) ){
			out.append(',#br#');
		}
		else{
			out.append('#br#');
		}
	}

	out.append('#tab#// END Functions for Scope: #key# #br##br#');

	fncIdx++;

}

out.append('    ]
}
');


fileWrite(expandPath('/coldbox/tests/tools/IDEDictionaries/ColdBox.sublime-completions'), out.toString());
</cfscript>

<textarea rows="30" cols="160">
<cfoutput>#out.toString()#</cfoutput>
</textarea>

