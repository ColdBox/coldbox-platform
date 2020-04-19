<cfoutput>
<table class="table table-striped table-condensed">
    <thead>
        <tr>
            <th>pattern</th>
            <th>regex</th>
            <th>moduleRouting</th>
            <th>namespaceRouting</th>
        </tr>
    </thead>

    <tbody>
    <cfloop array="#args.routes#" index="thisRoute">
        <tr>
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
    </cfloop>
    </tbody>
</table>
</cfoutput>