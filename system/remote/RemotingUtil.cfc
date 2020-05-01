/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano <lmajano@ortussolutions.com>
 * Remoting Utility
 */
component {

	/*
	Based on original function by Elliot Sprehn, found here
	http://livedocs.adobe.com/coldfusion/7/htmldocs/wwhelp/wwhimpl/common/html/wwhelp.htm?context=ColdFusion_Documentation&file=00000271.htm
	by Chris Blackwell
	*/

	/**
	 * Clear the CFHTMLHead buffer
	 */
	void function clearHeaderBuffer(){
		var my = {};

		switch ( trim( server.coldfusion.productname ) ) {
			case "ColdFusion Server":
				my.out = getPageContext().getOut();
				//  It's necessary to iterate over this until we get to a coldfusion.runtime.NeoJspWriter
				while ( getMetadata( my.out ).getName() == "coldfusion.runtime.NeoBodyContent" ) {
					my.out = my.out.getEnclosingWriter();
				}
				my.method = my.out.getClass().getDeclaredMethod( "initHeaderBuffer", [] );
				my.method.setAccessible( true );
				my.method.invoke( my.out, [] );
				break;
			case "Lucee":
				my.out = getPageContext().getOut();
				while ( getMetadata( my.out ).getName() == "lucee.runtime.writer.BodyContentImpl" ) {
					my.out = my.out.getEnclosingWriter();
				}
				my.headData = my.out.getClass().getDeclaredField( "headData" );
				my.headData.setAccessible( true );
				my.headData.set( my.out, createObject( "java", "java.lang.String" ).init( "" ) );
				break;
		}
	}

}
