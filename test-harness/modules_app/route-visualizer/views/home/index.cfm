<cfoutput>
<h1 class="display-4">ColdBox Route Visualizer</h1>

<p class="lead">Routes as they are traveresed for matching in specific order.</p>

#renderView(
    view = "home/routeTable",
    args = { routes = prc.aRoutes }
)#
</cfoutput>