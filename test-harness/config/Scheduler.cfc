component {

	property name="userService" inject="UserService";

	function configure(){

		task( "vistacaballo-notifications" )
			.call( () => runEvent( "tasks.sendNotifications" ) )
				.dailyAt( "9:00" )
				.environments( [ "staging", "production"] )
				.before( ( task ) => notifyJorge )
				.after( ( task, results ) => notifyJorge )
				.onFailure( ( task, exception ) => {} )
				.onSuccess( ( task, results ) => {} )
				.onOneServer();

	}

}