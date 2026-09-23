component {

	frameworkRoot = createObject( "java", "java.io.File" )
		.init( getDirectoryFromPath( getCurrentTemplatePath() ) & "../../" )
		.getCanonicalPath();

	this.name                   = "coldbox-full-null-regression-#hash( frameworkRoot )#";
	this.enableNullSupport      = true;
	this.mappings[ "/coldbox" ] = frameworkRoot;

}
