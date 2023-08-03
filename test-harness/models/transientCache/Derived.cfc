component extends="Base" threadsafe{

	/**
	* Init
	* @wirebox.inject wirebox
	*/
	public function init(
		required wirebox,
	) {
		SUPER.init( argumentCollection = arguments );
        return this;
    }
}
