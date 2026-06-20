/**
 * User service singleton — provides test user data.
 */
component singleton {

	function getUsers( numeric count=10 ){
		var result = []
		for( var i = 1; i <= arguments.count; i++ ){
			result.append({
				id        : i,
				firstName : "User",
				lastName  : "Number#i#",
				email     : "user#i#@perf.test",
				role      : ( i mod 3 == 0 ) ? "admin" : "user",
				active    : true,
				createdAt : now()
			})
		}
		return result
	}

	function getUserById( required numeric id ){
		return {
			id        : arguments.id,
			firstName : "User",
			lastName  : "Number#arguments.id#",
			email     : "user#arguments.id#@perf.test",
			role      : "user",
			active    : true,
			createdAt : now()
		}
	}

}
