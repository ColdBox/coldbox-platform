﻿component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		logbox   = new coldbox.system.logging.LogBox();
		appender = createMock( className = "coldbox.system.logging.AbstractAppender" );
		appender.init( "mytest", structNew() ).setLogBox( logbox );
	}

	function testIsInited(){
		assertEquals( appender.isInitialized(), false );
		assertEquals( 0, appender.getLevelMin() );
		assertEquals( 4, appender.getLevelMax() );
	}

	function testcanLog(){
		for ( x = 0; x lte 4; x++ ) assertTrue( appender.canLog( x ) );

		assertFalse( appender.canLog( 5 ) );

		appender.setLevelMax( 0 );
		for ( x = 1; x lte 4; x++ ) assertFalse( appender.canLog( x ) );
	}

}
