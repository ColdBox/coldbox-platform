component displayName="TestBox xUnit suite" labels="railo,cf" extends="Assertionscf9Test"{

	function beforeTests(){
		super.beforeTests();
		addAssertions({
			isAwesome = function( required expected ){
				return ( arguments.expected == "Luis Majano" ? true : false );
			},
			isNotAwesome = function( required expected ){
				return ( arguments.expected == "Luis Majano" ? false : true );
			}
		});
	}

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

	function testAwesomeCustomAssertion(){
		$assert.isAwesome( "Luis Majano" );
	}

	function testNegatedAwesomeCustomAssertion(){
		$assert.isNotAwesome( "Luis Majano" );
	}

}