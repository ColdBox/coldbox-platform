<cfcomponent name="configBeanTest" extends="coldbox.testing.tests.resources.baseMockCase">
	<!--- setup and teardown --->
	<cfset this.xmlSingle = "#getDirectoryFromPath(getMetadata(this).path)#beandefs.xml">
	<cfset this.xmlParent = "#getDirectoryFromPath(getMetadata(this).path)#beandefsParent.xml">
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			beanConfig = createObject("component","coldbox.testing.tests.cases.extras.lightwire.BeanConfig").init();		
			beanFactory = createObject("component","coldbox.system.extras.lightwire.LightWire").init(beanConfig);
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
		
	<cffunction name="testDefaultCreationSet" access="public" returntype="any" hint="" output="false" >
		<cfset testSet()>
	</cffunction>	

	<cffunction name="testUtilityMethods" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			try{
				/* Bad Bean */
				beanFactory.getBean('Whatever');
				fail('Method did not throw.');
			}
			catch("mxunit.exception.AssertionFailedError" e){
				rethrow(e);
			}
			Catch(Any e){
				AssertTrue(true);
			}
			
			AssertTrue( isStruct(beanFactory.getConfig()) );
			
			AssertTrue( len(beanFactory.getSingletonKeyList()) );
		</cfscript>
	</cffunction>

	<cffunction name="testContains" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			AssertFalse( beanFactory.localFactoryContainsBean('whatever') );
			
			AssertTrue( beanFactory.localFactoryContainsBean('Product') );
		</cfscript>
	</cffunction>
	
	<cffunction name="testXMLConfig" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			var config = 0;
			var factory = 0;
			var props = structnew();
			
			props.mapping = "coldbox.testing.testmodel";
			
			config = createObject("component","coldbox.testing.tests.cases.extras.lightwire.xmlBeanConfig").init(this.xmlSingle,props);		
			factory = createObject("component","coldbox.system.extras.lightwire.LightWire").init(config);
			
			testSet(factory);
			
			AssertTrue( isObject(factory.getBean('StringBuffer')));
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testParentFactory" access="public" returntype="any" hint="" output="false" >
		<cfscript>
			var config = 0;
			var factory = 0;
			var props = structnew();
			var parentConfig = 0;
			var parentFactory = 0;
			
			props.mapping = "coldbox.testing.testmodel";
			
			/* Parent Factory */
			parentconfig = createObject("component","coldbox.testing.tests.cases.extras.lightwire.xmlBeanConfig").init(this.xmlParent,props);		
			parentFactory = createObject("component","coldbox.system.extras.lightwire.LightWire").init(parentconfig);
			AssertTrue( parentFactory.containsBean('formBean') );
			
			/* Main Factory */
			config = createObject("component","coldbox.testing.tests.cases.extras.lightwire.xmlBeanConfig").init(this.xmlSingle,props);		
			factory = createObject("component","coldbox.system.extras.lightwire.LightWire").init(configBean=config,parentFactory=parentFactory);
			
			/* TestSet */
			testSet(factory);
			
			/* Test Parent */
			AssertFalse( factory.localFactoryContainsBean('formBean') );
			/* Test Hierarchy */
			AssertTrue( factory.containsBean('formBean') );
			/* Get It */
			AssertTrue( isObject(factory.getBean('formBean')) );
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testSet" access="private" returntype="any" hint="" output="false" >
		<cfargument name="factory" required="false" type="any" hint="">
		<cfscript>
			if (NOT structKeyExists(arguments,"factory") )
				factory = beanFactory;
			
			/* Get Services */
			ProductService = factory.getSingleton("ProductService");
			CategoryService = factory.getSingleton("CategoryService");
			Product = factory.getTransient("Product");
		
			/* TEST GETTING */
			AssertTrue( isObject(ProductService.getProductDAO()));
			AssertTrue( isObject(ProductService.getCategoryService()));
			
			/* Propertie */
			AssertTrue( len(ProductService.getMyMixinTitle()));
			AssertTrue( len(ProductService.getAnotherMixinProperty()));
			
			/* Category Service */
			AssertTrue( isObject(CategoryService.getCategoryDAO()));
			AssertTrue( isObject(CategoryService.getProductService()));
			
			/* Product */
			AssertTrue( isObject(Product.getProductDAO()));
			
			
		</cfscript>
	</cffunction>

</cfcomponent>

