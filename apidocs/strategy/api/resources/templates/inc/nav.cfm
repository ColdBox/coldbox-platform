<cfparam name="attributes.package" default="">
<cfparam name="attributes.file">

<cfset root = RepeatString('../', ListLen(attributes.package, ".")) />

<!-- ========= START OF NAVBAR ======= -->
<a name="navbar_top"></a>
<a href="#skip-navbar_top" title="skip navigation links"></a>	

<nav class="navbar navbar-default navbar-fixed-top" role="navigation">
	<div class="container-fluid">
    
		<div class="navbar-header">
			<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#class-navigation">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="#"><strong><cfoutput>#attributes.projecttitle#</cfoutput></strong></a>
		</div>

	    <div class="collapse navbar-collapse" id="class-navigation">
	    	<ul class="nav navbar-nav">
				<cfif attributes.page eq "overview">
					<li class="active"><a href="#"><i class="glyphicon glyphicon-plane"></i> overview</a></li>
				<cfelse>
					<cfoutput>
					<li><a href="#root#overview-summary.html"><i class="glyphicon glyphicon-plane"></i> overview</a></li>
					</cfoutput>
				</cfif>

				<cfif attributes.page eq "package">
					<li class="active"><a href="#"><i class="glyphicon glyphicon-folder-open"></i> &nbsp;package</a></li>
				<cfelseif attributes.page eq "class">
					<li><a href="package-summary.html"><i class="glyphicon glyphicon-folder-open"></i> &nbsp;package</a></li>
				</cfif>

			  	<cfif attributes.page eq "class">
					<li class="dropdown active">
						<a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="glyphicon glyphicon-file"></i> class <b class="caret"></b></a>

						<ul class="dropdown-menu">
							<li><a href="#class">Class Definition</a></li>
							<li><a href="#constructor_summary">Constructor Summary</a></li>
							<li><a href="#constructor_detail">Constructor Detail</a></li>
							<li><a href="#inherited_methods">Inherited Methods</a></li>
							<li><a href="#method_summary">Method Summary</a></li>
							<li><a href="#method_detail">Method Detail</a></li>
							<li><a href="#property_summary">Property Summary</a></li>
							<li><a href="#property_detail">Property Detail</a></li>
							
						</ul>
					</li>
				</cfif>
	      	</ul>

			<ul class="nav navbar-nav navbar-right">
				<li><cfoutput><a href="#root#index.html?#attributes.file#.html" target="_top">
					<i class="glyphicon glyphicon-fullscreen"></i> Frames
					</a></cfoutput>
				</li>
			</ul>
	    </div>

	</div>
</nav>	

<a name="skip-navbar_top"></a>
<!-- ========= END OF NAVBAR ========= -->