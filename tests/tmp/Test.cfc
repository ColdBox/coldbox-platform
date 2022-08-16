component
	delegates = "prefix>Delegate1,Delegate2,Delegate3"
{

	property name="data" observedBy="dataObserver";

	/**
	 * Observer for data changes.  Anytime data is set, it will be called
	 *
	 * @property The name of the property observed
	 * @old The old value
	 * @new The new value
	 */
	function dataObserver( property, old, new ){
		// Execute after data is set
	}

}
