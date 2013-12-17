/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Description :
	I model a coldbox request. I hold the request's variables, rendering variables, and facade to the request's HTTP request.
**/
component serializable=false{

	/************************************** CONSTRUCTOR *********************************************/
	
	function init(required struct properties, required any controller){
		instance = structnew();

		// Create the Collections
		instance.context		= structnew();
		instance.privateContext = structnew();

		// flag if using SES
		instance.isSES 				= false;
		// routed SES structures
		instance.routedStruct 		= structnew();
		// flag for no event execution
		instance.isNoExecution  	= false;
		// the name of the event via URL/FORM/REMOTE
		instance.eventName			= arguments.properties.eventName;

		// Registered Layouts
		instance.registeredLayouts	= structnew();
		if( structKeyExists(arguments.properties,"registeredLayouts") ){
			instance.registeredLayouts = arguments.properties.registeredLayouts;
		}

		// Registered Folder Layouts
		instance.folderLayouts	= structnew();
		if( structKeyExists(arguments.properties,"folderLayouts") ){
			instance.folderLayouts = arguments.properties.folderLayouts;
		}

		// Registered View Layouts
		instance.viewLayouts	= structnew();
		if( structKeyExists(arguments.properties,"viewLayouts") ){
			instance.viewLayouts = arguments.properties.viewLayouts;
		}

		// Default layout
		instance.defaultLayout = arguments.properties.defaultLayout;

		// SES Base URL
		instance.SESBaseURL = "";
		if( structKeyExists(arguments.properties,"SESBaseURL") ){
			instance.SESBaseURL = arguments.properties.SESBaseURL;
		}
		
		// Store Controller
		instance.controller = arguments.controller;

		return this;
	}
	
	/************************************** COLLECTION METHODS *********************************************/
	
	struct function getMemento(){
		return instance;
	}
	
	function setMemento(required struct memento){
		variables.instance = arguments.memento;
		return this;
	}
	
	/**
	* 
	*/
	function getCollection(boolean deepCopyFlag=false, boolean private=false){
		// Private Collection
		if( arguments.private ){
			if( arguments.deepCopyFlag ){ return duplicate(instance.privateContext); }
			return instance.privateContext;
		}
		// Public Collection
		if ( arguments.deepCopyFlag ){ return duplicate(instance.context); }
		return instance.context;
	}
	
	/**
	* 
	*/
	function clearCollection(boolean private=false){
		if( arguments.private ) { structClear(instance.privateContext); }
		else { structClear(instance.context); }
		return this;
	}
	
	/**
	* 
	*/
	function collectionAppend(boolean private=false){
		if( arguments.private ) { structAppend(instance.privateContext,arguments.collection, arguments.overwrite); }
		else { structAppend(instance.context,arguments.collection, arguments.overwrite); }
		return this;
	}
	
	/**
	* 
	*/
	numeric function getSize(boolean private=false){
		if( arguments.private ){ return structCount(instance.privateContext); }
		return structCount(instance.context);
	}
	
	/************************************** KEY METHODS *********************************************/
	
	/**
	* 
	*/
	function getValue(required name, defaultValue, boolean private=false){
		var collection = instance.context;

		// private context switch
		if( arguments.private ){ collection = instance.privateContext; }

		// Check if key exists
		if( structKeyExists(collection, arguments.name) ){
			return collection[arguments.name];
		}

		// Default value
		if( structKeyExists(arguments, "defaultValue") ){
			return arguments.defaultValue;
		}

		$throw("The variable: #arguments.name# is undefined in the request collection (private=#arguments.private#)",
			   "Keys Found: #structKeyList(collection)#",
			   "RequestContext.ValueNotFound");
	}
	
	/**
	* 
	*/
	function getTrimValue(required name, defaultValue, boolean private=false){
		var value = getValue(argumentCollection=arguments);

		// Verify if Simple
		if( isSimpleValue(value) ){ return trim(value); }

		return value;
	}
	
	/**
	* 
	*/
	function setValue(required name, required value, boolean private=false){
		var collection = instance.context;
		if( arguments.private ) { collection = instance.privateContext; }

		collection[arguments.name] = arguments.value;
		return this;
	}
	
	/**
	* 
	*/
	function removeValue(required name, boolean private=false){
		var collection = instance.context;
		if( arguments.private ){ collection = instance.privateContext; }

		structDelete(collection,arguments.name);

		return this;
	}
	
	/**
	* 
	*/
	function valueExists(required name, boolean private=false){
		var collection = instance.context;
		if( arguments.private ){ collection = instance.privateContext; }
		return structKeyExists(collection, arguments.name);
	}
	
	/**
	* 
	*/
	function paramValue(required name, required value, boolean private=false){
		if ( not valueExists(name=arguments.name,private=arguments.private) ){
			setValue(name=arguments.name,value=arguments.value,private=arguments.private);
		}
		return this;
	}
	
	/************************************** CURRENT DATA METHODS *********************************************/
	
	/**
	* 
	*/
	function getCurrentView(){
		return getValue("currentView","",true);
	}	

	/**
	* 
	*/
	function getCurrentViewArgs(){
		return getValue("currentViewArgs", structNew(), true);
	}
	
	function getCurrentLayout(){
		return getValue("currentLayout","",true);
	}

	function getCurrentEvent(){
		return getValue(getEventName(),"");
	}
	
	function getCurrentHandler(){
		var testHandler = reReplace(getCurrentEvent(),"\.[^.]*$","");
		if( listLen(testHandler,".") eq 1){
			return testHandler;
		}

		return listLast(testHandler,".");
	}
	
	function getCurrentAction(){
		return listLast(getCurrentEvent(),".");
	}
	
	/************************************** VIEW-LAYOUT METHODS *********************************************/
	
	/**
	* 
	*/
	function setView(view, boolean noLayout=false, layout, struct args={}){
	    var key 		= "";
	    var cacheEntry 	= structnew();

		// view and name mesh
		if( structKeyExists(arguments,"name") ){ arguments.view = arguments.name; }

		// Local Override
		if( structKeyExists( arguments,"layout" ) ){
			setLayout( arguments.layout );
		}
		// If we need a layout or we haven't overriden the current layout enter if...
	    else if ( NOT arguments.nolayout AND NOT getValue( "layoutoverride", false, true ) ){

	    	//Verify that the view has a layout in the viewLayouts structure.
		    if ( StructKeyExists( instance.ViewLayouts, lcase( arguments.view ) ) ){
				setValue( "currentLayout", instance.ViewLayouts[ lcase( arguments.view ) ], true );
		    }
			else{
				//Check the folders structure
				for( key in instance.folderLayouts ){
					if ( reFindnocase('^#key#', lcase( arguments.view ) ) ){
						setValue( "currentLayout", instance.FolderLayouts[ key ],true);
						break;
					}
				}//end for loop
			}//end else

			//If not layout, then set default from main application
			if( not valueExists( "currentLayout", true ) ){
				setValue( "currentLayout", instance.defaultLayout, true );
			}

		}//end if overridding layout

		// No Layout Rendering?
		if( arguments.nolayout ){
			removeValue( 'currentLayout', true );
		}

		//Set the current view to render.
		instance.privateContext[ "currentView" ] = arguments.view;

		// Record the optional arguments
		setValue("currentViewArgs", arguments.args, true);
		
		return this;
	}

	
	function noLayout(){
		// remove layout if any
		structDelete(instance.privateContext,"currentLayout");
		// set layout overwritten flag.
		instance.privateContext["layoutoverride"] = true;
		return this;
	}

	function setLayout(required name){
		var layouts = instance.registeredLayouts;
		// Set direct layout first.
		instance.privateContext[ "currentLayout" ] = trim( arguments.name ) & ".cfm";
		// Do an Alias Check and override if found.
		if( structKeyExists( layouts, arguments.name ) ){
			instance.privateContext[ "currentLayout" ] = layouts[ arguments.name ];
		}
		// set layout overwritten flag.
		instance.privateContext[ "layoutoverride" ] = true;
		return this;
	}
	
	function getDefaultLayout(){
		return instance.defaultLayout;
	}
	
	function setDefaultLayout(required defaultLayout){
		instance.defaultLayout = arguments.DefaultLayout;
		return this;
	}
	
	struct function getViewLayouts(){
		return instance.ViewLayouts;
	}
	
	struct function getRegisteredLayouts(){
    	return instance.registeredLayouts;
	}
	
	struct function getFolderLayouts(){
		return instance.FolderLayouts;
	}
	
	/************************************** EVENT METHODS *********************************************/

	function overrideEvent(required event){
		setValue(getEventName(),arguments.event);
		return this;
	}

	function noRender(boolean remove=false){
		if (arguments.remove eq false)
			setValue(name="coldbox_norender",value=true,private=true);
		else
			removeValue(name="coldbox_norender",private=true);

		return this;
	}

	function isNoRender(){
		return getValue(name="coldbox_norender",defaultValue=false,private=true);
	}
	
	function getEventName(){
		return instance.eventName;
	}
	
	function isNoExecution(){
		return instance.isNoExecution;
	}	
	
	function noExecution(){
		instance.isNoExecution = true;
   		return this;
	}

	/************************************** URL METHODS *********************************************/	

	function getSelf(){
		return "index.cfm?" & getEventName() & "=";
	}

	function buildLink(required linkTo, boolean ssl=false, baseURL="", queryString=""){
		var frontController = "index.cfm";

		// Base URL Override
		if( len( trim( arguments.baseURL ) ) neq 0 ){
			frontController = arguments.baseURL;
		}

		// Check if sending in Query String
		if( len( trim( arguments.queryString ) ) eq 0 ){
			return "#frontController#?#getEventName()#=#arguments.linkto#";
		}
		else{
			return "#frontController#?#getEventName()#=#arguments.linkto#&#arguments.queryString#";
		}
		
	}
	
	boolean function isSSL(){
		if (isBoolean(cgi.server_port_secure) AND cgi.server_port_secure) { return true; }
		return false;
	}
	
	/************************************** RESTFUL *********************************************/
	
	function renderData(type="HTML", required data, contentType="", encoding="utf-8", numeric statusCode=200, statusText="", location="",
						jsonCallback="", jsonQueryFormat="query", boolean jsonAsText=false,
						xmlColumnList="", boolean xmlUseCDATA=false, xmlListDelimiter=",", xmlRootName="",
						struct pdfArgs={}, formats="", formatsView="", boolean isBinary=false){

		var rd = structnew();
	
		// With Formats?
		if( isArray( arguments.formats ) OR len( arguments.formats ) ){
			return renderWithFormats( argumentCollection=arguments );
		}
		
		// Validate rendering type
		if( not reFindnocase("^(JSON|JSONP|JSONT|WDDX|XML|PLAIN|HTML|TEXT|PDF)$",arguments.type) ){
			$throw("Invalid rendering type","The type you sent #arguments.type# is not a valid rendering type. Valid types are JSON,JSONP,JSONT,XML,WDDX,TEXT,PLAIN,PDF","RequestContext.InvalidRenderTypeException");
		}

		// Default Values for incoming variables
		rd.type = arguments.type;
		rd.data = arguments.data;
		rd.encoding = arguments.encoding;
		rd.contentType = "text/html";
		rd.isBinary = arguments.isBinary;

		// HTTP status
		rd.statusCode = arguments.statusCode;
		rd.statusText = arguments.statusText;

		// XML Properties
		rd.xmlColumnList = arguments.xmlColumnList;
		rd.xmluseCDATA = arguments.xmlUseCDATA;
		rd.xmlListDelimiter = arguments.xmlListDelimiter;
		rd.xmlRootName = arguments.xmlRootName;

		// JSON Properties
		rd.jsonQueryFormat 	= arguments.jsonQueryFormat;
		rd.jsonCallBack 	= arguments.jsonCallBack;

		// PDF properties
		rd.pdfArgs = arguments.pdfArgs;

		// Automatic Content Types by marshalling type
		switch( rd.type ){
			case "JSON" : case "JSONP" : {
				rd.contenttype = 'application/json';
				if( arguments.jsonAsText ){ rd.contentType = "text/plain"; }
				break;
			}
			case "JSONT" :{
				rd.contentType = "text/plain";
				rd.type = "JSON";
				break;
			}
			case "XML" : case "WDDX" : { rd.contentType = "text/xml"; break; }
			case "TEXT" : { rd.contentType = "text/plain"; break; }
			case "PDF" : {
				rd.contentType = "application/pdf";
				rd.isBinary = true;
				break;
			}
		}

		// If contenttype passed, then override it?
		if( len(trim(arguments.contentType)) ){
			rd.contentType = arguments.contentType;
		}

		// HTTP Location?
		if( len(arguments.location) ){ setHTTPHeader(name="location", value=arguments.location); }

		// Save Rendering data privately.
		setValue(name='cbox_renderdata',value=rd,private=true);

		return this;
	}
	
	private function renderWithFormats(){
		var viewToRender = "";
			
		// inflate list to array if found
		if( isSimpleValue( arguments.formats ) ){ arguments.formats = listToArray( arguments.formats ); }
		// param incoming rc.format to "html"
		paramValue( "format", "html" );
		// try to match the incoming format with the ones defined, if not defined then throw an exception
		if( arrayFindNoCase( arguments.formats, instance.context.format )  ){
			// Cleanup of formats
			arguments.formats = "";
			// Determine view from incoming or implicit
			viewToRender = ( len( arguments.formatsView ) ? arguments.formatsView : replace( reReplaceNoCase( getCurrentEvent() , "^([^:.]*):", "" ) , ".", "/" ) );
			// Rendering switch
			switch( instance.context.format ){
				case "json" : case "jsonp" : case "jsont" : case "xml" : case "text" : case "wddx" : {
					arguments.type=instance.context.format;
					return renderData( argumentCollection=arguments );
				}
				case "pdf" : {
					arguments.type = "pdf";
					arguments.data = instance.controller.getRenderer().renderView( view=viewToRender);
					return renderData( argumentCollection=arguments );
				}
				case "html" : case "plain" : {
					return setView( view=viewToRender);
				}
			}
		}					
		else{
			throw(message="The incoming format #instance.context.format# is not a valid registered format", 
					  detail="Valid incoming formats are #arguments.formats.toString()#", 
					  type="RequestContext.InvalidFormat");
		}
	}
	
	function getRenderData(){
		return getValue(name="cbox_renderdata",defaultValue=structnew(),private=true);
	}

	function getHTTPMethod(){
		return cgi.REQUEST_METHOD;
	}

	function getHTTPContent(){
		return getHTTPRequestData().content;
	}

	function getHTTPHeader(required header, defaultValue=""){
		var headers = getHttpRequestData().headers;

		if( structKeyExists(headers, arguments.header) ){
			return headers[arguments.header];
		}
		if( structKeyExists(arguments,"default") ){
			return arguments.default;
		}

		throw(message="Header #arguments.header# not found in HTTP headers",detail="Headers found: #structKeyList(headers)#",type="RequestContext.InvalidHTTPHeader");
	}
	
	function setHTTPHeader(statusCode, statusText="", name, value=""){
		
		// status code?
		if( structKeyExists(arguments, "statusCode") ){
			getPageContext().getResponse().setStatus( arguments.statusCode, arguments.statusText );
		}// Name Exists
		else if( structKeyExists(arguments, "name") ){
			getPageContext().getResponse().addHeader( arguments.name, arguments.value );
		}
		else{
			throw(message="Invalid header arguments", detail="Pass in either a statusCode or name argument", type="RequestContext.InvalidHTTPHeaderParameters");
		}

		return this;
	}
	
	struct function getHTTPBasicCredentials(){
		var results 	= structnew();
		var authHeader 	= "";

		// defaults
		results.username = "";
		results.password = "";

		// set credentials
		authHeader = getHTTPHeader("Authorization","");

		// continue if it exists
		if( len(authHeader) ){
			authHeader = charsetEncode( binaryDecode( listLast(authHeader," "),"Base64"), "utf-8");
			results.username = listFirst( authHeader, ":");
			results.password = listLast( authHeader, ":");
		}

		return results;
    }
	
	boolean function isAjax(){
    	return ( getHTTPHeader("X-Requested-With","") eq "XMLHttpRequest" );
	}

}