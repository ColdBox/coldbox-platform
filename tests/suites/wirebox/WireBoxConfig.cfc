component extends="coldbox.system.ioc.config.Binder" {

	/**
	 * Configure WireBox, that's it!
	 */
	function configure(){
		// The WireBox configuration structure DSL
		wireBox = {
			// CacheBox Integration
			cacheBox          : { enabled : true },
			// Scope registration, automatically register a wirebox injector instance on any CF scope
			scopeRegistration : { enabled : true },
			// Package scan locations
			scanLocations     : [ "cbtestharness.models" ],
			// Stop recursions
			stopRecursions    : [ "coldbox.system.Interceptor" ],
			// LogBox
			logBoxConfig      : "tests.specs.ioc.config.samples.LogBox"
		};

		// WireBox Object Mappings
		var modelsPath = "cbtestharness.models";

		// map to constant value, no need for scope
		map( "jsonProperty" ).toValue( "[{name:'luis'},{name:'Jose'}]" );
		// map to rss feed
		map( "googleNews" )
			.toRSS( "http://news.google.com/news?pz=1&cf=all&ned=us&hl=en&output=rss" )
			.inCacheBox( key = "googleNews", timeout = 10 );
		// map to Java
		map( "stringBuffer" ).toJava( "java.lang.StringBuilder" ).initWith( 16000 );
		// map simple constructor arg
		map( "categoryDAO" )
			.to( "#modelsPath#.ioc.category.CategoryDAO" )
			.asSingleton()
			.noAutowire()
			.initArg( name = "dsn", value = "MyDSN" );
		mapPath( "#modelsPath#.ioc.product.ProductDAO" ).asSingleton();
		mapPath( "#modelsPath#.ioc.product.ProductService" )
			.noAutowire()
			.initArg( name = "ProductDAO", ref = "ProductDAO" );
		// Map simple notation inject cfc
		mapPath( "#modelsPath#.ioc.ScriptNotation" );
		// map using all 3 injection types
		mapPath( "#modelsPath#.ioc.category.CategoryService" )
			.noAutowire()
			.initArg( name = "categoryDAO", ref = "categoryDAO" )
			.property( name = "productService", ref = "productService" )
			.setter(
				name    = "jsonProperty",
				ref     = "jsonProperty",
				argName = "MyJsonProperty"
			)
			.setter( name = "jsonProperty2", ref = "jsonProperty" )
			.into( this.SCOPES.SINGLETON );

		// map by convention
		map( "CategoryBean" ).to( "#modelsPath#.ioc.category.CategoryBean" );
		map( "categoryCoolService" ).to( "#modelsPath#.ioc.category.CategoryService" ).asSingleton();
		// Scopes
		map( "RequestCategoryBean" ).to( "#modelsPath#.ioc.category.CategoryBean" ).into( this.SCOPES.REQUEST );
		map( "SessionCategoryBean" ).to( "#modelsPath#.ioc.category.CategoryBean" ).into( this.SCOPES.SESSION );
		map( "ApplicationCategoryBean" )
			.to( "#modelsPath#.ioc.category.CategoryBean" )
			.into( this.SCOPES.APPLICATION );
		map( "ServerCategoryBean" ).to( "#modelsPath#.ioc.category.CategoryBean" ).into( this.SCOPES.SERVER );
		// provider stuff
		map( "providerTest" ).to( "#modelsPath#.ioc.ProviderTest" );
		map( "pizza" ).to( "#modelsPath#.ioc.Simple" ).into( this.SCOPES.SESSION );
		// DSL creation
		map( "coolDSL" ).toDSL( "logbox:root" );

		// / factory beans
		map( "CoolFactory" ).to( "#modelsPath#.ioc.FactorySimple" ).asSingleton();
		map( "factoryBean1" )
			.toFactoryMethod( "coolFactory", "getTargetObject" )
			.methodArg( name = "name", value = "luis" )
			.methodArg( name = "cool", value = "true" );
		map( "factoryBean2" )
			.toFactoryMethod( "coolFactory", "getTargetObject" )
			.methodArg( name = "name", value = "alexia" )
			.methodArg( name = "cool", value = "true" );

		map( "calendar" ).noInit().toJava( "java.util.GregorianCalendar" );

		map( "calendar2" ).toJava( "java.util.GregorianCalendar" );

		// Mixins Beans
		map( "MixinTest" )
			.to( "#modelsPath#.ioc.Simple" )
			.mixins( [
				"/coldbox/test-harness/models/ioc/mixins/mixin1.cfm",
				"/coldbox/test-harness/models/ioc/mixins/mixin2.cfm"
			] );

		// PARENT Mappings
		// alpha and bravo are in the abstract service
		map( "someAlphaDAO" ).to( "#modelsPath#.parent.SomeAlphaDAO" );
		map( "someBravoDAO" ).to( "#modelsPath#.parent.SomeBravoDAO" );
		// charlie and delta are in the concrete service only that also inherits from  abstract service
		map( "someCharlieDAO" ).to( "#modelsPath#.parent.SomeCharlieDAO" );
		map( "someDeltaDAO" ).to( "#modelsPath#.parent.SomeDeltaDAO" );
		// define abstract parent service with required dependencies (alpha and bravo)
		map( "abstractService" )
			.to( "#modelsPath#.parent.AbstractService" )
			.property( name: "someAlphaDAO", ref: "someAlphaDAO" )
			.property( name: "someBravoDAO", ref: "someBravoDAO" );
		// define concrete service that inherits the abstract parent service dependencies via the parent method
		map( "concreteService" )
			.to( "#modelsPath#.parent.ConcreteService" )
			.parent( "abstractService" )
			.property( name: "someCharlieDAO", ref: "someCharlieDAO" )
			.property( name: "someDeltaDAO", ref: "someDeltaDAO" );

		// Inherited metadata
		map( "WireBoxURL" ).toValue( "http://www.coldbox.org" );
		map( "ConcreteMetadata" ).to( "coldbox.test-harness.models.ioc.inheritance.Concrete" );

		// Implicit properties
		map( "implicitTest" ).to( "#modelsPath#.ioc.ImplicitTest" ).setter( name = "testProperty", value = 123 );


		map( "closureProvider" ).toProvider( function(){
			return "closureProviderInstance";
		} );

		map( "instanceWithInfluence" )
			.toValue( "123" )
			.withInfluence( function(){
				return reverse( instance );
			} );

		map( "tests.resources.VirtualParentClass" )
			.to( "tests.resources.VirtualParentClass" )
			.initArg( name = "data", value = "Default Data" );
		;

		map( "virtually-inherited-class" )
			.to( "tests.resources.ChildClass" )
			.virtualInheritance( "tests.resources.VirtualParentClass" );
	}

}
