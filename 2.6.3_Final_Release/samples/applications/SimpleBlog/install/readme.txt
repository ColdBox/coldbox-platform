********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
SimpleBlog
by Henrik Joreteg
Revised by Luis Majano

This is a simple blog engine that has been built using 4 different techniques using ColdBox and Transfer.

********************************************************************************
Installation
********************************************************************************
1. You will need to create the database using the provided scripts, either MSSQL or MySQL
2. The datasource should be named: simpleblog


********************************************************************************
Default User:
********************************************************************************
username: admin
password: admin


********************************************************************************
Versions
********************************************************************************
1 - A basic blog using ColdBox and Transfer.  No service layers or gateways. All controller based.
Here are some techniques used:
	- Handler Caching setup
	- Usage of the ColdBox Cache
	- Event Caching
	- Event Caching Purging Techiniques
	- Autowiring from the cache
	- SES Routing
	- Basic Request Collection manipulation
	- Multi View Renderings
	
2 - Refactoring of controller model code to a model layer.
Here are some techniques used
	- Everything from Version 1 +
	- More advanced event caching
	- Transfer Decorators
	- More SES Routing
	- Model Layer Creation, primitive Service Layer
	- TQL queries
	- CF8 Per-App Mappings
	
3 - Refactoring the model layer to use more service layer approaches and more usage of ColdBox Goodies.
As our application gets more complex and our OO domain model grows, we are starting to see how our
dependencies are getting out of hand and we are writing a lot of code for them.
Here are some techniques used.
	- New RSS Service with RSS generation
	- Usage of the event.renderData() method.
	- More dependencies in our app init.
4. We start to use a depedency injection framework in order to leverage our dependencies and code. Our controller
code gets a cleanup because of this.  Just look at the onAppInit() event, what a difference.
Here are some techniques used:
	- IoC framework usage
	- Usage of the ColdBox Transfer Extras classes:
		- Custom Config Factory so only a coldbox.xml is used, and you can declare multiple datasources.
		- Transfer Decorator Injector
	- Custom Plugins
	- More Transfer Decorators
	- Usage of the security interceptor to secure the application
	- Simple Admin Interface
	- Jquery Integration + Effects
	- Service Layer Expanded
	- Transfer Decorator Injections
	