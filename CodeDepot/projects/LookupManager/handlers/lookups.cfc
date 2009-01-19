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
<cfcomponent name="lookup" 
			 extends="codex.handlers.baseHandler"
			 output="false"
			 hint="This is the lookup builder controller object"
			 autowire="true">

	<!--- Dependencies --->
	<cfproperty name="LookupService" type="ioc" scope="instance">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- This init is mandatory, including the super.init(). ---> 
	<cffunction name="init" access="public" returntype="Lookups" output="false">
		<cfargument name="controller" type="any">
		<cfscript>
			var qFiles = 0;
			super.init(arguments.controller);
			
			/* Get CSS Files */
			qFiles = getFiles(getSetting('ApplicationPath') & getSetting('lookups_cssPath'),"*.css");
			instance.cssList = valueList(qFiles.name);
			/* Get js Files */
			qFiles = getFiles(getSetting('ApplicationPath') & getSetting('lookups_jsPath'),"*.js");
			instance.jsList = valueList(qFiles.name);
			/* Handler Package Path */
			instance.handlerPackage = getSetting('lookups_packagePath');
			if( len(instance.handlerPackage) neq 0){
				instance.handlerPackage = instance.handlerPackage & ".";
			} 
			/* View PackagePath */
			instance.viewPackage = getSetting('lookups_packagePath');
			if( len(instance.viewPackage) neq 0 ){
				instance.viewPackage = instance.viewPackage & "/";
			}
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- preHandler --->
	<cffunction name="preHandler" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="any" required="yes">
	    <cfscript>
			var rc = event.getCollection();
			var x = 1;
			var exceptList = "display,dspCreate,dspEdit";
			var cssPath = getSetting('lookups_cssPath') & "/";
			var jsPath = getSetting('lookups_jsPath') & "/";
			
			/* Images  */
			rc.imgPath = getSetting('lookups_imgPath');
			/* Validations */
			if( listFindNoCase(exceptList,event.getCurrentAction()) ){
				/* Global Exit Handler for this handler */
				rc.xehLookupList 	= "#instance.viewPackage#lookups/display";
				
				/* Custom CSS According to settings */
				for(x=1;x lte listlen(instance.cssList);x=x+1){
					htmlhead('<link rel="stylesheet" type="text/css" href="' & cssPath & listgetAt(instance.cssList,x) & '" />');
				}
				/* Custom JS According to settings */
				for(x=1;x lte listlen(instance.jsList);x=x+1){
					htmlhead('<script type="text/javascript" src="' & jsPath & listgetAt(instance.jsList,x) & '"></script>');	
				}		
			}
		</cfscript> 
	</cffunction>

	<cffunction name="display" output="false" access="public" returntype="void" hint="Display System Lookups">
		<cfargument name="Event" type="any">
		<cfscript>
		//Local event reference
		var rc = event.getCollection();
		var key = "";
		
		/* SET XEH */
		rc.xehLookupCreate = "#instance.handlerPackage#lookups/dspCreate";
		rc.xehLookupDelete = "#instance.handlerPackage#lookups/doDelete";
		rc.xehLookupEdit = "#instance.handlerPackage#lookups/dspEdit";
		rc.xehLookupClean = "#instance.handlerPackage#lookups/cleanDictionary";
		
		//Get System Lookups
		rc.systemLookups = getSetting("lookups_tables");
		rc.systemLookupsKeys = structKeyArray(rc.systemLookups);
		ArraySort(rc.systemLookupsKeys,"text");
		
		//Param Choosen Lookup
		event.paramValue("lookupClass", rc.systemLookups[ rc.systemLookupsKeys[1] ]);
		
		//Prepare Lookup's Meta Data Dictionary
		rc.mdDictionary = getLookupService().prepareDictionary(rc.lookupClass);
		
		//Get Lookup Listing
		rc.qListing = getLookupService().getListing(rc.lookupClass);

		//Param sort Order
		if ( event.getValue("sortOrder","") eq "")
			event.setValue("sortOrder","ASC");
		else{
			if ( rc.sortOrder eq "ASC" )
				rc.sortOrder = "DESC";
			else
				rc.sortOrder = "ASC";
		}
		//Test for Sorting
		if ( event.getValue("sortby","") neq "" )
			rc.qListing = getPlugin("queryHelper").sortQuery(rc.qListing,"[#rc.sortby#]",rc.sortOrder);
		else
			event.setValue("sortBy",rc.mdDictionary.sortBy);

		//Set view to render
		event.setView("#instance.viewPackage#lookups/Listing");
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="cleanDictionary" output="false" access="public" returntype="void" hint="Clean the MD Dictionary">
		<cfargument name="Event" type="any">
		<cfscript>
			/* Clean's the dictionary */
			getLookupService().cleanDictionary();
			
			/* Messagebox. */
			getPlugin("messagebox").setMessage("info", "Metadata Dictionary Cleaned.");
					
			/* Relocate back to listing */
			setNextRoute(route="#instance.viewPackage#lookups/display");
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="doDelete" output="false" access="public" returntype="void" hint="Delete A Lookup">
		<cfargument name="Event" type="any">
		<cfscript>
		var i = 1;
		var rc = event.getCollection();
		
		//Check that listing sent in
		if ( event.getTrimValue("lookupid","") neq "" ){
			//Loop throught listing and delete objects
			for(i=1; i lte listlen(rc.lookupid); i=i+1){
				//Delete Entry
				getLookupService().delete(rc.lookupclass,listgetAt(rc.lookupid,i));
			}
			/* Messagebox. */
			getPlugin("messagebox").setMessage("info", "Record(s) Deleted Successfully.");
		}
		else{
			/* Messagebox. */
			getPlugin("messagebox").setMessage("warning", "No Records Selected");
		}
				
		/* Relocate back to listing */
		setNextRoute(route="#instance.handlerPackage#lookups/display/lookupclass/#rc.lookupclass#");
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="dspCreate" output="false" access="public" returntype="void" hint="Create Lookup">
		<cfargument name="Event" type="any">
		<cfscript>
		//collection reference
		var rc = event.getCollection();
		var i = 1;
		
		//LookupCheck
		fncLookupCheck(event);
		
		/* exit handlers */
		rc.xehLookupCreate = "#instance.handlerPackage#lookups/doCreate";

		//Get Lookup's md Dictionary
		rc.mdDictionary = getlookupService().getDictionary(rc.lookupclass);

		//Check Relations
		if ( rc.mdDictionary.hasManyToOne ){
			//Get Lookup Listings
			for (i=1;i lte ArrayLen(rc.mdDictionary.ManyToOneArray); i=i+1){
				structInsert(rc,"q#rc.mdDictionary.ManyToOneArray[i].alias#",getLookupService().getListing(rc.mdDictionary.ManyToOneArray[i].className));
			}
		}
		//Set view.
		event.setView("#instance.viewPackage#lookups/Add");
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="doCreate" output="false" access="public" returntype="void" hint="Create Lookup">
		<cfargument name="Event" type="any">
		<cfscript>
		var rc = event.getCollection();
		var oLookup = "";
		var tmpFKTO = "";
		//Get the Transfer Object's Metadata Dictionary
		var mdDictionary = "";
		var i = 1;
		var errors = 0;

		//LookupCheck
		fncLookupCheck(event);

		//Metadata
		mdDictionary = getLookupService().getDictionary(rc.lookupClass);

		//Get New Lookup Transfer Object to save
		oLookup = getLookupService().getLookupObject(rc.lookupClass);

		//Populate it with RC data
		getPlugin("beanFactory").populateBean(oLookup);
		
		/* Validate First, if a validate method exists on the lookup */
		if( structKeyExists(oLookup,"validate") ){
			errors = oLookup.validate();
			if( ArrayLen(errors) ){
				/* MB for error */
				getPlugin("messagebox").setMessage(type="error", messageArray=errors);
				/* Show Creation Form again to fix errors */
				dspCreate(event);
				/* Finalize this event */
				return;
			}
		}

		//Check for FK Relations
		if ( ArrayLen(mdDictionary.ManyToOneArray) ){
			//Loop Through relations
			for ( i=1;i lte ArrayLen(mdDictionary.ManyToOneArray); i=i+1 ){
				tmpFKTO = getLookupService().getLookupObject(mdDictionary.ManyToOneArray[i].className,rc["fk_"&mdDictionary.ManyToOneArray[1].alias]);
				//add the tmpTO to oLookup
				evaluate("oLookup.set#mdDictionary.ManyToOneArray[1].alias#(tmpFKTO)");
			}
		}
		//Tell service to save object
		getLookupService().save(oLookup);		
		/* Relocate back to listing */
		setNextRoute(route="#instance.handlerPackage#lookups/display/lookupclass/#rc.lookupclass#");
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="dspEdit" output="false" access="public" returntype="void" hint="Edit System Lookups">
		<cfargument name="Event" type="any">
		<cfscript>
		var rc = event.getCollection();
		var i = 1;
		var tmpAlias = "";
		
		//LookupCheck
		fncLookupCheck(event);
		
		/* exit handlers */
		rc.xehLookupCreate = "#instance.handlerPackage#lookups/doUpdate";
		rc.xehLookupUpdateRelation = "#instance.handlerPackage#lookups/doUpdateRelation";
		
		//Get the passed id's TO Object
		rc.oLookup = getLookupService().getLookupObject(rc.lookupClass,rc.id);

		//Get Lookup's md Dictionary
		rc.mdDictionary = getLookupService().getDictionary(rc.lookupClass);
		rc.pkValue = evaluate("rc.oLookup.get#rc.mdDictionary.PK#()");

		//Check ManyToOne Relations
		if ( ArrayLen(rc.mdDictionary.ManyToOneArray) ){
			//Get Lookup Listings
			for (i=1;i lte ArrayLen(rc.mdDictionary.ManyToOneArray); i=i+1){
				structInsert(rc,"q#rc.mdDictionary.ManyToOneArray[i].alias#",getLookupService().getListing(rc.mdDictionary.ManyToOneArray[i].className));
			}
		}
		//Check ManyToMany Relations
		if ( rc.mdDictionary.hasManyToMany ){
			for (i=1;i lte ArrayLen(rc.mdDictionary.manyToManyArray); i=i+1){
				tmpAlias = rc.mdDictionary.manyToManyArray[i].alias;
				//Get m2m relation query
				structInsert(rc,"q#tmpAlias#",getLookupService().getListing(rc.mdDictionary.manyToManyArray[i].linkToTO));
				//Get m2m relation Array
				structInsert(rc,"#tmpAlias#Array", evaluate("rc.oLookup.get#tmpAlias#Array()"));
			}
		}
		//view to display
		event.setView("#instance.viewPackage#lookups/Edit");
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="doUpdate" output="false" access="public" returntype="void" hint="Update Lookup">
		<cfargument name="Event" type="any">
		<cfscript>
			var rc = event.getCollection();
			var oLookup = "";
			var tmpFKTO = "";
			//Get the Transfer Object's Metadata Dictionary
			var mdDictionary = "";
			var i = 1;

			//LookupCheck
			fncLookupCheck(event);

			//Metadata
			mdDictionary = getLookupService().getDictionary(rc.lookupClass);
			//Get Lookup Transfer Object to update
			oLookup = getLookupService().getLookupObject(rc.lookupClass, rc.id);
			//Populate it with RC data
			getPlugin("beanFactory").populateBean(oLookup);
			
			//Check for FK Relations
			if ( ArrayLen(mdDictionary.ManyToOneArray) ){
				//Loop Through relations
				for ( i=1;i lte ArrayLen(mdDictionary.ManyToOneArray); i=i+1 ){
					tmpFKTO = getLookupService().getLookupObject(mdDictionary.ManyToOneArray[i].className,rc["fk_"&mdDictionary.ManyToOneArray[i].alias]);
					//add the tmpTO to current oLookup before saving.
					evaluate("oLookup.set#mdDictionary.ManyToOneArray[1].alias#(tmpFKTO)");
				}
			}

			//Save Record(s)
			getLookupService().save(oLookup);

			/* Relocate back to listing */
			setNextRoute(route="#instance.handlerPackage#lookups/display/lookupclass/#rc.lookupclass#");
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="doUpdateRelation" output="false" access="public" returntype="void" hint="Update a TO's m2m relation">
		<cfargument name="Event" type="any">
		<cfscript>
			//Local Variables
			var rc = event.getCollection();
			var mdDictionary = "";
			var oLookup = "";
			var oRelation = "";
			var i = 1;
			var deleteRelationList = "";
			
			/* Incoming Args: lookupClass, Lookup id, addrelation[boolean], linkTO, linkAlias, m2m_{alias} = listing */

			//LookupCheck
			fncLookupCheck(event);

			//Get Lookup Transfer Object to update
			oLookup = getLookupService().getLookupObject(rc.lookupClass, rc.id);
			
			//Metadata
			mdDictionary = getLookupService().getDictionary(rc.lookupClass);

			//Adding or Deleting
			if ( event.getValue("addRelation",false) ){
				//Get the relation object
				oRelation = getLookupService().getLookupObject(rc.linkTO, rc["m2m_#rc.linkAlias#"]);
				//Check if it is already in the collection
				if ( not evaluate("oLookup.contains#rc.linkAlias#(oRelation)") ){
					//Add Relation to parent
					evaluate("oLookup.add#rc.linkAlias#(oRelation)");
				}
			}
			else{
				//Del Param
				event.paramValue("m2m_#rc.linkAlias#_id","");
				deleteRelationList = rc["m2m_#rc.linkAlias#_id"];
				//Remove Relations
				for (i=1; i lte listlen(deleteRelationList); i=i+1){
					//Get Relation Object
					oRelation = getLookupService().getLookupObject(rc.linkTO,listGetAt(deleteRElationList,i));
					//Remove Relation to parent
					evaluate("oLookup.remove#rc.linkAlias#(oRelation)");
				}
			}

			//Save Records
			getLookupService().save(oLookup);

			/* Relocate back to edit */
			setNextRoute(route="#instance.handlerPackage#lookups/dspEdit/lookupclass/#rc.lookupclass#/id/#rc.id#",suffix="##m2m_#rc.linkAlias#");		
		</cfscript>
	</cffunction>


<!----------------------------------- PRIVATE ------------------------------>
	
	<!--- Get/Set lookup Service --->
	<cffunction name="getLookupService" access="private" output="false" returntype="any" hint="Get LookupService">
		<cfreturn instance.LookupService/>
	</cffunction>	

	<cffunction name="fncLookupCheck" output="false" access="private" returntype="void" hint="Do a parameter check, else redirect">
		<cfargument name="event" type="any" required="true"/>
		<cfscript>
		if ( event.getTrimValue("lookupclass","") eq "")
			setNextRoute("#instance.handlerPackage#lookups/display");
		</cfscript>
	</cffunction>
	
	<!--- getFiles --->
	<cffunction name="getFiles" output="false" access="private" returntype="query" hint="Get a set of files">
		<cfargument name="dirPath" type="string" required="true" default="" hint="The directory Path"/>
		<cfargument name="filter" type="string" required="false" default="" hint="The default filter to apply"/>
		<cfset var qFiles = 0>
		
		<cfdirectory action="list" 
					 directory="#arguments.dirPath#"
					 name="qFiles"
					 filter="#arguments.filter#">
	
		<cfreturn qFiles>
	</cffunction>


</cfcomponent>