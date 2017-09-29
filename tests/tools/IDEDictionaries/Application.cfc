component{
	this.name ="Builder Dictionaries";

	// setup root path
	rootPath = REReplaceNoCase( getDirectoryFromPath( getCurrentTemplatePath() ), "tests(\\|/)tools(\\|/)IDEDictionaries(\\|/)", "" );
	
	throw( getDirectoryFromPath( getCurrentTemplatePath() ) & ' --- ' & rootPath );
	
	// ColdBox Root path
	this.mappings[ "/coldbox" ] = rootPath;
	
}