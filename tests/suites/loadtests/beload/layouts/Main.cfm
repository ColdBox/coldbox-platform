<cfoutput>
	<!doctype html>
	<html lang="en">
	<head>
		<!--- Metatags --->
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta name="description" content="ColdBox Application Template">
		<meta name="author" content="Ortus Solutions, Corp">

		<!---Base URL --->
		<base href="#event.getHTMLBaseURL()#" />

		<!---css --->
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
		<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
		<style>
			.text-blue { color:##379BC1; }
		</style>

		<!--- Title --->
		<title>Welcome to Coldbox!</title>
	</head>
	<body
		data-spy="scroll"
		data-target=".navbar"
		data-offset="50"
		style="padding-top: 60px"
		class="d-flex flex-column h-100"
	>
		<!---Top NavBar --->
		<header>
			<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
				<div class="container-fluid">
					<!---Brand --->
					<a class="navbar-brand" href="#event.buildLink( 'main' )#">
						<strong><i class="bi bi-bounding-box-circles"></i> Welcome</strong>
					</a>

					<!--- Mobile Toggler --->
					<button
						class="navbar-toggler"
						type="button"
						data-bs-toggle="collapse"
						data-bs-target="##navbarSupportedContent"
						aria-controls="navbarSupportedContent"
						aria-expanded="false"
						aria-label="Toggle navigation"
					>
						<span class="navbar-toggler-icon"></span>
					</button>

					<div class="collapse navbar-collapse" id="navbarSupportedContent">

						<!---About --->
						<ul class="navbar-nav ms-5 mb-2 mb-lg-0">
							<li class="nav-item dropdown">
								<a
									class="nav-link dropdown-toggle"
									href="##"
									id="navbarDropdown"
									role="button"
									data-bs-toggle="dropdown"
									aria-expanded="false"
								>
									About  <b class="caret"></b>
								</a>
								<ul class="dropdown-menu" aria-labelledby="navbarDropdown">
									<li>
										<a href="https://coldbox.org" class="dropdown-item">
											<i class="bi bi-journal-text"></i> Official Site
										</a>
									</li>
									<li>
										<a href="https://ortussolutions.atlassian.net/browse/COLDBOX" class="dropdown-item">
											<i class="bi bi-bug"></i> Report a Bug
										</a>
									</li>
									<li>
										<a href="https://github.com/ColdBox/coldbox-platform/stargazers" class="dropdown-item">
											<i class="bi bi-star"></i> Star Us
										</a>
									</li>
									<li>
										<hr class="dropdown-divider">
									</li>
									<li class="p-2">
										<img class="rounded mx-auto block" width="150" src="includes/images/ColdBoxLogo2015_300.png" alt="logo"/>
									</li>
								</ul>
							</li>
						</ul>

						<!--- Community --->
						<ul class="navbar-nav mb-2 mb-lg-0">
							<li class="nav-item dropdown">
								<a
									class="nav-link dropdown-toggle"
									href="##"
									id="navbarDropdown"
									role="button"
									data-bs-toggle="dropdown"
									aria-expanded="false"
								>
									Learn  <b class="caret"></b>
								</a>
								<ul class="dropdown-menu" aria-labelledby="navbarDropdown">
									<li>
										<a class="dropdown-item" href="https://coldbox.ortusbooks.com">Documentation</a>
									</li>
									<li>
										<a class="dropdown-item" href="https://www.ortussolutions.com/blog">Blog</a>
									</li>
									<li>
										<a class="dropdown-item" href="https://www.cfcasts.com/" target="_blank">Videos</a>
									</li>
									<li>
										<a class="dropdown-item" href="https://www.ortussolutions.com/services/training" target="_blank">Courses</a>
									</li>
								</ul>
							</li>
						</ul>

						<!--- Support --->
						<ul class="navbar-nav mb-2 mb-lg-0">
							<li class="nav-item dropdown">
								<a
									class="nav-link dropdown-toggle"
									href="##"
									id="navbarDropdown"
									role="button"
									data-bs-toggle="dropdown"
									aria-expanded="false"
								>
									Support  <b class="caret"></b>
								</a>
								<ul class="dropdown-menu" aria-labelledby="navbarDropdown">
									<li>
										<a class="dropdown-item" href="https://boxteam.herokuapp.com">Slack</a>
									</li>
									<li>
										<a class="dropdown-item" href="https://groups.google.com/group/coldbox">Mailing List</a>
									</li>
									<li>
										<a class="dropdown-item" href="https://www.coldbox.org/support/overview">Community Support</a>
									</li>
									<li>
										<a class="dropdown-item" href="https://www.ortussolutions.com/services">Professional Support</a>
									</li>
								</ul>
							</li>
						</ul>
					</div>
				</div>
			</nav>
		</header>

		<!---Container And Views --->
		<main class="flex-shrink-0">
			#view()#
		</main>

		<!--- Footer --->
		<footer class="w-100 bottom-0 position-fixed border-top py-3 mt-5 bg-light">
			<div class="container">
				<p class="float-end">
					<a href="##" class="btn btn-info rounded-circle shadow" role="button">
						<i class="bi bi-arrow-bar-up"></i> <span class="visually-hidden">Top</span>
					</a>
				</p>
				<p>
					<a href="https://github.com/ColdBox/coldbox-platform/stargazers">ColdBox Platform</a> is a copyright-trademark software by
					<a href="https://www.ortussolutions.com">Ortus Solutions, Corp</a>
				</p>
			</div>
		</footer>

		<!---js --->
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
		<script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>
	</body>
	</html>
	</cfoutput>
