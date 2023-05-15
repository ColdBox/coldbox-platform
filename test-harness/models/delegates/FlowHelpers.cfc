component{

	/**
	 * Functional construct for if statements
	 *
	 * @target  The boolean evaluator, this can be a boolean value
	 * @success The closure/lambda to execute if the boolean value is true
	 * @failure The closure/lambda to execute if the boolean value is false
	 *
	 * @return Returns Itself, used for chaining
	 */
	function when(
		required boolean target,
		required success,
		failure
	){
		if ( arguments.target ) {
			arguments.success();
		} else if ( !isNull( arguments.failure ) ) {
			arguments.failure();
		}
		return this;
	}

	/**
	 * Functional construct for execution closures depending on the unless target
	 *
	 * @target  The boolean evaluator, this can be a boolean value
	 * @success The closure/lambda to execute if the boolean value is false
	 * @failure The closure/lambda to execute if the boolean value is true
	 *
	 * @return Returns Itself, used for chaining
	 */
	function unless(
		required boolean target,
		required success,
		failure
	){
		if ( !arguments.target ) {
			arguments.success();
		} else if ( !isNull( arguments.failure ) ) {
			arguments.failure();
		}
		return this;
	}

}
