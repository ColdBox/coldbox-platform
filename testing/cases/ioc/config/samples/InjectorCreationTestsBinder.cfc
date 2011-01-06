<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Description :
	The default ColdBox WireBox Injector configuration object that is used when the
	WireBox injector is created
----------------------------------------------------------------------->
<cfcomponent output="false" extends="coldbox.system.ioc.config.Binder">
<cfscript>
	
	/**
	* Configure WireBox, that's it!
	*/
	function configure(){
		
		// The WireBox configuration structure DSL
		wireBox = {
			// CacheBox Integration
			cacheBox = { enabled = true	},			
			// Scope registration, automatically register a wirebox injector instance on any CF scope
			scopeRegistration = { enabled = false},
			// Package scan locations
			scanLocations = [
				"coldbox.testing.testmodel"
			],
			// Stop recursions
			stopRecursions = [ "coldbox.system.Interceptor"	]
		};
		
		// WireBox Object Mappings
		var myPath = "coldbox.testing.testmodel";
		
		// map to constant value, no need for scope
		map("jsonProperty").toValue("[{name:'luis'},{name:'Jose'}]");
		// map to rss feed
		map("googleNews")
			.toRSS("http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&output=rss")
			.inCacheBox(key="googleNews",timeout=10);
		// map to Java
		map("stringBuffer").toJava("java.lang.StringBuffer").initWith(16000);
		// map simple constructor arg
		map("categoryDAO").to("#myPath#.ioc.category.CategoryDAO")
			.asSingleton().noAutowire().initArg(name="dsn",value="MyDSN");
		// map using all 3 injection types
		mapPath("#myPath#.ioc.category.CategoryService")
			.noAutowire().initArg(name="categoryDA",ref="categoryDAO")
			.property(name="productService",ref="productService")
			.setter(name="jsonProperty",ref="jsonProperty")
			.into(this.SCOPES.SINGLETON);
		// map by convention
		map("CategoryBean").to("#myPath#.ioc.category.CategoryBean");
		map("categoryCoolService").to("#myPath#.ioc.category.CategoryService").asSingleton();
	}	
</cfscript>
</cfcomponent>