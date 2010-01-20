<cfcomponent output="false" hint="My App Configuration">
<cfscript>
/**
public properties to set:
this.title = "Title of the module";
this.author = "Author of the module";
this.webURL = "Web URL for docs purposes";
this.description = "Module description";
this.version = "Module Version"
this.viewParentLookup = true [boolean] // If true, checks for views in the parent first, then it the module.If false, then modules first, then parent.

structures to create for configuration
- parentSettings : struct (will append and override parent)
- settings : struct
- datasources : struct (will append and override parent)
- webservices : struct (will append and override parent)
- customInterceptionPoints : string list of custom interception points
- interceptors : array
- routes : array

Available objects in variable scope
- controller
- appMapping (application mapping)
- moduleMapping (include,cf path)
- modulePath (absolute path)

Required Methods
- configure() : The method ColdBox calls to configure the module.

Optional Methods
- onLoad() 		: If found, it is fired once the module is fully loaded
- onUnload() 	: If found, it is fired once the module is unloaded

*/
	
	// Module Properties
	this.title 				= "My Test Module";
	this.author 			= "Luis Majano";
	this.webURL 			= "http://www.coldbox.org";
	this.description 		= "A funky test module";
	this.version			= "1.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	
	function configure(){
		
		// parent settings
		parentSettings = {
			woot = "Module set it!"
		};
	
		// module settings - stored in modules.name.settings
		settings = {
			display = "core"
		};
		
		// datasources
		datasources = {
			mysite   = {name="mySite", dbType="mysql", username="root", password="root"}
		};
		
		// web services
		webservices = {
			google = "http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&topic=h&num=3&output=rss"
		};
		
		// SES Routes
		routes = [
			{pattern="/docs", handler="api",action="index"}		
		];		
		
		
		customInterceptionPoints = "onPio";
		interceptors = [];
	}
	
	function onLoad(){
		controller.getLogBox().getLogger(this).info("onLoad called on module: #getMetadata(this).name#");
	}
	
	function onUnload(){
		controller.getLogBox().getLogger(this).info("onUnload called on module: #getMetadata(this).name#");
	}
	
	// This object can also act as an interceptor
	function preProcess(event,interceptData){
		controller.getLogBox().getLogger(this).info("I can now listen on preprocess from the Test1 Module");
	}
	
	/**
	* @interceptionPoint
	*/
	function onHenrik(event, interceptData){
	
	}
	
</cfscript>
</cfcomponent>