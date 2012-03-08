﻿<cfoutput>
<h2><img src="includes/images/coldbox.png" align="absmiddle" style="padding-right:10px"> #Event.getValue("welcomeMessage")#</h2>

<div id="infobox">
<p>
    You are now running <strong>#getSetting("codename",1)# #getSetting("version",1)# (#getsetting("suffix",1)#)</strong>.
	Welcome to the next generation of ColdFusion applications.  You can now start building your application with ease, we already did the hard work
	for you.
</p>
</div>

<table cellpadding="10" width="98%" align="center">
    <tr>
        <td valign="top">
            <h3>Getting Started</h3>
            <p>
                You have just auto-generated your application and are ready to customize your application.  Several directories and
				files have been created for you.  Please familiarize yourself with your application layout before customizing your
				application.
                  </p>
          <h4>Good Starting Links</h4>
            <p>
                <ol>
                    <li>
                        <a href="http://ortus.svnrepository.com/coldbox/trac.cgi/wiki/cbDirectoryStructure">Directory Structure & Conventions</a>
                    </li>
                    <li>
                        <a href="http://ortus.svnrepository.com/coldbox/trac.cgi/wiki/cbConfigGuide">Coldbox.xml Guide</a>
</pre>
                    </li>
                    <li>
                        <a href="http://ortus.svnrepository.com/coldbox/trac.cgi/wiki/cbEventHandlersGuide">Event Handler's Guide</a>
                    </li>
					<li>
                        <a href="http://ortus.svnrepository.com/coldbox/trac.cgi/wiki/cbRequestContext">Request Context's Guide</a>
                    </li>
					<li>
                        <a href="http://ortus.svnrepository.com/coldbox/trac.cgi/wiki/cbLayoutsViewsGuide">Layouts & Views Guide</a>
                    </li>
					<li>
						<a href="http://ortus.svnrepository.com/coldbox/trac.cgi/wiki/cbMyFirstApp">My First ColdBox App</a>
					</li>
            </ol>
			<sub>* <a href="http://ortus.svnrepository.com/coldbox/trac.cgi">Wiki Docs</a></sub>
            </p>
			<h4>ColdBox URL Actions</h4>
			<p>ColdBox can use some very important URL actions to interact with your application. You can try them out below:</p>
			<p>
				<ol>
                    <li>
						<a href="index.cfm?fwreinit=true">Reinitialize the framework</a> (fwreinit=1)
					</li>
					<li>
						<a href="index.cfm?debugmode=false">Remove Debug Mode</a> (debugmode=false)
					</li>
					<li>
						<a href="index.cfm?debugmode=true">Enable Debug Mode</a> (debugmode=true)
					</li>
				</ol>
				<sub>* <a href="http://ortus.svnrepository.com/coldbox/trac.cgi/wiki/cbURLActions">URL Actions Guide</a></sub>
			</p>
            <h4>Customizing your Application</h4>
            <p>
                You can now start editing your application and building great ColdBox enabled apps. Important files & locations:
                <ol>
                    <li>
                        <b>/config/coldbox.xml.cfm</b>: Your application configuration file
                    </li>
                    <li>
                        <b>/config/environments.xml.cfm</b>: Your per-tier settings
                    </li>
					 <li>
                        <b>/config/routes.cfm</b>: Your SES routing table
                    </li>
                    <li>
                        <b>/handlers</b>: Your Application controllers
                    </li>
					<li>
                        <b>/includes</b>: Assets, Helpers, i18n, templates and more.
                    </li>
					<li>
                        <b>/includes/helpers</b>: Place all your application and specific helpers here
                    </li>
					<li>
                        <b>/layouts</b>: Where you place all your application layouts
                    </li>
					<li>
                        <b>/logs</b>: The ColdBox Logs directory
                    </li>
					<li>
                        <b>/model</b>: The meat of your app, your business logic objects
                    </li>
					<li>
                        <b>/plugins</b>: Where you place custom plugins built by you!
                    </li>
					<li>
                        <b>/test</b>: Your unit testing folder (Just DO IT!!)
                    </li>
					<li>
                        <b>/views</b>: Where you create all your views and viewlets
                    </li>
                </ol>
            </p>
        </td>
		
		
		
        <td valign="top" id="sidebar">
        <h3>Docs Search</h3>
		<p>Search all of the docs</p>
        <li>
			<form id="search" method="get" action="http://ortus.svnrepository.com/coldbox/trac.cgi/search">
				<div>
				<input id="proj-search" type="text" value="" accesskey="f" size="15" name="q"/>
				<input type="submit" value="Search"/>
				<input type="hidden" value="on" name="wiki"/>
				<input type="hidden" value="off" name="changeset"/>
				<input type="hidden" value="on" name="ticket"/>
				</div>
			</form>
        </li>
        <li>
            <h3>ColdBox Community Links</h3>
            <ul class="links">
                <li>
                    <a href="http://www.coldbox.org">ColdBox Site</a>
                </li>
                <li>
                    <a href="http://blog.coldboxframework.com">Blog</a>
                </li>
                <li>
                    <a href="http://forums.coldboxframework.com/">Forums</a>
                </li>
                <li>
                    <a href="http://ortus.svnrepository.com/coldbox/">Bug Tracker/Wiki</a>
                </li>
				<li>
                    <a href="http://groups.google.com/group/coldbox">Mailing List</a>
                </li>
				<li>
					<a href="http://www.coldbox.org/index.cfm/download/main">Downloads</a>
				</li>
				<li>
					<a href="http://www.coldbox.org/api/">ColdBox API</a>
				</li>
				<li>
					<a href="http://ortus.svnrepository.com/coldbox/trac.cgi/wiki/cbCodeDepot">Code Depot</a>
				</li>
				<li>
					<a href="http://www.coldbox.org/index.cfm/download/videos">ColdBox Videos</a>
				</li>
				<li>
					<a href="http://www.coldbox.org/index.cfm/support/overview">Community Support</a>
				</li>
				<li>
					<a href="http://www.coldbox.org/index.cfm/support/training">Training & Courses</a>
				</li>
            </ul>
        </li>
		
		<p>&nbsp;</p>
		<div style="margin:auto;text-align:center">
		<img src="http://www.coldbox.org/includes/images/logos/poweredby.gif">
		</div>
    </td>
    </tr>
</table>
</cfoutput>