/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* This flash scope is smart enough to not create unecessary session variables
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

		variables.flashKey = "cbox_flash_scope";

		return this;
	}

	/**
	* Save the flash storage in preparing to go to the next request
	* @return SessionFlash
	*/
	function saveFlash(){
		lock scope="session" type="exclusive" throwontimeout="true" timeout="20"{
			session[ variables.flashKey ] = getScope();
		}
		return this;
	}

	/**
	* Checks if the flash storage exists and IT HAS DATA to inflate.
	*/
	boolean function flashExists(){
		// Check if session is defined first
		if( NOT isDefined( "session" ) ) { return false; }
		// Check if storage is set and not empty
		return ( structKeyExists( session, getFlashKey() ) AND NOT structIsEmpty( session[ getFlashKey() ] ) );
	}

	/**
	* Get the flash storage structure to inflate it.
	*/
	struct function getFlash(){
		if( flashExists() ){
			lock scope="session" type="readonly" throwontimeout="true" timeout="20"{
				return session[ variables.flashKey ];
			}
		}

		return {};
	}

	/**
	* Remove the entire flash storage
	* @return SessionFlash
	*/
	function removeFlash(){
		lock scope="session" type="exclusive" throwontimeout="true" timeout="20"{
			 structDelete( session, getFlashKey() );
		}
		return this;
	}

}