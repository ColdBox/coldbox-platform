<cfoutput>

<!---
	Custom Tags by Convention
	- Test removed for Adobe. Not working on Unix.  Test it later
--->
<cfif server.keyExists( "lucee" )>
	<cf_hello></cf_hello>
</cfif>

<div class="jumbotron">
	<img src="includes/images/ColdBoxLogoSquare_125.png" class="pull-left margin10" alt="logo"/>
	<h1>#prc.welcomeMessage#</h1>
	<p>
		 <strong>#getColdBoxSetting("codename")# #getColdBoxSetting("version")# (#getColdBoxSetting("suffix")#)</strong>.
		Test Harness Application
		<a class="btn btn-primary" href="index.cfm?fwreinit=1" >
			<strong>Reinitialize Framework</strong>
		</a>
	</p>
</div>

<div class="row">
	<div class="col-md-9">

		<section id="eventHandlers">
		<div class="page-header">
			<h2>
				Registered Event Handlers: #sayHello()# #sayViewHello()#
			</h2>
		</div>

		<div style="border:1px dotted gray; padding: 10px; margin: 10px 0px">
			#view( view = "viewWithArgs", args = { data = "Hi I am Data!" } )#
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

		<section id="named-routes">
		<div class="page-header">
	        <h2>
	        	Named Routes Construction
			</h2>
		</div>
		<ul>
			<li><a href="#event.route( "contactus" )#">#event.route( "contactus" )#</a></li>
			<li><a href="#event.buildLink( { name: "testRoute" } )#">#event.buildLink( { name: "testRoute" } )#</a></li>
			<li><a href="#event.route( "testRouteWithParams", { id=1, name='test' } )#">#event.route( "testRouteWithParams", { id=1, name='test' } )#</a></li>
			<li><a href="#event.buildLink( { name: "complexParams", params : { id=1, name='test' } } )#">#event.route( "complexParams", { id=1, name='test' } )#</a></li>
		</ul>
		</section>

	</div>

</div>
</cfoutput>
