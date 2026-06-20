/**
 * Module-scoped item service singleton.
 */
component singleton {

	function getItems( numeric count=10 ){
		var result = []
		for( var i = 1; i <= arguments.count; i++ ){
			result.append({
				id       : i,
				name     : "Item #i#",
				code     : "ITEM-#i#",
				value    : i * 1.5,
				active   : true
			})
		}
		return result
	}

}
