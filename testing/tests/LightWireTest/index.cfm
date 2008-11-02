<!--- 
LightWireTest/index.cfm

--->
<cfsetting showdebugoutput="false">
<cfset stime = getTickcount()>
<cfset myBeanConfig = createObject("component","BeanConfig").init()>
<cfset myBeanFactory = createObject("component","coldbox.system.extras.lightwire.LightWire").init(myBeanConfig)>

<!--- Get Services --->
<cfset ProductService = myBeanFactory.getSingleton("ProductService")>
<cfset CategoryService = myBeanFactory.getSingleton("CategoryService")>
<cfset ConfigStruct = myBeanConfig.getConfigStruct()>
<cfset Product = myBeanFactory.getTransient("Product")>
<cfoutput>
	
<strong>LightWire Test</strong><br />

<strong>Product Service:</strong>
<cfdump var="#ProductService#">

<em>contains product DAO which was constructor injected</em>
<cfdump var="#ProductService.getProductDAO()#">

<em>and category service which was mixin or setter injected</em>
<cfdump var="#ProductService.getCategoryService()#">

And the following mixed in properties:<br />
MyMixinTitle = #ProductService.getMyMixinTitle()#<br />
AnotherMixinProperty = #ProductService.getAnotherMixinProperty()#<br />

<br /><br /><strong>Category Service:</strong>
<cfdump var="#CategoryService#">

<em>contains category DAO which was constructor injected</em>
<cfdump var="#CategoryService.getCategoryDAO()#">

<em>and product service which was mixin or setter injected</em>
<cfdump var="#CategoryService.getProductService()#">

<br /><strong>Product Bean (Transient)</strong><br />
<cfdump var="#Product#">
<em>contains a Product DAO that was constructor injected</em>
<cfdump var="#Product.getProductDAO()#">

<br /><br />
<strong>And here is the config struct being passed to LightWire by the bean:</strong><br />
</cfoutput>
<cfdump var="#ConfigStruct#" expand="false">

<br /><br />
<cfoutput>Total Execution Time: #getTickcount()-stime# ms</cfoutput>
<br /><br />
<strong>Here is the singleton Report:</strong><br />
<cfdump var="#myBeanFactory.getSingletonKeyList()#">



