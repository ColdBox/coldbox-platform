
jQuery.uiDivFilter=function(jq,phrase,ifHidden,ifShown){if(this.last_phrase===phrase){return false};var phrase_length=phrase.length;var words=phrase.toLowerCase().split(" ");var test="";var search_text=function(){var elem=jQuery(this);if(jQuery.uiDivFilter.has_words(elem.text(),words)){elem.show();if(ifShown){ifShown(elem)}}
else{elem.hide();if(ifHidden){ifHidden(elem)}}}
if((words.length>1)&&(phrase.substr(0,phrase_length-1)===this.last_phrase)){var words=words[words.length-1];this.last_phrase=phrase;jq.filter(":visible").each(search_text);}
else{this.last_phrase=phrase;jq.each(search_text);}
return jq;};jQuery.uiDivFilter.last_phrase=""
jQuery.uiDivFilter.has_words=function(str,words,caseSensitive){var text=caseSensitive?str:str.toLowerCase();for(var i=0;i<words.length;i++){if(text.indexOf(words[i])===-1)return false;}
return true;}