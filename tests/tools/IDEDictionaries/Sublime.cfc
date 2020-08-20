component {

	variables.ignoreMethods = "init,$init,configure";
	variables.outFile 		= "ColdBox.sublime-completions";

	/**
	 * Generate the ColdBox Sublime Completions
	 */
	string function run(){
		var out = createObject( "java", "java.lang.StringBuilder" )
			.init( "{
				""scope"": ""meta.name.interpolated.hash - string, source.cfscript - source.sql - text.html.cfm - string - meta - comment, source.cfscript.embedded.cfml - string, source.sql, text, source.cfml.script, embedding.cfml"",
				""completions"":
				[
		" );

		// Transpile Globals + Scopes
		out.append( transpileGlobals() );
		out.append( "," );
		out.append( transpileScopes() );

		// Close it out
		out.append( "]}" );

		// Write it out
		fileWrite( variables.outFile, out.toString() );

		// Return data
		return out.toString();
	}

	private function transpileGlobals(){
		return {
			"FrameworkSuperType" : "coldbox.system.FrameworkSuperType",
			"EventHandler"       : "coldbox.system.EventHandler",
			"Interceptor"        : "coldbox.system.Interceptor",
			"BaseSpec"           : "testbox.system.BaseSpec"
		}
		// discover each components' function collection
		.map( ( k, v ) => getComponentMetadata( v ).functions )
		// process each function set
		.map( ( cfcName, functions ) => {
			return functions
				// Ignore reserved methods
				.filter( ( thisFunction ) => !listFindNoCase( variables.ignoreMethods, thisFunction.name ) )
				// Transpile function and parameters
				.map( ( thisFunction ) => {
					var fwName = ( findNoCase( "BaseSpec", cfcName ) ? "TestBox" : "ColdBox" );
					return
						"{
							""trigger"": ""#thisFunction.name#\tfn. (#fwName#:#cfcName#)"",
							""contents"": ""#thisFunction.name#(#processParams( thisFunction.parameters )# )""
					}";
				})
				// Flatten transpilation
				.toList();
		} )
		// Combine all globals
		.reduce( ( result, key, value ) => {
			result.append( value );
			return result;
		}, [] )
		// Flatten it
		.toList();
		;
	}

	private function processParams( parameters ){
		return arguments.parameters
			.map( ( thisParam, thisIndex, thisArray ) => {
				var thisType = thisParam.type ?: "any";
				var out = " #thisParam.name#=";

				if ( listFindNoCase( "string", thisType ) ) {
					out &= "\""${#thisIndex#:}\""";
				} else if ( listFindNoCase( "boolean", thisType ) ) {
					out &= "${#thisIndex#:true,false}";
				} else if ( listFindNoCase( "struct", thisType ) ) {
					out &= "${#thisIndex#:{}}";
				} else if ( listFindNoCase( "array", thisType ) ) {
					out &= "${#thisIndex#:[]}";
				} else {
					out &= "${#thisIndex#:#thisType#}";
				}
				return out;
			} )
			.toList();
	}

	private function transpileScopes(){
		return {
			"controller" : "coldbox.system.web.Controller",
			"event"      : "coldbox.system.web.context.RequestContext",
			"flash"      : "coldbox.system.web.flash.AbstractFlashScope",
			"log"        : "coldbox.system.logging.Logger",
			"logbox"     : "coldbox.system.logging.LogBox",
			"binder"     : "coldbox.system.ioc.config.Binder",
			"wirebox"    : "coldbox.system.ioc.Injector",
			"cachebox"   : "coldbox.system.cache.CacheFactory",
			"html"       : "coldbox.system.modules.HTMLHelper.models.HTMLHelper",
			"assert"     : "testbox.system.Assertion"
		}
		// discover each components' function collection
		.map( ( k, v ) => getComponentMetadata( v ).functions )
		// process each function set
		.map( ( thisScope, functions ) => {
			return functions
				// Ignore reserved methods
				.filter( ( thisFunction ) => !listFindNoCase( variables.ignoreMethods, thisFunction.name ) )
				// Transpile function and parameters
				.map( ( thisFunction ) => {
					var fwName = ( findNoCase( "assert", thisScope ) ? "TestBox" : "ColdBox" );
					return
						"{
							""trigger"": ""#thisScope#.#thisFunction.name#\tfn. (#fwName#:#thisScope#)"",
							""contents"": ""#thisScope#.#thisFunction.name#(#processParams( thisFunction.parameters )# )""
						}";
				})
				// Flatten transpilation
				.toList();
		} )
		// Combine all scopes
		.reduce( ( result, key, value ) => {
			result.append( value );
			return result;
		}, [] )
		// Flatten it
		.toList();
		;
	}
}