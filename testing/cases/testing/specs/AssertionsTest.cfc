component displayName="TestBox xUnit suite" labels="railo,cf" extends="Assertionscf9Test"{

	function testThrows(){
		$assert.throws(function(){
			var hello = invalidFunction();
		});
	}

	function testNotThrows(){
		$assert.notThrows(function(){
			var hello = 1;
		});
	}

}