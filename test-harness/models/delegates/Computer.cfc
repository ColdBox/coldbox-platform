component{

	// By Convention, prefix is the same as the property name
	// memoryRead(), memoryWrite()
	property name="memory" inject delegate delegatePrefix;

	// By specific prefix
	// memory2Read(), memory2Write()
	property name="memory2" inject delegate delegatePrefix="memory2";

	// By specific suffix
	// diskRead(), diskwrite()
	property name="disk" inject delegate delegateSuffix="disk";

	// Default Delegate all methods no prefix/suffix
	// work(), vacation()
	property name="worker" inject delegate;

	// Delegate only certain methods
	// workaholicWork()
	property name="workaholic" inject delegate="work" delegatePrefix;

	function init(){
		return this;
	}

}
