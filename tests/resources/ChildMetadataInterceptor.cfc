component extends="coldbox.tests.resources.BaseMetadataInterceptor" {

	/**
	 * @interceptionPoint true
	 * @asyncPriority high
	 * @eventPattern ^api
	 */
	function onCustomMetadata( event, data ){
	}

	function postProcess( event, data ){
	}

}
