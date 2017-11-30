<cfoutput>
<h1>Registered Routes</h1>

#renderView(
    view = "main/routeTable",
    args = { routes = prc.aRoutes } 
)#
</cfoutput>