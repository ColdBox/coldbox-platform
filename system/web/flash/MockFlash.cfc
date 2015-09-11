/**
*********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* A flash scope that is used for unit testing.
* @author Luis Majano <lmajano@ortussolutions.com>
*/
component extends="coldbox.system.web.flash.AbstractFlashScope" accessors="true"{

	// The flash struct
	property name="mockFlash";

	/**
	* Constructor
	* @controller.hint ColdBox Controller
	* @defaults.hint Default flash data packet for the flash RAM object=[scope,properties,inflateToRC,inflateToPRC,autoPurge,autoSave]
	*/
	function init( required controller, required struct defaults={} ){
		super.init( argumentCollection=arguments );

		variables.mockFlash = {};

		return this;
	}

	/**
	* Save the flash storage in preparing to go to the next request
	* @return MockFlash
	*/
	function saveFlash(){
		variables.mockFlash = getScope();
		return this;
	}

	/**
	* Checks if the flash storage exists and IT HAS DATA to inflate.
	*/
	boolean function flashExists(){
		return ( structIsEmpty( variables.mockFlash ) ? false : true );
	}

	/**
	* Get the flash storage structure to inflate it.
	*/
	struct function getFlash(){
		return flashExists() ? variables.mockFlash : {};
	}

	/**
	* Remove the entire flash storage
	* @return MockFlash
	*/
	function removeFlash(){
		structClear( variables.mockFlash );
		return this;
	}

}