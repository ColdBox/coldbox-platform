<cfscript>
out = createObject("java","java.lang.StringBuffer").init('');
tab = chr(9);
br  = chr(10);

out.append('<?xml version="1.0" ?>
<dictionary xmlns="http://www.cfeclipse.org/version1/dictionary"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://www.cfeclipse.org/version1/dictionary http://cfeclipse.tigris.org/version1/dictionary/dictionary.xsd"
>
	<tags></tags>
');

functions = {
	superType = "coldbox.system.FrameworkSuperType",
	eventHandler = "coldbox.system.EventHandler",
	plugin = "coldbox.system.Plugin",
	interceptor = "coldbox.system.Interceptor"
};

out.append('#tab#<functions>
');

for( key in functions ){
	
	md = getComponentMetaData( functions[key] );
	
	out.append('<!-- Functions for: #md.name# -->#br#');
	
	for(x=1; x lte arrayLen(md.functions); x++){
		if( NOT structKeyExists(md.functions[x],"returntype") ){ md.functions[x].returntype = "any"; }
		if( NOT structKeyExists(md.functions[x],"hint") ){ md.functions[x].hint = ""; }
		out.append('#tab#<function creator="8" name="#md.functions[x].name#" returns="#md.functions[x].returntype#">
			<help><![CDATA[ #md.functions[x].hint# (Context: #listLast(md.name,".")#) ]]></help>
		');	
		
		// Parameters
		for( y=1; y lte arrayLen(md.functions[x].parameters); y++){
			if(NOT structKeyExists(md.functions[x].parameters[y],"required") ){	md.functions[x].parameters[y].required = false;	}
			if(NOT structKeyExists(md.functions[x].parameters[y],"hint") ){	md.functions[x].parameters[y].hint = "";	}
			if(NOT structKeyExists(md.functions[x].parameters[y],"type") ){	md.functions[x].parameters[y].type = "any";	}
			
			out.append('<parameter name="#md.functions[x].parameters[y].name#" required="#md.functions[x].parameters[y].required#" type="#md.functions[x].parameters[y].type#">
				<help><![CDATA[ #md.functions[x].parameters[y].hint# ]]></help>
			</parameter>
			');
		}
		
		out.append('</function>#br#');
	}
}

out.append('#tab#</functions>#br##br#
<scopes>
');

scopes = {
	controller = "coldbox.system.web.Controller",
	event = "coldbox.system.web.context.RequestContext",
	flash = "coldbox.system.web.flash.AbstractFlashScope",
	log = "coldbox.system.logging.Logger",
	logbox = "coldbox.system.logging.LogBox",
	binder = "coldbox.system.ioc.config.Binder",
	wirebox = "coldbox.system.ioc.Injector",
	cachebox = "coldbox.system.cache.CacheFactory"
};
for( key in scopes ){
	
	md = getComponentMetaData( scopes[key] );
	
	for(x=1; x lte arrayLen(md.functions); x++){
		out.append('#tab#<scope value="#lcase(key)#.#md.functions[x].name#(');	
		
		// Args
		for( y=1; y lte arrayLen(md.functions[x].parameters); y++){
			if(NOT structKeyExists(md.functions[x].parameters[y],"required") ){
				md.functions[x].parameters[y].required = false;
			}
			out.append((md.functions[x].parameters[y].required ? '':'[') & '#md.functions[x].parameters[y].name#' & (md.functions[x].parameters[y].required ? '':']'));
			
			if( y le  ( arrayLen(md.functions[x].parameters)-1) ){
				out.append(",");
			} 
		}
		
		out.append(')">
		#tab#<help><![CDATA[#md.functions[x].hint#]]></help>
		</scope>#br#');
	}
	
}

out.append('
	</scopes>
</dictionary>');

fileWrite(expandPath('/coldbox/install/IDE Extras/CFEclipse Dictionary/coldbox.xml'), out.toString());
</cfscript>

<textarea rows="30" cols="160">
<cfoutput>#out.toString()#</cfoutput>
</textarea>

