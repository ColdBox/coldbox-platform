<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2008 by 
Luis Majano (Ortus Solutions, Corp) and Mark Mandel (Compound Theory)
www.transfer-orm.org |  www.coldboxframework.com
********************************************************************************
Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. 
You may obtain a copy of the License at 
    		
	http://www.apache.org/licenses/LICENSE-2.0 

Unless required by applicable law or agreed to in writing, software 
distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and 
limitations under the License.
********************************************************************************
$Build Date: @@build_date@@
$Build ID:	@@build_id@@
********************************************************************************
----------------------------------------------------------------------->
<cfoutput>
<cfsetting showdebugoutput="false">
<!--- js --->
<cfsavecontent variable="js">
<cfoutput>
<script type="text/javascript">
	$(document).ready(function() {
		/* Activate RTE */
		$('.rte-zone').rte("#getSetting('lookups_cssPath')#/lookups.css","#rc.imgPath#/rte/");  
		 
		//Activate Date Pickers
		$(".datepicker").datepicker({ 
		    showOn: "both"
		});
		
		/* Form Validation */
		$('##editform').formValidation({
			err_class 	: "invalidLookupInput",
			err_list	: true,
			callback	: 'prepareSubmit'
		});
	});
	function submitForm(){
		$('##editform').submit();		
	}
	function prepareSubmit(){
		$('##_buttonbar').slideUp("fast");
		$('##_loader').fadeIn("slow");		
		return true;
	}
	function submitM2M(relation,addRelation){
		//Add Relation Check
		var txtAddRelation = $("##add"+relation+"Form > input[@name='addRelation']");
		txtAddRelation.val(addRelation);
		$('##_buttonbar_'+relation).slideUp("fast");
		$('##_loader_'+relation).fadeIn("slow");
		$('##add'+relation+'Form').submit();
	}
	
	
</script>
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#js#">

<!--- Title --->
<h2><img src="#rc.imgPath#/cog.png" align="absmiddle"> System Lookup Manager > Edit Record</h2>
<!--- BACK --->
<div class="backbutton">
	<img src="#rc.imgPath#/arrow_left.png" align="absmiddle">
	<a href="#event.buildLink(rc.xehLookupList,0)#/lookupclass/#rc.lookupclass#.cfm">Back</a>
</div>
<p>Editing <strong>#rc.lookupClass#</strong>. Please fill out all the fields.</p>

<!--- Add Form --->
<form name="editform" id="editform" action="#event.buildLink(rc.xehLookupCreate,0)#.cfm" method="post">

<!--- Lookup Class Choosen to Add --->
<input type="hidden" name="lookupClass" id="lookupClass" value="#rc.lookupClass#">
<!--- Primary Key Value --->
<input type="hidden" name="ID" value="#rc.pkValue#">

<fieldset>
<legend><strong>Edit Form</strong></legend>
<div id="lookupFields">
	
	<!--- Primary Key --->
	<label class="primaryKeyLabel">#rc.mdDictionary.PK#:</label>
	<label class="primaryKey">#htmlEditFormat(rc.pkValue)#</label>
	
	<!--- Loop Through Foreign Keys, to create Drop Downs --->
	<cfloop from="1" to="#arrayLen(rc.mdDictionary.ManyToOneArray)#" index="i">
		<!--- Get the m20 query --->
		<cfset qListing = rc["q#rc.mdDictionary.ManyToOneArray[i].alias#"]>
		<cfset tmpValue = evaluate("rc.oLookup.get#rc.mdDictionary.ManyToOneArray[i].alias#().get#rc.mdDictionary.ManyToOneArray[i].PK#()")>
		<label class="labelNormal">#rc.mdDictionary.ManyToOneArray[i].alias#</label>
		<select name="fk_#rc.mdDictionary.ManyToOneArray[i].alias#"
				id="fk_#rc.mdDictionary.ManyToOneArray[i].alias#"
				required="#iif(rc.mdDictionary.FieldsArray[i].nullable,false,true)#">
			<cfloop query="qListing">
				<option value="#qListing[rc.mdDictionary.ManyToOneArray[i].PK][currentrow]#" <cfif qListing[rc.mdDictionary.ManyToOneArray[i].PK][currentrow] eq tmpValue>selected</cfif>>#qListing[rc.mdDictionary.ManyToOneArray[i].DisplayColumn][currentRow]#</option>
			</cfloop>
		</select>
		<br/>
	</cfloop>

	<!--- Loop through Fields --->
	<cfloop from="1" to="#ArrayLen(rc.mdDictionary.FieldsArray)#" index="i">
		<!--- Set value --->
		<cfset tmpValue = evaluate("rc.oLookup.get#rc.mdDictionary.FieldsArray[i].alias#()")>
		<!--- Do not show the ignore Updates and PK--->
		<cfif not rc.mdDictionary.FieldsArray[i].primaryKey and not rc.mdDictionary.FieldsArray[i].ignoreUpdate>
			<!--- PROPERTY LABEL --->
			<label class="labelNormal">
				#rc.mdDictionary.FieldsArray[i].alias#
				<cfif not rc.mdDictionary.FieldsArray[i].nullable>*</cfif>
			</label>
			<!--- Help Text --->
			<label class="helptext">#rc.mdDictionary.FieldsArray[i].helptext#</label>

			<!--- BOOLEAN TYPES --->
			<cfif rc.mdDictionary.FieldsArray[i].datatype eq "boolean">
				<cfif rc.mdDictionary.FieldsArray[i].html eq "radio">
					<input type="radio"
							 name="#rc.mdDictionary.FieldsArray[i].alias#"
							 id="#rc.mdDictionary.FieldsArray[i].alias#"
							 value="1"
							 checked="#tmpValue#"
							 required="#iif(rc.mdDictionary.FieldsArray[i].nullable,false,true)#">
					<label class="rbLabel" for="#rc.mdDictionary.FieldsArray[i].alias#">Yes</label>

					<input type="radio"
							 name="#rc.mdDictionary.FieldsArray[i].alias#"
							 id="#rc.mdDictionary.FieldsArray[i].alias#"
							 value="0"
							 checked="#not tmpValue#"
							 required="#iif(rc.mdDictionary.FieldsArray[i].nullable,false,true)#">
					<label class="rbLabel" for="#rc.mdDictionary.FieldsArray[i].alias#">No</label>
				<cfelse>
					<select name="#rc.mdDictionary.FieldsArray[i].alias#"
							id="#rc.mdDictionary.FieldsArray[i].alias#"
							required="#iif(rc.mdDictionary.FieldsArray[i].nullable,false,true)#"
							class="booleanSelect">
						<option value="1" <cfif tmpValue>selected="selected"</cfif>>True</option>
						<option value="0" <cfif not tmpValue>selected="selected"</cfif>>False</option>
					</select>
				</cfif>
			<!--- DATE TYPE --->
			<cfelseif rc.mdDictionary.FieldsArray[i].datatype eq "date">
			 <input type="text" size="25" value="#dateFormat(tmpValue,"mm/dd/yyyy")# #timeformat(tmpvalue)#" 
					name="#rc.mdDictionary.FieldsArray[i].alias#"
					id="#rc.mdDictionary.FieldsArray[i].alias#"
					required="#iif(rc.mdDictionary.FieldsArray[i].nullable,false,true)#"
					class="datepicker"/> 
			  <br />
			<cfelse>
				<cfif rc.mdDictionary.FieldsArray[i].html eq "text">
					<input type="text"
						   name="#rc.mdDictionary.FieldsArray[i].alias#"
						   id="#rc.mdDictionary.FieldsArray[i].alias#"
						   value="#tmpValue#"
						   size="50"
						   required="#iif(rc.mdDictionary.FieldsArray[i].nullable,false,true)#"
						   <cfif len(rc.mdDictionary.FieldsArray[i].validate)>
						   	mask="#rc.mdDictionary.FieldsArray[i].validate#"
						   </cfif>>
				<cfelseif rc.mdDictionary.FieldsArray[i].html eq "password">
					<input type="password"
							 name="#rc.mdDictionary.FieldsArray[i].alias#"
							 id="#rc.mdDictionary.FieldsArray[i].alias#"
							 value="#tmpValue#"
							 size="50"
							 required="#iif(rc.mdDictionary.FieldsArray[i].nullable,false,true)#">
				<cfelseif rc.mdDictionary.FieldsArray[i].html eq "textarea">
					<textarea name="#rc.mdDictionary.FieldsArray[i].alias#"
								id="#rc.mdDictionary.FieldsArray[i].alias#"
								rows="10"
								required="#iif(rc.mdDictionary.FieldsArray[i].nullable,false,true)#"
							 	>#tmpValue#</textarea>
				<cfelseif rc.mdDictionary.FieldsArray[i].html eq "richtext">
					<textarea name="#rc.mdDictionary.FieldsArray[i].alias#"
								id="#rc.mdDictionary.FieldsArray[i].alias#"
								class="rte-zone"
							  	required="#iif(rc.mdDictionary.FieldsArray[i].nullable,false,true)#"
							 	>#tmpValue#</textarea>
				</cfif>
			</cfif>
			<br />
		</cfif>
	</cfloop>
</div>
</fieldset>

<!--- Mandatory Label --->
<p>* Mandatory Fields</p>
<br />

<!--- Loader --->
<div id="_loader" class="formloader">
	<p>
		Submitting...<br />
		<img src="#rc.imgPath#/ajax-loader-horizontal.gif" align="absmiddle">
		<img src="#rc.imgPath#/ajax-loader-horizontal.gif" align="absmiddle">
	</p>
</div>

<!--- Create / Cancel --->
<div id="_buttonbar">
	<img src="#rc.imgPath#/cancel.png" border="0" align="absmiddle">
	<a href="#event.buildLink(rc.xehLookupList,0)#/lookupclass/#rc.lookupclass#.cfm" class="buttonLinks">
		Cancel
	</a>
	&nbsp;
	<img src="#rc.imgPath#/accept.png" border="0" align="absmiddle">
	<a href="javascript:submitForm()" class="buttonLinks">
		Update Record
	</a>
</div>
<br />
</form>

<!--- ************************************************************************************** --->
<!--- ************************************************************************************** --->
<!--- Many To Many Relations --->
<cfif rc.mdDictionary.hasManyToMany>
	<!--- Title --->
	<h3>Many to Many Manager(s)</h3>

	<cfloop from="1" to="#arrayLen(rc.mdDictionary.manytomanyarray)#" index="relIndex">
		<!--- Working MD M2M Array --->
		<cfset thisArray = rc.mdDictionary.manytomanyarray[relIndex]>
		<!--- Current M2M Listing Query --->
		<cfset qListing = rc["q#thisArray.alias#"]>
		<!--- Relation Array --->
		<cfset relationArray = rc["#thisArray.alias#Array"]>

		<!--- Display Relation Form --->
		<form name="add#thisArray.alias#Form" id="add#thisArray.alias#Form" action="#event.buildLink(rc.xehLookupUpdateRelation,0)#.cfm" method="post">
			<!--- Lookup Class Choosen to Add --->
			<input type="hidden" name="lookupClass" id="lookupClass" value="#rc.lookupClass#">
			<!--- Primary Key Value --->
			<input type="hidden" name="ID" value="#rc.pkValue#">
			<!--- Alias Name --->
			<input type="hidden" name="linkAlias" value="#thisArray.alias#">
			<input type="hidden" name="linkTO"    value="#thisArray.linkToTO#">
			<input type="hidden" name="addRelation" id="addRelation" value="1">

			<fieldset>
				<legend><a name="m2m_#thisArray.alias#"></a><strong>#thisArray.alias# Relation</strong></legend>

				<!--- Loader --->
				<div id="_loader_#thisArray.alias#" class="formloader">
					Submitting...<br />
					<img src="#rc.imgPath#/ajax-loader-horizontal.gif" align="absmiddle">
					<img src="#rc.imgPath#/ajax-loader-horizontal.gif" align="absmiddle">
				</div>
				<!--- Control Bar --->
				<div id="_buttonbar_#thisArray.alias#">
					<!--- M2M Drop Down Listing --->
					<select name="m2m_#thisArray.alias#" id="m2m_#thisArray.alias#">
						<cfloop query="qListing">
						<option value="#qListing[thisArray.linkToPK][currentrow]#">#qListing[thisArray.linkToSortBy][currentrow]#</option>
						</cfloop>
					</select>
					<!--- Add Button --->
					<cfif qListing.recordcount>
						<img src="#rc.imgPath#/add.png" border="0" align="absmiddle">
						<a href="javascript:submitM2M('#thisArray.alias#',1)" class="buttonLinks">
							Add Relation
						</a>
					</cfif>
					<cfif arraylen(relationArray)>
					<!--- Remove Button --->
					&nbsp;
					<img src="#rc.imgPath#/bin_closed.png" border="0" align="absmiddle">
					<a href="javascript:submitM2M('#thisArray.alias#',0)" class="buttonLinks">
						Remove Relation(s)
					</a>
					</cfif>
				</div>

				<br />
				<!--- Actual m2m for this lookup --->
				<cfif arraylen(relationArray)>
					<p><em> #arrayLen(relationArray)# records found.</em></p>
					<!--- Create Entry --->
					<cfloop from="1" to="#arrayLen(relationArray)#" index="i">
						<cfset thisRelationTO = relationArray[i]>
						<cfset thisRelationPKID = evaluate('thisRelationTO.get#thisArray.linkToPK#()')>
						<cfset thisRelationSortBy = evaluate('thisRelationTO.get#thisArray.linkToSortBy#()')>

						<input type="checkbox" name="m2m_#thisArray.alias#_id" id="m2m_#thisArray.alias#_id" value="#thisRelationPKID#" />
						<label class="relationLabel" for="m2m_#thisArray.alias#_id">#thisRelationSortBy#</label><br/>
					</cfloop>
				<cfelse>
					<p><em>No #thisArray.alias# relation records found.</em></p>
				</cfif>

			</fieldset>
		</form>
	</cfloop>
</cfif>

</cfoutput>