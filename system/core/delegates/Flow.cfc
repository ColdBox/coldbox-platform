/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This component is mostly used as a delegate to have flow control methods for fluent beauty
 */
component accessors=true {

	/**
	 * Pivots if used in delegate or normal mode.
	 */
	private function getParent(){
		return isNull( $parent ) ? this : $parent;
	}

	/**
	 * This function will execute the target closure and return the delegated object so you
	 * can continue chaining.
	 * <pre>
	 *  // Example Flow
	 *  user
	 * 	.setName( "Luis" )
	 *  .setAge( 21 )
	 *  .peek( user => println( user.getName() ) )
	 *  .setEmail( "lmajano@ortus.com" )
	 * </pre>
	 *
	 * @target The closure to execute with the delegate. We pass the target of the delegate as the first argument.
	 *
	 * @return Returns itself
	 */
	function peek( required target ) cbMethod{
		arguments.target( getParent() );
		return getParent();
	}

	/**
	 * This function evaluates the target boolean expression and if `true` it will execute the `success` closure
	 * else, if the `failure` closure is passed, it will execute it.
	 *
	 * @target  The boolean evaluator, this can be a boolean value
	 * @success The closure/lambda to execute if the boolean value is true
	 * @failure The closure/lambda to execute if the boolean value is false
	 *
	 * @return Returns itself
	 */
	function when(
		required boolean target,
		required success,
		failure
	) cbmethod{
		if ( arguments.target ) {
			arguments.success();
		} else if ( !isNull( arguments.failure ) ) {
			arguments.failure();
		}
		return getParent();
	}

	/**
	 * This function evaluates the target boolean expression and if `false` it will execute the `success` closure
	 * else, if the `failure` closure is passed, it will execute it.
	 *
	 * @target  The boolean evaluator, this can be a boolean value
	 * @success The closure/lambda to execute if the boolean value is true
	 * @failure The closure/lambda to execute if the boolean value is false
	 *
	 * @return Returns itself
	 */
	function unless(
		required boolean target,
		required success,
		failure
	) cbmethod{
		if ( !arguments.target ) {
			arguments.success();
		} else if ( !isNull( arguments.failure ) ) {
			arguments.failure();
		}
		return getParent();
	}

	/**
	 * This function evaluates the target boolean expression and if `true` it will throw the controlled exception
	 *
	 * @target  The boolean evaluator, this can be a boolean value
	 * @type    The exception type
	 * @message The exception message
	 * @detail  The exception detail
	 *
	 * @return Returns itself
	 */
	function throwIf(
		required boolean target,
		required type,
		message = "",
		detail  = ""
	) cbmethod{
		if ( arguments.target ) {
			throw(
				type    = arguments.type,
				message = arguments.message,
				detail  = arguments.detail
			);
		}
		return getParent();
	}

	/**
	 * This function evaluates the target boolean expression and if `false` it will throw the controlled exception
	 *
	 * @target  The boolean evaluator, this can be a boolean value
	 * @type    The exception type
	 * @message The exception message
	 * @detail  The exception detail
	 *
	 * @return Returns itself
	 */
	function throwUnless(
		required boolean target,
		required type,
		message = "",
		detail  = ""
	) cbmethod{
		if ( !arguments.target ) {
			throw(
				type    = arguments.type,
				message = arguments.message,
				detail  = arguments.detail
			);
		}
		return getParent();
	}

	/**
	 * Verify if the target argument is `null` and if it is, then execute the `success` closure, else if passed
	 * execute the `failure` closure.
	 */
	function ifNull( target, required success, failure ) cbmethod{
		return when(
			isNull( arguments.target ),
			arguments.success,
			arguments.failure ?: javacast( "null", "" )
		);
	}

	/**
	 * Verify if the target argument is not `null` and if it is, then execute the `success` closure, else if passed
	 * execute the `failure` closure.
	 */
	function ifPresent( target, required success, failure ) cbmethod{
		return when(
			!isNull( arguments.target ),
			arguments.success,
			arguments.failure ?: javacast( "null", "" )
		);
	}

}
