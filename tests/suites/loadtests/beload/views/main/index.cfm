<cfoutput>
	<div class="text-center card shadow-sm bg-light border border-5 border-white">
		<div class="card-body">
			<div>
				<img src="includes/images/ColdBoxLogo2015_300.png" class="m-2 mt-2" alt="logo" height="200"/>
			</div>
			<div class="badge bg-info mb-2">
				<strong>#getColdBoxSetting( "version" )# (#getColdBoxSetting( "suffix" )#)</strong>
			</div>

			<h1 class="display-5 fw-bold">
				#prc.welcomeMessage#
			</h1>

			<div class="col-lg-6 mx-auto">
				<p class="lead mb-4">
					Welcome to modern ColdFusion (CFML) development.  You can now start building your application with ease, we already did the hard work
					for you.
				</p>
			</div>
		</div>
	</div>
	<div class="container mb-5">
		<div class="row py-5 row-cols-lg-2 gx-4">
			<div class="col d-flex align-items-start">
				<div class="bg-light text-blue flex-shrink-0 me-3 px-2 fs-2 rounded-circle shadow-sm border border-5 border-white">
					<i class="bi bi-broadcast" aria-hidden="true"></i>
				</div>
				<div>
					<h2 class="text-blue">Event Handlers</h2>
					<p>
					You can click on the following event handlers to execute their default action
					<span class="badge bg-danger">index()</span>
					</p>
					<div class="list-group">
						<cfloop list="#getSetting("RegisteredHandlers")#" index="handler">
							<a href="#event.buildLink( handler )#" class="list-group-item list-group-item-action d-flex gap-2 py-3" title="Run Event">
								<div class="rounded-circle flex-shrink-0 text-success px-1">
									<i class="bi bi-play-btn" aria-hidden="true"></i>
								</div>
								<div class="d-flex gap-2 w-100 justify-content-between">#handler#</div>
							</a>
						</cfloop>
					</div>
				</div>
			</div>

			<div class="col d-flex align-items-start">
				<div class="bg-light text-blue flex-shrink-0 me-3 px-2 fs-2 rounded-circle shadow-sm border border-5 border-white">
					<i class="bi bi-cpu-fill"></i>
				</div>
				<div>
					<h2 class="text-blue">Modules</h2>
					<p>
					Here are your registered ColdBox Modules. Click on them to open their entry point.
					</p>
					<div class="list-group">
						<cfloop collection="#getSetting("Modules")#" item="thisModule">
							<a href="#event.buildLink( getModuleConfig( thisModule ).inheritedEntryPoint )#" class="list-group-item list-group-item-action d-flex gap-2 py-3" title="Run Event">
								<div class="rounded-circle flex-shrink-0 text-success px-1">
									<i class="bi bi-play-btn" aria-hidden="true"></i>
								</div>
								<div class="d-flex gap-2 w-100 justify-content-between">#thisModule#</div>
							</a>

						</cfloop>
					</div>
				</div>
			</div>
		</div>

		<div class="row pb-5 row-cols-lg-2 gx-4">
			<div class="col d-flex align-items-start">
				<div class="bg-light text-blue flex-shrink-0 me-3 px-2 fs-2 rounded-circle shadow-sm border border-3 border-white">
					<i class="bi bi-power"></i>
				</div>
				<div>
					<h2 class="text-blue">Reinitialize ColdBox</h2>
					<p>
						ColdBox caches things in memory for you to increase performance.  If you make any configuration changes, add/modify modules, etc, please make sure you reinit the framework
						so those changes take effect.  You can use the URL action shown below or CommandBox to issue a <code>coldbox reinit</code> command.
					</p>
					<table class="table table-striped">
						<thead>
							<th>URL Action</th>
							<th width="100">Execute</th>
						</thead>
						<tbody>
							<tr>
								<td>
									<em>?fwreinit=1</em><br/>
									<em>?fwreinit={ReinitPassword}</em>
								</td>
								<td>
									<a class="btn btn-dark" href="index.cfm?fwreinit=1">
										<i class="bi bi-power" aria-hidden="true"></i> Run
									</a>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>

			<div class="col d-flex align-items-start">
				<div class="bg-light text-blue flex-shrink-0 me-3 px-2 fs-2 rounded-circle shadow-sm border border-5 border-white">
					<i class="bi bi-card-checklist" aria-hidden="true"></i>
				</div>
				<div>
					<h2 class="text-blue">Tests</h2>
					<p>
					Unit and integration testing are integral parts to any ColdBox application.  We have scaffolded the test harness under the <code>tests</code> folder.
					From here you can open the <strong>Tests Browser</strong> and also execute all your tests.  Please note that you can also run all your tests via
					CommandBox: <code>testbox run</code>. You can even start a watcher which will check for source changes and run your tests for your: <code>testbox watch</code>
					</p>

					<div class="d-grid gap-2 d-sm-flex justify-content-sm-center">
						<a
							href="#getSetting( "appMapping" )#/tests/index.cfm"
							class="btn btn-dark btn-lg"
							role="button"
							target="_blank"
						>
							<i class="bi bi-binoculars" aria-hidden="true"></i>
							Test Browser
						</a>

						<a
							href="#getSetting( "appMapping" )#/tests/runner.cfm"
							class="btn btn-dark btn-lg"
							role="button"
							target="_blank"
						>
							<i class="bi bi-activity" aria-hidden="true"></i>
							Test Runner
						</a>
					</div>
				</div>
			</div>
		</div>
	</div>

#view( "partials/p1" )#
#view( "partials/p2" )#
#view( "partials/p3" )#
#view( "partials/p1" )#
#view( "partials/p2" )#
#view( "partials/p3" )#
</cfoutput>
