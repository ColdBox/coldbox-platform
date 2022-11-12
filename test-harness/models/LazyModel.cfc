/**
 * I am a lazy object
 */
component accessors="true" singleton{

	// Lazy Properties by Convention
	property name="util" lazy;
	property name="lazyData" lazyNoLock;

	// Lazy Properties by Explicit Name
	property name="util2" lazy="constructUtil";
	property name="lazyData2" lazyNoLock="constructData";

	function buildUtil(){
		return "Utility Built at #now()#";
	}
	function buildLazyData(){
		return {
			name : "lazy", now : now()
		};
	}
	function constructUtil(){
		return buildUtil();
	}
	function constructData(){
		return buildLazyData();
	}

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

}
