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
Framework Settings Guide.</span>
<br />

<h2>Introduction</h2>

<p>In order to create a ColdBox application you must adhere to some naming conventions (look at eventhandlers) and a directory structure. This is needed in order for ColdBox to find what it needs and to help you find modules easier. It is up to you to organize your code. The only required naming convention is for the event handlers. As for the views and layouts, well that is up to you. </p>

<h2>ColdBox Naming Conventions:</h2>

<pre>Views (Optional) : All of my views start with 'vw'
 ex: vwMyview.cfm, vwHello.cfm</pre>
<pre>Layouts (Optional) : All of my layouts start with 'Layout.'
   ex: Layout.Main.cfm, Layout.Open.cfm, Layout.Popup.cfm</pre>
<pre>Event Handlers (<strong>Required</strong>): 
   All event handlers method calls follow this regular expression
   &quot;^eh[a-zA-Z]+\.(dsp|do|on)[a-zA-Z]+&quot;
   ex: ehGeneral.doLogin, ehTools.doParse, ehGeneral.dspHome
   All event handlers start with 'eh' + the name.
   ex: ehGeneral.cfc, ehLuis.cfc, ehTools.cfc, ehBase.cfc</pre>

<h2>
<br />ColdBox Application Directory Structure:</h2>

<pre> |<strong>ApplicationRoot</strong>
|---+ <strong>config</strong> (REQUIRED where your config.xml.cfm file goes) 
|---+ <strong>handlers</strong> (REQUIRED where your event handler cfc's go.) 
|---+ <strong>layouts</strong> (REQUIRED where all your layouts go) 
|---+ <strong>views</strong> (REQUIRED where all your views go) 
|---+ <strong>system</strong> (REQUIRED The ColdBox system folder) 
|---* <em>Application.cfc</em> (Application.cfm for MX 6 or BlueDragon) 
|---* <em>index.cfm</em> (The file that includes coldbox.cfm)
|---+ <em>includes</em> (OPTIONAL where your includes go. <br />                 REQUIRED for i18N resource bundle locations.) 
|---+ <em>images</em> (OPTIONAL where your images can go) 
|---+ <em>model</em> (OPTIONAL where your model cfc's go) </pre>

<h2><br />
ColdBox System Requirements:</h2>

<ul>
  <li>ColdFusion MX 6.0 and above</li>
  <li>Application scope enabled</li>
  <li>Session scope enabled</li>
  <li>Client scope enabled for the <strong>messagebox and clientstorage</strong> plugins only.</li>
</ul>

<p>&nbsp;</p>
<hr />

<h2><br >Do I place a copy of ColdBox in every Application?</h2>

<p>
Since every ColdBox application needs the system folder to be in the root of the
application folder, you can use a central location in your OS for your coldbox system folder
and then just use a symbolic link to it.  This is for those Unix/Linux/Mac OS X flavored OS.
As for windows, you will need to use a special software to do this such as:
Link Magic at <a href="http://www.rekenwonder.com/linkmagic.htm" target="_blank">http://www.rekenwonder.com/linkmagic.htm</a>.
However, if you do this, then you will have to update the coldbox system folder manually, the auto-update features
will not work.

This method will save space and the issue of maintaning several coldbox installations for multiple
applications. However, you loose the auto-update feature, which I know most of us would prefer to do a 
manual replace of the system.
</p>
<p>&nbsp;</p>
<hr />

<h2>Quick Start</h2>

<p>How to start?&nbsp; Start of by copying the ApplicationTemplate folder to your web root and<br />
  name it to something you want. Then, the first place to start is your config/config.xml.cfm file.<br />
  Open it and adjust it to your liking. You can read the config.xml guide in order<br />
to understand all the variables in this file. </p>
<p>Then you need to change the name property of your Application.cfc or Application.cfm template. So open the <br />
  file Application.cfc and change the this.name property to whatever you want it<br />
  to be. Remember that every application will need its own name property. Also,<br />
  please note that ColdBox uses the client scope for some plugins and the session scope for the controller. So both of <br />
  these scopes will need to be active in order for the framework to work.</p>
<p>Once you have completed editing the config.xml file make sure that you now go to <br />
  your CFMX administrator and create the CFMX mapping if needed. If your application<br />
  lies on the root of your server, then you do not need a mapping. The mapping  will<br />
  be left blank.</p>
<p>Now that you have a mapping, if used, you will need to alter the default event handler provided,<br />
  ehGeneral, in order to extend the base eventhandler.cfc located in the system folder of your current application.<br />
  Every event handler that you code needs to extend this base cfc. Open the file and enter <br />
  the name of the mapping in the extends property. Your extends property should look similar to <br />
  the one below:</p>
<p><strong>extends=&quot;MyMapping.system.eventhandler&quot;</strong></p>
<p>Now that you have completed editing your config, Application.cfc and your first<br />
  event handler, you are ready to see results. Point your browser to your application<br />
  folder and you will see a message display:</p>
<p><strong>Welcome to Coldbox!!</strong></p>
<p>Now get your mind out of procedural code, dive into OO Programming. Please make sure<br />
  to fasten your seat belts, it WILL GET BUMPY!!</p>
<p><strong>NOTES:</strong><br />
  Please note that in order to use the clientstorage and the messagebox plugin you <br />
will need to have the client scope activated.</p>
<p>&nbsp;  </p>
<hr />

<h2>The Internal Structures  </h2>

<p>ColdBox uses  internal coldfusion structures in order to run.&nbsp; One is the<strong> &quot;fwSettingsStruct&quot;</strong> and the other is the <strong>&quot;ConfigStruct&quot;</strong> which are created on the application's initial request.&nbsp; The <strong>fwSettingsStruct</strong> and the  <strong>ConfigStruct</strong> reside in the application scope  and can be reinitialized by using the <strong>&quot;fwreinit=1&quot;</strong> url param.</p>
<h2>ConfigStruct</h2>
<p>The <strong>ConfigStruct</strong> is the structure that gets created with your <em>config.xml.cfm</em> file. All your application settings are here.&nbsp; You can retrieve any setting (<em>key</em>) from this structure by using the controller's <strong>getSetting()</strong> method call. </p>
<p><em>Example: getSetting(&quot;Environment&quot;) </em></p>
<p>You can also create new settings via the <strong>setSetting()</strong> method call. </p>
<p>Below is a screenshot of a sample application's configstructure dump, click on the image to view it full size. </p>
<p align="center">
<cfif not valueExists("cfdoctype") >
<a href="images/configstruct.png" target="_blank"><img src="images/configstruct_tmb.png" border="1" /></a>
<cfelse>
<img src="images/configstruct_tmb.png" border="1" />
</cfif>
</p>

<hr />
<h2>fwSettingsStruct</h2>

<p>The fwSettingsStruct is the internal structure that ColdBox uses to run. You can also use the keys for anything you might need in your application.&nbsp; There are several useful entries in this structure that contain information you don't need to retrieve again.&nbsp;You can get these settings by using the controller's <strong>getSetting()</strong> method call. However, you need to pass a boolean true as a second parameter in order to retrieve settings from the <strong>fwsettingsstruct</strong>.&nbsp; </p>
<p><em>Example: getSetting(&quot;Version&quot;,true)</em>, getSetting(&quot;ApplicationPath&quot;,1) </p>
<p>Below is a table of the keys in this structure as of ColdBox latest version.&nbsp; You can also see a dump of a sample fwsettings structure below: </p>
<cfoutput>
  <table width="100%" border="0" cellspacing="5" cellpadding="0">
    <tr>
      <td width="23%" align="right" class="titlesDarkBg"><strong>Setting (Key) </strong></td>
      <td align="center" class="titlesDarkBg"><strong>Description</strong></td>
    </tr>
    <tr>
      <td align="right" class="fw_errorTablesTitles">ApplicationPath</td>
      <td class="fw_errorTablesCells">The full physical path to your current running application </td>
    </tr>
    <tr>
      <td  align="right" class="fw_errorTablesTitles">Author</td>
      <td class="fw_errorTablesCells">The ColdBox author, me!! </td>
    </tr>
    <tr>
      <td align="right" class="fw_errorTablesTitles">AuthorEmail</td>
      <td class="fw_errorTablesCells">The ColdBox author's email address. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">AuthorWebsite</td>
      <td class="fw_errorTablesCells"> The ColdBox author's website address. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">ChildApp</td>
      <td class="fw_errorTablesCells"> A boolean showing if you are currently running a child application or the master application. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">Codename</td>
      <td class="fw_errorTablesCells">The codename of your current ColdBox installation. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">ConfigFileLocation</td>
      <td class="fw_errorTablesCells">The physical path to the <strong>current running's</strong> application config.xml.cfm</td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">ConfigFileSchemaLocation</td>
      <td class="fw_errorTablesCells">The physical path to the ColdBox Config File Schema, config.xsd </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">Description</td>
      <td class="fw_errorTablesCells">The description of the framework. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">DistanceString</td>
      <td class="fw_errorTablesCells"> The distance string (relative path) to the parent application. This only applies if you are running a child application. You can use this setting to retreive images, layouts, etc, from the parent application using this relative path. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">DistanceToParent</td>
      <td class="fw_errorTablesCells">The numeric representation of the distance string to the parent application.&nbsp; It tells you how many directories below your child application is from the parent. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">ModifyLogLocation</td>
      <td class="fw_errorTablesCells">The physical path to the ColdBox readme.txt file. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">OSFileSeparator</td>
      <td class="fw_errorTablesCells">The File System Separator of your current running operating system. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">ParentAppPath</td>
      <td class="fw_errorTablesCells">The physical path of your parent application.&nbsp; This only applies if your are running a child application. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">Suffix</td>
      <td class="fw_errorTablesCells">A suffix to the ColdBox installation codename. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">FrameworkAPI</td>
      <td class="fw_errorTablesCells">The link to the live API of ColdBox </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">FrameworkBlog</td>
      <td class="fw_errorTablesCells">The link to the ColdBox live forums </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">FrameworkPath</td>
      <td class="fw_errorTablesCells">The physical path to the current running ColdBox installation. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">FrameworkPluginsPath</td>
      <td class="fw_errorTablesCells">The physical path to the current running ColdBox plugins folder. </td>
    </tr>
    <tr>
      <td align="right" valign="top" class="fw_errorTablesTitles">Version</td>
      <td class="fw_errorTablesCells">The current version of your ColdBox installation. </td>
    </tr>
  </table>
  
  <p align="center">
  <cfif not valueExists("cfdoctype") >
  <a href="images/fwsettingsstruct.png" target="_blank"><img src="images/fwsettingsstruct_tmb.png" border="1" /></a>
  <Cfelse>
  <img src="images/fwsettingsstruct_tmb.png" border="1" />
  </cfif>
  </p>
  <hr />

</cfoutput>