component
	delegates="Memory, FlowHelpers, >Memory, ram2>memory, <Memory, ram<Memory, Worker=vacation"
{
	// Simple: Memory -> read(), write()
	// Simple: FlowHelpers -> unless(), when()
	// Empty Prefix: >Memory 		->  memoryRead(), memoryWrite()
	// Filled Prefix: ram2>Memory 	-> ram2Read(), ram2Write()
	// Empty Suffix: <Memory 		-> readMemory(), writeMemory()
	// Filled Suffix ram<Memory 	-> readRam(), writeRam()
	// Targeted Methods: Worker(vacation) -> vacation() NO work()

	function init(){
		return this;
	}

}
