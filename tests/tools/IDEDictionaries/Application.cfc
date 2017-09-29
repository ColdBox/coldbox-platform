component{
	this.name ="Builder Dictionaries";

	// setup root path
	rootPath = REReplaceNoCase( getDirectoryFromPath( getCurrentTemplatePath() ), "tests(\\|/)tools(\\|/)IDEDictionaries(\\|/)", "" );
	// ColdBox Root path
	writeOutput( getDirectoryFromPath( getCurrentTemplatePath() ) );
	writeOutput( rootPath ); abort;
	this.mappings[ "/coldbox" ] = rootPath;
	
}