component {

	this.name = "Builder Dictionaries";

	// setup root path
	rootPath = reReplaceNoCase(
		getDirectoryFromPath( getCurrentTemplatePath() ),
		"tests(\\|/)tools(\\|/)IDEDictionaries(\\|/)",
		""
	);

	// ColdBox Root path
	this.mappings[ "/coldbox" ] = rootPath;

}
