<cfscript>
	for (i = 0; i < 10; i++) {
		thread name="a#i#" {
			sleep(10)
			getInstance( "Derived" ).basefoo()
		}
		thread name="b#i#" {
			sleep(10)
			getInstance( "Derived" ).basefoo()
		}
		thread name="c#i#" {
			sleep(10)
			getInstance( "Derived" ).basefoo()
		}

		thread name="a#i#" action="join";
		thread name="b#i#" action="join";
		thread name="c#i#" action="join";

		if (
			structKeyExists( cfthread[ "a#i#" ], "error" ) ||
			structKeyExists( cfthread[ "b#i#" ], "error" ) ||
			structKeyExists( cfthread[ "c#i#" ], "error" )
		) {
			writedump( cfthread[ "a#i#" ] );
			writedump( cfthread[ "b#i#" ] );
			writedump( cfthread[ "c#i#" ] );
			abort;
		} else {
			//writedump( var = cfthread[ "a#i#" ], label="Thread a#i#", expand="false" );
			//writedump( var = cfthread[ "b#i#" ], label="Thread b#i#", expand="false" );
			//writedump( var = cfthread[ "c#i#" ], label="Thread c#i#", expand="false" );
		}

	}

	writedump("OK...")
</cfscript>
