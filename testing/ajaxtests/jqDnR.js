/*
 * jqDnR - Minimalistic Drag'n'Resize for jQuery.
 *
 * Copyright (c) 2007 Brice Burgess <bhb@iceburg.net>, http://www.iceburg.net
 * Licensed under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * $Version: 2007.02.09 +r1
 */
(function($){
$.fn.jqDrag=function(r){$.jqDnR.init(this,r,'d'); return this;}
$.fn.jqResize=function(r){$.jqDnR.init(this,r,'r'); return this;}
$.jqDnR={
init:function(w,r,t){ r=(r)?$(r,w):w;
	r.bind('mousedown',{w:w,t:t},function(e){ var h=e.data; var w=h.w;
	hash=$.extend({oX:f(w,'left'),oY:f(w,'top'),oW:f(w,'width'),oH:f(w,'height'),pX:e.pageX,pY:e.pageY,o:w.css('opacity')},h);
	h.w.css('opacity',0.8); $().mousemove($.jqDnR.drag).mouseup($.jqDnR.stop);
	return false;});
},
drag:function(e) {var h=hash; var w=h.w[0];
	if(h.t == 'd') h.w.css({left:h.oX + e.pageX - h.pX,top:h.oY + e.pageY - h.pY});
	else h.w.css({width:Math.max(e.pageX - h.pX + h.oW,0),height:Math.max(e.pageY - h.pY + h.oH,0)});
	return false;},
stop:function(){var j=$.jqDnR; hash.w.css('opacity',hash.o); $().unbind('mousemove',j.drag).unbind('mouseup',j.stop);},
h:false};
var hash=$.jqDnR.h;
var f=function(w,t){return parseInt(w.css(t)) || 0};
})(jQuery);