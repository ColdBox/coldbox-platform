<cfoutput>
<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey eq "Yes"><cfset primaryKey = root.bean.dbTable.xmlChildren[i].xmlAttributes.name></cfif></cfloop>
<h1>#root.bean.xmlAttributes.name# List</h1>

<%cfoutput%>
<div>
[<a href="%getSetting('sesBaseURL')%/%rc.xehEditor%">Add New #root.bean.xmlAttributes.name#</a>]
</div>
<br/><br/>
%getPlugin("messagebox").renderit()%
<%/cfoutput%>

<table border="1" cellpadding="5" cellspacing="0" class="tablelisting">
	<%cfoutput%>
	<tr>
		<th><%cfif rc.sortBy eq '#primaryKey#'%><%cfif rc.sortOrder eq "asc"%>&%%8249;<%cfelse%>&%%8250;<%/cfif%><%/cfif%>
			<a href="%rc.xehList%?sortBy=#primaryKey#&sortOrder=%rc.sortOrder%">#primaryKey#</a></th>
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.name neq primaryKey>
		<th><%cfif rc.sortBy eq '#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#'%><%cfif rc.sortOrder eq "asc"%>&%%8249;<%cfelse%>&%%8250;<%/cfif%><%/cfif%>
			<a href="%rc.xehList%?sortBy=#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#&sortOrder=%rc.sortOrder%">#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#</a></th></cfif></cfloop>
		<th>actions</th>
	</tr>
	<%/cfoutput%>
	
	<%cfoutput query="rc.q#root.bean.xmlAttributes.name#"%>
	<tr <%cfif currentrow mod 2 eq 0%>class="even"<%/cfif%>>
		<td>%rc.q#root.bean.xmlAttributes.name#.#primaryKey#[currentrow]%</td>
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.name neq primaryKey>	
		<td><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.type eq "date">%dateFormat(#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#,"MM-DD-YYYY")%<cfelseif root.bean.dbtable.xmlChildren[i].xmlAttributes.type eq "boolean">%yesnoformat(#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#)%<cfelse>%#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#%</cfif></td></cfif></cfloop>
		<td><a href="%getSetting('sesBaseURL')%/%rc.xehEditor%?#primaryKey#=%#primaryKey#%">Edit </a> | <a href="%getSetting('sesBaseURL')%/%rc.xehDelete%?#primaryKey#=%#primaryKey#%">Delete</a></td>
		
	</tr>
	<%/cfoutput%>
</table>
<%cfif rc.q#root.bean.xmlAttributes.name#.recordcount eq 0%>
<h3>No records found</h3>	
<%/cfif%>
	
	
</cfoutput>