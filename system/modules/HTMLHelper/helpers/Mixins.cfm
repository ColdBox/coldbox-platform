<cfscript>
	/**
	 * Add a js/css asset(s) to the html head section. You can also pass in a list of assets. This method
	 * keeps track of the loaded assets so they are only loaded once
	 *
	 * @asset The asset(s) to load, only js or css files. This can also be a comma delimited list.
	 */
	string function addAsset( required asset ){
		return html().addAsset( argumentCollection = arguments );
	}

	/**
	 * Get the HTML Helper model
	 *
	 * @return HTMLHelper.models.HTMLHelper
	 */
	function html(){
		if( isNull( variableas.htmlHelper ) ){
			variables.htmlHelper = getInstance( "@HTMLHelper" );
		}
		return variables.htmlHelper;
	}
</cfscript>
