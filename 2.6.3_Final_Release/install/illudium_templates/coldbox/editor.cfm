<cfoutput>
<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey eq "Yes"><cfset primaryKey = root.bean.dbTable.xmlChildren[i].xmlAttributes.name></cfif></cfloop>

<%cfoutput%>
<div>
[<a href="index.cfm?event=%rc.xehList%">Back To Listing</a>]
</div>
<br/>
<%/cfoutput%>

<%cfoutput%>
<form name="editor_form" id="editor_form" action="index.cfm?event=%rc.xehSave%" method="post" >
<input type="hidden" name="#primaryKey#" value="%rc.o#root.bean.xmlAttributes.name#bean.get#primaryKey#()%" />

<fieldset>
<legend>#root.bean.xmlAttributes.name# Editor : <%cfif rc.o#root.bean.xmlAttributes.name#bean.get#primaryKey#() eq 0 %>Add<%cfelse%>Edit<%/cfif%> Record</legend>

<ul class="formLayout">
<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i">
<cfset element = root.bean.dbtable.xmlChildren[i].xmlAttributes>
<cfif primaryKey neq element.name>
<li><label for="#element.name#"><cfif element.required eq "Yes"><em>*</em></cfif>#element.name#:</label>
<cfif element.type eq "boolean">
<select name="#element.name#" id="#element.name#">
<option value="1" <%cfif isBoolean(rc.o#root.bean.xmlAttributes.name#bean.get#element.name#()) and rc.o#root.bean.xmlAttributes.name#bean.get#element.name#() %>selected="selected"<%/cfif%>>Yes</option>
<option value="0" <%cfif isBoolean(rc.o#root.bean.xmlAttributes.name#bean.get#element.name#()) and not rc.o#root.bean.xmlAttributes.name#bean.get#element.name#() %>selected="selected"<%/cfif%>>No</option>
</select>
<cfelseif element.type eq "date"><input id="#element.name#" name="#element.name#" type="text"	<%cfif %rc.o#root.bean.xmlAttributes.name#bean.get#element.name#()% eq ""%>value="%now()%"<%cfelse%>value="%rc.o#root.bean.xmlAttributes.name#bean.get#element.name#()%"<%/cfif%> size="40"  /><cfelse><input id="#element.name#" name="#element.name#" type="text" value="%rc.o#root.bean.xmlAttributes.name#bean.get#element.name#()%" maxlength="#element.length#" size="40" /></cfif></li></cfif></cfloop>
</ul>
<br/>
<div><strong>*</strong> Indicates required field</div>
<br/>
<div>
<input type="submit" value="Submit" class="" />
</div>
</fieldset>
</form>
<%/cfoutput%>

</cfoutput>