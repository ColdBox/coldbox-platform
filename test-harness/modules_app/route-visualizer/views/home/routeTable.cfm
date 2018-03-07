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
			<th width="150" class="text-center">actions</th>
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
            <td <cfif args.type eq "root">class="pattern"</cfif>>
				#thisRoute.pattern#<br>
				<strong>Regex:</strong> #thisRoute.regexpattern#
				<cfif thisRoute.keyExists( "domain" )>
					<strong>Domain:</strong> <span title="Regex" class="badge badge-#thisRoute.domain.len() ? "success" : "info"#">#thisRoute.domain.len() ? thisRoute.domain : "all"#</span>
				</cfif>
			</td>
			<td>
				<cfif thisRoute.keyExists( "verbs" )>
				#thisRoute.verbs.len() ? "<span class='badge badge-info'>#thisRoute.verbs#</span>" : "any"#
				<cfelse>
					any
				</cfif>
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

				<cfif thisRoute.redirect.len() ?: 0>
					<strong>Redirect:</strong> #thisRoute.statusCode ?: ''#: #thisRoute.redirect#
				</cfif>

				<cfif thisRoute.view.len() ?: 0>
					<strong>View:</strong> #thisRoute.view#<br>
					<strong>No Layout:</strong> #thisRoute.viewNoLayout#<br>
					<strong>Layout:</strong> #thisRoute.layout#
				</cfif>

				<cfif thisRoute.keyExists( "response" ) and isSimpleValue( thisRoute.response ) and thisRoute.response.len()>
					<strong>Simple Response:</strong><br>
					<pre class="card"><code>
						#htmlCodeFormat( thisRoute.response )#
					</code></pre>
				</cfif>

				<cfif thisRoute.keyExists( "response" ) and isClosure( thisRoute.response )>
					<strong>Lambda Response:</strong><br>
					<cfdump var="#thisRoute.response#">
				</cfif>
			</td>
			<td>
				#thisRoute.moduleRouting#
				<cfif thisRoute.moduleRouting.len()>
					<br>
					<button class="btn btn-primary btn-sm" onclick="$( '##module-#thisRoute.id#' ).toggle()">Open Router</button>
				</cfif>
            </td>
            <td>
				#thisRoute.namespaceRouting#
				<cfif thisRoute.namespaceRouting.len()>
					<br>
					<button class="btn btn-primary btn-sm" onclick="$( '##namespace-#thisRoute.id#' ).toggle()">Open Router</button>
				</cfif>
			</td>
			<td class="text-center">
				<button class="btn btn-danger btn-sm" onclick="$( '##debug-#thisRoute.id#' ).toggle()">Dump</button>
				<a href="#event.buildLink( thisRoute.pattern )#" target="_blank" class="btn btn-sm btn-primary">Run</a>
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
					args = { routes = prc.aModuleRoutes[ thisRoute.moduleRouting ], type = "module" }
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
                    args = { routes = prc.aNamespaceRoutes[ thisRoute.namespaceRouting ], type = "namespace" }
                )#
            </td>
        </tr>
        </cfif>

    </cfloop>
    </tbody>
</table>
</cfoutput>