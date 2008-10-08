// basic html textarea editor
function tag(tag) {
	
//The src textarea	
var src = document.getElementById("body");
	
	if(tag == 'break'){ start = "[break]"; end = "";}
	
	else if(tag == 'br'){ start = ""; end = "<br />";}
	
	else if(tag == 'img'){	
		var url = prompt("Enter Image URL", "");
		var alt = prompt("Enter Image Alt", "");
		if(url != null) { start = "<img src=\""+url+"\" alt=\""+alt+"\" />"; end = ""; } else { start = ""; end = ""; }
	} 
	else if(tag == 'link'){	
		var url = prompt("Enter Link URL", "");		
		var title = prompt("Enter Link Title", "");
		if(url != null) { start = "<a href=\""+url+"\" title=\""+title+"\">"; end = "<\/a>"; } else { start = ""; end = ""; }
	} 
	else if(tag == 'include'){	
		var url = prompt("Enter File URL", "");
		if(url != null) { start = "[include]" + url + "[/include]"; end = ""; } else { start = ""; end = ""; }
	} 
	else if (tag == 'more'){
		start="<more/>"; end = "";
	}
	else{ 
		var start = "<" + tag + ">"; 
		var end = "</" + tag + ">"; 
	}
	
	//Selection Range
	if(!src.setSelectionRange) {
		var selected = document.selection.createRange().text;
		if(selected.length <= 0) { 
			src.value += start + end;
		} 
		else {
			var codetext = start + selected + end;
			document.selection.createRange().text = codetext;
		}
	} 
	else {
		var pretext = src.value.substring(0, src.selectionStart);
		var codetext = start + src.value.substring(src.selectionStart, src.selectionEnd) + end;
		var posttext = src.value.substring(src.selectionEnd, src.value.length)
		if(codetext == start + end)
			codetext = start + end;
		src.value = pretext + codetext + posttext;
	}	
	//focus the source
	src.focus();
}