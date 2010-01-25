/*
 * Modified by Luis Majano July 2009
 * Copyright (c) 2009 Luis Majano
 * 
   JS on Load:
   $(document).ready(function() {
   		$("##productFilter").keyup(function(){
			$.uiDivFilter( $(".ProductCollectionTab"), this.value, divIsHidden )
		})
	})
	
	//Callback when items are hidden
   function divIsHidden(elem){
		var words = elem.attr("id").split("_");
		var id = words[1];
		
		if( id ){
			var pvtab = $("##pvtab_"+id);
			pvtab.hide();
		}
	}
  
  Input Declaration For Filter
  <input size="40" type="text" name="productFilter" id="productFilter" />
 
  Divs:
  <div id="ptab_#productID#" class="ProductCollectionTab<cfif currentrow mod 2 eq 0> even</cfif>">
		<!--- Collection Name --->
		<span><img src="includes/images/organization.png" border="0" align="top" alt="#name#" /> #name#</span>
   </div>
 
  
 * Original Creator:
 * Copyright (c) 2008 Greg Weber greg at gregweber.info
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * documentation at http://gregweber.info/projects/uitablefilter
 *
 * allows divs to be filtered (made invisible)
 * <code>
 * divs = $('.class') or any multi-div selector
 * $.uiDivFilter( divs, phrase, hiddenCallBack, shownCallBack )
 * </code>
 * arguments:
 *   jQuery object with all divs selectors
 *   phrase to search for
 *   hidden call back function that receives the element that got hidden
 *   shown call back function that receives the element that got showned
 */
jQuery.uiDivFilter = function(jq, phrase, ifHidden, ifShown){
	if (this.last_phrase === phrase) {
		return false
	};
	var phrase_length = phrase.length;
	var words = phrase.toLowerCase().split(" ");
	var test = "";
	
	// Search Method
	var search_text = function(){
		var elem = jQuery(this);
		if( jQuery.uiDivFilter.has_words( elem.text(), words ) ){
			elem.show();	
			// Call callback if defined
			if( ifShown ){ ifShown(elem) }		
		}
		else{
			elem.hide();
			// Call callback if defined
			if( ifHidden ){ ifHidden(elem) }
		}
	}	
	// if added one letter to last time,
	// just check newest word and only need to hide
	if( (words.length > 1) && (phrase.substr(0, phrase_length - 1) === this.last_phrase) ) {
		var words = words[words.length-1];
		this.last_phrase = phrase;
		jq.filter(":visible").each( search_text );
	}
	else {
		this.last_phrase = phrase;
		jq.each( search_text );
	}	
	return jq;
};

jQuery.uiDivFilter.last_phrase = ""

// not jQuery dependent
// "" [""] -> Boolean
// "" [""] Boolean -> Boolean
jQuery.uiDivFilter.has_words = function( str, words, caseSensitive ){
  var text = caseSensitive ? str : str.toLowerCase();
  for (var i=0; i < words.length; i++) {
    if (text.indexOf(words[i]) === -1) return false;
  }
  return true;
}
