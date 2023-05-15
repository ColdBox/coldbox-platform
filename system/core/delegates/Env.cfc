/**
 * This delegate is useful to deal with environment and Java property variables
 */
component singleton {

	/**
	 * Retrieve a Java System property or env value by name. It looks at properties first then environment variables
	 *
	 * @key          The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 *
	 * @throws SystemSettingNotFound When the java system property or env is not found
	 */
	function getSystemSetting( required key, defaultValue ){
		var value = getJavaSystem().getProperty( arguments.key );
		if ( !isNull( local.value ) ) {
			return value;
		}

		value = getJavaSystem().getEnv( arguments.key );
		if ( !isNull( local.value ) ) {
			return value;
		}

		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}

		throw(
			type   : "SystemSettingNotFound",
			message: "Could not find a Java System property or Env setting with key [#arguments.key#]."
		);
	}

	/**
	 * Retrieve a Java System property value by key
	 *
	 * @key          The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 *
	 * @throws SystemSettingNotFound When the java system property is not found
	 */
	function getSystemProperty( required key, defaultValue ){
		var value = getJavaSystem().getProperty( arguments.key );
		if ( !isNull( local.value ) ) {
			return value;
		}

		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}

		throw(
			type    = "SystemSettingNotFound",
			message = "Could not find a Java System property with key [#arguments.key#]."
		);
	}

	/**
	 * Retrieve a Java System environment value by name
	 *
	 * @key          The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 *
	 * @throws SystemSettingNotFound When the java system property is not found
	 */
	function getEnv( required key, defaultValue ){
		var value = getJavaSystem().getEnv( arguments.key );
		if ( !isNull( local.value ) ) {
			return value;
		}

		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}

		throw(
			type    = "SystemSettingNotFound",
			message = "Could not find a environment variable with key [#arguments.key#]."
		);
	}

	/**
	 * Retrieve an instance of Java System
	 */
	function getJavaSystem(){
		if ( isNull( variables.javaSystem ) ) {
			variables.javaSystem = createObject( "java", "java.lang.System" );
		}
		return variables.javaSystem;
	}

}
