LightWire is a lightweight dependency injection that supports constructor, setter and mixin injection into both singletons and transients. It is configured using a configuration bean.
 
LightWire is composed of two key files:
LightWire.cfc is the actual framework that does the heavy lifting
BaseConfigObject is a base configuration bean that your config bean must extend

You will then want to create your own custom config object. Just use the provided BeanConfig.cfc, adding all of your configuration settings in the init() method. Look at the sample init code and look at the comments at the top of the file for a detailed description of all of the methods and properties.

You can download all of the files from the Subversion repository:
http://svn.riaforge.org/lightwire. Latest version is under trunk/LightWire0.5.

Out of the box, you need to either create a lightwire mapping or put the lightwire directory in your web root, but if you want to use LightWire elsewhere, all you need to do is change the path you use to create LightWire.cfc and the "extends" attribute of your custom BeanConfig so it can find the BaseConfigObject. With those two changes, you can put LightWire anywhere you want (although the LightWireTest sample files depend on lightwire being a mapping or in your web root, but they are only there for educational purposes).

To call LightWire, first you need to call your configuration bean and then you need to pass it into LightWire. Check out the sample code in LightWireTest/index.cfm:

<cfset myBeanConfig = createObject("component","lightwire.lightwiretest.BeanConfig").init()>
<cfset myBeanFactory = createObject("component","lightwire.LightWire").init(myBeanConfig)>

Then you can just call transients and singletons with the following syntax:
<cfset ProductService = myBeanFactory.getSingleton("ProductService")>
<cfset Product = myBeanFactory.getTransient("Product")>
You can also just use getBean() to get either a transient or a singleton. It just acts as a simple facade to getSingleton() and getTransient(), so there is no reason to choose either approach over the other expect for your personal preference. Example:
<cfset ProductService = myBeanFactory. getBean("ProductService")>
<cfset Product = myBeanFactory.getBean("Product")>

And if you ever want to see your config properties visually, you can just call the getConfigStruct() method on your config bean:

<cfset ConfigStruct = myBeanConfig.getConfigStruct()>

Happy injecting!!!

[UPDATE 3/11/2007 - 20:00 EST - Just added custom factory support. Tested and working. See the BeanConfig for the API - addSingletonFromFactory(FactoryBean, FactoryMethod, BeanName) and addTransientFromFactory(FactoryBean, FactoryMethod, BeanName))]

Contributors:
Brian Rinaldi
Paul Marcotte
Peter Bell