<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Description :
	A cool utility that helps you when working with HTML
----------------------------------------------------------------------->
<cfcomponent hint="A cool utility that helps you when working with HTML, from creating doc types, to managing your js/css assets, to rendering tables and lists from data"
       		 extends="coldbox.system.FrameworkSupertype"
       		 output="false"
       		 singleton>

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="HTMLHelper" output="false">
		<cfargument name="controller" required="true" inject="coldbox">
		<cfscript>
			variables.controller = arguments.controller;

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC HELPER METHODS ------------------------------------------>

	<!--- addJSContent --->
	<cffunction name="addJSContent" output="false" access="public" returntype="any" hint="Open and close HTML5 javascript tags so you can easily just add content">
		<cfargument name="content" 		type="any" 		required="true" hint="The content to render out"/>
		<cfargument name="addToHeader"	type="boolean" 	required="false" default="false" hint="Send to header or return content"/>
		<cfscript>
			var str = '<script type="text/javascript">#arguments.content#</script>';
			if( arguments.addToHeader ){
				$htmlhead( str );
			} else {
				return str;
			}
		</cfscript>
	</cffunction>

	<!--- addCSSContent --->
	<cffunction name="addStyleContent" output="false" access="public" returntype="any" hint="Open and close xhtml style tags so you can easily just add content">
		<cfargument name="content" 		type="any" 		required="true" hint="The content to render out"/>
		<cfargument name="addToHeader"	type="boolean" 	required="false" default="false" hint="Send to header or return content"/>
		<cfscript>
			var str = '<style type="text/css">#arguments.content#</style>';
			if( arguments.addToHeader ){
				$htmlhead( str );
			} else {
				return str;
			}
		</cfscript>
	</cffunction>

	<!--- addAsset --->
	<cffunction name="addAsset" output="false" access="public" returntype="any" hint="Add a js/css asset(s) to the html head section. You can also pass in a list of assets via the asset argument to try to load all of them.	You can also make this method return the string that will be sent to the header instead.">
		<cfargument name="asset" 		type="any"		required="true" hint="The asset(s) to load, only js or css files. This can also be a comma delimmited list."/>
		<cfargument name="sendToHeader" type="boolean"	required="false" default="true" hint="Send to the header via htmlhead by default, else it returns the content"/>
		<cfargument name="async" 		type="boolean" 	required="false" default="false" hint="HTML5 JavaScript argument: Specifies that the script is executed asynchronously (only for external scripts)"/>
		<cfargument name="defer" 		type="boolean" 	required="false" default="false" hint="HTML5 JavaScript argument: Specifies that the script is executed when the page has finished parsing (only for external scripts)"/>
		<cfscript>
			var sb = createObject("java","java.lang.StringBuilder").init('');
			var x = 1;
			var thisAsset = "";
			var event = controller.getRequestService().getContext();
			var asyncStr = "";
			var deferStr = "";

			// Global location settings
			var jsPath = "";
			var cssPath = "";
			if( settingExists("htmlhelper_js_path") ){ jsPath = getSetting('htmlhelper_js_path'); }
			if( settingExists("htmlhelper_css_path") ){ cssPath = getSetting('htmlhelper_css_path'); }

			// Async HTML5 attribute
			if( arguments.async ){ asyncStr = " async='async'"; }
			// Defer HTML5 attribute
			if( arguments.defer ){ deferStr = " defer='defer'"; }

			// request assets storage
			event.paramValue(name="cbox_assets",value="",private=true);

			for(x=1; x lte listLen(arguments.asset); x=x+1){
				thisAsset = trim( listGetAt( arguments.asset, x ) );
				// Is asset already loaded
				if( NOT listFindNoCase(event.getValue(name="cbox_assets",private=true),thisAsset) ){

					// Load Asset
					if( findNoCase(".js", thisAsset) ){
						sb.append('<script src="#jsPath##thisAsset#" type="text/javascript"#asyncStr##deferStr#></script>');
					}
					else{
						sb.append('<link href="#cssPath##thisAsset#" type="text/css" rel="stylesheet" />');
					}

					// Store It as Loaded
					event.setValue(name="cbox_assets",value=listAppend(event.getValue(name="cbox_assets",private=true),thisAsset),private=true);
				}
			}

			//Load it
			if( arguments.sendToHeader AND len(sb.toString())){
				$htmlhead(sb.toString());
			}
			else{
				return sb.toString();
			}
		</cfscript>
	</cffunction>

	<!--- br --->
	<cffunction name="br" output="false" access="public" returntype="any" hint="Generate line breaks">
		<cfargument name="count" type="numeric" required="false" default="1" hint="The number of breaks"/>
		<cfreturn repeatString("<br/>",arguments.count)>
	</cffunction>

	<!--- nbs --->
	<cffunction name="nbs" output="false" access="public" returntype="any" hint="Generate non-breaking spaces (&nbsp;)">
		<cfargument name="count" type="numeric" required="false" default="1" hint="The number of spaces"/>
		<cfreturn repeatString("&nbsp;",arguments.count)>
	</cffunction>

	<!--- heading --->
	<cffunction name="heading" output="false" access="public" returntype="any" hint="Generate header tags">
		<cfargument name="title" type="string" required="true"	hint="The header content"/>
		<cfargument name="size" type="numeric" required="false" default="1" hint="The header size: h1, h2, hx"/>
		<cfreturn "<h#arguments.size#>#arguments.title#</h#arguments.size#>">
	</cffunction>

	<!--- tag --->
	<cffunction name="tag" output="false" access="public" returntype="any" hint="Surround content with a tag">
		<cfargument name="tag" 			type="string" required="true"	hint="The tag to generate"/>
		<cfargument name="content"		type="string" required="false" default=""	hint="The content of the tag"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var buffer	= createObject("java","java.lang.StringBuilder").init( "<#arguments.tag#" );

			// append tag attributes
			flattenAttributes( arguments, "tag,content", buffer ).append( '>#arguments.content#</#arguments.tag#>' );

			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- anchor --->
	<cffunction name="anchor" output="false" access="public" returntype="any" hint="Create an anchor tag">
		<cfargument name="name" 	 	type="any" 		required="true" 	hint="The name of the anchor"/>
		<cfargument name="text" 	 	type="any" 		required="false" default="" 	hint="The text of the link"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var buffer 		= createObject("java","java.lang.StringBuilder").init("<a");

			// build link
			flattenAttributes( arguments, "text", buffer ).append( '>#arguments.text#</a>' );

			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- href --->
	<cffunction name="href" output="false" access="public" returntype="any" hint="Create href tags, using the SES base URL or not">
		<cfargument name="href" 	 	type="any" 		required="false" 	default="" hint="Where to link to, this can be an action, absolute, etc"/>
		<cfargument name="text" 	 	type="any" 		required="false"		default="" hint="The text of the link"/>
		<cfargument name="queryString"	type="any"		required="false"		default="" hint="The query string to append, if needed.">
		<cfargument name="title"	 	type="any" 		required="false" 	default="" hint="The title attribute"/>
		<cfargument name="target"	 	type="any" 		required="false" 	default="" hint="The target of the href link"/>
		<cfargument name="ssl" 			type="boolean" 	required="false" 	default="false" hint="If true, it will change http to https if found in the ses base url ONLY"/>
		<cfargument name="noBaseURL" 	type="boolean" 	required="false" 	default="false" hint="Defaults to false. If you want to NOT append a request's ses or html base url then set this argument to true"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var buffer 	= createObject( "java", "java.lang.StringBuilder" ).init( "<a" );
			var event	= controller.getRequestService().getContext();

			// self-link?
			if( NOT len( arguments.href ) ){
				arguments.href = event.getCurrentEvent();
			}

			// Check if we have a base URL and if we need to build our link
			if( arguments.noBaseURL eq FALSE and NOT find( "://", arguments.href ) ){
				// Verify SSL Bit
				if( structKeyExists( arguments, "ssl" ) ){ 
					arguments.href = event.buildLink(
						linkto 		= arguments.href,
						ssl			= arguments.ssl,
						queryString = arguments.queryString
					); 
				} else { 
					arguments.href = event.buildLink( linkto=arguments.action, queryString=arguments.queryString ); 
				}
			}

			// build link
			flattenAttributes( arguments, "noBaseURL,text,querystring,ssl", buffer )
				.append( '>#arguments.text#</a>' );

			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- link --->
	<cffunction name="link" output="false" access="public" returntype="any" hint="Create link tags, using the SES base URL or not">
		<cfargument name="href" 	 	type="any" 		required="true" hint="The href link to link to"/>
		<cfargument name="rel" 		 	type="any"		required="false"	default="stylesheet" hint="The rel attribute"/>
		<cfargument name="type" 	 	type="any"		required="false" 	default="text/css" hint="The type attribute"/>
		<cfargument name="title"	 	type="any" 		required="false" 	default="" hint="The title attribute"/>
		<cfargument name="media" 	 	type="any"		required="false" 	default="" hint="The media attribute"/>
		<cfargument name="noBaseURL" 	type="boolean" 	required="false" 	default="false" hint="Defaults to false. If you want to NOT append a request's ses or html base url then set this argument to true"/>
		<cfargument name="charset" 		type="any" 		required="false" 	default="UTF-8" hint="The charset to add, defaults to utf-8"/>
		<cfargument name="sendToHeader" type="boolean"	required="false" 	default="false" hint="Send to the header via htmlhead by default, else it returns the content"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var buffer 		= createObject("java","java.lang.StringBuilder").init("<link");

			// Check if we have a base URL
			arguments.href = prepareBaseLink(arguments.noBaseURL,arguments.href);

			//exclusions
			local.excludes = "noBaseURL";
			if(structKeyExists(arguments,'rel')){
				if(arguments.rel == "canonical"){
					local.excludes &= ",type,title,media,charset";
				}
			}

			// build link
			flattenAttributes(arguments,local.excludes,buffer).append('/>');

			//Load it
			if( arguments.sendToHeader AND len(buffer.toString())){
				$htmlhead(buffer.toString());
			}
			else{
				return buffer.toString();
			}
		</cfscript>
	</cffunction>

	<!--- img --->
	<cffunction name="img" output="false" access="public" returntype="any" hint="Create image tags using the SES base URL or not">
		<cfargument name="src" 		 type="any" 	required="true" hint="The source URL to link to"/>
		<cfargument name="alt" 		 type="string"	required="false" default="" hint="The alt tag"/>
		<cfargument name="class" 	 type="string"	required="false" default="" hint="The class tag"/>
		<cfargument name="width" 	 type="string"	required="false" default="" hint="The width tag"/>
		<cfargument name="height"		type="string"	required="false" default="" hint="The height tag"/>
		<cfargument name="title" 	 type="string"	required="false" default="" hint="The title tag"/>
		<cfargument name="rel" 		 type="string"	required="false" default="" hint="The rel tag"/>
		<cfargument name="name" 	 type="string"	required="false" default="" hint="The name tag"/>
		<cfargument name="noBaseURL" type="boolean" required="false" default="false" hint="Defaults to false. If you want to NOT append a request's ses or html base url then set this argument to true"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var buffer = createObject("java","java.lang.StringBuilder").init("<img");

			// ID Normalization
			normalizeID(arguments);

			// Check if we have a base URL
			arguments.src = prepareBaseLink(arguments.noBaseURL, arguments.src);

			// create image
			flattenAttributes(arguments,"noBaseURL",buffer).append(' />');

			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- ul --->
	<cffunction name="ul" output="false" access="public" returntype="any" hint="Create un-ordered lists according to passed in values and arguments, compressed HTML">
		<cfargument name="values" 		type="any" 		required="true"	default="" hint="An array of values or list of values"/>
		<cfargument name="column"		 	type="string" required="false" default="" hint="If the values is a query, this is the name of the column to get the data from to create the list"/>
		<cfset arguments.tag = "ul">
		<cfreturn toHTMLList(argumentCollection=arguments)>
	</cffunction>

	<!--- ol --->
	<cffunction name="ol" output="false" access="public" returntype="any" hint="Create ordered lists according to passed in values and arguments, compressed HTML">
		<cfargument name="values" 		type="any" 		required="true"	default="" hint="An array of values or list of values"/>
		<cfargument name="column"		 	type="string" required="false" default="" hint="If the values is a query, this is the name of the column to get the data from to create the list"/>
		<cfset arguments.tag = "ol">
		<cfreturn toHTMLList(argumentCollection=arguments)>
	</cffunction>

	<!--- table --->
	<cffunction name="table" output="false" access="public" returntype="any" hint="Convert a table out of data (either a query or array of structures or array of entities)">
		<cfargument name="data" 		type="any"			 required="true"	hint="The query or array of structures or array of entities to convert into a table"/>
		<cfargument name="includes" 	type="string"		required="false" default=""	hint="The columns to include in the rendering"/>
		<cfargument name="excludes" 	type="string"		required="false" default=""	hint="The columns to exclude in the rendering"/>
		<cfargument name="name" 		type="string"		 required="false" default="" hint="The name tag"/>
		<cfscript>
			var str		= createObject("java","java.lang.StringBuilder").init('');
			var attrs	= "";
			var key		= "";

			// ID Normalization
			normalizeID(arguments);

			// Start Table
			str.append("<table");

			// flatten extra attributes via arguments
			flattenAttributes(arguments,"data,includes,excludes",str).append("><thead><tr>");

			// Buffer Reference
			arguments.buffer = str;

			// Convert Query To Table Body
			if( isQuery(arguments.data) ){
				queryToTable(argumentCollection=arguments);
			}
			// Convert Array to Table Body
			else if( isArray(arguments.data) and arrayLen(arguments.data) ){

				// Check first element for an object, if it is then convert to query
				if( isObject(arguments.data[1]) ){
					arguments.data = entityToQuery(arguments.data);
					queryToTable(argumentCollection=arguments);
				}
				else{
					arrayToTable(argumentCollection=arguments);
				}
			}

			// Finalize table
			str.append("</tbody></table>");

			return str.toString();
		</cfscript>
	</cffunction>

	<!--- meta --->
	<cffunction name="meta" output="false" access="public" returntype="any" hint="Helps you generate meta tags">
		<cfargument name="name" 	type="any" 		required="true" hint="A name for the meta tag or an array of struct data to convert to meta tags.Keys [name,content,type]"/>
		<cfargument name="content" 	type="any" 		required="false" default="" hint="The content attribute"/>
		<cfargument name="type" 	type="string"	 required="false" default="name" hint="Either ''name'' or ''equiv'' which produces http-equiv instead of the name"/>
		<cfargument name="sendToHeader" type="boolean"	required="false" default="false" hint="Send to the header via htmlhead by default, else it returns the content"/>
		<cfargument name="property" type="any" 		required="false" default="" hint="The property attribute"/>
		<cfscript>
			var x 		= 1;
			var buffer	= createObject("java","java.lang.StringBuilder").init("");
			var tmpType = "";

			// prep type
			if( arguments.type eq "equiv" ){ arguments.type = "http-equiv"; };

			// Array of structs or simple value
			if( isSimpleValue(arguments.name) ){
				buffer.append('<meta #arguments.type#="#arguments.name#" content="#arguments.content#" />');
			}

			if(isArray(arguments.name)){
				for(x=1; x lte arrayLen(arguments.name); x=x+1 ){
					if( NOT structKeyExists(arguments.name[x], "type") ){
						arguments.name[x].type = "name";
					}
					if(	arguments.name[x].type eq "equiv" ){
						arguments.name[x].type = "http-equiv";
					}
					if ( structKeyExists(arguments.name[x], "property") ) {
						buffer.append('<meta property=#arguments.name[x].property# #arguments.name[x].type#="#arguments.name[x].name#" content="#arguments.name[x].content#" />');
					} else {
						buffer.append('<meta #arguments.name[x].type#="#arguments.name[x].name#" content="#arguments.name[x].content#" />');
					}
				}
			}

			//Load it
			if( arguments.sendToHeader AND len(buffer.toString())){
				$htmlhead(buffer.toString());
			}
			else{
				return buffer.toString();
			}
		</cfscript>
	</cffunction>

	<!--- docType --->
	<cffunction name="docType" output="false" access="public" returntype="any" hint="Render a doctype by type name: xhtml11,xhtml1-strict,xhtml-trans,xthml-frame,html5,html4-strict,html4-trans,html4-frame">
		<cfargument name="type" type="string" required="false" default="html5" hint="The doctype to generate, we default to HTML 5"/>
		<cfscript>
			switch( arguments.type ){
				case 'html5'		 : { return '<!DOCTYPE html>'; }
				case 'xhtml11' 		 : { return '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'; }
				case 'xhtml1-strict' : { return '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'; }
				case 'xhtml1-trans'  : { return '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'; }
				case 'xhtml1-frame'	 : { return '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'; }
				case 'html4-strict'	 : { return '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'; }
				case 'html4-trans'	 : { return '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'; }
				case 'html4-frame'	 : { return '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">'; }
			}
		</cfscript>
	</cffunction>

	<!--- slugify --->
	<cffunction name="slugify" output="false" access="public" returntype="string" hint="Create a URL safe slug from a string">
		<cfargument name="str" 			type="string" 	required="true" hint="The string to slugify"/>
		<cfargument name="maxLength" 	type="numeric" 	required="false" default="0" hint="The maximum number of characters for the slug"/>
		<cfargument name="allow" type="string" required="false" default="" hint="a regex safe list of additional characters to allow"/>
		<cfscript>
			// Cleanup and slugify the string
			var slug 	= lcase( trim( arguments.str ) );
			slug 		= replaceList( slug, '#chr(228)#,#chr(252)#,#chr(246)#,#chr(223)#', 'ae,ue,oe,ss' );
			slug 		= reReplace( slug, "[^a-z0-9-\s#arguments.allow#]", "", "all" );
			slug 		= trim ( reReplace( slug, "[\s-]+", " ", "all" ) );
			slug 		= reReplace( slug, "\s", "-", "all" );

			// is there a max length restriction
			if( arguments.maxlength ){ slug = left( slug, arguments.maxlength ); }

			return slug;
		</cfscript>
	</cffunction>

	<!--- autoDiscoveryLink --->
	<cffunction name="autoDiscoveryLink" output="false" access="public" returntype="any" hint="Creates auto discovery links for RSS and ATOM feeds.">
		<cfargument name="type" 		type="string" 	required="false" default="RSS" hint="Type of feed: RSS or ATOM or Custom Type"/>
		<cfargument name="href" 	 	type="any" 		required="false" hint="The href link to discover"/>
		<cfargument name="rel" 		 	type="any"		required="false" default="alternate" hint="The rel attribute"/>
		<cfargument name="title"	 	type="any" 		required="false" default="" hint="The title attribute"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var buffer	= createObject("java","java.lang.StringBuilder").init("<link");

			// type: determination
			switch(arguments.type){
				case "rss"	: { arguments.type = "application/rss+xml";	break;}
				case "atom" : { arguments.type = "application/atom+xml"; break;}
				default 	: { arguments.type = arguments.type; }
			}

			// create link
			flattenAttributes(arguments,"",buffer).append('/>');

			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- video --->
	<cffunction name="video" output="false" access="public" returntype="any" hint="Create an HTML 5 video tag">
		<cfargument name="src" 		 type="any" 	required="true" hint="The source URL or array or list of URL's to create video tags for"/>
		<cfargument name="width" 	 type="string"	required="false" default="" hint="The width tag"/>
		<cfargument name="height"		type="string"	required="false" default="" hint="The height tag"/>
		<cfargument name="poster"		 type="string"	required="false" default="" hint="The URL of the image when video is unavailable"/>
		<cfargument name="autoplay"	type="boolean" required="false" default="false" hint="Whether or not to start playing the video as soon as it can"/>
		<cfargument name="controls"	type="boolean" required="false" default="true" hint="Whether or not to show controls on the video player"/>
		<cfargument name="loop"		 type="boolean" required="false" default="false" hint="Whether or not to loop the video over and over again"/>
		<cfargument name="preload"	 type="boolean" required="false" default="false" hint="If true, the video will be loaded at page load, and ready to run. Ignored if 'autoplay' is present"/>
		<cfargument name="noBaseURL" type="boolean" required="false" default="false" hint="Defaults to false. If you want to NOT append a request's ses or html base url then set this argument to true"/>
		<cfargument name="name" 	 type="string"	required="false" default="" hint="The name tag"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var video 		= createObject("java","java.lang.StringBuilder").init("<video");
			var x			= 1;

			// autoplay diff
			if( arguments.autoplay ){ arguments.autoplay = "autoplay";}
			else{ arguments.autoplay = "";}
			// controls diff
			if( arguments.controls ){ arguments.controls = "controls";}
			else{ arguments.controls = "";}
			// loop diff
			if( arguments.loop ){ arguments.loop = "loop";}
			else{ arguments.loop = "";}
			// preLoad diff
			if( arguments.preLoad ){ arguments.preLoad = "preload";}
			else{ arguments.preLoad = "";}

			// src array check
			if( isSimpleValue(arguments.src) ){ arguments.src = listToArray(arguments.src); }

			// ID Normalization
			normalizeID(arguments);

			// create video tag
			flattenAttributes(arguments,"noBaseURL,src",video);

			// Add single source
			if( arrayLen(arguments.src) eq 1){
				arguments.src[1] = prepareBaseLink(arguments.noBaseURL, arguments.src[1]);
				video.append(' src="#arguments.src[1]#" />');
				return video.toString();
			}

			// create source tags
			video.append(">");
			for(x=1; x lte arrayLen(arguments.src); x++){
				arguments.src[x] = prepareBaseLink(arguments.noBaseURL, arguments.src[x]);
				video.append('<source src="#arguments.src[x]#"/>');
			}
			video.append("</video>");

			return video.toString();
		</cfscript>
	</cffunction>

	<!--- audio --->
	<cffunction name="audio" output="false" access="public" returntype="any" hint="Create an HTML 5 audio tag">
		<cfargument name="src" 		 type="any" 	required="true" hint="The source URL or array or list of URL's to create audio tags for"/>
		<cfargument name="autoplay"	type="boolean" required="false" default="false" hint="Whether or not to start playing the audio as soon as it can"/>
		<cfargument name="controls"	type="boolean" required="false" default="true" hint="Whether or not to show controls on the audio player"/>
		<cfargument name="loop"		 type="boolean" required="false" default="false" hint="Whether or not to loop the audio over and over again"/>
		<cfargument name="preLoad"	 type="boolean" required="false" default="false" hint="If true, the audio will be loaded at page load, and ready to run. Ignored if 'autoplay' is present"/>
		<cfargument name="noBaseURL" type="boolean" required="false" default="false" hint="Defaults to false. If you want to NOT append a request's ses or html base url then set this argument to true"/>
		<cfargument name="name" 	 type="string"	required="false" default="" hint="The name tag"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var audio 		= createObject("java","java.lang.StringBuilder").init("<audio");
			var x			= 1;

			// autoplay diff
			if( arguments.autoplay ){ arguments.autoplay = "autoplay";}
			else{ arguments.autoplay = "";}
			// controls diff
			if( arguments.controls ){ arguments.controls = "controls";}
			else{ arguments.controls = "";}
			// loop diff
			if( arguments.loop ){ arguments.loop = "loop";}
			else{ arguments.loop = "";}
			// preLoad diff
			if( arguments.preLoad ){ arguments.preLoad = "preload";}
			else{ arguments.preLoad = "";}

			// src array check
			if( isSimpleValue(arguments.src) ){ arguments.src = listToArray(arguments.src); }

			// ID Normalization
			normalizeID(arguments);

			// create video tag
			flattenAttributes(arguments,"noBaseURL,src",audio);

			// Add single source
			if( arrayLen(arguments.src) eq 1){
				arguments.src[1] = prepareBaseLink(arguments.noBaseURL, arguments.src[1]);
				audio.append(' src="#arguments.src[1]#" />');
				return audio.toString();
			}

			// create source tags
			audio.append(">");
			for(x=1; x lte arrayLen(arguments.src); x++){
				arguments.src[x] = prepareBaseLink(arguments.noBaseURL, arguments.src[x]);
				audio.append('<source src="#arguments.src[x]#"/>');
			}
			audio.append("</audio>");

			return audio.toString();
		</cfscript>
	</cffunction>

	<!--- canvas --->
	<cffunction name="canvas" output="false" access="public" returntype="any" hint="Create a canvas tag">
		<cfargument name="id" 		 type="string"	required="true"	hint="The id of the canvas"/>
		<cfargument name="width" 	 type="string"	required="false" default="" hint="The width tag"/>
		<cfargument name="height"		type="string"	required="false" default="" hint="The height tag"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var canvas 		= createObject("java","java.lang.StringBuilder").init("<canvas");

			// create canvas tag
			flattenAttributes(arguments,"",canvas).append("></canvas>");

			return canvas.toString();
		</cfscript>
	</cffunction>

	<!--- startForm --->
	<cffunction name="startForm" output="false" access="public" returntype="any" hint="Create cool form tags. Any extra argument will be passed as attributes to the form tag">
		<cfargument name="action" 		type="string" 	required="false" 	default="" hint="The event or route action to submit to.	This will be inflated using the request's base URL if not a full http URL. If empty, then it is a self-submitting form"/>
		<cfargument name="name" 		type="string" 	required="false" 	default="" hint="The name of the form tag"/>
		<cfargument name="method" 		type="string" 	required="false" 	default="POST" 	hint="The HTTP method of the form: POST or GET"/>
		<cfargument name="multipart" 	type="boolean" 	required="false" 	default="false"	hint="Set the multipart encoding type on the form"/>
		<cfargument name="ssl" 			type="boolean" 	required="false" 	hint="If true, it will change http to https if found in the ses base url ONLY, false will remove SSL"/>
		<cfargument name="noBaseURL" 	type="boolean" 	required="false" 	default="false" hint="Defaults to false. If you want to NOT append a request's ses or html base url then set this argument to true"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var formBuffer	  = createObject( "java", "java.lang.StringBuilder" ).init( "<form" );
			var event         = controller.getRequestService().getContext();
			var desiredMethod = '';

			// Browsers can't support all the HTTP verbs, so if we passed in something
			// besides GET or POST, we'll default to POST and save off
			// the desired method to spoof later.
			if ( arguments.method != "GET" AND arguments.method != "POST" ) {
				desiredMethod = arguments.method;
				arguments.method = "POST";
			}

			// self-submitting?
			if( NOT len( arguments.action ) ){
				arguments.action = event.getCurrentEvent();
			}

			// Check if we have a base URL and if we need to build our link
			if( arguments.noBaseURL eq FALSE and NOT find( "://", arguments.action ) ){
				// Verify SSL Bit
				if( structKeyExists( arguments, "ssl" ) ){ 
					arguments.action = event.buildLink(
						linkto 		= arguments.action,
						ssl			= arguments.ssl
					); 
				} else { 
					arguments.action = event.buildLink( linkto=arguments.action ); 
				}
			}

			// ID Normalization
			normalizeID( arguments );

			// Multipart Encoding Type
			if( arguments.multipart ){ arguments.enctype = "multipart/form-data"; }
			else{ arguments.enctype = "";}

			// create tag
			flattenAttributes( arguments, "noBaseURL,ssl,multipart", formBuffer )
				.append( ">" );
				
			// If we wanted to use PUT, PATCH, or DELETE, spoof the HTTP method
			// by including a hidden field in the form that ColdBox will look for.
			if ( len( desiredMethod ) ) {
				formBuffer.append( "<input type=""hidden"" name=""_method"" value=""#desiredMethod#"" />" );
			}

			return formBuffer.toString();
		</cfscript>
	</cffunction>

	<!--- endForm --->
	<cffunction name="endForm" output="false" access="public" returntype="any" hint="End a form tag">
		<cfreturn "</form>">
	</cffunction>

	<!--- startFieldset --->
	<cffunction name="startFieldset" output="false" access="public" returntype="any" hint="Create a fieldset tag with or without a legend.">
		<cfargument name="legend" 		type="string" 	required="false" 	default="" hint="The legend to use (if any)"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var buffer = createObject("java","java.lang.StringBuilder").init('<fieldset');

			// fieldset attributes
			flattenAttributes(arguments,"legend",buffer).append(">");

			// add Legend?
			if( len(arguments.legend) ){
				buffer.append("<legend>#arguments.legend#</legend>");
			}

			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- endFieldset --->
	<cffunction name="endFieldset" output="false" access="public" returntype="any" hint="End a fieldset tag">
		<cfreturn "</fieldset>">
	</cffunction>

	<!--- label --->
	<cffunction name="label" access="public" returntype="any" output="false" hint="Render a label tag. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="field" 		type="string" required="true"	hint="The for who attribute"/>
		<cfargument name="content" 		type="string" required="false" default="" hint="The label content. If not passed the field is used"/>
		<cfargument name="wrapper" 		type="string" required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfargument name="class"		type="string" required="false" default="" hint="The class to be applied to the label">
		<cfscript>
			var buffer = createObject("java","java.lang.StringBuilder").init('');

			// wrapper?
			wrapTag(buffer,arguments.wrapper);

			// get content
			if( NOT len(content) ){ arguments.content = makePretty(arguments.field); }
			arguments.for = arguments.field;

			// create label tag
			buffer.append("<label");
			flattenAttributes(arguments,"content,field,wrapper",buffer).append(">#arguments.content#</label>");

			//wrapper?
			wrapTag(buffer,arguments.wrapper,1);

			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- textArea --->
	<cffunction name="textArea" access="public" returntype="any" output="false" hint="Render out a textarea. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the textarea"/>
		<cfargument name="cols" 		type="numeric" 	required="false" hint="The number of columns"/>
		<cfargument name="rows" 		type="numeric" 	required="false" hint="The number of rows"/>
		<cfargument name="value" 		type="string"	required="false" default="" hint="The value of the textarea"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="readonly" 	type="boolean" 	required="false" default="false" hint="Readonly"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfargument name="bind" 		type="any" 		required="false" default="" hint="The entity binded to this control, the value comes by convention from the name attribute"/>
		<cfargument name="bindProperty" type="any" 		required="false" default="" hint="The property to use for the value, by convention we use the name attribute"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var buffer = createObject("java","java.lang.StringBuilder").init('');

			// ID Normalization
			normalizeID(arguments);
			// group wrapper?
			wrapTag(buffer,arguments.groupWrapper);
			// label?
			if( len(arguments.label) ){ buffer.append( this.label(field=arguments.id,content=arguments.label,wrapper=arguments.labelWrapper,class=arguments.labelClass) ); }

			//wrapper?
			wrapTag(buffer,arguments.wrapper);

			// disabled fix
			if( arguments.disabled ){ arguments.disabled = "disabled"; }
			else{ arguments.disabled = ""; }
			// readonly fix
			if( arguments.readonly ){ arguments.readonly = "readonly"; }
			else{ arguments.readonly = ""; }

			// Entity Binding?
			bindValue(arguments);

			// create textarea
			buffer.append("<textarea");
			flattenAttributes(arguments,"value,label,wrapper,labelWrapper,groupWrapper,labelClass,bind,bindProperty",buffer).append(">#arguments.value#</textarea>");

			//wrapper?
			wrapTag(buffer,arguments.wrapper,1);
			// group wrapper?
			wrapTag(buffer,arguments.groupWrapper,1);
			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- passwordField --->
	<cffunction name="passwordField" access="public" returntype="any" output="false" hint="Render out a password field. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="" hint="The value of the field"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="readonly" 	type="boolean" 	required="false" default="false" hint="Readonly"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfargument name="bind" 		type="any" 		required="false" default="" hint="The entity binded to this control"/>
		<cfargument name="bindProperty" type="any" 		required="false" default="" hint="The property to use for the value, by convention we use the name attribute"/>
		<cfscript>
			arguments.type="password";
			return inputField(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- urlfield --->
	<cffunction name="urlfield" access="public" returntype="any" output="false" hint="Render out a URL field. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="" hint="The value of the field"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="readonly" 	type="boolean" 	required="false" default="false" hint="Readonly"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfargument name="bind" 		type="any" 		required="false" default="" hint="The entity binded to this control"/>
		<cfargument name="bindProperty" type="any" 		required="false" default="" hint="The property to use for the value, by convention we use the name attribute"/>
		<cfscript>
			arguments.type="url";
			return inputField(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- emailField --->
	<cffunction name="emailField" access="public" returntype="any" output="false" hint="Render out an email field. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="" hint="The value of the field"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="readonly" 	type="boolean" 	required="false" default="false" hint="Readonly"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfargument name="bind" 		type="any" 		required="false" default="" hint="The entity binded to this control"/>
		<cfargument name="bindProperty" type="any" 		required="false" default="" hint="The property to use for the value, by convention we use the name attribute"/>
		<cfscript>
			arguments.type="email";
			return inputField(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- hiddenField --->
	<cffunction name="hiddenField" access="public" returntype="any" output="false" hint="Render out a hidden field. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="" hint="The value of the field"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfargument name="bind" 		type="any" 		required="false" default="" hint="The entity binded to this control"/>
		<cfargument name="bindProperty" type="any" 		required="false" default="" hint="The property to use for the value, by convention we use the name attribute"/>
		<cfscript>
			arguments.type="hidden";
			return inputField(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- textField --->
	<cffunction name="textField" access="public" returntype="any" output="false" hint="Render out a text field. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="" hint="The value of the field"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="readonly" 	type="boolean" 	required="false" default="false" hint="Readonly"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfargument name="bind" 		type="any" 		required="false" default="" hint="The entity binded to this control"/>
		<cfargument name="bindProperty" type="any" 		required="false" default="" hint="The property to use for the value, by convention we use the name attribute"/>
		<cfscript>
			arguments.type="text";
			return inputField(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- button --->
	<cffunction name="button" access="public" returntype="any" output="false" hint="Render out a button. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="" hint="The value of the field"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled button or not?"/>
		<cfargument name="type" 		type="string"	 required="false" default="button" hint="The type of button to create: button, reset or submit"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfscript>
			var buffer = createObject("java","java.lang.StringBuilder").init('');

			// ID Normalization
			normalizeID(arguments);
			// group wrapper?
			wrapTag(buffer,arguments.groupWrapper);
			// label?
			if( len(arguments.label) ){ buffer.append( this.label(field=arguments.id,content=arguments.label,wrapper=arguments.labelWrapper,class=arguments.labelClass) ); }

			//wrapper?
			wrapTag(buffer,arguments.wrapper);

			// disabled fix
			if( arguments.disabled ){ arguments.disabled = "disabled"; }
			else{ arguments.disabled = ""; }

			// create textarea
			buffer.append("<button");
			flattenAttributes(arguments,"value,label,wrapper,labelWrapper,groupWrapper,labelClass",buffer).append(">#arguments.value#</button>");

			//wrapper?
			wrapTag(buffer,arguments.wrapper,1);
			// group wrapper?
			wrapTag(buffer,arguments.groupWrapper,1);
			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- fileField --->
	<cffunction name="fileField" access="public" returntype="any" output="false" hint="Render out a file field. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="" hint="The value of the field"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="readonly" 	type="boolean" 	required="false" default="false" hint="Readonly"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfscript>
			arguments.type="file";
			return inputField(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- checkBox --->
	<cffunction name="checkBox" access="public" returntype="any" output="false" hint="Render out a checkbox. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="true" hint="The value of the field, defaults to true"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="checked" 		type="boolean" 	required="false" default="false" hint="Checked"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfargument name="bind" 		type="any" 		required="false" default="" hint="The entity binded to this control"/>
		<cfargument name="bindProperty" type="any" 		required="false" default="" hint="The property to use for the value, by convention we use the name attribute"/>
		<cfscript>
			arguments.type="checkbox";
			return inputField(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- radioButton --->
	<cffunction name="radioButton" access="public" returntype="any" output="false" hint="Render out a radio button. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="true" hint="The value of the field, defaults to true"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="checked" 		type="boolean" 	required="false" default="false" hint="Checked"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfargument name="bind" 		type="any" 		required="false" default="" hint="The entity binded to this control"/>
		<cfargument name="bindProperty" type="any" 		required="false" default="" hint="The property to use for the value, by convention we use the name attribute"/>
		<cfscript>
			arguments.type="radio";
			return inputField(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- submitButton --->
	<cffunction name="submitButton" access="public" returntype="any" output="false" hint="Render out a submit button. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="Submit" hint="The value of the field"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfscript>
			arguments.type="submit";
			return inputField(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- resetButton --->
	<cffunction name="resetButton" access="public" returntype="any" output="false" hint="Render out a reset button. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="Reset" hint="The value of the field"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfscript>
			arguments.type="reset";
			return inputField(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- imageButton --->
	<cffunction name="imageButton" access="public" returntype="any" output="false" hint="Render out a image button. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="src" 			type="string"	required="true"	hint="The image src"/>
		<cfargument name="name" 		type="string" 	required="false" default=""	hint="The name of the field"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfscript>
			arguments.type="image";
			return inputField(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- options --->
	<cffunction name="options" access="public" returntype="any" output="false" hint="Render out options. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="values" 			type="any"		required="false" hint="The values array, list, or query to build options for"/>
		<cfargument name="column" 			type="any" 		required="false" default=""	hint="If using a query or array of objects the column to display as value and name"/>
		<cfargument name="nameColumn" 		type="any" 		required="false" default=""	hint="If using a query or array of objects, the name column to display, if not passed defaults to the value column"/>
		<cfargument name="selectedIndex" 	type="any" 		required="false" default="0" hint="selected index(s) if any. So either one or a list of indexes"/>
		<cfargument name="selectedValue" 	type="any" 		required="false" default=""	hint="selected value(s) if any. So either one or a list of values"/>
		<cfscript>
			var buffer 		= createObject("java","java.lang.StringBuilder").init('');
			var val 		= "";
			var nameVal		= "";
			var x	 		= 1;
			var qColumns 	= "";
			var thisName	= "";
			var thisValue	= "";

			// check if an array? So we can do array of objects check
			if( isArray(arguments.values) AND arrayLen(arguments.values) ){
				// Check first element for an object, if it is then convert to query
				if( isObject(arguments.values[1]) ){
					arguments.values = entityToQuery(arguments.values);
				}
			}
			// is this a simple value, if so, inflate it
			if( isSimpleValue(arguments.values) ){
				arguments.values = listToArray(arguments.values);
			}

			// setup local variables
			val 	= arguments.values;
			nameVal = arguments.values;

			// query normalization?
			if( isQuery(val) ){
				// check if column sent? Else select the first column
				if( NOT len(column) ){
					// select the first one
					qColumns = listToArray( arguments.values.columnList );
					arguments.column = qColumns[1];
				}
				// column for values
				val 	= getColumnArray(arguments.values,arguments.column);
				nameVal = val;
				// name column values
				if( len(arguments.nameColumn) ){
					nameVal = getColumnArray(arguments.values,arguments.nameColumn);
				}
			}

			// values
			for(x=1; x lte arrayLen(val); x++){

				thisValue = val[x];
				thisName = nameVal[x];

				// struct normalizing
				if( isStruct( val[x] ) ){
					// Default
					thisName = thisValue;

					// check for value?
					if( structKeyExists(val[x], "value") ){ thisValue = val[x].value; }
					if( structKeyExists(val[x], "name") ){ thisName = val[x].name; }

					// Check if we have a column to use for the default value
					if( structKeyExists( val[x], arguments.column ) ){ thisValue = val[x][column]; }

					// Do we have name column
					if( len( arguments.nameColumn ) ){
						if( structKeyExists( val[x], arguments.nameColumn ) ){ thisName = val[x][nameColumn]; }
					}
					else{
						if( structKeyExists( val[x], arguments.column ) ){ thisName = val[x][column]; }
					}

				}

				// create option
				buffer.append('<option value="#thisValue#"');

				// selected
				if( listfindNoCase( arguments.selectedIndex, x ) ){
					buffer.append(' selected="selected"');
				}
				// selected value
				if( listfindNoCase( arguments.selectedValue, thisValue ) ){
					buffer.append(' selected="selected"');
				}
				buffer.append(">#thisName#</option>");

			}

			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- select --->
	<cffunction name="select" access="public" returntype="any" output="false" hint="Render out a select tag. Remember that any extra arguments are passed as tag attributes">
		<cfargument name="name" 			type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="options" 			type="any"		required="false" default="" hint="The value for the options, usually by calling our options() method"/>
		<!--- option arguments --->
		<cfargument name="column" 			type="string" 	required="false" default=""	hint="If using a query or array of objects the column to display as value and name"/>
		<cfargument name="nameColumn" 		type="string" 	required="false" default=""	hint="If using a query or array of objects, the name column to display, if not passed defaults to the value column"/>
		<cfargument name="selectedIndex" 	type="numeric" 	required="false" default="0" hint="selected index"/>
		<cfargument name="selectedValue" 	type="string" 	required="false" default="" hint="selected value if any"/>
		<cfargument name="bind" 			type="any" 		required="false" default="" hint="The entity binded to this control"/>
		<cfargument name="bindProperty"	 	type="any" 		required="false" default="" hint="The property to use for the value, by convention we use the name attribute"/>
		<!--- html arguments --->
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled button or not?"/>
		<cfargument name="multiple" 	type="boolean" 	required="false" default="false" hint="multiple button or not?"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>

		<cfscript>
			var buffer = createObject("java","java.lang.StringBuilder").init('');

			// ID Normalization
			normalizeID(arguments);
			// group wrapper?
			wrapTag(buffer,arguments.groupWrapper);
			// label?
			if( len(arguments.label) ){ buffer.append( this.label(field=arguments.id,content=arguments.label,wrapper=arguments.labelWrapper,class=arguments.labelClass) ); }

			//wrapper?
			wrapTag(buffer,arguments.wrapper);

			// disabled fix
			if( arguments.disabled ){ arguments.disabled = "disabled"; }
			else{ arguments.disabled = ""; }
			// multiple fix
			if( arguments.multiple ){ arguments.multiple = "multiple"; }
			else{ arguments.multiple = ""; }

			// create select
			buffer.append("<select");
			flattenAttributes(arguments,"options,column,nameColumn,selectedIndex,selectedValue,bind,bindProperty,label,wrapper,labelWrapper,groupWrapper,labelClass",buffer).append(">");

			// binding of option
			bindValue(arguments);
			if( structKeyExists(arguments,"value") AND len(arguments.value) ){
				arguments.selectedValue = arguments.value;
			}

			// options, are they inflatted already or do we inflate
			if( isSimpleValue(arguments.options) AND findnocase("</option>",arguments.options) ){
				buffer.append( arguments.options );
			}
			else{
				buffer.append( this.options(arguments.options,arguments.column,arguments.nameColumn,arguments.selectedIndex,arguments.selectedValue) );
			}

			// finalize select
			buffer.append("</select>");

			//wrapper?
			wrapTag(buffer,arguments.wrapper,1);
			// group wrapper?
			wrapTag(buffer,arguments.groupWrapper, 1);

			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- inputField --->
	<cffunction name="inputField" output="false" access="public" returntype="any" hint="Create an input field using some cool tags and features.	Any extra arguments are passed to the tag">
		<cfargument name="type" 		type="string"	 required="false" default="text" hint="The type of input field to create"/>
		<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the field"/>
		<cfargument name="value" 		type="string"	required="false" default="" hint="The value of the field"/>
		<cfargument name="disabled" 	type="boolean" 	required="false" default="false" hint="Disabled"/>
		<cfargument name="checked" 		type="boolean" 	required="false" default="false" hint="Checked"/>
		<cfargument name="readonly" 	type="boolean" 	required="false" default="false" hint="Readonly"/>
		<cfargument name="wrapper" 		type="string" 	required="false" default="" hint="The wrapper tag to use around the tag. Empty by default">
		<cfargument name="groupWrapper" type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="label" 		type="string"	required="false" default="" hint="If Passed we will prepend a label tag"/>
		<cfargument name="labelwrapper" type="string"	required="false" default="" hint="The wrapper tag to use around the label. Empty by default"/>
		<cfargument name="labelClass" 	type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfargument name="bind" 		type="any" 		required="false" default="" hint="The entity binded to this control"/>
		<cfargument name="bindProperty" type="any" 		required="false" default="" hint="The property to use for the value, by convention we use the name attribute"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var buffer 		= createObject( "java", "java.lang.StringBuilder" ).init( '' );
			var excludeList = "label,wrapper,labelWrapper,groupWrapper,labelClass,bind,bindProperty";

			// ID Normalization
			normalizeID( arguments );
			// group wrapper?
			wrapTag( buffer, arguments.groupWrapper );
			// label?
			if( len( arguments.label ) ){ buffer.append( this.label( field=arguments.id, content=arguments.label, wrapper=arguments.labelWrapper, class=arguments.labelClass ) ); }
			//wrapper?
			wrapTag( buffer, arguments.wrapper );

			// disabled fix
			if( arguments.disabled ){ arguments.disabled = "disabled"; }
			else{ arguments.disabled = ""; }
			// checked fix
			if( arguments.checked ){ arguments.checked = "checked"; }
			else{ arguments.checked = ""; }
			// readonly fix
			if( arguments.readonly ){ arguments.readonly = "readonly"; }
			else{ arguments.readonly = ""; }

			// binding?
			bindValue( arguments );

			// create textarea
			buffer.append("<input");
			flattenAttributes( arguments, excludeList, buffer ).append( "/>" );

			//wrapper?
			wrapTag( buffer, arguments.wrapper, 1 );
			// group wrapper?
			wrapTag( buffer, arguments.groupWrapper, 1 );

			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- entityFields --->
	<cffunction name="entityFields" output="false" access="public" returntype="any" hint="Create fields based on entity properties">
		<cfargument name="entity" 			type="any" 		required="true" hint="The entity binded to this control"/>
		<cfargument name="groupWrapper" 	type="string" 	required="false" default="" hint="The wrapper tag to use around the tag and label. Empty by default">
		<cfargument name="fieldwrapper" 	type="any"		required="false" default="" hint="The wrapper tag to use around the field items. Empty by default"/>
		<cfargument name="labelwrapper" 	type="any"		required="false" default="" hint="The wrapper tag to use around the label items. Empty by default"/>
		<cfargument name="labelClass" 		type="string"	required="false" default="" hint="The class to be applied to the label"/>
		<cfargument name="textareas" 		type="any"		required="false" default="" hint="A list of property names that you want as textareas"/>
		<cfargument name="booleanSelect" 	type="boolean" 	required="false" default="true" hint="If a boolean is detected a dropdown is generated, if false, then radio buttons"/>
		<cfargument name="showRelations" 	type="boolean" 	required="false" default="true" hint="If true it will show relation tables for one to one and one to many"/>
		<cfargument name="manytoone" 		type="struct" 	required="false" default="#structnew()#" hint="A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string]. Example: {criteria={productid=1},sortorder='Department desc'}"/>
		<cfargument name="manytomany" 		type="struct" 	required="false" default="#structnew()#" hint="A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string,selectColumn='']. Example: {criteria={productid=1},sortorder='Department desc'}"/>
		<cfscript>
			var buffer 	= createObject("java","java.lang.StringBuilder").init('');
			var md 		= getMetadata( arguments.entity );
			var x		= 1;
			var y		= 1;
			var prop	= "";
			var args	= {};
			var loc		= {};

			// if no properties just return.
			if( NOT structKeyExists(md,"properties") ){ return ""; }

			// iterate properties array
			for(x=1; x lte arrayLen(md.properties); x++ ){
				prop = md.properties[x];

				// setup some defaults
				loc.persistent 	= true;
				loc.ormtype		= "string";
				loc.fieldType	= "column";
				loc.insert		= true;
				loc.update		= true;
				loc.formula		= "";
				loc.readonly	= false;
				if( structKeyExists(prop,"persistent") ){ loc.persistent = prop.persistent; }
				if( structKeyExists(prop,"ormtype") ){ loc.ormtype = prop.ormtype; }
				if( structKeyExists(prop,"fieldType") ){ loc.fieldType = prop.fieldType; }
				if( structKeyExists(prop,"insert") ){ loc.insert = prop.insert; }
				if( structKeyExists(prop,"update") ){ loc.update = prop.update; }
				if( structKeyExists(prop,"formula") ){ loc.formula = prop.formula; }
				if( structKeyExists(prop,"readonly") ){ loc.readonly = prop.readonly; }

				// html 5 data items
				arguments["data-ormtype"] 	= loc.ormtype;
				arguments["data-insert"] 	= loc.insert;
				arguments["data-update"] 	= loc.update;

				// continue on non-persistent ones or formulas or readonly
				loc.orm = ORMGetSession();
				if( NOT loc.persistent OR len(loc.formula) OR loc.readOnly OR
					( loc.orm.contains(arguments.entity) AND NOT loc.update ) OR
					( NOT loc.orm.contains(arguments.entity) AND NOT loc.insert )
				){ continue; }

				switch(loc.fieldType){
					//primary key as hidden field
					case "id" : {
						args = {
							name=prop.name,bind=arguments.entity
						};
						buffer.append( hiddenField(argumentCollection=args) );
						break;
					}
					case "many-to-many" : {
						// prepare lookup args
						loc.criteria			= {};
						loc.sortorder 		= "";
						loc.column 			= "";
						loc.nameColumn 		= "";
						loc.selectColumn 	= "";
						loc.values			= [];
						loc.relArray		= [];
						arguments["data-ormtype"] 	= "many-to-many";

						// is key found in manytoone arg
						if( structKeyExists(arguments.manytomany, prop.name) ){
							if( structKeyExists(arguments.manytomany[prop.name],"valueColumn") ){ loc.column = arguments.manytomany[prop.name].valueColumn; }
							else{
								throw(message="The 'valueColumn' property is missing from the '#prop.name#' relationship data, which is mandatory",
									   detail="A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string,selectColumn='']. Example: {criteria={productid=1},sortorder='Department desc'}",
									   type="EntityFieldsInvalidRelationData");
							}
							if( structKeyExists(arguments.manytomany[prop.name],"nameColumn") ){ loc.nameColumn = arguments.manytomany[prop.name].nameColumn; }
							else{
								loc.nameColumn = arguments.manytomany[prop.name].valueColumn;
							}
							if( structKeyExists(arguments.manytomany[prop.name],"criteria") ){ loc.criteria = arguments.manytomany[prop.name].criteria; }
							if( structKeyExists(arguments.manytomany[prop.name],"sortorder") ){ loc.sortorder = arguments.manytomany[prop.name].sortorder; }
							if( structKeyExists(arguments.manytomany[prop.name],"selectColumn") ){ loc.selectColumn = arguments.manytomany[prop.name].selectColumn; }
						}
						else{
							throw(message="There is no many to many information for the '#prop.name#' relationship in the entityFields() arguments.  Please make sure you create one",
								  detail="A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string,selectColumn='']. Example: {criteria={productid=1},sortorder='Department desc'}",
								  type="EntityFieldsInvalidRelationData");
						}

						// values should be an array of objects, so let's convert them
						loc.relArray = evaluate("arguments.entity.get#prop.name#()");
						if( isNull(loc.relArray) ){ loc.relArray = []; }
						if( NOT len(loc.selectColumn) AND arrayLen(loc.relArray) ){
							// if select column is empty, then select first property as select value, not perfect but hey better than nothing
							loc.selectColumn = getMetadata( loc.relArray[1] ).properties[1].name;
						}
						// iterate and select
						for(y=1; y lte arrayLen(loc.relArray); y++){
							arrayAppend(loc.values, evaluate("loc.relArray[y].get#loc.selectColumn#()") );
						}
						// generation args
						args = {
							name=prop.name, options=entityLoad( prop.cfc, loc.criteria, loc.sortorder ), column=loc.column, nameColumn=loc.nameColumn,
							multiple=true, label=prop.name, labelwrapper=arguments.labelWrapper, labelClass=arguments.labelClass, wrapper=arguments.fieldwrapper,
							groupWrapper=arguments.groupWrapper, selectedValue=arrayToList( loc.values )
						};
						structAppend(args,arguments);
						buffer.append( this.select(argumentCollection=args) );
						break;
					}
					// one to many display
					case "one-to-many" : {
						loc.orm = ORMGetSession();
						// A new or persisted entity? If new, then skip out
						if( NOT loc.orm.contains(arguments.entity) OR NOT arguments.showRelations){
							break;
						}
						arguments["data-ormtype"] 	= "one-to-many";
						// We just show them as a nice table because we are not scaffolding, just display
						// values should be an array of objects, so let's convert them
						loc.relArray = evaluate("arguments.entity.get#prop.name#()");
						if( isNull(loc.relArray) ){ loc.relArray = []; }

						// Label Generation
						args = {
							field=prop.name, wrapper=arguments.labelWrapper, class=arguments.labelClass
						};
						structAppend(args,arguments);
						buffer.append( this.label(argumentCollection=args) );

						// Table Generation
						if( arrayLen(loc.relArray) ){
							args = {
								name=prop.name, data=loc.relArray
							};
							structAppend(args,arguments);
							buffer.append( this.table(argumentCollection=args) );
						}
						else{
							buffer.append("<p>None Found</p>");
						}

						break;
					}
					// one to many display
					case "one-to-one" : {
						loc.orm = ORMGetSession();
						// A new or persisted entity? If new, then skip out
						if( NOT loc.orm.contains(arguments.entity) OR NOT arguments.showRelations){
							break;
						}

						arguments["data-ormtype"] 	= "one-to-one";
						// We just show them as a nice table because we are not scaffolding, just display
						// values should be an array of objects, so let's convert them
						loc.data = evaluate("arguments.entity.get#prop.name#()");
						if( isNull(loc.data) ){ loc.relArray = []; }
						else{ loc.relArray = [ loc.data ]; }

						// Label Generation
						args = {
							field=prop.name, wrapper=arguments.labelWrapper, class=arguments.labelClass
						};
						structAppend(args,arguments);
						buffer.append( this.label(argumentCollection=args) );

						// Table Generation
						if( arrayLen(loc.relArray) ){
							args = {
								name=prop.name, data=loc.relArray
							};
							structAppend(args,arguments);
							buffer.append( this.table(argumentCollection=args) );
						}
						else{
							buffer.append("<p>None Found</p>");
						}
						break;
					}
					// many to one
					case "many-to-one" : {
						arguments["data-ormtype"] 	= "many-to-one";
						// prepare lookup args
						loc.criteria	= {};
						loc.sortorder = "";
						loc.column = "";
						loc.nameColumn = "";
						// is key found in manytoone arg
						if( structKeyExists(arguments.manytoone, prop.name) ){
							// Verify the valueColumn which is mandatory
							if( structKeyExists(arguments.manytoone[prop.name],"valueColumn") ){ loc.column = arguments.manytoone[prop.name].valueColumn; }
							else{
								throw(message="The 'valueColumn' property is missing from the '#prop.name#' relationship data, which is mandatory",
									   detail="A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string]. Example: {criteria={productid=1},sortorder='Department desc'}",
									   type="EntityFieldsInvalidRelationData");
							}
							if( structKeyExists(arguments.manytoone[prop.name],"nameColumn") ){ loc.nameColumn = arguments.manytoone[prop.name].nameColumn; }
							else { loc.nameColumn = arguments.manytoone[prop.name].valueColumn; }
							if( structKeyExists(arguments.manytoone[prop.name],"criteria") ){ loc.criteria = arguments.manytoone[prop.name].criteria; }
							if( structKeyExists(arguments.manytoone[prop.name],"sortorder") ){ loc.sortorder = arguments.manytoone[prop.name].sortorder; }
						}
						else{
							throw(message="There is no many to one information for the '#prop.name#' relationship in the entityFields() arguments.  Please make sure you create one",
								  detail="A structure of data to help with many to one relationships on how they are presented. Possible key values for each key are [valuecolumn='',namecolumn='',criteria={},sortorder=string]. Example: {criteria={productid=1},sortorder='Department desc'}",
								  type="EntityFieldsInvalidRelationData");
						}
						// generation args
						args = {
							name=prop.name, options=entityLoad( prop.cfc, loc.criteria, loc.sortorder ),
							column=loc.column, nameColumn=loc.nameColumn,
							label=prop.name, bind=arguments.entity, labelwrapper=arguments.labelWrapper, labelClass=arguments.labelClass,
							wrapper=arguments.fieldwrapper, groupWrapper=arguments.groupWrapper
						};
						structAppend(args,arguments);
						buffer.append( this.select(argumentCollection=args) );
						break;
					}
					// columns
					case "column" : {

						// booleans?
						if( structKeyExists(prop,"ormtype") and prop.ormtype eq "boolean"){
							// boolean select or radio buttons
							if( arguments.booleanSelect ){
								args = {
									name=prop.name, options=[true,false], label=prop.name, bind=arguments.entity, labelwrapper=arguments.labelWrapper, labelClass=arguments.labelClass,
									wrapper=arguments.fieldwrapper, groupWrapper=arguments.groupWrapper
								};
								structAppend(args,arguments);
								buffer.append( this.select(argumentCollection=args) );
							}
							else{
								args = {
									name=prop.name, value="true", label="True", bind=arguments.entity, labelwrapper=arguments.labelWrapper, labelClass=arguments.labelClass,
									groupWrapper=arguments.groupWrapper, wrapper=arguments.fieldWrapper
								};
								structAppend(args,arguments);
								buffer.append( this.radioButton(argumentCollection=args) );
								args.value="false";
								args.label="false";
								buffer.append( this.radioButton(argumentCollection=args) );
							}
							continue;
						}
						// text args
						args = {
							name=prop.name, label=prop.name, bind=arguments.entity, labelwrapper=arguments.labelWrapper, labelClass=arguments.labelClass,
							wrapper=arguments.fieldwrapper, groupWrapper=arguments.groupWrapper
						};
						structAppend(args,arguments);
						// text and textarea fields
						if( len(arguments.textareas) AND listFindNoCase(arguments.textareas, prop.name) ){
							buffer.append( this.textarea(argumentCollection=args) );
						}
						else{
							buffer.append( this.textfield(argumentCollection=args) );
						}
					}// end case column

				}// end switch

			}// end for loop

			return buffer.toString();
		</cfscript>
	</cffunction>

	<!--- elixir --->
	<cffunction name="elixir" output="false" access="public" returntype="void" hint="Adds the versioned path for an asset to the view">
		<cfargument name="fileName" type="string" required="true" hint="The asset path to find relative to the includes convention directory"/>
		<cfargument name="buildDirectory" type="string" required="false" default="build" hint="The build directory inside the includes convention directory"/>
		<cfargument name="sendToHeader" type="boolean" required="false" default="true" hint="Send to the header via htmlhead by default, else it returns the content"/>
		<cfargument name="async" type="boolean" required="false" default="false" hint="HTML5 JavaScript argument: Specifies that the script is executed asynchronously (only for external scripts)"/>
		<cfargument name="defer" type="boolean" required="false" default="false" hint="HTML5 JavaScript argument: Specifies that the script is executed when the page has finished parsing (only for external scripts)"/>
		<cfscript>
			addAsset(
				elixirPath( arguments.fileName, arguments.buildDirectory ),
				arguments.sendToHeader,
				arguments.async,
				arguments.defer
			);
		</cfscript>
	</cffunction>

	<!--- elixirPath --->
	<cffunction name="elixirPath" output="false" access="public" returntype="string" hint="Finds the versioned path for an asset">
		<cfargument name="fileName" 		type="string" required="true" hint="The asset path to find relative to the includes convention directory"/>
		<cfargument name="buildDirectory" 	type="string" required="false" default="build" hint="The build directory inside the includes convention directory"/>
		<cfscript>
			var includesLocation 	= controller.getSetting( "IncludesConvention", true );
			var event 				= getRequestContext();
			var mapping 			= event.getCurrentModule() != "" ? event.getModuleRoot() : controller.getSetting( "appMapping" );
			var filePath 			= expandPath( "#mapping#/#includesLocation#/#arguments.buildDirectory#/rev-manifest.json" );
			var href 				= "#mapping#/#includesLocation#/#arguments.fileName#";
			
			if ( ! fileExists( filePath ) ) {
				return href;
			}

			var fileContents = fileRead( filePath );
			if ( ! isJSON( fileContents ) ) {
				return href;
			}

			var json = deserializeJSON( fileContents );
			if ( ! structKeyExists( json, arguments.fileName ) ) {
				return href;
			}

			return "#mapping#/#includesLocation#/#arguments.buildDirectory#/#json[ arguments.fileName ]#";
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- arrayToTable --->
	<cffunction name="arrayToTable" output="false" access="private" returntype="void" hint="Convert a table out of an array">
		<cfargument name="data" 		type="any"			 required="true"	hint="The array to convert into a table"/>
		<cfargument name="includes" 	type="string"		required="false" default=""	hint="The columns to include in the rendering"/>
		<cfargument name="excludes" 	type="string"		required="false" default=""	hint="The columns to exclude in the rendering"/>
		<cfargument name="buffer" 		type="any" 	 	 required="true"/>
		<cfscript>
			var str		= arguments.buffer;
			var attrs	= "";
			var x		= 1;
			var y		= 1;
			var key		= "";
			var cols	= structKeyArray( data[ 1 ] );

			// Render Headers
			for(x=1; x lte arrayLen(cols); x=x+1){
				// Display?
				if( passIncludeExclude(cols[x],arguments.includes,arguments.excludes) ){
					str.append("<th>#cols[x]#</th>");
				}
			}
			str.append("</tr></thead>");

			// Render Body
			str.append("<tbody>");
			for(x=1; x lte arrayLen(arguments.data); x=x+1){
				str.append("<tr>");
				for(y=1; y lte arrayLen(cols); y=y+1){
					// Display?
					if( passIncludeExclude(cols[y],arguments.includes,arguments.excludes) ){
						str.append("<td>#arguments.data[x][cols[y]]#</td>");
					}
				}
				str.append("</tr>");
			}
		</cfscript>
	</cffunction>

	<!--- queryToTable --->
	<cffunction name="queryToTable" output="false" access="private" returntype="void" hint="Convert a table out of an array of structures">
		<cfargument name="data" 		type="any"			 required="true"	hint="The query to convert into a table"/>
		<cfargument name="includes" 	type="string"		required="false" default=""	hint="The columns to include in the rendering"/>
		<cfargument name="excludes" 	type="string"		required="false" default=""	hint="The columns to exclude in the rendering"/>
		<cfargument name="buffer" 		type="any" 	 	 required="true"/>
		<cfscript>
			var str		= arguments.buffer;
			var cols	 = listToArray(arguments.data.columnList);
			var x			= 1;
			var y		 = 1;

			// Render Headers
			for(x=1; x lte arrayLen(cols); x=x+1){
				// Display?
				if( passIncludeExclude(cols[x],arguments.includes,arguments.excludes) ){
					str.append("<th>#cols[x]#</th>");
				}
			}
			str.append("</tr></thead>");

			// Render Body
			str.append("<tbody>");
			for(x=1; x lte arguments.data.recordcount; x=x+1){
				str.append("<tr>");
				for(y=1; y lte arrayLen(cols); y=y+1){
					// Display?
					if( passIncludeExclude(cols[y],arguments.includes,arguments.excludes) ){
						str.append("<td>#arguments.data[cols[y]][x]#</td>");
					}
				}
				str.append("</tr>");
			}
		</cfscript>
	</cffunction>

	<!--- toHTMLList --->
	<cffunction name="toHTMLList" output="false" access="private" returntype="any" hint="Convert a sent in tag type to an HTML list">
		<cfargument name="tag"	 		type="string" required="true" hint="The list tag type"/>
		<cfargument name="values" 		type="any"		required="true" default="" hint="An array of values or list of values"/>
		<cfargument name="column"		 	type="string" required="false" default="" hint="If the values is a query, this is the name of the column to get the data from to create the list"/>
		<cfargument name="data"			type="struct" required="false" default="#structNew()#"	hint="A structure that will add data-{key} elements to the HTML control"/>
		<cfscript>
			var val 	= arguments.values;
			var x	 	= 1;
			var str 	= createObject("java","java.lang.StringBuilder").init("");
			var br		= chr(13);
			var args	= "";

			// list or array or query?
			if( isSimpleValue(val) ){ val = listToArray(val); }
			if( isQuery(val) ){ val = getColumnArray(val,arguments.column); }

			// start tag
			str.append("<#arguments.tag#");
			// flatten extra attributes via arguments
			flattenAttributes(arguments,"tag,values,column",str).append(">");

			// values
			for(x=1; x lte arrayLen(val); x=x+1){

				if( isArray(val[x]) ){
					str.append( toHTMLList(arguments.tag,val[x],arguments.column) );
				}
				else{
					str.append("<li>#val[x]#</li>");
				}

			}

			str.append("</#arguments.tag#>");
			return str.toString();
		</cfscript>
	</cffunction>

	<!--- bindValue --->
	<cffunction name="bindValue" output="false" access="private" returntype="any" hint="Bind entity values">
		<cfargument name="args">
		<cfscript>
			var entityValue = "";

			// binding?
			if( isObject( arguments.args.bind ) ){
				// do we have a bindProperty, else default it from the name
				if( NOT len( arguments.args.bindProperty ) ){

					// check if name exists else throw exception
					if( NOT structKeyExists( arguments.args, "name" ) OR NOT len( arguments.args.name ) ){
						throw( type="HTMLHelper.NameBindingException", message="The 'name' argument was not passed and not binding property was passed, so we can't bind dude!" );
					}

					// bind name property
					arguments.args.bindProperty = arguments.args.name;
				}

				// entity value
				entityValue = evaluate( "arguments.args.bind.get#arguments.args.bindProperty#()" );
				if( isNull( entityValue ) ){ entityValue = ""; }
				// Verify if the value is an entity, if it is, then use the 'column' to retrieve the value
				if( isObject( entityValue ) ){ entityValue = evaluate( "entityValue.get#arguments.args.column#()" ); }

				// If radio or checkbox button, check it
				if( structKeyExists( arguments.args, "type" ) AND listFindNoCase( "radio,checkbox", arguments.args.type ) ){
					// is incoming value eq to property value with boolean aspects
					if( structKeyExists( arguments.args, "value" ) and
					    isBoolean( arguments.args.value ) and
					    yesNoFormat( arguments.args.value ) EQ yesNoFormat( entityValue ) ){
						arguments.args.checked = true;
					}
					// else with no boolean evals
					else if( structKeyExists( arguments.args, "value" ) and arguments.args.value EQ entityValue ){
						arguments.args.checked = true;
					}
				}
				else{
					// If there is no incoming value, then bind it
					arguments.args.value = entityValue;
				}
			}
		</cfscript>
	</cffunction>

	<!--- normalizeID --->
	<cffunction name="normalizeID" output="false" access="private" returntype="any" hint="Normalize ID with name arguments">
		<cfargument name="args">
		<cfscript>
			if( structKeyExists(arguments.args,"name") AND len(arguments.args.name) AND NOT structKeyExists(arguments.args,"id") ){
				arguments.args.id = arguments.args.name;
			}
		</cfscript>
	</cffunction>

	<!--- wrapTag --->
	<cffunction name="wrapTag" output="false" access="private" returntype="any">
		<cfargument name="buffer">
		<cfargument name="tag">
		<cfargument name="end" required="false" default="false">
		<cfscript>
			var slash = "";
			if( len( arguments.tag ) ){
				if( arguments.end ){ slash = "/"; }
				arguments.buffer.append("<#slash##arguments.tag#>");
			}
		</cfscript>
	</cffunction>

	<!--- makePretty --->
	<cffunction name="makePretty" access="private" returntype="any" output="false" hint="make pretty text">
		<cfargument name="text">
		<cfscript>
			return ucase( left( arguments.text, 1 ) ) & removeChars( lcase( replace( arguments.text, "_", " ") ), 1, 1 );
		</cfscript>
	</cffunction>

	<!--- prepareBaseLink --->
	<cffunction name="prepareBaseLink" output="false" access="private" returntype="any" hint="Prepare a base link">
		<cfargument name="noBaseURL">
		<cfargument name="src">
		<cfscript>
			var baseURL = replacenocase( controller.getRequestService().getContext().getSESbaseURL() ,"index.cfm","");
			// return if base is eempty
			if( NOT len(baseURL) ){ return arguments.src; }

			// Check if we have a base URL
			if( arguments.noBaseURL eq FALSE and NOT find("://",arguments.src)){
				arguments.src = baseURL & "/" & arguments.src;
			}
			return arguments.src;
		</cfscript>
	</cffunction>

	<!--- passIncludeExclude --->
	<cffunction name="passIncludeExclude" output="false" access="private" returntype="boolean" hint="checks if a list include exclude check passes">
		<cfargument name="value" 		type="string"		required="true" hint="The value to test"/>
		<cfargument name="includes" 	type="string"		required="false" default=""	hint="The columns to include in the rendering"/>
		<cfargument name="excludes" 	type="string"		required="false" default=""	hint="The columns to exclude in the rendering"/>
		<cfscript>
			var disp = true;
			// Include List?
			if( len(arguments.includes) AND NOT listFindNoCase(arguments.includes,arguments.value) ){
				disp = false;
			}
			// Exclude List?
			if( len(arguments.excludes) AND listFindNoCase(arguments.excludes,arguments.value) ){
				disp = false;
			}
			return disp;
		</cfscript>
	</cffunction>

	<!--- flattenAttributes --->
	<cffunction name="flattenAttributes" output="false" access="private" returntype="any" hint="flatten a struct of attributes to strings">
		<cfargument name="target" 	type="struct" required="true">
		<cfargument name="excludes" type="any" required="false" default=""/>
		<cfargument name="buffer" 	type="any" required="true"/>
		<cfscript>
			var key	 = "";
			var datakey = "";

			// global exclusions
			arguments.excludes &= ",fieldWrapper,labelWrapper,entity,booleanSelect,textareas,manytoone,onetomany,sendToHeader,bind";

			for(key in arguments.target){
				// Excludes
				if( len( arguments.excludes ) AND listFindNoCase( arguments.excludes, key ) ){
					continue;
				}
				// Normal Keys
				if( structKeyExists( arguments.target, key ) AND isSimpleValue( arguments.target[ key ] ) AND len( arguments.target[ key ] ) ){
					arguments.buffer.append(' #lcase( key )#="#HTMLEditFormat( arguments.target[ key ] )#"');
				}
				// data keys
				if( isStruct( arguments.target[ key ] ) ){
					for( dataKey in arguments.target[ key ] ){
						if( isSimplevalue( arguments.target[ key ][ dataKey ] ) AND len( arguments.target[ key ][ dataKey ] ) ){
							arguments.buffer.append(' #lcase( key )#-#lcase( dataKey )#="#HTMLEditFormat( arguments.target[ key ][ datakey ] )#"');
						}
					}
				}

			}

			return arguments.buffer;
		</cfscript>
	</cffunction>

	<!--- onMissingMethod --->
    <cffunction name="onMissingMethod" output="false" access="public" returntype="any" hint="Proxy calls to provided element">
    	<cfargument	name="missingMethodName"		required="true"	hint="missing method name"	/>
		<cfargument	name="missingMethodArguments" 	required="true"	hint="missing method arguments"/>

    	<!---Incorporate tag to args --->
    	<cfset missingMethodArguments.tag = arguments.missingMethodName>

		<!--- Do Content --->
		<cfif structKeyExists(arguments.missingMethodArguments, 1)>
			<cfset arguments.missingMethodArguments.content = arguments.missingMethodArguments.1>
			<cfset structdelete( arguments.missingMethodArguments, 1)>
		</cfif>

		<!--- Execute Tag --->
    	<cfreturn tag( argumentCollection=arguments.missingMethodArguments )>

    </cffunction>

    <cffunction name="getColumnArray" access="private" returntype="any" output="false" hint="Returns an array of the values">
        <cfargument name="qry"			type="query"	required="true" hint="cf query" />
        <cfargument name="columnName"	type="string"	required="true" hint="column name" />
        <cfscript>
            var arValues = [];

            if( arguments.qry.recordcount ){
                for( var i = 1; i LTE arguments.qry.recordcount; i++){
                    ArrayAppend( arValues, arguments.qry[ arguments.columnName ][ i ] );
                }
            }

            return arValues;
        </cfscript>
    </cffunction>

    <!--- cfhtml head facade --->
	<cffunction name="$htmlhead" access="public" returntype="void" hint="Facade to cfhtmlhead" output="false" >
		<cfargument name="content" required="true" type="string" hint="The content to send to the head">
		<cfhtmlhead text="#arguments.content#">
	</cffunction>

</cfcomponent>
