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
Config.xml Guide </span><br />

<p>  The config file is the heart of your ColdBox application. It contains the initialization variables for your application and extra information used by the ColdBox plugins.&nbsp; Below is an overview of every section of the file.&nbsp;<span class="fw_redText">All the data in the config.xml.cfm will be placed in the configStruct.&nbsp; If you would like to reload your settings,&nbsp; you will need to reinitialize the framework by using the fwreinit=1 URL action. </span></p>
<p><strong>Note About Security: </strong>Your config.xml file is actually a cfm template. I did this in order to protect the download of the file with the use of an Application.cfm template (Thanks to Raymond Camden).&nbsp; However, for added security I also use an apache acces file: .htaccess. You will  find the .htaccess file on the distribution archive for the config directory. This is used by Apache for executing directory security.</p>
<p>  (<a href="http://httpd.apache.org/docs/2.0/howto/htaccess.html" target="_blank">Read more on .htaccess)</a>. </p>
<p>In IIS, you will have to configure the directory's security from the IIS Manager. <br />
  <br />
  (<a href="http://www.windowsecurity.com/articles/Installing_Securing_IIS_Servers_Part1.html" target="_blank">Good article on securing IIS)</a> </p>
<p>&nbsp;</p>
<h2>&lt;Settings&gt;</h2>

This section is for  ColdBox settings. These are pre-defined and you cannot rename them or ommit them since they are validated against its XML Schema, please remember that <span class="fw_redText">XML IS CASE-SENSATIVE</span>.<a name="settings" id="settings"></a></p>
<cfoutput>
  <table width="100%" border="0" cellspacing="5" cellpadding="0">
    <tr>
      <td width="23%" align="right" class="titlesDarkBg"><strong>Setting  </strong></td>
      <td align="center" class="titlesDarkBg"><strong>Description</strong></td>
      <td width="10%" align="center" class="titlesDarkBg"><strong>Type</strong></td>
    </tr>
    <tr>
      <td align="right" class="fw_errorTablesTitles"><strong>AppName:</strong></td>
      <td class="fw_errorTablesCells">The unique name of your application </td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td  align="right" class="fw_errorTablesTitles"><strong> AppCFMXMapping </strong></td>
      <td class="fw_errorTablesCells">The Coldfusion Mapping for your application. Leave blank if the application is in the root of your webserver. </td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td align="right" class="fw_errorTablesTitles"><strong>DebugMode</strong></td>
      <td class="fw_errorTablesCells"> Enable/Disable ColdBox debug mode. </td>
      <td align="center" class="fw_errorTablesCells">Boolean</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">DebugPassword</td>
      <td class="fw_errorTablesCells">The password you would like to use to go into debugmode. You will need to pass this string as a URL param combined with the DebugMode to use. Look at examples below</td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles"><strong>DumpVarActive </strong></td>
      <td class="fw_errorTablesCells"> Enable/Disable the use of the URL action to dump variables. </td>
      <td align="center" class="fw_errorTablesCells">Boolean</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles"><strong>ColdfusionLogging</strong></td>
      <td class="fw_errorTablesCells"> Enable/Disable Coldfusion Error Logs. </td>
      <td align="center" class="fw_errorTablesCells">Boolean</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles"><strong>DefaultEvent:</strong></td>
      <td class="fw_errorTablesCells">The name of the event handler for the default event to run: ehGeneral.dspHome </td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles"><strong>RequestStartHandler:</strong></td>
      <td class="fw_errorTablesCells">The name of the onRequestStart handler to run: ehGeneral.onRequestStart, leave blank if not used. </td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles"><strong>RequestEndHandler:</strong></td>
      <td class="fw_errorTablesCells">The name of the onRequestEnd handler to run: ehGeneral.onRequestEnd, leave blank if not used </td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">ApplicationStartHandler</td>
      <td class="fw_errorTablesCells">The name of the onApplicationStart handler to run: ehGeneral.onAppStart, leave blank if not used. To trigger again this handler, you must reinitialize the framework: fwreinit=1 </td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles"><strong>OwnerEmail:</strong></td>
      <td class="fw_errorTablesCells">The email that will be used to send all email communications. </td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles"><strong>EnableBugReports:</strong></td>
      <td class="fw_errorTablesCells"> Enable/Disable the emailing of bug reports </td>
      <td align="center" class="fw_errorTablesCells">Boolean</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles"><strong>UDFLibraryFile</strong></td>
      <td class="fw_errorTablesCells">The location of your UDF library if in use, else leave blank.&nbsp;ColdBox will first look in your includes directory, so you can just place the name of the UDF here, or the full path you write including CFMX Mappings. Ex: /ColdBoxSamples/includes/udf.cfm </td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">ExceptionHandler</td>
      <td class="fw_errorTablesCells">The custom exception handler to run on all framework exceptions. You decide what to do. </td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles"><strong>CustomErrorTemplate</strong></td>
      <td class="fw_errorTablesCells">ColdBox comes with its own error template. However, if you wish to customize your errors, which you should, then just place the location of your custom error template. For example: includes/errorpage.cfm or /mymapping/templates/error.cfm Then in order to retrieve the error, you will need to get the Exception Bean from the request collection: getValue(&quot;ExceptionBean&quot;). You can then use this bean to render your error page. Please look at the API to get a better understanding of the bean. </td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">MessageboxStyleClass</td>
      <td class="fw_errorTablesCells">The CSS class name to be used with the messagebox plugin.&nbsp;If left blank, ColdBox will use its internal CSS class. </td>
      <td align="center" class="fw_errorTablesCells">String</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">HandlersIndexAutoReload</td>
      <td class="fw_errorTablesCells">This is a flag mostly used during development.&nbsp; ColdBox onApplication Start will read your handlers directory and store the names of the available handlers.&nbsp; When requests are made and handlers get instantiated, they are instantiated using the internal syntax.&nbsp; Thus, if you are developing and are adding handlers, with this flag set to TRUE, then ColdBox will reload the list.&nbsp; Else, you will have to manually reload the structures using the <strong>fwreinit=1 url action </strong></td>
      <td align="center" class="fw_errorTablesCells">Boolean</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">ConfigAutoReload</td>
      <td class="fw_errorTablesCells">This is a flag mostly used during development. It will reload your config.xml settings on every request.&nbsp; Else you will have to manually reload the structures using fwreinit=1 </td>
      <td align="center" class="fw_errorTablesCells">Boolean</td>
    </tr>
  </table>
  
  
  <p><strong>DebugMode example:</strong><br />
  In order to enter/leave ColdBox debugmode, you will need to append some URL parameters in order to do this.&nbsp; The url below will activate debugmode:</p>
  <p><em>http://apppath/index.cfm?debugmode=true&amp;debugpass=ColdBox</em></p>
  <p> This url tells ColdBox to enable debugmode and use the debugpass variable to test against the config.xml.cfm DebugPassword settting.&nbsp; If you do not want to assign a debug password, you can leave the setting blank.<br />
    The url below will deactivate debugmode.</p>
  <p><em> http://apppath/index.cfm?debugmode=false&amp;debugpass=ColdBox.</em></p>
  <h2>&lt;YourSettings&gt;</h2>
  This section is used only if you want to specify your own settings for your application.&nbsp; Like for example your datasource name, your own email address, etc. &nbsp; You can then retrieve them using the <em><strong>getSetting()</strong></em> method. Example:</p>
    <pre>&lt;YourSettings&gt;
&nbsp;&nbsp; &lt;Setting name=&quot;myurl&quot; value=&quot;http://myurl.com&quot; /&gt;<br />   &lt;Setting name=&quot;mysetting&quot; value=&quot;myvalue&quot; /&gt;
&lt;/YourSettings&gt;	</pre>

  <h2>&lt;MailServerSettings&gt;</h2>
  
    This section is provided to bypass the Coldfusion Administrator's mail settings.&nbsp;For example: for hosted environments where you do not have access to the ColdFusion Administrator. 
  You can then retrieve them using the <em><strong>getSetting()</strong></em> method
  <pre>&lt;MailServerSettings&gt;<br />   &lt;MailServer&gt;mail.mymailserver.com&lt;/MailServer&gt;<br />   &lt;MailUsername&gt;luismajano&lt;/MailUsername&gt;<br />   &lt;MailPassword&gt;PASSWORD&lt;/MailPassword&gt;
&lt;/MailServerSettings&gt;</pre>

 <h2>&lt;BugTracerReports&gt;</h2>
 
    ColdBox can send multiple users bug reports.&nbsp; You define all the email addresses that will receive these mail reports.&nbsp; However, in order for the bug reports to be active, you need to set the <strong><a href="##settings">EnableBugReports</a></strong> setting to true.
  You can then retrieve them using the <em><strong>getSetting()</strong></em> method
  <pre>&lt;BugTracerReports&gt;<br />   &lt;BugEmail&gt;lmajano@gmail.com&lt;/BugEmail&gt;
   &lt;BugEmail&gt;someone@mail.com&lt;/BugEmail&gt;<br />&lt;/BugTracerReports&gt;</pre>
   
   <h2>&lt;DevEnvironments&gt;</h2>
 
    This section is used to keep track of your environment.  You can list as many url's as you want, ColdBox will try to match at least one. If it does then it will set the ENVIRONMENT variable to DEVELOPMENT, else to PRODUCTION.
    You can then retrieve them using the <em><strong>getSetting()</strong></em> method
    <pre>&lt;DevEnvironments&gt;<br />  &lt;url&gt;dev&lt;/url&gt;<br />  &lt;url&gt;lmajano&lt;/url&gt;
&lt;/DevEnvironments&gt;</pre>

  <h2>&lt;WebServices&gt;</h2>
 
    You may use this section to list all your webservices that your application can use instead of registering them in the Coldfusion Administrator. This becomes useful, since you can refresh their stubs using the webservices API. Another nice feature, is that you can declare for every webservice a development url and/or a production url.
    You can then retrieve them using the <em><strong>getSetting()</strong></em> method
    <pre>&lt;WebServices&gt;<br />  &lt;WebService name=&quot;DistributionWS&quot; 
  URL=&quot;http://ColdBox.luismajano.com/ColdBox.cfc?wsdl&quot; 
  DevURL=&quot;http://dev.com/ColdBox.cfc?wsdl&quot; /&gt;
  &lt;WebService name=&quot;GoogleWS&quot; URL=&quot;http://ws.google.com/ws?wsdl&quot;/&gt;<br />&lt;/WebServices&gt;</pre>
  
  <h2>&lt;Layouts&gt;</h2>
 
  <p> This is a very important setting for your ColdBox application.  You will need to fill out a mandatory setting which is the <DefaultLayout> 
  element.  This element tells ColdBox to always use this Layout unless specifically specified.  You can then retrieve them using the <em><strong>getSetting()</strong></em> method</p>
   <p><strong>For example:</strong> Your application only uses one layout, then this section would look like this: </p>
   <pre>&lt;Layouts&gt;<br />  &lt;DefaultLayout&gt;Layout.Main.cfm&lt;/DefaultLayout&gt;<br />&lt;Layouts&gt;</pre>
   <p>However, if your application has some views that need a different layout, then you need to define them here.&nbsp; You can also change a view's layout programmatically by using the <strong>SetLayout({layout_name})</strong> method.&nbsp; So you define a Layout first, with a file and name attribute.&nbsp; You will then proceed to create<strong> &lt;View&gt;</strong> elements with the name of the view. Do not use the .cfm extension, ColdBox applies it automatically. You can then retrieve them using the <em><strong>getSetting()</strong></em> method.</p>
   
   <pre>&lt;Layouts&gt;<br />  &lt;DefaultLayout&gt;Layout.Main.cfm&lt;/DefaultLayout&gt;
  &lt;Layout file=&quot;Layout.Login.cfm&quot; name=&quot;login&quot;&gt;<br />    &lt;View&gt;vwLogin&lt;/View&gt;<br />  &lt;/Layout&gt;  
  &lt;Layout file=&quot;Layout.Open.cfm&quot; name=&quot;open&quot;&gt;
    &lt;View&gt;vwLuis&lt;/View&gt;
    &lt;View&gt;vwPopup&lt;/View&gt;
  &lt;/Layout&gt;<br />&lt;Layouts&gt;</pre>
   <br />
</cfoutput>
<h2>&lt;i18N&gt;</h2>
<p> This element is used to define a default resource bundle, a default java standard locale and the storage for the locale in your ColdBox application.&nbsp;This will be used to activate ColdBox's Internationalization features.&nbsp;ColdBox will read the defined resource bundle according to the set locale, parse it and store it in an internal <strong>Application</strong> variable.&nbsp;Then from the event handlers, layouts or views you can just use the <em><strong>getResource(&quot;Key&quot;)</strong></em> method to get keys from the bundle structure. ex:<em> <strong>getResource(&quot;cancelbutton&quot;)</strong></em></p>
<p>For now, ColdBox can only use i18N via properties files.&nbsp; The database version is on the works. The options for LocaleStorage are session or client.&nbsp; This is just the scope where ColdBox will place the <em><strong>DefaultLocale</strong></em> variable in.&nbsp; You can manipulate this variable and more through the <em><strong>i18n</strong></em> plugin. Please look at the API. </p>
<pre>&lt;i18N&gt;<br />  &lt;DefaultResourceBundle&gt;includes/main&lt;/DefaultResourceBundle&gt;<br />  &lt;DefaultLocale&gt;en_US&lt;/DefaultLocale&gt;<br />  &lt;LocaleStorage&gt;session&lt;/LocaleStorage&gt;<br />&lt;i18N&gt;</pre>
<p>&nbsp;</p>
<p>&nbsp;</p>