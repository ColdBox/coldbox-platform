/**
 * @displayname Validator Message
 * @hint I will load and retrieve default messages from the properties file passed in.
 * @accessors true
 * @output false
 */
component implements="iValidationMessageProvider" {

	property string resourceBundle;
	property array messages;

	public ValidatorMessage function init(required String rb){
		setResourceBundle(arguments.rb);
		setMessages(arrayNew(1));
		loadResourceBundle();
		return this;
	}

	public string function getMessageByType(String type,Struct prop){
		var messages = getMessages();
		var errorMessage = "";
			
		for(i=1; i <= arrayLen(messages); ++i){
			if(messages[i].type == arguments.type){
				if(!structKeyExists(arguments.prop,"display")){
					prop.display = humanize(prop.name);
				}
				errorMessage = replaceTemplateText(messages[i].message,prop);					
				
			}
		}

		return errorMessage;
	}
	
	private string function replaceTemplateText(String message,Struct prop){
		var templates = reMatchNoCase("({)([\w])+?(})",arguments.message);
		var m = arguments.message;
		
		if( arrayLen(templates) ) {
			// looop over the array, in each
			for(var i=1; i<=arrayLen(templates); ++i){
				var placeHolder = templates[i];
				var property = reReplaceNoCase(placeHolder,"({)([\w]+)(})","\2");
				// now we know the key we are looking for
				for(key in prop) {						
					if(uCase(key) == ucase(property)){
						m = replaceNoCase(m,placeHolder,prop[key],"all");
					}
				}
			}
		}

		return m;
	}	

	private void function loadResourceBundle(Boolean isAbsolutePath=false){
		var dir = getDirectoryFromPath(getCurrentTemplatePath());
		var rbPath = dir & "resources/" & getResourceBundle();

		// read in the properties for the resource bundle
		if(findNoCase(".properties",getResourceBundle())){
			var file = fileOpen(rbPath);
		} else {
			var file = fileOpen(rbPath & ".properties");
		}

	    while (! fileIsEOF(file)) {
	        var x = fileReadLine(file);
			var type = listFirst(x,"=");
			var message = listLast(x,"=");
			arrayAppend(getMessages(),{type=type,message=message});
	    }

	}

	public array function getDefaultErrorMessages(){
		return getMessages();
	}

	private string function humanize(String text){
		var loc = {};
		loc.returnValue = reReplace(arguments.text, "([[:upper:]])", " \1", "all"); 
		loc.returnValue = reReplace(loc.returnValue, "([[:upper:]]) ([[:upper:]]) ", "\1\2", "all"); 
		loc.returnValue = replace(loc.returnValue, "-", " ", "all"); 
		loc.returnValue = ucase(left(loc.returnValue,1)) & right(loc.returnValue,len(loc.returnValue)-1);	
		return loc.returnValue;		
	}
}