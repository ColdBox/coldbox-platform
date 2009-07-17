/*
 * jQuery RTE plugin 0.2 - create a rich text form for Mozilla, Opera, and Internet Explorer
 *
 * Copyright (c) 2007 Batiste Bieler
 * Distributed under the GPL (GPL-LICENSE.txt) licenses.
 * Updated by Luis Majano 2008
 */
// define the rte light plugin
jQuery.fn.rte = function(css_url, media_url) {

    if(document.designMode || document.contentEditable)
    {
        $(this).each( function(){
            var textarea = $(this);
            enableDesignMode(textarea);
        });
    }
    
    function formatText(iframe, command, option) {
        iframe.contentWindow.focus();
        try{
            iframe.contentWindow.document.execCommand(command, false, option);
        }catch(e){console.log(e)}
        iframe.contentWindow.focus();
    }
    
    function tryEnableDesignMode(iframe, doc, callback) {
        try {
            iframe.contentWindow.document.open();
            iframe.contentWindow.document.write(doc);
            iframe.contentWindow.document.close();
        } catch(error) {
            console.log(error)
        }
        if (document.contentEditable) {
            iframe.contentWindow.document.designMode = "On";
            callback();
            return true;
        }
        else if (document.designMode != null) {
            try {
                iframe.contentWindow.document.designMode = "on";
                callback();
                return true;
            } catch (error) {
                console.log(error)
            }
        }
        setTimeout(function(){tryEnableDesignMode(iframe, doc, callback)}, 250);
        return false;
    }
    
    function enableDesignMode(textarea) {
        // need to be created this way
        var iframe = document.createElement("iframe");
        iframe.frameBorder=0;
        iframe.frameMargin=0;
        iframe.framePadding=0;
        iframe.height=200;
        if(textarea.attr('class'))
            iframe.className = textarea.attr('class');
        if(textarea.attr('id'))
            iframe.id = textarea.attr('id') + "_i";
        if(textarea.attr('name'))
            iframe.title = textarea.attr('name');
		textarea.after(iframe);
        var css = "";
        if(css_url)
            var css = "<link type='text/css' rel='stylesheet' href='"+css_url+"' />"
        var content = textarea.val();
        // Mozilla need this to display caret
        if($.trim(content)=='')
            content = '<br>';
        var doc = "<html><head>"+css+"</head><body class='frameBody'>"+content+"</body></html>";
        tryEnableDesignMode(iframe, doc, function() {
            $("#toolbar-"+iframe.title).remove();
            $(iframe).before(toolbar(iframe));
            textarea.toggle();
        });
    }
    
    function disableDesignMode(iframe, submit) {
		if(!iframe.contentWindow)
			return false;
        var content = iframe.contentWindow.document.getElementsByTagName("body")[0].innerHTML;
        var textareaID = iframe.id.split("_");
		var textarea = $('#'+textareaID[0]);
		textarea.val(content);
        $(iframe).before(textarea);
        if (submit != true) {
			$(iframe).remove();
			textarea.toggle();
		}
		else{
			if( content == '<br>' ){
				textarea.val('');
			}			
		}
        return textarea;
    }
   
    function toolbar(iframe) {
        var tb = $("<div class='rte-toolbar' id='toolbar-"+iframe.title+"'><div>\
            <p>\
                <select>\
                    <option value=''>Bloc style</option>\
                    <option value='pre'>Pre style</option>\
                    <option value='p'>Paragraph</option>\
                    <option value='h1'>Title (H1)</option>\
					<option value='h2'>Title (H2)</option>\
					<option value='h3'>Title (H3)</option>\
					<option value='h4'>Title (H4)</option>\
                </select>\
            </p>\
            <p>\
            	<a href='#' class='bold'><img src='"+media_url+"bold.png' alt='bold' align='absmiddle' /></a>\
                <a href='#' class='italic'><img src='"+media_url+"italic.png' alt='italic' align='absmiddle' /></a>\
				<a href='#' class='underline'><img src='"+media_url+"underline.png' alt='underline' align='absmiddle' /></a>\
			 	<a href='#' class='alignleft'><img src='"+media_url+"align_left.png' alt='Align Left' align='absmiddle' /></a>\
                <a href='#' class='aligncenter'><img src='"+media_url+"align_center.png' alt='Align Center' align='absmiddle' /></a>\
				<a href='#' class='alignright'><img src='"+media_url+"align_right.png' alt='Align Right' align='absmiddle' /></a>\
           	    <a href='#' class='indent'><img src='"+media_url+"indent.png' alt='indent' align='absmiddle' /></a>\
                <a href='#' class='outdent'><img src='"+media_url+"outdent.png' alt='outdent' align='absmiddle' /></a>\
                <a href='#' class='unorderedlist'><img src='"+media_url+"list_bullets.png' alt='unordered list' align='absmiddle' /></a>\
                <a href='#' class='orderedlist'><img src='"+media_url+"list_numbers.png' alt='ordered list' align='absmiddle' /></a>\
                <a href='#' class='hr'><img src='"+media_url+"hr.png' alt='hr' align='absmiddle' /></a>\
                <a href='#' class='link'><img src='"+media_url+"link.png' alt='link' align='absmiddle' /></a>\
                <a href='#' class='image'><img src='"+media_url+"image.png' alt='image' align='absmiddle' /></a>\
				<a href='#' class='disable'><img src='"+media_url+"html.png' alt='close rte' align='absmiddle' /></a>\
            </p></div></div>");
        $('select', tb).change(function(){
            var index = this.selectedIndex;
            if( index!=0 ) {
                var selected = this.options[index].value;
                formatText(iframe, "formatblock", '<'+selected+'>');
            }
        });
        $('.bold', tb).click(function(){ formatText(iframe, 'bold');return false; });
        $('.italic', tb).click(function(){ formatText(iframe, 'italic');return false; });
		$('.underline', tb).click(function(){ formatText(iframe, 'underline');return false; });
        $('.unorderedlist', tb).click(function(){ formatText(iframe, 'insertunorderedlist');return false; });
		$('.orderedlist', tb).click(function(){ formatText(iframe, 'insertOrderedList');return false; });
		$('.indent', tb).click(function(){ formatText(iframe, 'indent');return false; });
        $('.outdent', tb).click(function(){ formatText(iframe, 'outdent');return false; });
		$('.hr', tb).click(function(){ formatText(iframe, 'insertHorizontalRule');return false; });
        $('.alignleft', tb).click(function(){ formatText(iframe, 'justifyLeft');return false; });
        $('.aligncenter', tb).click(function(){ formatText(iframe, 'justifyCenter');return false; });
        $('.alignright', tb).click(function(){ formatText(iframe, 'justifyRight');return false; });
        $('.link', tb).click(function(){ 
            var p=prompt("URL:");
            if(p)
                formatText(iframe, 'CreateLink', p);
            return false; });
        $('.image', tb).click(function(){ 
            var p=prompt("image URL:");
            if(p)
                formatText(iframe, 'InsertImage', p);
            return false; });
        $('.disable', tb).click(function() {
            var txt = disableDesignMode(iframe);
            var edm = $('<a href="#">Enable design mode</a>');
            tb.empty().append(edm);
            edm.click(function(){
                enableDesignMode(txt);
                return false;
            });
            return false; 
        });
        $(iframe).parents('form').submit(function(){
			disableDesignMode(iframe, true);
		});
        var iframeDoc = $(iframe.contentWindow.document);
        
        var select = $('select', tb)[0];
        iframeDoc.mouseup(function(){ 
            setSelectedType(getSelectionElement(iframe), select);
            return true;
        });
        iframeDoc.keyup(function(){ 
            setSelectedType(getSelectionElement(iframe), select);
            var body = $('body', iframeDoc);
            if(body.scrollTop()>0)
                iframe.height = Math.min(350, parseInt(iframe.height)+body.scrollTop());
            return true;
        });
        
        return tb;
    }
        
    function setSelectedType(node, select) {
        while(node.parentNode) {
            var nName = node.nodeName.toLowerCase();
            for(var i=0;i<select.options.length;i++) {
                if(nName==select.options[i].value){
                    select.selectedIndex=i;
                    return true;
                }
            }
            node = node.parentNode;
        }
        select.selectedIndex=0;
        return true;
    }
    
    function getSelectionElement(iframe) {
        if (iframe.contentWindow.document.selection) {
            // IE selections
            selection = iframe.contentWindow.document.selection;
            range = selection.createRange();
            try {
                node = range.parentElement();
            }
            catch (e) {
                return false;
            }
        } else {
            // Mozilla selections
            try {
                selection = iframe.contentWindow.getSelection();
                range = selection.getRangeAt(0);
            }
            catch(e){
                return false;
            }
            node = range.commonAncestorContainer;
        }
        return node;
    }
}