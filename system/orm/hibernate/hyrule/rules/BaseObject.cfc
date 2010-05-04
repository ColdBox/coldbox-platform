component {

	public string function getType(data){

		if(isNull(arguments.data)){
			return "Null";
		}

		if( isSimpleValue(arguments.data) ){

			if(isNumeric(arguments.data)) {
				return "Numeric";
			}
			if(isDate(arguments.data)) {
				return "Date";
			}
			if(isBoolean(arguments.data)) {
				return "Boolean";
			}
			if(isBinary(arguments.data)) {
				return "Binary";
			}
			return "String";

		} else {

			if(isArray(arguments.data)) {
				return "Array";
			}
			if(isStruct(arguments.data)) {
				return "Struct";
			}
			if(isQuery(arguments.data)) {
				return "Query";
			}
			if(isObject(arguments.data)) {
				return "Object";
			}

		}
	}

}