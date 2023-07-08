component threadsafe{

    property name="wirebox" inject="wirebox";
    property name="someSingleton" inject="SomeSingleton";

    /**
	* Init
	* @wirebox.inject wirebox
	*/
	public function init( required wirebox ) {
        return this;
    }

    public function basefoo() {
        return someSingleton.doSomeWork(); // ~1/20 chance that someSingleton is null
    }
}
