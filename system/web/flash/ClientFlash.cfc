/**
*********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* This flash scope is smart enought to not create unecessary client variables
* unless data is put in it.  Else, it does not abuse session.
* @author Luis Majano <lmajano@ortussolutions.com>
*/
component extends="coldbox.system.web.flash.AbstractFlashScope" accessors="true"{

	// The flash key
	property name="flashKey";

	/**
	* Constructor
	* @controller.hint ColdBox Controller
	* @defaults.hint Default flash data packet for the flash RAM object=[scope,properties,inflateToRC,inflateToPRC,autoPurge,autoSave]
	*/
	function init( required controller, required struct defaults={} ){
		super.init( argumentCollection=arguments );

		variables.converter = new coldbox.system.core.conversion.ObjectMarshaller();
		variables.flashKey 	= "cbox_flash";

		return this;
	}

	/**
	* Save the flash storage in preparing to go to the next request
	* @return ClientFlash
	*/
	function saveFlash(){
		client[ getFlashKey() ] = variables.converter.serializeObject( getScope() );
		return this;
	}

	/**
	* Checks if the flash storage exists and IT HAS DATA to inflate.
	*/
	boolean function flashExists(){
		// Check if session is defined first
		if( NOT isDefined( "client" ) ) { return false; }
		// Check if storage is set
		return ( structKeyExists( client, getFlashKey() ) );
	}

	/**
	* Get the flash storage structure to inflate it.
	*/
	struct function getFlash(){
		return flashExists() ? variables.converter.deserializeObject( client[ getFlashKey() ] ) : {};
	}

	/**
	* Remove the entire flash storage
	* @return ClientFlash
	*/
	function removeFlash(){
		structDelete( client, getFlashKey() );
		return this;
	}

}