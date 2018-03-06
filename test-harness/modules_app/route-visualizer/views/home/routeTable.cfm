<cfoutput>
<table class="table table-striped table-condensed table-hover" id="table-routes">
    <thead class="thead-dark">
        <tr>
            <th>order</th>
            <th>pattern+regex</th>
			<th>HTTP Verbs</th>
			<th>terminator</th>
            <th width="50">module</th>
			<th width="50">namespace</th>
			<th width="50">action</th>
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
            <td class="pattern">
				#thisRoute.pattern#<br>
				<strong>Regex:</strong> #thisRoute.regexpattern#<br>
				<strong>Domain:</strong> <span title="Regex" class="badge badge-#thisRoute.domain.len() ? "success" : "info"#">#thisRoute.domain.len() ? thisRoute.domain : "all"#</span>
			</td>
			<td>
				#thisRoute.verbs.len() ? "<span class='badge badge-info'>#thisRoute.verbs#</span>" : "any"#
            </td>
			<td>
				<cfif thisRoute.handler.len() ?: 0>
					<strong>Handler:</strong> #thisRoute.handler#<br>
				</cfif>

				<cfif thisRoute.action.len() ?: 0>
					<strong>Action:</strong> #serializeJSON( thisRoute.action )#
				</cfif>

				<cfif thisRoute.event.len() ?: 0>
					<strong>Event:</strong> #thisRoute.event.toString()#
				</cfif>

				<cfif thisRoute.redirect.len()>
					<strong>Redirect:</strong> #thisRoute.statusCode ?: ''#: #thisRoute.redirect#
				</cfif>

				<cfif thisRoute.view.len()>
					<strong>View:</strong> #thisRoute.view#<br>
					<strong>No Layout:</strong> #thisRoute.viewNoLayout#<br>
					<strong>Layout:</strong> #thisRoute.layout#
				</cfif>

				<cfif isSimpleValue( thisRoute.response ) and thisRoute.response.len()>
					<strong>response:</strong><br>
					<pre class="card"><code>
						#htmlCodeFormat( thisRoute.response )#
					</code></pre>
				</cfif>

				<cfif isCustomFunction( thisRoute.response )>
					<strong>response:</strong><br>
					<cfdump var="#thisRoute.response#">
				</cfif>
			</td>
			<td>
				#thisRoute.moduleRouting#
				<cfif thisRoute.moduleRouting.len()>
					<br>
					<button class="btn btn-primary btn-sm" onclick="$( '##module-#thisRoute.id#' ).toggle()">Open Module Router</button>
				</cfif>
            </td>
            <td>
				#thisRoute.namespaceRouting#
				<cfif thisRoute.namespaceRouting.len()>
					<br>
					<button class="btn btn-primary btn-sm" onclick="$( '##namespace-#thisRoute.id#' ).toggle()">Open Namespace Router</button>
				</cfif>
			</td>
			<td>
				<button class="btn btn-danger btn-sm" onclick="$( '##debug-#thisRoute.id#' ).toggle()">Route Dump</button>
			</td>
		</tr>

		<!-- Debug Span -->
		<tr class="table-danger" id="debug-#thisRoute.id#" style="display:none">
			<td colspan="7">
				<button class="float-right btn btn-danger btn-sm" onclick="$( '##debug-#thisRoute.id#' ).toggle()">Close</button>
				<h3>Route Dump</h3>
				<cfdump var="#thisRoute#">
			</td>
		</tr>

        <!-- Module Routing -->
        <cfif thisRoute.moduleRouting.len()>
        <tr class="table-success" id="module-#thisRoute.id#" style="display:none">
			<td colspan="7">
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
			<td colspan="7">
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