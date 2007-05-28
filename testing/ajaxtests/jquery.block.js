/*
 * jQuery blockUI plugin
 * Version 1.00 (02/28/2007)
 * @requires jQuery v1.1.1
 *
 * Examples at: http://malsup.com/jquery/block/
 * Copyright (c) 2007 M. Alsup
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 */
 (function($) {
/**
 * blockUI provides a mechanism for blocking user interaction with a page (or parts of a page).
 * This can be an effective way to simulate synchronous behavior during ajax operations without
 * locking the browser.  It will prevent user operations for the current page while it is
 * active ane will return the page to normal when it is deactivate.  blockUI accepts the following
 * two optional arguments:
 *
 *   message (String|Element|jQuery): The message to be displayed while the UI is blocked. The message
 *              argument can be a plain text string like "Processing...", an HTML string like
 *              "<h1><img src="busy.gif" /> Please wait...</h1>", a DOM element, or a jQuery object.
 *              The default message is "<h1>Please wait...</h1>"
 *
 *   css (Object):  Object which contains css property/values to override the default styles of
 *              the message.  Use this argument if you wish to override the default
 *              styles.  The css Object should be in a format suitable for the jQuery.css
 *              function.  For example:
 *              $.blockUI({
 *                    backgroundColor: '#ff8',
 *                    border: '5px solid #f00,
 *                    fontWeight: 'bold'
 *              });
 *
 * The default blocking message used when blocking the entire page is "<h1>Please wait...</h1>"
 * but this can be overridden by assigning a value to $.blockUI.defaults.pageMessage in your
 * own code.  For example:
 *
 *      $.blockUI.defaults.pageMessage = "<h1>Bitte Wartezeit</h1>";
 *
 * The default message styling can also be overridden.  For example:
 *
 *      $.extend($.blockUI.defaults.pageMessageCSS, { color: '#00a', backgroundColor: '#0f0' });
 *
 * The default styles work well for simple messages like "Please wait", but for longer messages
 * style overrides may be necessary.
 *
 * @example  $.blockUI();
 * @desc prevent user interaction with the page (and show the default message of 'Please wait...')
 *
 * @example  $.blockUI( { backgroundColor: '#f00', color: '#fff'} );
 * @desc prevent user interaction and override the default styles of the message to use a white on red color scheme
 *
 * @example  $.blockUI('Processing...');
 * @desc prevent user interaction and display the message "Processing..." instead of the default message
 *
 * @name blockUI
 * @param String|jQuery|Element message Message to display while the UI is blocked
 * @param Object css Style object to control look of the message
 * @cat Plugins/blockUI
 */
$.blockUI = function(msg, css) {
    $.blockUI.impl.install(window, msg, css);
};

/**
 * unblockUI removes the UI block that was put in place by blockUI
 *
 * @example  $.unblockUI();
 * @desc unblocks the page
 *
 * @name unblockUI
 * @cat Plugins/blockUI
 */
$.unblockUI = function() {
    $.blockUI.impl.remove(window);
};

/**
 * Blocks user interaction with the selected elements.  (Hat tip: Much of
 * this logic comes from Brandon Aaron's bgiframe plugin.  Thanks, Brandon!)
 * By default, no message is displayed when blocking elements.
 *
 * @example  $('div.special').block();
 * @desc prevent user interaction with all div elements with the 'special' class.
 *
 * @example  $('div.special').block('Please wait');
 * @desc prevent user interaction with all div elements with the 'special' class
 * and show a message over the blocked content.
 *
 * @name block
 * @type jQuery
 * @param String|jQuery|Element message Message to display while the element is blocked
 * @param Object css Style object to control look of the message
 * @cat Plugins/blockUI
 */
$.fn.block = function(msg, css) {
    return this.each(function() {
		if (!this.$pos_checked) {
            if ($.css(this,"position") == 'static')
                this.style.position = 'relative';
            this.$pos_checked = 1;
        }
        $.blockUI.impl.install(this, msg, css);
    });
};

/**
 * Unblocks content that was blocked by "block()"
 *
 * @example  $('div.special').unblock();
 * @desc unblocks all div elements with the 'special' class.
 *
 * @name unblock
 * @type jQuery
 * @cat Plugins/blockUI
 */
$.fn.unblock = function() {
    return this.each(function() {
        $.blockUI.impl.remove(this);
    });
};

// override these in your code to change the default messages and styles
$.blockUI.defaults = {
    // the message displayed when blocking the entire page
    pageMessage:    '<h1>Please wait...</h1>',
    // the message displayed when blocking an element
    elementMessage: '', // none
    // styles for the overlay iframe
    overlayCSS:  { backgroundColor: '#fff', opacity: '0.5' },
    // styles for the message when blocking the entire page
    pageMessageCSS:    { width:'250px', margin:'-50px 0 0 -125px', top:'50%', left:'50%', textAlign:'center', color:'#000', backgroundColor:'#fff', border:'3px solid #aaa' },
    // styles for the message when blocking an element
    elementMessageCSS: { width:'250px', padding:'10px', textAlign:'center', backgroundColor:'#fff'}
};

// the gory details
$.blockUI.impl = {
    pageBlock: null,
    op8: window.opera && window.opera.version() < 9,
    ffLinux: $.browser.mozilla && /Linux/.test(navigator.platform),
    ie6: $.browser.msie && typeof XMLHttpRequest == 'function',
    install: function(el, msg, css) {
        var full = (el == window), noalpha = this.op8 || this.ffLinux;
        if (full && this.pageBlock) this.remove(window);
        // check to see if we were only passed the css object (a literal)
        if (msg && typeof msg == 'object' && !msg.jquery && !msg.nodeType) {
            css = msg;
            msg = null;
        }
        msg = msg ? (msg.nodeType ? $(msg) : msg) : full ? $.blockUI.defaults.pageMessage : $.blockUI.defaults.elementMessage;
        var basecss = jQuery.extend({}, full ? $.blockUI.defaults.pageMessageCSS : $.blockUI.defaults.elementMessageCSS);
        css = jQuery.extend(basecss, css || {});
        var f = (this.ie6) ? $('<iframe class="blockUI" style="z-index:1000;border:none;margin:0;padding:0 position:absolute;width:100%;height:100%;top:0;left:0" src="javascript:false;document.write(\'\');"></iframe>')
                           : $('<div class="blockUI" style="display:none"></div>');
        var w = $('<div class="blockUI" style="z-index:1001;cursor:wait;border:none;margin:0;padding:0;width:100%;height:100%;top:0;left:0"></div>');
        var m = full ? $('<div class="blockUI blockMsg" style="z-index:1002;cursor:wait;padding:0;position:fixed"></div>')
                     : $('<div class="blockUI" style="display:none;z-index:1002;cursor:wait;position:absolute"></div>');
        w.css('position', full ? 'fixed' : 'absolute');
        if (msg) m.css(css);
        if (!noalpha) w.css($.blockUI.defaults.overlayCSS);
        if (this.op8) w.css({ width:''+el.clientWidth,height:''+el.clientHeight }); // lame
        if (this.ie6) f.css('opacity','0.0');
        $([f[0],w[0],m[0]]).appendTo(full ? 'body' : el);
        if (full) this.pageBlock = m[0];

        if (this.ie6 || ($.browser.msie && !$.boxModel)) {
            // stretch content area if it's short
            if (full && $.boxModel && document.body.offsetHeight < document.documentElement.clientHeight)
                $('html,body').css('height','100%');
            // simulate fixed position
            $.each([f,w,m], function(i) {
                var s = this[0].style;
                s.position = 'absolute';
                if (i < 2) {
                    full ? s.setExpression('height','document.body.scrollHeight > document.body.offsetHeight ? document.body.scrollHeight : document.body.offsetHeight + "px"')
                         : s.setExpression('height','this.parentNode.offsetHeight + "px"');
                    full ? s.setExpression('width','jQuery.boxModel && document.documentElement.clientWidth || document.body.clientWidth + "px"')
                         : s.setExpression('width','this.parentNode.offsetWidth + "px"');
                }
                else {
                    full ? s.setExpression('top','(document.documentElement.clientHeight || document.body.clientHeight) / 2 - (this.offsetHeight / 2) + (blah = document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop) + "px"')
                         : s.setExpression('top','this.parentNode.top');
                    s.marginTop = 0;
                }
            });
        }
        this.bind(1, el);
        m.append(msg).show();
        if (msg.jquery) msg.show();
        full ? setTimeout(this.focus, 10): this.center(m[0]);
        if (this.op8) this.simulate(true,el);
    },
    remove: function(el) {
        this.bind(0, el);
        var full = el == window;
        if (full) {
            $('body').children().filter('.blockUI').remove();
            this.pageBlock = null;
        }
        else $('.blockUI', el).remove();
        if (this.op8) this.simulate(false,el);
    },
    // event handler to suppress keyboard/mouse events when blocking
    handler: function(e) {
        if (e.keyCode && e.keyCode == 9) return true;
        if ($(e.target).parents('div.blockMsg').length > 0)
            return true;
        return $(e.target).parents().children().filter('div.blockUI').length == 0;
    },
    // bind/unbind the handler
    bind: function(b, el) {
        var full = el == window;
        // don't bother unbinding if there is nothing to unbind
        if (!b && (full && !this.pageBlock || !full && !el.$blocked)) return;
        if (!full) el.$blocked = b;
        var $e = full ? $() : $(el).find('a,:input');
        $.each(['mousedown','mouseup','keydown','keypress','keyup','click'], function(i,o) {
            $e[b?'bind':'unbind'](o, $.blockUI.impl.handler);
        });
    },
    // simulate blocking in opera8
    simulate: function(dis, el) {
        var full = el == window;
        $(':input', full ? 'body' : el).each(function() {
            if (full && $(this).parents('div.blockMsg').length > 0) return;
            if (this.$orig_disabled == undefined)
                this.$orig_disabled = this.disabled;
            var d = dis || this.$orig_disabled;
            if (d) this.$orig_disabled = this.disabled;
            this.disabled = d;
        });
    },
    focus: function() {
        var v = $(':input:visible', $.blockUI.impl.pageBlock)[0];
        if (v) v.focus();
    },
    center: function(el) {
		var p = el.parentNode, s = el.style;
        var l = (this.sz(p,1) - this.sz(el,1))/2, t = (this.sz(p,0) - this.sz(el,0))/2;
        s.left = l > 0 ? (l+'px') : '0';
        s.top  = t > 0 ? (t+'px') : '0';
    },
    sz: function(el, w) { return parseInt($.css(el,(w?"width":"height"))); }
};

})(jQuery);
