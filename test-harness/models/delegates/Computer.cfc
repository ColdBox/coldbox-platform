component{

	// By Convention, prefix is the same as the property name
	// memoryRead(), memoryWrite()
	property name="memory" inject delegate delegatePrefix;

	// By specific prefix
	// memory2Read(), memory2Write()
	property name="memory2" inject="Memory" delegate delegatePrefix="memory2";

	// By specific suffix
	// readDisk(), writeDisk()
	property name="disk" inject delegate delegateSuffix="disk";

	// By convention suffix
	// readDisk2(), writeDisk2()
	property name="disk2" inject="Disk" delegate delegateSuffix;

	// Default Delegate all methods no prefix/suffix
	// work(), vacation()
	property name="worker" inject delegate;

	// Default Delegate all methods no prefix/suffix
	// vacation()
	property name="manager" inject="Worker" delegate delegatePrefix delegateExcludes="work";

	// Delegate only certain methods
	// workaholicWork()
	property name="workaholic" inject="Worker" delegate="work" delegatePrefix;

	function init(){
		return this;
	}

	function getOutput(){
		return "Hola Computadora!";
	}

}
