<cfif false>
<link rel="stylesheet" href="../includes/style.css" type="text/css" />
</cfif>
<span class="dashboardTitles">
<cfif not valueExists("cfdoctype") >
<cfoutput>
<a href="#cgi.script_name#?event=#getValue('event')#&cfdoctype=pdf" target="_blank"><img src="images/i_pdf.gif" border="0" align="absbottom"/></a> 
<a href="#cgi.script_name#?event=#getValue('event')#&cfdoctype=flashpaper" target="_blank"><img src="images/flashpaper.gif" border="0" align="absbottom"/></a>
</cfoutput>
</cfif>
Event Handlers Guide.  </span><br />

<h2><strong>Introduction</strong></h2>
<p>This is a quick guide to event handlers for the ColdBox Coldfusion  Framework. It will give you a quick overview of event handler syntax, regulations,  locations, method invocations, and declarations.&nbsp; It will also show you some event handler code  samples. </p>
<h2>&nbsp;<br />
    <strong>Event Handler Location</strong></h2>
<p>All event handlers should be placed in the <strong>handlers</strong> directory of your application. </p>
<pre><em>|ApplicationRoot</em><br /><em>|----+ handlers (Event  Handlers Directory</em><em>
|----+ </em><em>system (Coldbox System  Directory)</em>
 </pre>
</p>&nbsp;<br />
    <strong>Event Handler Syntax  Regulations</strong>
    <p><strong><em>{event Handler  CFC}.{method}</em></strong><br />
    <strong><em>Complete Regular  Expression: ^eh[a-zA-Z]+\.(dsp|do|on)[a-zA-Z]+</em></strong></p>
<p>This looks very similar to a java method call, example:  String.getLength(), but without the parenthesis.&nbsp; In order for the framework to execute events,  you need to tell it which events to run. You can do this by setting the <strong>&quot;event&quot;</strong> variable in the  request collection either through URL or FORM variables.&nbsp; Once the event variable is set, the framework  runs a regular expression match on the event string in order to validate it. If  it fails, it will then throw a framework error and stop all execution.&nbsp; If the match is successful, the framework  will then tokenize the event string to retrieve the cfc and method call and validate it against the internal registered events. &nbsp; It then continues to instantiate the event  handler and call the event handler's method that are registered in the interal ColdBox structures. </p>
<p>In order to also provide a coding methodology, event handlers will  be named in the following manner:</p>
<p><strong>eh{Name}.cfc</strong><br />
    <strong>example: ehGeneral.cfc,  ehUsers.cfc</strong></p>
<p><strong><em>Regular Expression:  ^eh[a-zA-Z]+\.</em></strong></p>
<p>It includes the prefix &quot;eh&quot; in order to distinguish them  in your code and error messages.&nbsp; If you  do not comply to this format, the framework will throw an invalid event handler  error. </p>
<p>As for method syntax please see the section below.<br />
</p>
<hr />
<h2><strong>Event Handler Method  Regulations</strong></h2>
<p>As of now, there are only three types of event handler methods  that the framework accepts for public execution, private methods can be named  as you like, like it should be:</p>
<p>&nbsp;&nbsp; 1. onMethods<br />
  &nbsp;&nbsp; 2. doMethods<br />
  &nbsp;&nbsp; 3. dspMethods</p>
<p>The framework does a regular expression&nbsp; match on the method name in order to validate  it according to prefix.</p>
<p><strong>Regular Expression:  (on|do|dsp)[a-zA-Z]+</strong></p>
<hr />
<h2><strong>onMethods</strong>: </h2>
<p>These methods are to  facade the internal Coldfusion Application.cfc methods or it could be whatever  you want.&nbsp; You declare them in your  config.xml file like so:</p>
<pre>&lt;Setting  name=&quot;RequestStartHandler&quot;  <br />          value=&quot;ehGeneral.onRequestStart&quot;/&gt;<br />&lt;Setting  name=&quot;RequestEndHandler&quot; &nbsp;&nbsp;<br />          value=&quot;ehGeneral.onRequestEnd&quot;/&gt; </pre>
<p>Below you will find an example onRequestStart handler:</p>
<pre>&lt;cffunction name=&quot;onRequestStart&quot;  access=&quot;public&quot;&gt;
  &lt;cfif  isDefined(&quot;session.authorized&quot;)&gt;
    &lt;cfif not session.authorized&gt;
      &lt;cfset setView(&quot;vwLogin&quot;)&gt;
    &lt;/cfif&gt;
  &lt;cfelse&gt;
&nbsp;&nbsp;&nbsp;&nbsp; &lt;cfset setView(&quot;vwLogin&quot;)&gt;
&nbsp; &lt;/cfif&gt;
&lt;/cffunction&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </pre>
<hr />
<h2><strong>doMethods</strong>: </h2>
<p>These are most likely  your model invocation calls, depending on your application.&nbsp; The main purpose is for them to carry out a  certain processing operation.&nbsp; Example:  doLogin, doCreateAccount.</p>
<p>However, with these methods you have two alternatives of program  flow described below:</p>
<p>&nbsp;&nbsp; 1. Do your processing and  continue your flow by rendering a view, using <strong>setView()</strong>.<br />
&nbsp;&nbsp; 2. Do your processing and  set a next event (relocation). This will make the controller relocate your  browser to the next event. This flow will allow you for example to make the  user relocate to another section of your site, without incurring with POST  submits on refresh.</p>
<p>1. If you are going to use the first alternative then you will need  to set a view for display. This is accomplished by calling the <strong>setView</strong>() method of the  controller.&nbsp; Below is an example of such  event handler:</p>
<pre>&lt;cffunction name=&quot;doHello&quot;  access=&quot;public&quot;&gt;
  &lt;!--- Do Your Logic  Here ---&gt;
  &lt;cfif getValue(&quot;firstname&quot;)  eq &quot;&quot;&gt;
&nbsp;&nbsp;&nbsp; &lt;cfset setValue(&quot;firstname&quot;,&quot;Not  Found&quot;)&gt;
  &lt;cfelse&gt;
&nbsp;&nbsp; &lt;cfset setValue(&quot;firstname&quot;,  getValue(&quot;firstname&quot;))&gt;
&nbsp; &lt;/cfif&gt;
&nbsp; &lt;!--- Set the View  To Display ---&gt;
&nbsp; &lt;cfset setView(&quot;vwHelloRich&quot;)&gt;
&lt;/cffunction&gt;</pre>
<p>If you do not set a view in your event handler then the framework  will have no view to render and throw a view not set error.</p>
<p>2. As for the second program flow you will need to set a next event  to be run by forcing the controller to relocate. You will do this by using the <strong>setNextEvent()</strong>  method of the controller or you can just simple use a cflocation with an event  url parameter.&nbsp; Below is an example of  such event handler:</p>
<pre>&lt;cffunction name=&quot;doStartOver&quot;  access=&quot;public&quot;&gt;
   &nbsp;&lt;!--- Do Your Logic  Here ---&gt;
   &nbsp;&lt;cfset rtn=model.insert(getValue(&quot;fname&quot;),getValue(&quot;lname&quot;))&gt;
   &nbsp;&lt;!--- Relocate with  new Event ---&gt;
   &nbsp;&lt;cfset setNextEvent(&quot;ehGeneral.dspUserListings&quot;)&gt;
&lt;/cffunction&gt; </pre>
<hr />
<h2><strong>dspMethods</strong>:&nbsp; </h2>
<p>These methods are usually used to prepare a  view for display.&nbsp; Let's say that your  are preparing a view that needs two queries in order to be displayed.&nbsp; You will place those query model calls here  and then render the view.&nbsp; Example:  dspLogin, dspUserListings.&nbsp; Please note  that every dspMethod needs to set a view to render, it needs to call the <strong>setView</strong>() method in the  controller.&nbsp; Below is an example of such  event handler:</p>
<pre>&lt;cffunction name=&quot;dspLogin&quot;  access=&quot;public&quot;&gt;
  &lt;cfset var user = CreateObject(&quot;component&quot;,&quot;model.users&quot;)&gt;
  &lt;cfset var general = CreateObject(&quot;component&quot;,&quot;model.general&quot;)&gt;
  &lt;!--- Do Your Logic  Here ---&gt;
  &lt;cfset setValue(&quot;qRoles&quot;,user.getRoles())&gt;
  &lt;cfset setValue(&quot;qDepartments&quot;,general.getDepartments())&gt;
&nbsp; &lt;!--- Set the view  to render ---&gt;
&nbsp; &lt;cfset setView(&quot;vwTest&quot;)&gt;
&lt;/cffunction&gt;</pre>
<h2><strong>How to set and get values</strong> (Event Handlers and Views) </h2>
<p>In order for any event handler to work, it needs values. Most  likely url parameters, form submissions or application/session/client  variables.&nbsp; The framework provides you  with a <strong>reqCollection</strong> structure for  all your variable needs.&nbsp; The framework  automatically captures the FORM and URL scopes, in specific precedence, into  the reqCollection for your usage.&nbsp;&nbsp; It  also provides you with utility methods to interact with the reqCollection.&nbsp; For more in depth methods look the the <a href="?event=ehColdbox.dspApi"> API</a></p>
<p>&nbsp;&nbsp; 1. <strong>getValue</strong> ( name, defaultValue )<br />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1. name: The name  of the variable to return from the reqCollection<br />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2. defaultValue:  The default variable to return if the variable is not found in the  reqCollection.&nbsp; Since there are no  default values that can be set for complex variables, you can send the  following action keywords to return an empty complex variable according to the  keyword. Please note that you need to pass in the keyword in brackets. Else the  regular expression match will fail and the simple value will be returned.<br />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1. [array]<br />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2. [struct]<br />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3.  [query]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <br />
  &nbsp;&nbsp; 2. <strong>setValue</strong> ( name, value )<br />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1. name: The name  of the variable to set in the reqCollection.<br />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2. value: The value  of the variable (simple or complex)</p>
<p>So if you need to retrieve a value from a form POST or URL  parameters, then you will use the <strong>getValue</strong>()  method. If you need to store values into the reqCollection in order for the  views and layouts to access them, use the <strong>setValue</strong>()  method.&nbsp; Please remember that you can  still continue to use both of these scopes, FORM and URL in your event handler.</p>
<p>So in your views and layouts, you can use the getValue() method to retrieve variables to show or queries. Just look at the sample apps for more info.</p>
<p>&nbsp;</p>
<hr />
<p>&nbsp; </p>
