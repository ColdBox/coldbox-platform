<cfoutput>
<div class="jumbotron">
	<div class="row">
		<div class="col-md-5">
			<img src="includes/images/ColdBoxLogo2015_300.png" class="pull-left margin10" alt="logo"/>
			<p class="text-center">
				<a class="btn btn-primary" href="http://coldbox.ortusbooks.com" target="_blank" title="Read our ColdBox Manual" rel="tooltip">
					<strong>Read ColdBox Manual</strong>
				</a>
			</p>
		</div>

		<div class="col-md-7">
			<h1>#prc.welcomeMessage#</h1>
			<p>
				You are now running <strong>#getSetting("codename",1)# #getSetting("version",1)# (#getsetting("suffix",1)#)</strong>.
				Welcome to the next generation of ColdFusion (CFML) applications.  You can now start building your application with ease, we already did the hard work
				for you.
			</p>
		</div>
	</div>
</div>

<div class="row">
	<div class="col-md-9">

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
			<li><a href="#event.buildLink( handler )#">#handler#</a></li>
			</cfloop>
		</ul>
		</section>

		<section id="modules">
		<div class="page-header">
	        <h2>
	        	Registered Modules
			</h2>
		</div>
		<p>Below are your application's loaded modules, click on them to visit them.</p>
		<ul>
			<cfloop collection="#getSetting("Modules")#" item="thisModule">
			<li><a href="#event.buildLink( getModuleConfig( thisModule ).entryPoint )#">#thisModule#</a></li>
			</cfloop>
		</ul>
		<cfif structCount( getSetting("Modules") ) eq 0>
			<div class="alert alert-info">There are no modules in your application</div>
		</cfif>
		</section>

		<section id="test-harness">
		<div class="page-header">
			<h2>
				Application Test Harness
			</h2>
		</div>
		<p>
			You can find your entire test harness in the following location: <code>#getSetting("ApplicationPath")#tests</code>
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
						Test resources like fixtures, itegrations, etc.
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
						<a class="btn btn-info" href="index.cfm?fwreinit=1">Execute</a>
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
            You can now start editing your application and building great ColdBox enabled apps. Important files & locations:
        </p>
		<ol>
		    <li>
		        <code>/config/ColdBox.cfc</code>: Your application configuration file
		    </li>
			<li>
		        <code>/config/Routes.cfm</code>: Your URL Mappings
		    </li>
		    <li>
		        <code>/config/WireBox.cfc</code>: Your WireBox Binder
		    </li>
		    <li>
		        <code>/handlers</code>: Your application event handlers
		    </li>
		    <li>
		        <code>/interceptors</code>: System interceptors
		    </li>
			<li>
		        <code>/includes</code>: Assets, Helpers, i18n, templates and more.
		    </li>
			<li>
		        <code>/layouts</code>:Your application skin layouts
		    </li>
		    <li>
		        <code>/lib</code>: Where Jar files can be integrated
		    </li>
			<li>
		        <code>/models</code>: Your model layer
		    </li>
			<li>
		        <code>/modules</code>: Your application modules
		    </li>
			<li>
		        <code>/tests</code>: Your BDD testing harness (Just DO IT!!)
		    </li>
			<li>
		        <code>/views</code>: Your application views
		    </li>
		</ol>
		</section>
	</div>

	<!---Side Bar --->
	<div class="col-md-3">
		<div class="well">
			<ul class="nav nav-list">
				<li><strong>Important Links</strong></li>
				<li>
	                <a href="http://www.coldbox.org">ColdBox Site</a>
	            </li>
	            <li>
	                <a href="http://blog.coldbox.org">Blog</a>
	            </li>
	            <li>
	                <a href="https://ortussolutions.atlassian.net/browse/COLDBOX">Issue Tracker</a>
	            </li>
				<li>
	                <a href="https://github.com/ColdBox/coldbox-platform">Source Code</a>
	            </li>
				<li>
	                <a href="http://coldbox.ortusbooks.com">Manual</a>
	            </li>
				<li>
					<a href="http://apidocs.coldbox.org">Quick API Docs</a>
				</li>
				<li>
					<a href="http://www.coldbox.org/forgebox" rel="tooltip" title="Community for interceptors, modules, etc.">ForgeBox</a>
				</li>
				<li><strong>Training</strong></li>
	            <li>
	                <a href="http://www.ortussolutions.com/services/training">Course Catalog</a>
	            </li>
				<li>
					<a href="http://coldbox.org/media">Training Videos</a>
				</li>
				<li>
					<a href="http://coldbox.org/media/connection">ColdBox Connection</a>
				</li>
	            <li><strong>Support</strong></li>
	            <li>
	                <a href="http://groups.google.com/group/coldbox">Mailing List</a>
	            </li>
				<li>
					<a href="http://www.coldbox.org/support/overview">Community Support</a>
				</li>
				<li>
					<a href="http://www.ortussolutions.com/services">Professional Support</a>
				</li>
			</ul>
		</div>
	</div>
</div>
</cfoutput>