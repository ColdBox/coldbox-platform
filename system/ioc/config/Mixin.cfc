component {

	function $init( required mixins ){
		// Include the mixins
		for ( var thisMixin in arguments.mixins ) {
			thisMixin = trim( thisMixin );
			if ( listLast( thisMixin, "." ) != "cfm" ) {
				include "#thisMixin#.cfm";
			} else {
				include "#thisMixin#";
			}
		}

		// Expose them
		for ( var key in variables ) {
			if ( isCustomFunction( variables[ key ] ) AND !structKeyExists( this, key ) ) {
				this[ key ] = variables[ key ];
			}
		}

		return this;
	}

}
