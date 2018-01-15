<cfoutput>
<h1>ColdBox Route Visualizer</h1>

<p>Routes as they are traveresed for matching</p>

#renderView(
    view = "home/routeTable",
    args = { routes = prc.aRoutes } 
)#
</cfoutput>