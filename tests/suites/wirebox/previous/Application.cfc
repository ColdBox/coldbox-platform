component extends="tests.Application"{

	this.name = "prev test suite";

	this.mappings[ "/coldbox" ] = getDirectoryFromPath( getCurrentTemplatePath() ) & "lib/coldbox";

}
