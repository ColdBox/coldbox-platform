<cfoutput>
<h2>#rc.welcomeMessage#</h2>

<div id="infobox">
<p>
    You are now running <strong>#getSetting("codename",1)# #getSetting("version",1)# (#getsetting("suffix",1)#)</strong>.
	Welcome to the next generation of ColdFusion applications.  You can now start building your application with ease, we already did the hard work
	for you.
</p>
</div>
<table cellpadding="5" width="98%" align="center">
    <tr>
        <td valign="top">
            <div id="cse" style="width: 100%;"></div>
			<script src="http://www.google.com/jsapi" type="text/javascript"></script>
			<script type="text/javascript">
			  google.load('search', '1', {language : 'en'});
			  google.setOnLoadCallback(function(){
			    var customSearchControl = new google.search.CustomSearchControl('016428578290111247219:83ttrlkrtrw');
			    customSearchControl.setResultSetSize(google.search.Search.FILTERED_CSE_RESULTSET);
			    customSearchControl.draw('cse');
			  }, true);
			</script>
			<link rel="stylesheet" href="http://www.google.com/cse/style/look/default.css" type="text/css" />
			
			<h3>Registered Event Handlers</h3>
			<p>You can click on the following event handlers to execute their default action.</p>
			<ul>
				<cfloop list="#getSetting("RegisteredHandlers")#" index="handler">
				<li><a href="#event.buildLink(handler)#">#handler#</a></li>
				</cfloop>
			</ul>
            
            <h3>Registered Modules</h3>
			<p>You can click on the following modules to visit them (If they have an entry point defined)</p>
			<ul>
				<cfloop collection="#getSetting("Modules")#" item="thisModule">
				<li><a href="#event.buildLink(getModuleSettings(thisModule).entryPoint)#">#thisModule#</a></li>
				</cfloop>
			</ul>
           
           
           <h4>ColdBox URL Actions</h4>
			<p>ColdBox can use some very important URL actions to interact with your application. You can try them out below:</p>
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
				<sub>* <a href="http://wiki.coldbox.org/wiki/URLActions.cfm">URL Actions Guide</a></sub>
			<h4>Customizing your Application</h4>
            <p>
                You can now start editing your application and building great ColdBox enabled apps. Important files & locations:
            </p>   
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
        </td>
		<td valign="top" id="sidebar">
            <h3>Community Links</h3>
            <ul class="links">
                <li>
                    <a href="http://www.coldbox.org">ColdBox Site</a>
                </li>
                <li>
                    <a href="http://blog.coldbox.org">Blog</a>
                </li>
                <li>
                    <a href="http://forums.coldbox.org/">Forums</a>
                </li>
                <li>
                    <a href="http://coldbox.assembla.com/spaces/dashboard/index/coldbox">Bug Tracker</a>
                </li>
                <li>
                    <a href="http://wiki.coldbox.org">Documentation</a>
                </li>
				<li>
                    <a href="http://groups.google.com/group/coldbox">Mailing List</a>
                </li>
				<li>
					<a href="http://www.coldbox.org/download">Downloads</a>
				</li>
				<li>
					<a href="http://www.coldbox.org/api/">ColdBox API</a>
				</li>
				<li>
					<a href="http://www.coldbox.org/forgebox">ForgeBox</a>
				</li>
				<li>
					<a href="http://coldbox.org/media">ColdBox Videos</a>
				</li>
				<li>
					<a href="http://www.coldbox.org/support/overview">Community Support</a>
				</li>
				<li>
					<a href="http://www.coldbox.org/support/training">Training & Courses</a>
				</li>
            </ul>
		
		<div style="margin:auto;text-align:center">
			<img src="http://www.coldbox.org/includes/images/logos/poweredby.gif" alt="ColdBox" />
		</div>
    </td>
    </tr>
</table>
</cfoutput>