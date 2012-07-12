/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

@Author Luis Majano
@Description A cool annotation based Transaction Aspect for WireBox
	This interceptor will inspect objects for the 'transactional' annotation and if found,
	it will wrap it in a transaction safe hibernate transaction.  This aspect is a self binding
	aspect for WireBox that registers itself using the two annotations below
@classMatcher any
@methodMatcher annotatedWith:transactional

The transactional annotation can have a value if you are using multi-datasources with ORM.
The value of the transactional annotation denotes the dsn.
**/
component implements="coldbox.system.aop.MethodInterceptor" accessors="true" {

	// Dependencies
	property name="log" inject="logbox:logger:{this}";

	/**
	* Constructor
	*/
	function init(){
		orm = new coldbox.system.orm.hibernate.util.ORMUtilFactory().getORMUtil();
		return this;
	}

	/**
	* The AOP around advice for hibernate transactions
	*/
	any function invokeMethod(required invocation) output=false{

		// Are we already in a transaction?
		if( structKeyExists(request,"cbox_aop_transaction") ){
			// debug?
			if( log.canDebug() ){ log.debug("Call to '#arguments.invocation.getTargetName()#.#arguments.invocation.getMethod()#()' already transactioned, just executing it"); }
			// Just execute and return;
			return arguments.invocation.proceed();
		}

		// Determine default datasource
		var datasource = orm.getDefaultDatasource();
		// Check if the method transactional annotation has a value or not, which should be the datasource
		var methodMD = arguments.invocation.getMethodMetadata();
		if( structKeyExists(methodMD, "transactional") and len(methodMD.transactional) ){
			datasource = methodMD.transactional;
		}

		// Else, transaction safe call
		var tx = orm.getSession( datasource ).beginTransaction();
		try{

			// mark transaction began
			request["cbox_aop_transaction"] = true;

			// debug?
			if( log.canDebug() ){ log.debug("Call to '#arguments.invocation.getTargetName()#.#arguments.invocation.getMethod()#()' is now transactioned and begins execution"); }

			// Proceed
			var results = arguments.invocation.proceed();

			// commit transaction
			tx.commit();
		}
		catch(Any e){
			// remove pointer
			structDelete(request,"cbox_aop_transaction");
			// Log Error
			log.error("An exception ocurred in the AOPed transactio for target: #arguments.invocation.getTargetName()#, method: #arguments.invocation.getMethod()#: #e.message# #e.detail#",e);
			// rollback
			try{
				tx.rollback();
			}
			catch(any e){
				// silent rollback as something really went wrong
				log.error("Error rolling back transaction: #e.detail# #e.message#", e);
			}
			//throw it
			rethrow;
		}

		// remove pointer, out of transaction now.
		structDelete(request,"cbox_aop_transaction");

		// Results? If found, return them.
		if( NOT isNull(results) ){ return results; }
	}

}