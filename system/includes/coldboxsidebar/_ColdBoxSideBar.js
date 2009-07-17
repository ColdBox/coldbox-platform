/*********************************************************************
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Ernst van der Linden ( evdlinden@gmail.com | http://evdlinden.behindthe.net )
Date     :	7/31/2008
Description : JS Functions for the ColdBox Sidebar 
		
Modification History:
08/10/2008 evdlinden : FireFox problem solved
08/13/2008 evdlinden : Total renew; Now you can create a sidebar in the ColdBox namespace.
10/13/2008 evdlinden : added waitTimeBeforeOpen, open and close function
**********************************************************************/

/* ColdBox Namespace */
var cbox;
if (!cbox) cbox = {};

// SideBar					
cbox.SideBar = function(arguments){
	this.init(arguments);
}

cbox.SideBar.prototype.init = function(arguments)
{
	// Needed for FireFox display problem
	var NS6CorrectionX = 10;
	
	// Used to store time out functions. Needs to be in global scope
	this.moving = setTimeout('null',1);

	this.setIsNS6( (document.getElementById&&!document.all) );
	this.setIsIE( (document.all) );
	this.setLastWindowY(0); 
	this.setSlideSpeed(arguments.slideSpeed); 
	this.setWaitTimeBeforeOpen(arguments.waitTimeBeforeOpen);   
	this.setWaitTimeBeforeClose(arguments.waitTimeBeforeClose);   
	this.setYOffset(arguments.yOffset);   
	this.setIsScroll(arguments.isScroll);   
	this.setWidth(arguments.width);   
	
	// Set document element objects used by the side bar
	if ( this.getIsNS6() ){
		this.setSideBarElement( document.getElementById(arguments.elementId) );
		this.setContainerElement( document.getElementById(arguments.containerElementId) );
		// Left correction
		this.getSideBarElement().style.left = parseInt(this.getSideBarElement().style.left) + NS6CorrectionX + "px"; 
		// Width correction
		this.setWidth( (this.getWidth()-NS6CorrectionX) );
		
	} else if ( this.getIsIE() ) {
		this.setSideBarElement( document.all(arguments.elementId) );
		this.setContainerElement( document.all(arguments.containerElementId) );
	}
	
	// Set Container clipping	
	this.getContainerElement().style.clip="rect(0 "+( this.getSideBarElement().offsetWidth )+ " " + this.getSideBarElement().offsetHeight + " 0)";
	// Show side bar
	this.getSideBarElement().style.visibility = "visible";	

	// Scroll enabled?
	if(this.getIsScroll()){
		this.scrollSideBar();
	}	
}
// SideBar Element 
cbox.SideBar.prototype.setSideBarElement = function(sideBarElement){ this.sideBarElement = sideBarElement; }
cbox.SideBar.prototype.getSideBarElement = function(){ return this.sideBarElement}
// Container element
cbox.SideBar.prototype.setContainerElement = function(containerElement){ this.containerElement = containerElement; }
cbox.SideBar.prototype.getContainerElement = function(){ return this.containerElement}
// IE?
cbox.SideBar.prototype.setIsIE = function(isIE){ this.isIE = isIE; }
cbox.SideBar.prototype.getIsIE = function(){ return this.isIE;}
// NS6?
cbox.SideBar.prototype.setIsNS6 = function(isNS6){ this.isNS6 = isNS6; }
cbox.SideBar.prototype.getIsNS6 = function(){ return this.isNS6;}
// Slide Speed
cbox.SideBar.prototype.setSlideSpeed = function(slideSpeed){ this.slideSpeed = slideSpeed; }
cbox.SideBar.prototype.getSlideSpeed = function(){ return this.slideSpeed;}
// Wait Time Open
cbox.SideBar.prototype.setWaitTimeBeforeOpen= function(waitTimeBeforeOpen){ this.waitTimeBeforeOpen = waitTimeBeforeOpen; }
cbox.SideBar.prototype.getWaitTimeBeforeOpen= function(){ return this.waitTimeBeforeOpen;}
// Wait Time Close
cbox.SideBar.prototype.setWaitTimeBeforeClose = function(waitTimeBeforeClose){ this.waitTimeBeforeClose = waitTimeBeforeClose; }
cbox.SideBar.prototype.getWaitTimeBeforeClose = function(){ return this.waitTimeBeforeClose;}
// Y Offset
cbox.SideBar.prototype.setYOffset = function(yOffset){ this.yOffset = yOffset; }
cbox.SideBar.prototype.getYOffset = function(){ return this.yOffset;}
// Scroll?
cbox.SideBar.prototype.setIsScroll = function(isScroll){ this.isScroll = isScroll; }
cbox.SideBar.prototype.getIsScroll = function(){ return this.isScroll;}
// Last Window Y
cbox.SideBar.prototype.setLastWindowY = function(lastWindowY){ this.lastWindowY = lastWindowY; }
cbox.SideBar.prototype.getLastWindowY = function(){ return this.lastWindowY;}
// Width
cbox.SideBar.prototype.setWidth = function(width){ this.width = width; }
cbox.SideBar.prototype.getWidth = function(){ return this.width;}
// Open: wait before moveOut
cbox.SideBar.prototype.open = function(){ 
	var self = this;	
	clearTimeout(this.moving);
	var selfMoveOut = function moveOut(){ self.moveOut(); }
	this.moving = setTimeout(selfMoveOut, this.getWaitTimeBeforeOpen());	
}
// Close
cbox.SideBar.prototype.close = function(){
	this.moveBack();
}
// Move Out
cbox.SideBar.prototype.moveOut = function(){ 
	var self = this;	
	if ( (this.getIsNS6() )&& parseInt( this.getSideBarElement().style.left)<0 || this.getIsIE() && this.getSideBarElement().style.pixelLeft<0){
		clearTimeout(this.moving);
		var selfMoveOut = function moveOut(){ self.moveOut(); }
		this.moving = setTimeout(selfMoveOut, this.getSlideSpeed());
		this.slide(10);
	}else {
		clearTimeout(this.moving);
		this.moving=setTimeout('null',1);
	}
}
// Move Back
cbox.SideBar.prototype.moveBack = function(){
	var self = this;	
	clearTimeout(this.moving);
	var selfMoveBack1 = function moveBack1(){ self.moveBack1(); }
	this.moving = setTimeout(selfMoveBack1, this.getWaitTimeBeforeClose());
}
// Move Back 1
cbox.SideBar.prototype.moveBack1 = function(){
	var self = this;
	if ((this.getIsNS6()) && parseInt(this.getSideBarElement().style.left)>(-this.getWidth()) || this.getIsIE() && this.getSideBarElement().style.pixelLeft>(-this.getWidth())) {
		clearTimeout(this.moving);
		var selfMoveBack1 = function moveBack1(){ self.moveBack1(); }
		this.moving = setTimeout(selfMoveBack1, this.getSlideSpeed());
		this.slide(-10);
	} else {
		clearTimeout(this.moving);
		this.moving=setTimeout('null',1);
	}
}
// Slide
cbox.SideBar.prototype.slide = function(num){
	if (this.getIsIE()) {
		this.getSideBarElement().style.pixelLeft += num;
	}
	if (this.getIsNS6()) {
		this.getSideBarElement().style.left = parseInt(this.getSideBarElement().style.left)+num+"px";
	}
}
// Scroll
cbox.SideBar.prototype.scrollSideBar = function(){
	var self = this;
	var smooth = 0;
	var windowY = getScrollXY().y;

	if (windowY!=this.getLastWindowY()&&windowY > this.getYOffset()) {
		smooth = .2 * (windowY - lastWindowY - this.getYOffset());
	}else if (gthis.etYOffset()+lastWindowY>this.getYOffset()) {
		smooth = .2 * (windowY - lastWindowY - (this.getYOffset()-(this.getYOffset()-windowY)));
	} else {
		smooth=0;
	}
	if(smooth > 0){
		 smooth = Math.ceil(smooth);
	}else {
		smooth = Math.floor(smooth);
	}	
	if (this.getIsIE()){
		this.getSideBarElement().style.top=parseInt(this.getSideBarElement().style.top)+smooth+"px";
	} 
	if (this.isNS6()){
		this.getSideBarElement().style.top=parseInt(this.getSideBarElement().style.top)+smooth+"px";	
	} 
	this.setLastWindowY( (this.getLastWindowY()+smooth));
	var selfScroll = function scroll(){ self.scroll(); }
	setTimeout(selfScroll, 1);
	
	if (this.getIsIE()) {
		this.getSideBarElement().style.pixelLeft += num;
	}
	if (this.getIsNS6()) {
		this.getSideBarElement().style.left = parseInt(this.getSideBarElement().style.left)+num+"px";
	}
}

function getScrollXY() {
  var scrollXY = {x:0,y:0};
  if( typeof( window.pageYOffset ) == 'number' ) {
    //Netscape compliant
    scrollXY.y = window.pageYOffset;
    scrollXY.x = window.pageXOffset;
  } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
    //DOM compliant
    scrollXY.y = document.body.scrollTop;
    scrollXY.x = document.body.scrollLeft;
  } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
    //IE6 standards compliant mode
    scrollXY.y = document.documentElement.scrollTop;
    scrollXY.x = document.documentElement.scrollLeft;
  }
  return scrollXY;
}