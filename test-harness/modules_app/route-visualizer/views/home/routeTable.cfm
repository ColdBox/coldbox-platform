<cfoutput>
<table class="table table-striped table-condensed table-hover">
    <thead>
        <tr>
            <th>order</th>
            <th>pattern</th>
            <th>regex</th>
            <th>module</th>
            <th>namespace</th>
        </tr>
    </thead>

    <tbody>
    <cfset index = 1>
    <cfloop array="#args.routes#" item="thisRoute">
        <tr>
            <td>
                #index++#
            </td>
            <td>
                #thisRoute.pattern#
            </td>
            <td>
                #thisRoute.regexpattern#
            </td>
            <td>
                #thisRoute.moduleRouting#
            </td>
            <td>
                #thisRoute.namespaceRouting#
            </td>
        </tr>

        <!-- Module Routing -->
        <cfif thisRoute.moduleRouting.len()>
        <tr class="info">
            <td colspan="5">
                <h3>#thisRoute.moduleRouting#</h3>
                #renderView(
                    view = "home/routeTable",
                    args = { routes = prc.aModuleRoutes[ thisRoute.moduleRouting ] } 
                )#
            </td>
        </tr>
        </cfif>

        <!-- Namespace Routing -->
        <cfif thisRoute.namespaceRouting.len()>
        <tr class="success">
            <td colspan="5">
                <h3>#thisRoute.namespaceRouting#</h3>
                #renderView(
                    view = "home/routeTable",
                    args = { routes = prc.aNamespaceRoutes[ thisRoute.namespaceRouting ] } 
                )#
            </td>
        </tr>
        </cfif>

    </cfloop>
    </tbody>
</table>
</cfoutput>