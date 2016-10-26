/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* I model an Exception
*/
component accessors="true"{

	/**
	* Exception Struct
	*/
	property name="exceptionStruct";
	/**
	* Custom error messages
	*/
	property name="extraMessage";
	/**
	* Extra info for exception tracking
	*/
	property name="extraInfo";

	// STATIC Constructs
	variables.STRINGNULL 	= "";
	variables.ARRAYNULL 	= [];

	/**
	* Constructor
	* @errorStruct The CFML error structure
	* @extraMessage Custom error messages
	* @extraInfo Extra info to store in the error
	*/
	ExceptionBean function init(
		any errorStruct = {},
		any extraMessage = "",
		any extraInfo = ""
	){
		// init exception to empty struct
		variables.exceptionStruct = {};
		// If valid arguments, then populate it.
		if( isObject( arguments.errorStruct ) || isStruct( arguments.errorStruct ) ){
			variables.exceptionStruct = arguments.errorStruct;
		}
		variables.extraMessage 	= arguments.extraMessage;
		variables.extraInfo 	= arguments.extraInfo;

		return this;
	}

	/**
	* Get memento representation
	*/
	struct function getMemento(){
		return {
			"exceptionStruct" 	= variables.exceptionStruct,
			"extraMessage" 		= variables.extraMessage,
			"extraInfo" 		= variables.extraInfo
		};
	}

	/**
	* Set Memento
	* @memento The mento to set
	*/
	ExceptionBean function setMemento( required memento ){
		structAppend( variables, arguments.memento, true );
		return this;
	}

	/**
	* Get error type
	*/
	function getType(){
		if( structKeyExists( variables.exceptionStruct, "type" ) ){
			return variables.exceptionStruct.type;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get error message
	*/
	function getMessage(){
		if( structKeyExists( variables.exceptionStruct, "message" ) ){
			return variables.exceptionStruct.message;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get error detail
	*/
	function getDetail(){
		if( structKeyExists( variables.exceptionStruct, "detail" ) ){
			return variables.exceptionStruct.detail;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get error stackTrace
	*/
	function getStackTrace(){
		if( structKeyExists( variables.exceptionStruct, "StackTrace" ) ){
			return variables.exceptionStruct.StackTrace;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get error tag context
	*/
	array function getTagContext(){
		if( structKeyExists( variables.exceptionStruct, "TagContext" ) ){
			return variables.exceptionStruct.TagContext;
		}
		return variables.ARRAYNULL;
	}

	/**
	* Get tag context as string
	*/
	function getTagContextAsString(){
		var thisTagContext = getTagContext();

		if( arrayLen( thisTagContext ) ){
			var entry 		= "";
			var rtnString 	= "";
			for( var thisRow in thisTagContext ){
				savecontent variable="entry"{
					writeOutput( " ID: " );
					if( not structKeyExists( thisRow, "ID" ) ){
						writeOutput( "N/A;" );
					} else {
						writeOutput( "#thisRow.id#;" );
					}
					writeOutput( " LINE: #thisRow.line#; TEMPLATE: #thisRow.template# #chr( 13 )##chr( 10 )#" );
				}
				rtnString &= entry;
			}
			return rtnString;
		}

		return variables.STRINGNULL;
	}

	/**
	* Get native error code
	*/
	function getNativeErrorCode(){
		if( structKeyExists( variables.exceptionStruct, "nativeErrorCode" ) ){
			return variables.exceptionStruct.nativeErrorCode;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get SQL State
	*/
	function getSqlState(){
		if( structKeyExists( variables.exceptionStruct, "sqlState" ) ){
			return variables.exceptionStruct.sqlState;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get SQL
	*/
	function getSql(){
		if( structKeyExists( variables.exceptionStruct, "sql" ) ){
			return variables.exceptionStruct.sql;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get queryError
	*/
	function getQueryError(){
		if( structKeyExists( variables.exceptionStruct, "queryError" ) ){
			return variables.exceptionStruct.queryError;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get where portion
	*/
	function getWhere(){
		if( structKeyExists( variables.exceptionStruct, "where" ) ){
			return variables.exceptionStruct.where;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get err number
	*/
	function getErrNumber(){
		if( structKeyExists( variables.exceptionStruct, "errNumber" ) ){
			return variables.exceptionStruct.errNumber;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get missing file name
	*/
	function getMissingFileName(){
		if( structKeyExists( variables.exceptionStruct, "missingFileName" ) ){
			return variables.exceptionStruct.missingFileName;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get lock name
	*/
	function getLockName(){
		if( structKeyExists( variables.exceptionStruct, "lockName" ) ){
			return variables.exceptionStruct.lockName;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get lock operation
	*/
	function getLockOperation(){
		if( structKeyExists( variables.exceptionStruct, "lockOperation" ) ){
			return variables.exceptionStruct.lockOperation;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get error code
	*/
	function getErrorCode(){
		if( structKeyExists( variables.exceptionStruct, "errorCode" ) ){
			return variables.exceptionStruct.errorCode;
		}
		return variables.STRINGNULL;
	}

	/**
	* Get error extended info
	*/
	function getExtendedInfo(){
		if( structKeyExists( variables.exceptionStruct, "extendedInfo" ) ){
			return variables.exceptionStruct.extendedInfo;
		}
		return variables.STRINGNULL;
	}

	/**
	* String representation of this error
	*/
	function $toString(){
		var buffer = "";

		// Prepare String Buffer
		buffer = createObject( "java", "java.lang.StringBuilder" ).init( getExtraMessage() & chr( 13 ) );

		if ( getType() neq  "" ){
			buffer.append( "CFErrorType=" & getType() & chr( 13 ) );
		}
		if ( getDetail() neq  "" ){
			buffer.append( "CFDetails=" & getDetail() & chr( 13 ) );
		}
		if ( getMessage() neq "" ){
			buffer.append( "CFMessage=" & getMessage() & chr( 13 ) );
		}
		if ( getStackTrace() neq "" ){
			buffer.append( "CFStackTrace=" & getStackTrace() & chr( 13 ) );
		}
		if ( getTagContextAsString() neq "" ){
			buffer.append( "CFTagContext=" & getTagContextAsString() & chr( 13 ) );
		}
		if ( isSimpleValue( getExtraInfo() ) ){
			buffer.append( "CFExtraInfo=" & getExtraInfo() & chr( 13 ) );
		} else {
			buffer.append( "CFExtraInfo=" & serializeJSON( getExtraInfo() ) & chr( 13 ) );
		}
		return buffer.toString();
	}

}
