<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Ben Garrett
Date        :	May/18/2009
License     :	Apache 2 License
Version     :	2
Description :
	Additional methods for the feed reader plug-in that were separated
	to reduce potential bloat in the plug-in component.

----------------------------------------------------------------------->
<cfcomponent name="FeedReader"
			 hint="Feed reader plug-in additional methods"
			 output="false">
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="FeedReader" output="false">
		<cfargument name="controller" type="any">
		<cfscript>
			variables.controller = arguments.controller;
			return this;
		</cfscript>
	</cffunction>

<!--------------------------------------------------------------------------------------------------->
	
	<!--- Get author --->
	<cffunction name="findAuthor" access="public" output="false" returntype="string" hint="Parse an item and find an author">
		<!--- ******************************************************************************** --->
		<cfargument name="itemRoot" type="xml" required="true" hint="The item to look in"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var item = arguments.itemRoot;
			var path = "";
			var y = 1;
			if( structKeyExists(item,"media:group") and structKeyExists(item["media:group"],"media:credit") ) path = item["media:group"]["media:credit"];
			else if (structKeyExists(item,"media:credit") ) path = item["media:credit"];
			if( not IsSimpleValue(path) and arrayLen(path) ){
				for(y=1; y lte arrayLen(path);y=y+1){
					if( isStruct(path[y]) and structKeyExists(path[y],'role') and path[y].role is "author" ) return path[y].xmlText;
					else if( not isStruct(path[y]) and not structKeyExists(path[y],'role') ) return path[y].xmlText;
				}
			}
			else if( structKeyExists(item,"author") and structKeyExists(item.author,"name") ) return normalizeAtomTextConstruct(item.author.name); // atom author
			else if( structKeyExists(item,"dc:creator") ) return item["dc:creator"].xmlText; // dublincore creator
			else if( StructKeyExists(item,"itunes:author") ) return item["itunes:author"].xmlText; // itunes author
			else if( structKeyExists(item,"dc:contributor") ) return item["dc:contributor"].xmlText; // dublincore contributor
			else if( structKeyExists(item,"dc:publisher") ) return item["dc:publisher"].xmlText; // dublincore publisher
			return "";
		</cfscript>
	</cffunction>

	<!--- Get category --->
	<cffunction name="findCategory" access="public" output="false" returntype="array" hint="Parse an item and find a categories">
		<!--- ******************************************************************************** --->
		<cfargument name="itemRoot" type="xml" required="true" hint="The item to look in"/>
		<cfargument name="categorynode" type="array" required="true" hint="Existing category to merge with categories"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var item = arguments.itemRoot;
			var categoryCol = arguments.categorynode;
			var path = "";
			var y = 1;
			var itemStruct = "";
			
			// MediaRSS categories
			if( structKeyExists(item,"media:group") and structKeyExists(item["media:group"],"media:category") ) path = item["media:group"]["media:category"];
			else if (structKeyExists(item,"media:category") ) path = item["media:category"];
			if( not IsSimpleValue(path) and arrayLen(path) ){
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.tag = path[y].xmlText;
					if( structKeyExists(path[y].xmlAttributes,'scheme') ) itemStruct.domain = path[y].xmlAttributes.scheme;
					else itemStruct.domain = "http://search.yahoo.com/mrss/category/";
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			// mediarss keywords
			if( isArray(path) and structKeyExists(item,"media:group") and structKeyExists(item["media:group"],"media:keywords") ) path = item["media:group"]["media:keywords"];
			else if (structKeyExists(item,"media:keywords") ) path = item["media:keywords"];
			if( not IsSimpleValue(path) and arrayLen(path) ) {
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.tag = path[y].xmlText;
					itemStruct.domain = "http://search.yahoo.com/mrss/keywords/";
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			// atom and rss categories
			if(StructKeyExists(item,"category")) path = item.category;
			if( not IsSimpleValue(path) and arrayLen(path) ){
				for(y=1; y lte arrayLen(path); y=y+1){
					// atom
					if( StructKeyExists(path[y].xmlAttributes,'term') and len(path[y].xmlAttributes.term) ) { 
						itemStruct = StructNew();
						itemStruct.tag = path[y].XMLAttributes.term;
						if(StructKeyExists(path[y].xmlAttributes,'scheme')) itemStruct.domain = path[y].xmlAttributes.scheme;
						else itemStruct.domain = ""; 
					}
					// rss
					else if( len(path[y].xmlText) ) { 
						itemStruct = StructNew();
						itemStruct.tag = path[y].xmlText;
						if(StructKeyExists(path[y].xmlAttributes,'domain')) itemStruct.domain = path[y].xmlAttributes.domain;
						else itemStruct.domain = ""; 
					}
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			// Dublin Core subject being used as a category
			if( structKeyExists(item,"dc:subject") ) path = item["dc:subject"];
			if( not IsSimpleValue(path) and arrayLen(path) ) {
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.tag = path[y].xmlText;
					itemStruct.domain = "http://purl.org/dc/elements/1.1/subject";
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			// iTunes Category
			if( structKeyExists(item,"itunes:category") ) path = item["itunes:category"];
			if( not IsSimpleValue(path) and arrayLen(path) ) {
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.tag = path[y].xmlText;
					itemStruct.domain = "http://www.apple.com/itunes/whatson/podcasts/specs.html##category";
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			// iTunes Keywords
			if( structKeyExists(item,"itunes:keywords") ) path = item["itunes:keywords"];
			if( not IsSimpleValue(path) and arrayLen(path) ) {
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.tag = path[y].xmlText;
					itemStruct.domain = "http://www.apple.com/itunes/whatson/podcasts/specs.html##keywords";
					ArrayAppend(categoryCol,itemStruct);
				}
			}
			path = "";
			return categoryCol;
		</cfscript>
	</cffunction> 

	<!--- Get comments --->
	<cffunction name="findComments" access="public" output="false" returntype="struct" hint="Parse an item and find comments">
		<!--- ******************************************************************************** --->
		<cfargument name="itemRoot" type="xml" required="true" hint="The item to look in"/>
		<cfargument name="commentsnode" type="struct" required="true" hint="Existing comments structure to be updated"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var item = arguments.itemRoot;
			var itemStruct = arguments.commentsnode;
			var path = "";
			var y = 1;
			// google data api
			if( structKeyExists(item,"gd:comments") and structKeyExists(item["gd:comments"],"gd:feedLink") ){
				path = item["gd:comments"]["gd:feedLink"];
				if( structKeyExists(path.XmlAttributes,'href') ) itemStruct.url = path.XmlAttributes.href;
				if( structKeyExists(path.XmlAttributes,'countHint') ) itemStruct.count = path.XmlAttributes.countHint;
			}
			return itemStruct;
		</cfscript>
	</cffunction>

	<!--- Get MediaRSS content --->
	<cffunction name="findMediaContent" access="public" output="false" returntype="array" hint="Parse an item and find media content">
		<!--- ******************************************************************************** --->
		<cfargument name="itemRoot" type="xml" required="true" hint="The item to look in"/>
		<cfargument name="attachmentnode" type="array" required="true" hint="Existing attachments to merge with media content"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var item = arguments.itemRoot;
			var itemStruct = StructNew();
			var attachmentCol = arguments.attachmentnode;
			var path = "";
			var y = 1;
			if( structKeyExists(item,"media:group") and structKeyExists(item["media:group"],"media:content") ) path = item["media:group"]["media:content"];
			else if (structKeyExists(item,"media:content") ) path = item["media:content"];
			if( not IsSimpleValue(path) and arrayLen(path) ){
				for(y=1; y lte arrayLen(path);y=y+1){
					itemStruct = StructNew();
					itemStruct.type = "media";
					if( structKeyExists(path[y].xmlAttributes,'url') ) itemStruct.url = path[y].xmlAttributes.url;
					else itemStruct.url = "";
					if( structKeyExists(path[y].xmlAttributes,'filesize') ) itemStruct.size = path[y].xmlAttributes.filesize;
					else itemStruct.size = "";
					if( structKeyExists(path[y].xmlAttributes,'type') ) itemStruct.mimetype = path[y].xmlAttributes.type;
					else itemStruct.type = "";
					if( structKeyExists(path[y].xmlAttributes,'medium') ) itemStruct.medium = path[y].xmlAttributes.medium;
					else itemStruct.medium = "";
					if( structKeyExists(path[y].xmlAttributes,'isDefault') ) itemStruct.isDefault = path[y].xmlAttributes.isDefault;
					else itemStruct.isDefault = "";
					if( structKeyExists(path[y].xmlAttributes,'height') ) itemStruct.height = path[y].xmlAttributes.height;
					else itemStruct.height = "";
					if( structKeyExists(path[y].xmlAttributes,'width') ) itemStruct.width = path[y].xmlAttributes.width;
					else itemStruct.width = "";
					if( structKeyExists(path[y].xmlAttributes,'duration') ) itemStruct.duration = path[y].xmlAttributes.duration;
					else itemStruct.duration = "";
					ArrayAppend(attachmentCol,itemStruct);
				}
			}
			return attachmentCol;
		</cfscript>
	</cffunction> 

	<!--- Get created date --->
	<cffunction name="findCreatedDate" access="public" output="false" returntype="string" hint="Parse the document to find a created date">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlRoot" type="xml" required="true" hint="The XML root to look in"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var createdDate = "";
			// rss 0.92 / 2
			if(StructKeyExists(arguments.xmlRoot,"lastBuildDate")) 
				createdDate = arguments.xmlRoot.lastBuildDate.xmlText;
			// atom 1
			else if(StructKeyExists(arguments.xmlRoot,"updated"))
				createdDate = arguments.xmlRoot.updated.xmlText;	
			return createdDate;
		</cfscript>
	</cffunction>

	<!--- Get keywords --->
	<cffunction name="findKeywords" access="public" returntype="string" output="false" hint="Parse an item's category array and find keywords">
		<!--- ******************************************************************************** --->
		<cfargument name="categoryRoot" type="array" required="true" hint="The category root to look in"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var catList = "";
			var elem = "";
			var i = "";
			var categories = arguments.categoryRoot;
			var j = "";
			var set = StructNew();
			/* Find category tags whose domain contains either keyword or tag */
			for(j=1; j lte arrayLen(categories);j=j+1){
				if(categories[j].domain contains 'keywords' or categories[j].domain contains 'tag') {
					catList = ListAppend(catList,categories[j].tag);
					catList = ReplaceNocase(catList,', ',',','all');
				}
			}
		</cfscript>
		<!--- Remove duplicate items --->
		<cfloop list="#catList#" index="elem">
			<cfset set[elem] = "">
		</cfloop>
		<!--- Convert the set back to a list --->
		<cfset catList = StructKeyList(set)>
		<cfset catList = ListSort(catList, 'textnocase')/>
		<!--- Return value --->
		<cfreturn catList>
	</cffunction>

	<!--- Get thumbnail --->
	<cffunction name="findThumbnails" access="public" output="false" returntype="array" hint="Parse an item and find thumbnails">
		<!--- ******************************************************************************** --->
		<cfargument name="itemRoot" type="xml" required="true" hint="The item to look in"/>
		<cfargument name="attachmentnode" type="array" required="true" hint="Existing attachments to merge with thumbnails"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var item = arguments.itemRoot;
			var itemStruct = StructNew();
			var attachmentCol = arguments.attachmentnode;
			var path = "";
			var y = 1;
			if( structKeyExists(item,"media:group") and structKeyExists(item["media:group"],"media:thumbnail") ) path = item["media:group"]["media:thumbnail"];
			else if (structKeyExists(item,"media:thumbnail") ) path = item["media:thumbnail"];
			if( not IsSimpleValue(path) and arrayLen(path) ) {
				for(y=1; y lte arrayLen(path);y=y+1){
					writeoutput(y);
					itemStruct = StructNew();
					if ( StructKeyExists(path[y].xmlAttributes,'height') ) itemStruct.height = path[y].xmlAttributes.height;
					if ( StructKeyExists(path[y].xmlAttributes,'width') ) itemStruct.width = path[y].xmlAttributes.width;
					itemStruct.url = path[y].xmlAttributes.url;
					itemStruct.medium = "image";
					itemStruct.type = "thumbnail";
					ArrayAppend(attachmentCol,itemStruct);
				}
			}
			return attachmentCol;
		</cfscript>
	</cffunction>

	<!--- Get updated date --->
	<cffunction name="findUpdatedDate" access="public" output="false" returntype="string" hint="Parse the document and find a updated date">
		<!--- ******************************************************************************** --->
		<cfargument name="xmlRoot" type="xml" required="true" hint="The XML root to look in"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var updatedDate = "";
			// rss .92 / 2
			if(StructKeyExists(arguments.xmlRoot,"pubDate")) 
				updatedDate = arguments.xmlRoot.pubDate.xmlText;
			// dublin core for rdf/rss 1
			else if(StructKeyExists(arguments.xmlRoot,"dc:date"))
				updatedDate = arguments.xmlRoot["dc:date"].xmlText;
			// atom 1
			else if(StructKeyExists(arguments.xmlRoot,"published"))
				updatedDate = arguments.xmlRoot.published.xmlText;
			else if(StructKeyExists(arguments.xmlRoot,"updated"))
				updatedDate = arguments.xmlRoot.updated.xmlText;
			return updatedDate;
		</cfscript>
	</cffunction>

	<!--- Is ISO8601 Date Format? --->
	<cffunction name="isDateISO8601" access="public" returntype="boolean" hint="Checks if a date is in ISO8601 format" output="false" >
		<cfargument name="datetime" required="true" type="string" hint="The datetime string to check">
		<cfscript>
			if( REFind("[[:digit:]]T[[:digit:]]", arguments.datetime) )
				return true;
			else
				return false;
		</cfscript>
	</cffunction>

	<!--- Normalize an Atom text construct --->
	<cffunction name="normalizeAtomTextConstruct" access="public" output="false" returntype="string" hint="Send an element and it will return the appropriate text construct">
		<cfargument name="entity" required="true" hint="The XML construct" />
		<cfscript>
			var results = "";
			var x = 1;
			/* Check for type */
			if( structKeyExists(arguments.entity.xmlAttributes,"type") ){
				if( arguments.entity.xmlAttributes.type is "xhtml" ){
					if( not structKeyExists(arguments.entity,"div") ){
						$throw("Invalid Atom data: XHTML text construct does not contain a child DIV tag.",'','plugins.FeedReader.InvalidAtomConstruct');	
					}
					for(x=1;x lte ArrayLen(arguments.entity.xmlChildren);x=x+1){
						results = results & arguments.entity.xmlChildren[x].toString();
					}
				}
				else{
					results = arguments.entity.xmlText;
				}
			}//end type exists
			else{
				/* No type just return text */
				results = arguments.entity.xmlText;
			}
			/* Return results */
			return results;
		</cfscript>
	</cffunction>

	<!--- Parse Atom items --->
	<cffunction name="parseAtomItems" access="public" returntype="any" hint="Parse the items an return an array of structures" output="false" >
		<!--- ******************************************************************************** --->
		<cfargument name="items" 		type="any" 		required="true" hint="The xml of items">
		<cfargument name="itemsType" 	type="string" 	required="false" default="array" hint="The type of the items either query or array, array is used by default"/>
		<cfargument name="maxItems" 	type="numeric" 	required="false" default="0" hint="The maximum number of entries to retrieve, default is display all"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var x = 1;
			var y = 1;
			var itemLength = arrayLen(arguments.items);
			var itemStruct = StructNew();
			var rtnItems = "";
			var node = "";
			var loop = "";
			var oUtilities = controller.getPlugin("DateUtils");

			/* Items length */
			if( arguments.maxItems neq 0 and arguments.maxItems lt itemLength ){
				itemLength = arguments.maxItems;
			}

			/* Correct return items type */
			if( arguments.itemsType eq "array")
				rtnItems = ArrayNew(1);
			else
				rtnItems = QueryNew("attachment,author,body,category,comments,datepublished,dateupdated,id,rights,title,url");
			/* Loop and add to array */
			for(x=1; x lte itemLength; x=x + 1){
				/* new node */
				node = structnew();
				/* Basic node */
				node.attachment = ArrayNew(1);	
				node.author = "";
				node.body = "";
				node.category = ArrayNew(1);
				node.comments = StructNew();
				node.comments.count = "";
				node.comments.hit_parade = "";
				node.comments.url = "";	
				node.datepublished = "";
				node.dateupdated = "";
				node.id = "";
				node.rights = "";
				node.title = "";
				node.url = "";
				/* Author */
				node.author = findAuthor(items[x]);
				/* Attachments (MediaRSS media content) */
				node.attachment = findMediaContent(items[x],node.attachment);
				/* Category */
				node.category = findCategory(items[x],node.category);
				/* Body (MediaRSS description or Atom content/summary) */
				if( structKeyExists(items[x],"media:group") and structKeyExists(items[x]["media:group"],"media:description") and len(items[x]["media:group"]["media:description"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x]["media:group"]["media:description"]);
				else if( structKeyExists(items[x],"media:description") and len(items[x]["media:description"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x]["media:description"]);
				else if( structKeyExists(items[x],"content") and len(items[x]["content"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x].content);
				else if( structKeyExists(items[x],"summary") and len(items[x]["summary"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x].summary);
				/* Comments (GoogleData API) */
				node.comments = findComments(items[x],node.comments);
				/* Date and updated dates */
				node.datepublished = oUtilities.parseISO8601(findCreatedDate(items[x]));
				node.dateupdated = oUtilities.parseISO8601(findUpdatedDate(items[x]));
				/* Id */
				if( structKeyExists(items[x],"id") ) node.id = normalizeAtomTextConstruct(items[x].id);
				/* Links & attachments */	
				if( structKeyExists(items[x],"link") ){
					for(y=1; y lte arrayLen(items[x].link);y=y+1){
						if ( items[x].link[y].xmlAttributes.rel is "alternate" and StructKeyExists(items[x].link[y].xmlAttributes,'href') ){
							node.url = items[x].link[y].xmlAttributes.href;
						}
						else if ( items[x].link[y].xmlAttributes.rel is "enclosure" and StructKeyExists(items[x].link[y].xmlAttributes,'href')){
							itemStruct = StructNew();
							itemStruct.duration = "";
							itemStruct.mimetype = "";
							itemStruct.filesize = "";
							itemStruct.type = "enclosure";
							itemStruct.url = items[x].link[y].xmlAttributes.href;
							if ( StructKeyExists(items[x].link[y].xmlAttributes,'length') ) itemStruct.filesize = items[x].link[y].xmlAttributes.length;
							if ( StructKeyExists(items[x].link[y].xmlAttributes,'type') ) itemStruct.mimetype = items[x].link[y].xmlAttributes.type;
							ArrayAppend(node.attachment,itemStruct);
						}
					}
				}
				/* Keywords */
				node.keywords = findKeywords(node.category);
				/* Rights */
				if( structKeyExists(items[x],"media:group") and structKeyExists(items[x]["media:group"],"media:copyright") ) node.rights = normalizeAtomTextConstruct(items[x]["media:group"]["media:copyright"]);
				else if( structKeyExists(items[x],"media:copyright") ) node.rights = normalizeAtomTextConstruct(items[x]["media:copyright"]);
				else if( structKeyExists(items[x],"rights") ) node.rights = normalizeAtomTextConstruct(items[x].rights);
				/* Thumbnail previews */
				node.attachment = findThumbnails(items[x],node.attachment);
				/* Title */
				if( structKeyExists(items[x],"media:group") and structKeyExists(items[x]["media:group"],"media:title") ) node.title = normalizeAtomTextConstruct(items[x]["media:group"]["media:title"]);
				else if( structKeyExists(items[x],"media:title") ) node.title = normalizeAtomTextConstruct(items[x]["media:title"]);
				else if( structKeyExists(items[x],"title") ) node.title = normalizeAtomTextConstruct(items[x].title);

				if( arguments.itemsType eq "array" ){
					// Append to array
					ArrayAppend(rtnItems,node);
				}
				else{
					QueryAddRow(rtnItems,1);
					if( arrayLen(node.attachment) ) QuerySetCell(rtnItems, "attachment", node.attachment[1].url);
					else QuerySetCell(rtnItems, "attachment", "");
					QuerySetCell(rtnItems, "author", node.author);
					QuerySetCell(rtnItems, "category", findKeywords(node.category));
					QuerySetCell(rtnItems, "comments", node.comments.count);
					QuerySetCell(rtnItems, "body", node.body);
					QuerySetCell(rtnItems, "datepublished", node.datepublished);
					QuerySetCell(rtnItems, "dateupdated", node.dateupdated);
					QuerySetCell(rtnItems, "id", node.id);
					QuerySetCell(rtnItems, "rights", node.rights);
					QuerySetCell(rtnItems, "title", node.title);
					QuerySetCell(rtnItems, "url", node.url);
				}
			}
			/* Return items */
			return rtnItems;
		</cfscript>
	</cffunction>

	<!--- Parse RSS/RDF items --->
	<cffunction name="parseRSSItems" access="public" returntype="any" hint="Parse the items an return an array of structures" output="false" >
		<!--- ******************************************************************************** --->
		<cfargument name="items" 		type="any" 		required="true" hint="The xml of items">
		<cfargument name="itemsType" 	type="string" 	required="false" default="array" hint="The type of the items either query or array, array is used by default"/>
		<cfargument name="maxItems" 	type="numeric" 	required="false" default="0" hint="The maximum number of entries to retrieve, default is display all"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			var x = 1;
			var y = 1;
			var itemLength = arrayLen(arguments.items);
			var rtnItems = "";
			var node = "";
			var loop = "";
			var merge = "";
			var oUtilities = controller.getPlugin("DateUtils");
			var itemStruct = "";
			
			/* Itemslength */
			if( arguments.maxItems neq 0 and arguments.maxItems lt itemLength ){
				itemLength = arguments.maxItems;
			}

			/* Correct return items type */
			if( arguments.itemsType eq "array")
				rtnItems = ArrayNew(1);
			else
				rtnItems = QueryNew("attachment,author,category,comments,body,datepublished,dateupdated,id,rights,title,url");

			/* Loop and add to array */
			for(x=1; x lte itemLength; x=x + 1){
				/* new node */
				node = structnew();
				/* basic node */
				node.attachment = ArrayNew(1);	
				node.author = "";
				node.body = "";	
				node.category = ArrayNew(1);	
				node.comments = StructNew();
				node.comments.count = "";
				node.comments.hit_parade = "";
				node.comments.url = "";
				node.datepublished = "";
				node.dateupdated = "";
				node.id = "";
				node.keywords = "";
				node.rights = "";
				node.title = "";
				node.url = "";

				/* Attachments (MediaRSS media content) */
				node.attachment = findMediaContent(items[x],node.attachment);
				/* Attachments aka enclosures */
				if( structKeyExists(items[x],"enclosure") and structKeyExists(items[x].enclosure.xmlAttributes,"url") ){
					for(y=1; y lte arrayLen(items[x].enclosure);y=y+1){
						if ( StructKeyExists(items[x].enclosure[y].xmlAttributes,'url')){
							itemStruct = StructNew();
							itemStruct.duration = "";
							itemStruct.filesize = "";
							itemStruct.mimetype = "";
							itemStruct.type = "enclosure";
							itemStruct.url = items[x].enclosure[y].xmlAttributes.url;
							if ( StructKeyExists(items[x],"itunes:duration") ) itemStruct.duration = items[x]["itunes:duration"].xmlText;
							if ( StructKeyExists(items[x].enclosure[y].xmlAttributes,'length') ) itemStruct.filesize = items[x].enclosure[y].xmlAttributes.length;
							if ( StructKeyExists(items[x].enclosure[y].xmlAttributes,'type') ) itemStruct.mimetype = items[x].enclosure[y].xmlAttributes.type;
							ArrayAppend(node.attachment,itemStruct);
						}
					}
				}
				/* Author */
				node.author = findAuthor(items[x]);
				/* Body aka description */
				if( structKeyExists(items[x],"media:group") and structKeyExists(items[x]["media:group"],"media:description") and len(items[x]["media:group"]["media:description"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x]["media:group"]["media:description"]);
				else if( structKeyExists(items[x],"media:description") and len(items[x]["media:description"].xmlText) ) node.body = normalizeAtomTextConstruct(items[x]["media:description"]);
				else if( structKeyExists(items[x],"content:encoded") ) node.body = items[x]["content:encoded"].xmlText;
				else if( structKeyExists(items[x],"description") ) node.body = items[x].description.xmlText;
				else if( structKeyExists(items[x],"dc:description") ) node.body = items[x]["dc:description"].xmlText;
				else if( StructKeyExists(items[x],"itunes:subtitle") ) node.body = items[x]["itunes:subtitle"].xmlText;
				else if( StructKeyExists(items[x],"itunes:summary") ) node.body = items[x]["itunes:summary"].xmlText;
				/* Category */
				node.category = findCategory(items[x],node.category);
				/* Comments */
				if( structKeyExists(items[x],"comments") ) {
					for(y=1; y lte arrayLen(items[x]["comments"]); y=y+1){
						if( structKeyExists(items[x],"slash:comments") and isNumeric(items[x]["slash:comments"].xmlText) ) node.comments.count = items[x]["comments"][y].xmlText;
						else node.comments.url = items[x]["comments"][y].xmlText;
					}
				}
				if( structKeyExists(items[x],"slash:comments") ) node.comments.count = items[x]["slash:comments"].xmlText;
				if( structKeyExists(items[x],"slash:hit_parade") ) node.comments.hit_parade = items[x]["slash:hit_parade"].xmlText;
				/* Comments (GoogleData API, overwrites slash comments if there is a clash) */
				node.comments = findComments(items[x],node.comments);
				/* Dates */
				node.datepublished = findCreatedDate(items[x]);
				if( isDateISO8601(node.datepublished) ){ 
					node.datepublished = oUtilities.parseISO8601(node.datepublished);
				}
				else{ 
					node.datepublished = oUtilities.parseRFC822(node.datepublished);
				}
				node.dateupdated = findUpdatedDate(items[x]);
				if( isDateISO8601(node.dateupdated) ){
					node.dateupdated = oUtilities.parseISO8601(node.dateupdated);
				}
				else{
					node.dateupdated = oUtilities.parseRFC822(node.dateupdated);
				}
				// verify dates
				if( len(node.datepublished) neq 0 and len(node.dateupdated) eq 0){
					node.dateupdated = CreateODBCDateTime(node.datepublished);
				}
				else if( len(node.dateupdated) neq 0 and len(node.datepublished) eq 0){
					node.datepublished = CreateODBCDateTime(node.dateupdated);
				}
				/* Id */
				if( structKeyExists(items[x],"guid") ) node.id = items[x].guid.xmlText;
				else if( structKeyExists(items[x],"dc:identifier") ) node.id = items[x]["dc:identifier"].xmlText;
				else if( structKeyExists(items[x],"link") ) node.id = items[x].link.xmlText;
				/* Keywords */
				node.keywords = findKeywords(node.category);
				/* Link */
				if ( structKeyExists(items[x],"link") ){
					node.url = items[x].link.xmlText;
				}
				else if ( structKeyExists(items[x],"guid") and (not structKeyExists(items[x].guid.xmlAttributes, "isPermaLink") or items[x].guid.xmlAttributes.isPermaLink) ){
					node.url = items[x].guid.xmlText;
				}
				else if ( structKeyExists(items[x],"source") and structKeyExists(items[x].source.xmlAttributes,"url") ){
					node.url = items[x].source.xmlAttributes.url;
				}
				/* Rights (uses Creative Commons, MRSS or DC extensions) */
				if( structKeyExists(items[x],"creativeCommons:license") and not len(node.rights) ) node.rights = items[x]["creativeCommons:license"].xmlText;
				else if( structKeyExists(items[x],"media:group") and structKeyExists(items[x]["media:group"],"media:copyright") ) node.rights = normalizeAtomTextConstruct(items[x]["media:group"]["media:copyright"]);
				else if( structKeyExists(items[x],"media:copyright") ) node.rights = normalizeAtomTextConstruct(items[x]["media:copyright"]);
				else if( structKeyExists(items[x],"dc:rights") ) node.rights = items[x]["dc:rights"].xmlText;
				/* Thumbnail previews */
				node.attachment = findThumbnails(items[x],node.attachment);
				/* Title */
				if( structKeyExists(items[x],"media:group") and structKeyExists(items[x]["media:group"],"media:title") ) node.title = normalizeAtomTextConstruct(items[x]["media:group"]["media:title"]);
				else if( structKeyExists(items[x],"media:title") ) node.title = normalizeAtomTextConstruct(items[x]["media:title"]);
				else if( structKeyExists(items[x],"title") ) node.title = items[x].title.xmlText;
				else if( structKeyExists(items[x],"dc:title") ) node.title = items[x]["dc:title"].xmlText;

				if( arguments.itemsType eq "array" ){
					/* Append to array */
					ArrayAppend(rtnItems,node);
				}

				else{
					QueryAddRow(rtnItems,1);
					if( arrayLen(node.attachment) ) QuerySetCell(rtnItems, "attachment", node.attachment[1].url);
					else QuerySetCell(rtnItems, "attachment", "");
					QuerySetCell(rtnItems, "author", node.author);
					QuerySetCell(rtnItems, "category", findKeywords(node.category));
					QuerySetCell(rtnItems, "category", node.category);
					QuerySetCell(rtnItems, "comments", node.comments.count);
					QuerySetCell(rtnItems, "body", node.body);
					QuerySetCell(rtnItems, "datepublished", node.datepublished);
					QuerySetCell(rtnItems, "dateupdated", node.dateupdated);
					QuerySetCell(rtnItems, "id", node.id);
					QuerySetCell(rtnItems, "rights", node.rights);
					QuerySetCell(rtnItems, "title", node.title);
					QuerySetCell(rtnItems, "url", node.url);
				}

			}//end of for loop 	
		/* Return items */
		return rtnItems;
		</cfscript>
	</cffunction>

	<!--- Set parseFeed() Variables --->
	<cffunction name="parseVariablesSet" access="public" returntype="struct" hint="Set empty structure variables that will be used by parseFeed" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="feed" type="struct" required="true" hint="Structure of the current state of the parseFeed process"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			// Set the elements
			feed.author = StructNew();
			feed.author.email = "";
			feed.author.name = "";
			feed.author.url = "";
			feed.category = ArrayNew(1);
			feed.datebuilt = "";
			feed.dateupdated = "";
			feed.description = "";
			feed.image = StructNew();
			feed.image.description = "";
			feed.image.height = "";
			feed.image.icon = "";
			feed.image.link = "";
			feed.image.title = "";
			feed.image.url = "";
			feed.image.width = "";
			feed.language = "";
			feed.rating = "";
			feed.rights = StructNew();
			feed.rights.creativecommons = "";
			feed.rights.copyright = "";
			feed.title = "";
			feed.websiteurl = "";
			// OpenSearch 
			feed.opensearch = StructNew();
			feed.opensearch.autodiscovery = StructNew();
			feed.opensearch.autodiscovery.url = "";
			feed.opensearch.autodiscovery.title = "";
			feed.opensearch.itemsperpage = "";
			feed.opensearch.startindex = "";
			feed.opensearch.totalresults = "";
			feed.opensearch.query = ArrayNew(1);
			
			return feed;
		</cfscript>
	</cffunction>
	
	<cffunction name="arrayOfStructsSort" access="public" returntype="array" output="false" hint="Sorts a structured array by a selected value">
		<!--- ******************************************************************************** --->
		<cfargument name="aOfS" type="array" required="true" hint="The array to sort"/>
		<cfargument name="key" type="string" required="true" hint="Structure Key to sort by"/>
		<cfargument name="sortOrder" type="string" default="desc" hint="Order to sort by, asc or desc"/>
		<cfargument name="sortType" type="string" default="textnocase" hint="Text, textnocase, or numeric"/>
		<!--- ******************************************************************************** --->
		<cfscript>
			/**
			* Sorts an array of structures based on a key in the structures.
			*
			* @return Returns a sorted array.
			* @author Nathan Dintenfass (nathan@changemedia.com)
			* @version 1, December 10, 2001
			* 
			*/
	        //by default, use ascii character 30 as the delim
	        var delim = ".";
	        //make an array to hold the sort stuff
	        var sortArray = arraynew(1);
	        //make an array to return
	        var returnArray = arraynew(1);
	        //grab the number of elements in the array (used in the loops)
	        var count = arrayLen(arguments.aOfS);
	        //make a variable to use in the loop
	        var ii = 1;
			
	        //if there is a 3rd argument, set the sortOrder
	        if(arraylen(arguments) GT 2)
	            arguments.sortOrder = arguments[3];
	        //if there is a 4th argument, set the sortType
	        if(arraylen(arguments) GT 3)
	        	arguments.sortType = arguments[4];
	        //if there is a 5th argument, set the delim
	        if(arraylen(arguments) GT 4)
	            delim = arguments[5];
	        //loop over the array of structs, building the sortArray
	        for(ii = 1; ii lte count; ii = ii + 1)
	            sortArray[ii] = arguments.aOfS[ii][key] & delim & ii;
	        //now sort the array
	        arraySort(sortArray,sortType,sortOrder);
	        //now build the return array
	        for(ii = 1; ii lte count; ii = ii + 1)
	            returnArray[ii] = arguments.aOfS[listLast(sortArray[ii],delim)];
	        //return the array
	        return returnArray;
		</cfscript>
	</cffunction>

	<cffunction name="querySortandTrim" access="public" returntype="query" output="false" hint="Sorts a structured array by a selected value">
		<!--- ******************************************************************************** --->
		<cfargument name="query" type="query" required="true" hint="The query to trim"/>
		<cfargument name="maxRecords" type="numeric" required="true" hint="Trim to maximum records"/>
		<cfargument name="sort" type="string" required="true" hint="Sort query by this column"/>
		<cfargument name="direction" type="string" required="true" hint="Sort direction, either 'asc' or 'desc'"/>
		<!--- ******************************************************************************** --->
		<cfset var lowFatQuery = "">
		<cfif not reFindnocase("^(asc|desc)$",arguments.direction)>
			<cfset arguments.direction = "desc">
		</cfif>
		<cfquery dbtype="query" name="lowFatQuery" maxrows="#arguments.maxRecords#">
			SELECT *
			FROM arguments.query
			ORDER BY #arguments.sort# #arguments.direction#;
		</cfquery>
		<cfreturn lowFatQuery>
	</cffunction>
	
</cfcomponent>