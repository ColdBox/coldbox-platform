/**
 * Test fixture: a module that registers one of everything unload() has to clean up.
 */
component {

	this.title      = "Unload Fixture";
	this.aliases    = [ "unloadAlias" ];
	this.entryPoint = "unloadmain";

	function configure(){
		variables.interceptors = [ { class  : "tests.resources.unloadfixtures.unloadMain.interceptors.Listener" } ];

		variables.executors = {
			// The spec creates this one first, so it belongs to someone else
			"unloadShared" : { type  : "fixed", threads  : 1 },
			// Only this module declares this one
			"unloadOwn"    : { type  : "fixed", threads  : 1 }
		};
	}

	function onUnload(){
		param request.unloadMainCount = 0;
		request.unloadMainCount++;
	}

}
