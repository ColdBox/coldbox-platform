/**
 * Product service singleton — provides test product data.
 */
component singleton {

	variables.CATEGORIES = [ "Electronics", "Clothing", "Books", "Food", "Tools" ]

	function getProducts( numeric count=5 ){
		var result = []
		for( var i = 1; i <= arguments.count; i++ ){
			result.append({
				id       : i,
				name     : "Product #i#",
				sku      : "SKU-#numberFormat( i, "00000" )#",
				price    : precisionEvaluate( i * 9.99 ),
				category : variables.CATEGORIES[ ( ( i - 1 ) mod variables.CATEGORIES.len() ) + 1 ],
				inStock  : ( i mod 4 != 0 ),
				tags     : [ "tag#i#", "perf", "test" ]
			})
		}
		return result
	}

}
