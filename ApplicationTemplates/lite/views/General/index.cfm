﻿<cfoutput>
<div class="hero-unit">
	<img src="includes/images/ColdBoxLogoSquare_125.png" class="pull-left margin10" alt="logo"/>
	<h1>#rc.welcomeMessage#</h1>
	<p>
		You are now running <strong>#getSetting("codename",1)# #getSetting("version",1)# (#getsetting("suffix",1)#)</strong>.
		Welcome to the next generation of ColdFusion applications.  You can now start building your application with ease, we already did the hard work
		for you.
		<a class="btn btn-primary" href="http://wiki.coldbox.org/wiki/ColdBox.cfm" target="_blank" title="Read our ColdBox Overview Document" rel="tooltip">
			<strong>ColdBox Overview</strong>
		</a>
	</p>
</div>

<div class="row">
	<div class="span9">

		<section id="eventHandlers">
		<div class="page-header">
			<h2>
				Registered Event Handlers
			</h2>
		</div>
		<p>
			You can click on the following event handlers to execute their default action
			<span class="label label-important">index()</span>
		</p>
		<ul>
			<cfloop list="#getSetting("RegisteredHandlers")#" index="handler">
			<li><a href="#event.buildLink(handler)#">#handler#</a></li>
			</cfloop>
		</ul>
		</section>

		<section id="testHarness">
		<div class="page-header">
			<h2>
				Application Test Harness
			</h2>
			<div class="btn-group pull-right">
				<a class="btn dropdown-toggle btn-small" href="##" data-toggle="dropdown">
					<i class="icon-info-sign"></i> Related Docs
					<span class="caret"></span>
				</a>
				<ul class="dropdown-menu">
					<li><a href="http://wiki.coldbox.org/wiki/Testing.cfm"><i class="icon-bookmark"></i> Unit & Integration Testing</a></li>
					<li><a href="http://wiki.coldbox.org/wiki/MockBox.cfm"><i class="icon-bookmark"></i> MockBox: Mocking Framework</a></li>
					<li><a href="http://www.mxunit.org"><i class="icon-bookmark"></i> MXUnit: Testing Framework</a></li>
				</ul>
			</div>
		</div>
		<p>
			You can find your entire test harness in the following location: <code>#getSetting("ApplicationPath")#test</code>
		</p>
		<table class="table table-striped">
			<thead>
				<th>File/Folder</th>
				<th>Description</th>
			</thead>
			<tbody>
				<tr>
					<td>
						<em>integration</em>
					</td>
					<td>Where all your global integration tests go</td>
				</tr>
				<tr>
					<td>
						<em>mocks</em>
					</td>
					<td>Where custom mock objects/data can be placed</td>
				</tr>
				<tr>
					<td>
						<em>resources</em>
					</td>
					<td>
						Where test resources go, we have placed two for you:
						<ul>
							<li><strong>HttpAntRunner</strong> - ANT Integration</li>
							<li><strong>RemoteFacade</strong> - Eclipse Integration</li>
						</ul>
					</td>
				</tr>
				<tr>
					<td>
						<em>unit</em>
					</td>
					<td>Where unit tests go</td>
				</tr>
				<tr>
					<td>
						<em>Application.cfc</em>
					</td>
					<td>A unique Application.cfc for your testing harness, please spice up as needed.</td>
				</tr>
				<tr>
					<td>
						<em>test.xml</em>
					</td>
					<td>A script for executing all application tests via ANT</td>
				</tr>
				<tr>
					<td>
						<em>TestSuite.cfm</em>
					</td>
					<td>A test suite for executing all application tests via a browser.</td>
				</tr>
			</tbody>
		</table>
		</section>

		<section id="urlActions">
		<div class="page-header">
       		<h2>ColdBox URL Actions</h2>
	   	</div>
		<p>ColdBox can use some very important URL actions to interact with your application. You can try them out below:</p>
		<table class="table table-striped">
			<thead>
				<th>URL Action</th>
				<th>Description</th>
				<th>Execute</th>
			</thead>
			<tbody>
				<tr>
					<td>
						<em>?fwreinit=1</em><br/>
						<em>?fwreinit={ReinitPassword}</em>
					</td>
					<td>Reinitialize the Application</td>
					<td>
						<a class="btn btn-danger" href="index.cfm?fwreinit=1">Execute</a>
					</td>
				</tr>
			</tbody>
		</table>
		</section>

		<section id="customize">
		<div class="page-header">
			<h2>Customizing your Application</h2>
        </div>
		<p>
            You can now start editing your application and building great ColdBox LITE enabled apps. Important files & locations:
        </p>
		<ol>
		    <li>
		        <b>/config/ColdBox.cfc</b>: Your application configuration file
		    </li>
			<li>
		        <b>/handlers</b>: Your application event handlers
		    </li>
			<li>
		        <b>/includes</b>: Assets, Helpers, i18n, templates and more.
		    </li>
			<li>
		        <b>/layouts</b>:Your application skin layouts
		    </li>
			<li>
		        <b>/model</b>: Your model layer
		    </li>
			<li>
		        <b>/test</b>: Your unit testing harness (Just DO IT!!)
		    </li>
			<li>
		        <b>/views</b>: Your application views
		    </li>
		</ol>
		</section>
	</div>

	<!---Side Bar --->
	<div class="span3">
		<div class="well">
		<ul class="nav nav-list">
			<li class="nav-header">Important Links</li>
			<li>
                <a href="http://www.coldbox.org">ColdBox Site</a>
            </li>
            <li>
                <a href="http://blog.coldbox.org">Blog</a>
            </li>
            <li>
                <a href="http://coldbox.assembla.com">Bug Tracker</a>
            </li>
			<li>
                <a href="https://github.com/ColdBox/coldbox-platform">Source Code</a>
            </li>
			<li>
                <a href="http://wiki.coldbox.org">Docs</a>
            </li>
			<li>
				<a href="http://apidocs.coldbox.org">Quick API Docs</a>
			</li>
			<li>
				<a href="http://www.coldbox.org/forgebox" rel="tooltip" title="Community for plugins, interceptors, modules, etc.">ForgeBox</a>
			</li>
			<li class="nav-header">Training</li>
            <li>
                <a href="http://www.coldbox.org/support/training">Course Catalog</a>
            </li>
			<li>
				<a href="http://coldbox.org/media">Training Videos</a>
			</li>
			<li>
				<a href="http://coldbox.org/media/connection">ColdBox Connection</a>
			</li>
            <li class="nav-header">Support</li>
            <li>
                <a href="http://groups.google.com/group/coldbox">Mailing List</a>
            </li>
			<li>
				<a href="http://www.coldbox.org/support/overview">Community Support</a>
			</li>
			<li>
				<a href="http://www.coldbox.org/support/paid">Professional Support</a>
			</li>
		</ul>
		<br/>
		<div class="centered margin10">
			<img src="http://www.coldbox.org/includes/images/logos/poweredby.gif" alt="ColdBox" />
		</div>

		</div>
	</div>
</div>
</cfoutput>