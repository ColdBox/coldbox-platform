<cfscript>
	/**
	 * Add a js/css asset(s) to the html head section. You can also pass in a list of assets. This method
	 * keeps track of the loaded assets so they are only loaded once
	 *
	 * @asset The asset(s) to load, only js or css files. This can also be a comma delimited list.
	 */
	string function addAsset( required asset ){
		return getInstance( "@HTMLHelper" ).addAsset( argumentCollection = arguments );
	}
</cfscript>
