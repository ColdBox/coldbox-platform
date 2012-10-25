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
			scopeRegistration = { enabled = true},
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
		// map to ws
		map("coldboxWS").toWebservice("http://coldbox.jfetmac/distribution/test.cfc?wsdl");
		// map to rss feed
		map("googleNews")
			.toRSS("http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&output=rss")
			.inCacheBox(key="googleNews",timeout=10);
		// map to Java
		map("stringBuffer").toJava("java.lang.StringBuffer").initWith(16000);
		// map simple constructor arg
		map("categoryDAO").to("#myPath#.ioc.category.CategoryDAO")
			.asSingleton().noAutowire().initArg(name="dsn",value="MyDSN");
		mapPath("#myPath#.ioc.product.ProductDAO").asSingleton();
		mapPath("#myPath#.ioc.product.ProductService")
			.noAutowire().initArg(name="ProductDAO",ref="ProductDAO");
		// map using all 3 injection types
		mapPath("#myPath#.ioc.category.CategoryService")
			.noAutowire().initArg(name="categoryDAO",ref="categoryDAO")
			.property(name="productService",ref="productService")
			.setter(name="jsonProperty",ref="jsonProperty",argName="MyJsonProperty")
			.setter(name="jsonProperty2",ref="jsonProperty")
			.into(this.SCOPES.SINGLETON);
		// map by convention
		map("CategoryBean").to("#myPath#.ioc.category.CategoryBean");
		map("categoryCoolService").to("#myPath#.ioc.category.CategoryService").asSingleton();
		// Scopes
		map("RequestCategoryBean").to("#myPath#.ioc.category.CategoryBean").into( this.SCOPES.REQUEST );
		map("SessionCategoryBean").to("#myPath#.ioc.category.CategoryBean").into( this.SCOPES.SESSION );
		map("ApplicationCategoryBean").to("#myPath#.ioc.category.CategoryBean").into( this.SCOPES.APPLICATION );
		map("ServerCategoryBean").to("#myPath#.ioc.category.CategoryBean").into( this.SCOPES.SERVER );
		// provider stuff
		map("providerTest").to("#myPath#.ioc.ProviderTest");
		map("pizza").to("#myPath#.ioc.Simple").into(this.SCOPES.SESSION);
		// DSL creation
		map("coolDSL").toDSL("logbox:root");

		/// factory beans
		map("CoolFactory").to("#myPath#.ioc.FactorySimple").asSingleton();
		map("factoryBean1").toFactoryMethod("coolFactory","getTargetObject")
			.methodArg(name="name",value="luis")
			.methodArg(name="cool",value="true");
		map("factoryBean2").toFactoryMethod("coolFactory","getTargetObject")
			.methodArg(name="name",value="alexia")
			.methodArg(name="cool",value="true");

		map("calendar")
        	.noInit()
            .toJava("java.util.GregorianCalendar");

		map("calendar2")
        	.toJava("java.util.GregorianCalendar");

        // Mixins Beans
        map("MixinTest")
        	.to("#myPath#.ioc.Simple")
        	.mixins( ["/coldbox/testing/testmodel/ioc/mixins/mixin1.cfm", "/coldbox/testing/testmodel/ioc/mixins/mixin2.cfm" ] );

		// PARENT Mappings
		// alpha and bravo are in the abstract service
		map("someAlphaDAO").to("#myPath#.parent.SomeAlphaDAO");
		map("someBravoDAO").to("#myPath#.parent.SomeBravoDAO");
		// charlie and delta are in the concrete service only that also inherits from  abstract service
		map("someCharlieDAO").to("#myPath#.parent.SomeCharlieDAO");
		map("someDeltaDAO").to("#myPath#.parent.SomeDeltaDAO");
		// define abstract parent service with required dependencies (alpha and bravo)
		map("abstractService").to("#myPath#.parent.AbstractService")
			.property(name:"someAlphaDAO", ref:"someAlphaDAO")
			.property(name:"someBravoDAO", ref:"someBravoDAO");
		// define concrete service that inherits the abstract parent service dependencies via the parent method
		map("concreteService").to("#myPath#.parent.ConcreteService")
			.parent("abstractService")
			.property(name:"someCharlieDAO", ref:"someCharlieDAO")
			.property(name:"someDeltaDAO", ref:"someDeltaDAO");

		// Inherited metadata
		map("WireBoxURL").toValue("http://www.coldbox.org");
		map("ConcreteMetadata").to("coldbox.testing.testmodel.ioc.inheritance.Concrete");

		// Implicit properties
		map("implicitTest").to("#myPath#.ioc.ImplicitTest").setter(name="testProperty",value=123); 


	}
</cfscript>
</cfcomponent>