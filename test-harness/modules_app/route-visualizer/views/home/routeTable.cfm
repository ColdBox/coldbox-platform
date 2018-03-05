<cfoutput>
<table class="table table-striped table-condensed table-hover">
    <thead class="thead-dark">
        <tr>
            <th>order</th>
            <th>pattern</th>
            <th>domain</th>
            <th>module</th>
			<th>namespace</th>
			<th>event</th>
			<th>redirect</th>
			<th>action</th>
        </tr>
    </thead>

    <tbody>
    <cfset index = 1>
	<cfloop array="#args.routes#" index="thisRoute">
		<cfset thisRoute.id = hash( thisRoute.toString() )>
        <tr>
            <td>
                #index++#
            </td>
            <td>
				#thisRoute.pattern#
				<br>
				<span title="Regex" class="badge badge-info">#thisRoute.regexpattern#</span>
            </td>
            <td>
				#thisRoute.domain#
            </td>
            <td>
				#thisRoute.moduleRouting#
				<cfif thisRoute.moduleRouting.len()>
					<br>
					<button class="btn btn-primary btn-sm" onclick="$( '##module-#thisRoute.id#' ).toggle()">Expand</button>
				</cfif>
            </td>
            <td>
				#thisRoute.namespaceRouting#
				<cfif thisRoute.namespaceRouting.len()>
					<br>
					<button class="btn btn-primary btn-sm" onclick="$( '##namespace-#thisRoute.id#' ).toggle()">Expand</button>
				</cfif>
			</td>
			<td>
				<cfif thisRoute.handler.len() ?: 0>
					<strong>Handler:</strong> #thisRoute.handler#<br>
				</cfif>

				<cfif thisRoute.action.len() ?: 0>
					<strong>Action:</strong> #thisRoute.action.toString()#
				</cfif>

				<cfif thisRoute.event.len() ?: 0>
					#thisRoute.event.toString()#
				</cfif>
			</td>
			<td>
				<cfif thisRoute.redirect.len()>
					#thisRoute.statusCode ?: ''#: #thisRoute.redirect#
				</cfif>
			</td>
			<td>
				<button class="btn btn-danger btn-sm" onclick="$( '##debug-#thisRoute.id#' ).toggle()">Route Dump</button>
			</td>
		</tr>

		<!-- Debug Span -->
		<tr class="table-danger" id="debug-#thisRoute.id#" style="display:none">
			<td colspan="8">
				<button class="float-right btn btn-danger btn-sm" onclick="$( '##debug-#thisRoute.id#' ).toggle()">Close</button>
				<h3>Route Dump</h3>
				<cfdump var="#thisRoute#">
			</td>
		</tr>

        <!-- Module Routing -->
        <cfif thisRoute.moduleRouting.len()>
        <tr class="table-success" id="module-#thisRoute.id#" style="display:none">
			<td colspan="8">
				<button class="float-right btn btn-danger btn-sm" onclick="$( '##module-#thisRoute.id#' ).toggle()">Close</button>
				<h3>#thisRoute.moduleRouting# Module Routes</h3>
				#getRenderer().renderView(
					view = "home/routeTable",
					args = { routes = prc.aModuleRoutes[ thisRoute.moduleRouting ] }
				)#
            </td>
        </tr>
        </cfif>

        <!-- Namespace Routing -->
        <cfif thisRoute.namespaceRouting.len()>
			<tr class="table-success" id="namespace-#thisRoute.id#" style="display:none">
			<td colspan="8">
				<button class="float-right btn btn-danger btn-sm" onclick="$( '##namespace-#thisRoute.id#' ).toggle()">Close</button>
                <h3>#thisRoute.namespaceRouting# Namespace Routes</h3>
                #getRenderer().renderView(
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