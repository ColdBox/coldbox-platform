<cfoutput>
<div class="hero-unit">
	<img src="includes/images/ColdBoxLogoSquare_125.png" class="pull-left margin10" alt="logo"/>
	<h1>#prc.welcomeMessage#</h1>
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
			<div class="btn-group pull-right">
				<a class="btn dropdown-toggle btn-small" href="##" data-toggle="dropdown">
					<i class="icon-info-sign"></i> Related Docs
					<span class="caret"></span>
				</a>
				<ul class="dropdown-menu">
					<li><a href="http://wiki.coldbox.org/wiki/EventHandlers.cfm"><i class="icon-bookmark"></i> Event Handlers</a></li>
					<li><a href="http://wiki.coldbox.org/wiki/layouts-views.cfm"><i class="icon-bookmark"></i> Layouts & Views</a></li>
					<li><a href="http://wiki.coldbox.org/wiki/RequestContext.cfm"><i class="icon-bookmark"></i> Request Context</a></li>
					<li><a href="http://wiki.coldbox.org/wiki/URLMappings.cfm"><i class="icon-bookmark"></i> URL Mappings</a></li>
					<li><a href="http://wiki.coldbox.org/wiki/Validation.cfm"><i class="icon-bookmark"></i> Form-Object Validation</a></li>
				</ul>
			</div>
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

		<section id="modules">
		<div class="page-header">
	        <h2>
	        	Registered Modules
			</h2>
			<div class="btn-group pull-right">
				<a class="btn dropdown-toggle btn-small" href="##" data-toggle="dropdown">
					<i class="icon-info-sign"></i> Related Docs
					<span class="caret"></span>
				</a>
				<ul class="dropdown-menu">
					<li><a href="http://wiki.coldbox.org/wiki/Modules.cfm"><i class="icon-bookmark"></i> ColdBox Modules</a></li>

				</ul>
			</div>
		</div>
		<p>Below are your application's loaded modules, click on them to visit them.</p>
		<ul>
			<cfloop collection="#getSetting("Modules")#" item="thisModule">
			<li><a href="#event.buildLink(getModuleSettings(thisModule).entryPoint)#">#thisModule#</a></li>
			</cfloop>
		</ul>
		<cfif structCount( getSetting("Modules") ) eq 0>
			<div class="alert alert-error">There are no modules in your application</div>
		</cfif>
		</section>

		<section id="test-harness">
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
						<em>specs</em>
					</td>
					<td>Where all your bdd, module, unit and integration tests go</td>
				</tr>
				<tr>
					<td>
						<em>results</em>
					</td>
					<td>Where automated test results go</td>
				</tr>
				<tr>
					<td>
						<em>resources</em>
					</td>
					<td>
						Where test resources go, we have placed two for you:
						<ul>
							<li><strong>HttpAntRunner</strong> - MXUnit ANT Integration</li>
							<li><strong>RemoteFacade</strong> - MXUnit Eclipse Integration</li>
						</ul>
					</td>
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
					<td>A script for executing all application tests via TestBox ANT</td>
				</tr>
				<tr>
					<td>
						<em>runner.cfm</em>
					</td>
					<td>A TestBox runner so you can execute your tests.</td>
				</tr>
			</tbody>
		</table>
		</section>

		<section id="urlActions">
		<div class="page-header">
       		<h2>ColdBox URL Actions</h2>
			<div class="btn-group pull-right">
				<a class="btn dropdown-toggle btn-small" href="##" data-toggle="dropdown">
					<i class="icon-info-sign"></i> Related Docs
					<span class="caret"></span>
				</a>
				<ul class="dropdown-menu">
					<li><a href="http://wiki.coldbox.org/wiki/URLActions.cfm"><i class="icon-bookmark"></i> URL Actions</a></li>

				</ul>
			</div>
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
				<tr>
					<td>
						<em>?debugmode=false</em><br/>
						<em>?debugmode=false&debugpass={DebugPassword}</em>
					</td>
					<td>Remove debug mode</td>
					<td>
						<a class="btn btn-danger" href="index.cfm?debugmode=false">Execute</a>
					</td>
				</tr>
				<tr>
					<td>
						<em>?debugmode=true</em><br/>
						<em>?debugmode=true&debugpass={DebugPassword}</em>
					</td>
					<td>Enable debug mode</td>
					<td>
						<a class="btn btn-danger" href="index.cfm?debugmode=true">Execute</a>
					</td>
				</tr>
			</tbody>
		</table>
		</section>

		<section id="customize">
		<div class="page-header">
			<h2>Customizing your Application</h2>
			<div class="btn-group pull-right">
				<a class="btn dropdown-toggle btn-small" href="##" data-toggle="dropdown">
					<i class="icon-info-sign"></i> Related Docs
					<span class="caret"></span>
				</a>
				<ul class="dropdown-menu">
					<li><a href="http://wiki.coldbox.org/wiki/DirectoryStructure-Conventions.cfm"><i class="icon-bookmark"></i> Directory Structure & Conventions</a></li>
					<li><a href="http://wiki.coldbox.org/wiki/Bootstrapper.cfm"><i class="icon-bookmark"></i> Application Bootstrapper</a></li>
					<li><a href="http://wiki.coldbox.org/wiki/ConfigurationCFC.cfm"><i class="icon-bookmark"></i> Configuration CFC</a></li>
					<li><a href="http://wiki.coldbox.org/wiki/layouts-views.cfm"><i class="icon-bookmark"></i> Layouts & Views</a></li>

				</ul>
			</div>
        </div>
		<p>
            You can now start editing your application and building great ColdBox enabled apps. Important files & locations:
        </p>
		<ol>
		    <li>
		        <b>/config/ColdBox.cfc</b>: Your application configuration file
		    </li>
			<li>
		        <b>/config/routes.cfm</b>: Your URL Mappings
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
		        <b>/modules</b>: Your application modules
		    </li>
			<li>
		        <b>/plugins</b>: Where you place ColdBox custom plugins built by you!
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
                <a href="https://ortussolutions.atlassian.net/browse/COLDBOX">Bug Tracker</a>
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