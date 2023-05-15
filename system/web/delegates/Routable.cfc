/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Provides ColdBox routing capabilities
 */
component {

	// DI
	property
		name    ="context"
		inject  ="coldbox:requestContext"
		delegate="getHTMLBaseURL,getHTMLBasePath,getSESBasePath,getSESBaseURL,route,buildLink,getPath,getUrl";

}
