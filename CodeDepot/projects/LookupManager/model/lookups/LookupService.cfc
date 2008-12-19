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
<cfcomponent hint="This is the lookup manager using Transfer" output="false">

<!----------------------------------- CONSTRUCTOR ------------------------------>

	<cffunction name="init" returntype="LookupService" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="transfer" 	hint="the Transfer ORM" type="transfer.com.Transfer" required="Yes">
		<cfargument name="transaction" 	hint="The Transfer transaction" type="transfer.com.sql.transaction.Transaction" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			instance = StructNew();
	
			setTransfer(arguments.transfer);
	
			arguments.transaction.advise(this, "^save");
			arguments.transaction.advise(this, "^delete");
			
			/* Metadata Cache */
			setMDDictionary( structnew() );
	
			return this;
		</cfscript>
	</cffunction>

<!----------------------------------- PUBLIC ------------------------------>

	<!--- Get a table listing --->
	<cffunction name="getListing" access="public" returntype="query" output="false" hint="Get a Lookup's query listing.">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass" type="string" required="true" hint="The qualified transfer class name for this lookup. e.g. lookups.settings ">
		<!--- ************************************************************* --->
		<cfscript>
		//get lookup listing
		return getTransfer().list(arguments.lookupClass, getDictionary(arguments.lookupClass).sortBy);
		</cfscript>
	</cffunction>

	<!--- Get's the lookups Transfer Object --->
	<cffunction name="getLookupMetaData" access="public" returntype="any" output="false" hint="Get a lookup's TO Metadata Object">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass" type="string" required="true" hint="The qualified transfer class name for this lookup. e.g. lookups.settings ">
		<!--- ************************************************************* --->
		<cfscript>
		//get lookup listing
		return getTransfer().getTransferMetaData(arguments.lookupClass);
		</cfscript>
	</cffunction>

	<!--- Get's the lookups Transfer Object --->
	<cffunction name="getLookupObject" access="public" returntype="any" output="false" hint="Get a new or set TO of the Lookup">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass"   type="string" required="true">
		<cfargument name="lookupID" type="string" required="false" default="">
		<!--- ************************************************************* --->
		<cfscript>
		var oLookup = "";

		//Get by ID or new
		if ( len(trim(arguments.lookupID)) eq 0){
			oLookup = getTransfer().new(arguments.lookupClass);
		}
		else{
			oLookup = getTransfer().get(arguments.lookupClass, arguments.lookupID);
		}
		/* return lookup object */
		return oLookup;
		</cfscript>
	</cffunction>

	<!--- Get a lookup by a property struct --->
	<cffunction name="getLookupByPropertyStruct" access="public" returntype="any" output="false" hint="Get a lookup object using a property structure.">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass"   		type="string" required="true">
		<cfargument name="propertyStruct" 	type="struct" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var oLookup = "";
		
		//Get by Property Struct
		oLookup = getTransfer().readByPropertyMap(arguments.lookupClass, arguments.propertyStruct);

		return oLookup;
		</cfscript>
	</cffunction>

	<!--- Delete Listing --->
	<cffunction name="delete" access="public" returntype="void" output="false" hint="Hard Delete a lookup object">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass" 	type="string" required="false" default="">
		<cfargument name="id"     		type="string" required="false" default="">
		<cfargument name="lookupObject" required="false" type="any" hint="You can send the lookup object to delete. MUTEX with lookupClass and id.">
		<!--- ************************************************************* --->
		<cfscript>
			var oLookup = "";
			
			/* Deleting with TO? */
			if( structKeyExists(arguments,"lookupObject") ){
				oLookup = arguments.lookupObject;
			}
			else{
				oLookup = getTransfer().get(arguments.lookupClass,arguments.id);
			}
			//Remove Entry
			getTransfer().delete(oLookup);
		</cfscript>
	</cffunction>
	
	<!--- Save the Lookup Object --->
	<cffunction name="save" hint="Saves a lookup object" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="LookupObject" hint="The Lookup object" type="any" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			getTransfer().save(arguments.LookupObject);
		</cfscript>
	</cffunction>

	<!--- Get MD Dcitionary for a TO Class --->
	<cffunction name="getDictionary" access="public" returntype="struct" hint="Get a TO Metadata Dictionary entry" output="false">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass" 	type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			var lookupDictionary = structnew();
			
			if ( not structKeyExists( getmdDictionary() , arguments.lookupClass) ){
				//dictionary not found, prepare it
				lookupDictionary = prepareDictionary(arguments.lookupClass);
			}
			else
				lookupDictionary = structFind(getmdDictionary(), arguments.lookupClass );
				
			return lookupDictionary;
		</cfscript>
	</cffunction>

	<!--- Prepare MD Dictionary for TO Class --->
	<cffunction name="prepareDictionary" access="public" returntype="struct" hint="Prepare a TO Metadata Dictionary" output="false">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass" 	type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var oTO = "";
		var oTOMD = "";
		var mdStruct = structNew();
		var propIterator = "";
		var oProperty = "";
		var prop = structnew();
		var relIterator = "";
		var oRelation = "";
		var oPK = "";
		var rel = structnew();
		var oRelMD = "";
		var tmpTO = "";
		var tableConfig = structnew();

		//check if Dictionary set for this lookup, else end.
		if ( not structKeyExists(instance.mdDictionary,arguments.lookupClass) ){
			//Get lookup TO
			oTO = getLookupObject(arguments.lookupClass);
			//Get lookup TO MetaData Object
			oTOMD = getLookupMetaData(arguments.lookupClass);
			//Primary Key Object
			oPK = oTOMD.getPrimaryKey();
			//Table Config From Decorator if it exists
			if( structKeyExists(oTo,"getTableConfig") ){
				tableConfig = oTO.getTableConfig();
			}
			else{
				tableConfig = structnew();
			}
			//Get Lookup MD structure
			mdStruct.PK = oPK.getName();
			mdStruct.PKColumn = oPK.getColumn();
			if( structKeyExists(tableConfig,"sortBy") ){
				mdStruct.sortBy = tableConfig.sortBy;
			}
			else{
				mdStruct.sortBy = mdStruct.PK;
			}
			mdStruct.FieldsArray = ArrayNew(1);
			//Relations MD
			mdStruct.hasManyToOne = oTOMD.hasManyToOne();
			mdStruct.ManyToOneArray = ArrayNew(1);
			mdStruct.hasManyToMany = oTOMD.hasManyToMany();
			mdStruct.ManyToManyArray = ArrayNew(1);

			//Primary Key Field
			prop = structnew();
			prop.alias = oPK.getName();
			prop.column = oPK.getColumn();
			prop.datatype = oPK.getType();
			prop.nullable = oPK.getIsNullable();
			//Display Property for PK
			if ( structKeyExists(tableConfig,prop.alias) and structKeyExists(tableConfig[prop.alias],"display") )
				prop.display = tableConfig[prop.alias].display;
			else
				prop.display = true;
			prop.html = "text";
			prop.ignoreInsert = false;
			prop.ignoreUpdate = false;
			prop.primaryKey = true;
			
			/* Add the PK to the fields array */
			ArrayAppend(mdStruct.FieldsArray,prop);

			//Get Properties
			propIterator = oTOMD.getPropertyIterator();
			while ( propIterator.hasNext() ){
				oProperty = propIterator.next();
				prop = structnew();
				prop.alias = oProperty.getName();
				prop.column = oProperty.getColumn();
				prop.datatype = oProperty.getType();
				prop.nullable = oProperty.getIsNullable();
				prop.ignoreInsert = oProperty.getIgnoreInsert();
				prop.ignoreUpdate = oProperty.getIgnoreUpdate();
				prop.primaryKey = false;

				//List Display MD
				if ( structKeyExists(tableConfig,prop.alias) and structKeyExists(tableConfig[prop.alias],"display") ){
					prop.display = tableConfig[prop.alias].display;
				}
				else{
					prop.display = true;
				}
				//HTML Type MD
				if ( structKeyExists(tableConfig,prop.alias) and structKeyExists(tableConfig[prop.alias],"html") ){
					prop.html = tableConfig[prop.alias].html;
				}
				else{
					prop.html = "text";
				}
				//Help TEXT
				if( structKeyExists(tableConfig,prop.alias) and structKeyExists(tableConfig[prop.alias],"helptext") ){
					prop.helptext = tableConfig[prop.alias].helptext;
				}
				else{
					prop.helptext = '';
				}
				if( structKeyExists(tableConfig,prop.alias) and structKeyExists(tableConfig[prop.alias],"validate") ){
					prop.validate = tableConfig[prop.alias].validate;
				}
				else{
					prop.validate = '';
				}
				
				//Atach Property
				ArrayAppend(mdStruct.FieldsArray,prop);
			}

			//Get Relations : Many To One
			relIterator = oTOMD.getManyToOneIterator();
			while ( relIterator.hasNext() ){
				oRelation = relIterator.next();
				rel = structnew();
				rel.alias = oRelation.getName();
				rel.column = oRelation.getLink().getColumn();
				rel.className = oRelation.getLink().getTO();
				
				/* Display column comes from the tableconfig */
				if( structKeyExists(tableConfig,rel.alias) and structKeyExists(tableConfig[rel.alias],"displayColumn") ){
					rel.DisplayColumn = tableConfig[rel.alias].DisplayColumn;
				}
				else{
					throw(message="The display column for the relation: #rel.alias# was not found in the table config.",
						  detail="This method is needed for many to one relations. Please check your code.",
						  type="LookupService.missingDisplayColumn");
				}
				
				//Get Relation MD
				oRelMD = getLookupMetaData(rel.className);
				rel.PK = oRelMD.getPrimaryKey().getName();
				rel.PKColumn = oRelMD.getPrimaryKey().getColumn();

				//Attach Relation
				ArrayAppend(mdStruct.ManyToOneArray,rel);
			}

			//Get Relations Many To Many
			relIterator = oTOMD.getManyToManyIterator();
			while ( relIterator.hasNext() ){
				oRelation = relIterator.next();
				rel = structnew();
				rel.alias = oRelation.getName();
				rel.linktable = oRelation.getTable();
				//From
				rel.linkFromColumn = oRelation.getLinkFrom().getColumn();
				rel.linkFromTO = oRelation.getLinkFrom().getTO();
				//To
				rel.linkToColumn = oRelation.getLinkTo().getColumn();
				rel.linkToTO = oRelation.getLinkTo().getTO();
				//Get tmp TO
				oRelMD = getDictionary(rel.linkToTO);
				//Setup DIsplay
				rel.linkToPK = oRelMD.PK;
				rel.linkToSortBy = oRelMD.SortBy;
				//CollectionType
				rel.collectionType = oRelation.getCollection().getType();
				//Attach Relation
				ArrayAppend(mdStruct.ManyToManyArray,rel);
			}

			//Attach to Dictionary
			StructInsert(instance.mdDictionary,arguments.lookupClass, mdStruct);
			
		}// end for if dictionary found
		else{
			/* Else just get the dictionary locally. */
			mdStruct = structFind(getmdDictionary(), arguments.lookupClass );
		}
		return mdStruct;
		</cfscript>
	</cffunction>
	
	<!--- Clean Dictionary --->
	<cffunction name="cleanDictionary" access="public" returntype="void" output="false">
		<cfset setmdDictionary(structnew())>
	</cffunction>

<!----------------------------------- UTILITY GETTER/SETTERS ------------------------------>

	<!--- getter and setter for mdDictionary --->
	<cffunction name="getmdDictionary" access="public" returntype="struct" output="false">
		<cfreturn instance.mdDictionary>
	</cffunction>
	<cffunction name="setmdDictionary" access="public" returntype="void" output="false">
		<cfargument name="mdDictionary" type="struct" required="true">
		<cfset instance.mdDictionary = arguments.mdDictionary>
	</cffunction>
	
	<!--- Get Set Transfer --->
	<cffunction name="getTransfer" access="private" returntype="transfer.com.Transfer" output="false">
		<cfreturn instance.transfer />
	</cffunction>	
	<cffunction name="setTransfer" access="private" returntype="void" output="false">
		<cfargument name="transfer" type="transfer.com.Transfer" required="true">
		<cfset instance.transfer = arguments.transfer />
	</cffunction>

<!----------------------------------- PRIVATE ------------------------------>

	<!--- Get the util object --->
	<cffunction name="getUtil" output="false" access="private" returntype="codex.model.util.utility" hint="Utility Object">
		<cfreturn CreateObject("component","codex.model.util.utility")>
	</cffunction>

</cfcomponent>