<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	March 05 2008
Description :	Home Page.
----------------------------------------------------------------------->

<cfoutput>
<h1>#Event.getValue("welcomeMessage")#</h1>
<h5>You are running #getSetting("codename",1)# #getSetting("version",1)# (#getsetting("suffix",1)#)</h5>
</cfoutput>
<br />
The coldbox proxy object have the option to either create remote objects that extend the proxy or create one object that extends the proxy and use the event driven model within coldbox.
<br />
<h5>(1) Event Driven Model:</h5>
<p>
Flex or any external GUI application requests to the ColdBox event model. 
You do this by calling the process() method and attaching the event name argument plus any other arguments you would like to pass into the request, just like a form/url action.
 
The framework then treats the request as any other event requests, executes the handler and action needed, detects if the event handler produces any kind of result and then relays back the results to Flex/Ajax/Air. 

This approach let's you share event handlers with any gui and you can create different executions paths by just using: event.isProxyRequest().
 
This method determines if you are within a normal MVC html execution or a remote execution. This let's you decide if you want to produce HTML or return results.
</p>

<h5>(2) Remote Proxies:</h5>
<p>
This approach is basically the same as if you where building remote proxies to a built object model. 
The difference is that these proxy objects, extend the coldbox proxy object. 
This way, you can easily tap into coldspring/lightwire and get beans to interact with.
<br />
You can create a function called getUsers() that has the following:
<pre><strong>&lt; cfreturn getBean("UserService").getUsers() &gt;</strong></pre>
<br />
That's it. The proxy knows how to get to the ioc plugin and get your beans.
What are the differences? With remote proxies, you are just going directly to model objects and getting or saving data. 
With the event-driven model, you are actually creating a lifecycle for a request. 
The request can have interceptions, security, and implicit events.
</p>
