/*********************************************************************
Author 	 :	Ernst van der Linden
Date     :	7/31/2008
Description : Shows the ColdBox Sidebar 
		
Modification History:
08/10/2008 evdlinden : FireFox problem solved
**********************************************************************/

NS6 = (document.getElementById&&!document.all);
IE = (document.all);
moving=setTimeout('null',1);
	
function moveOut() {
	if ((NS6)&&parseInt(sideBar.left)<0 || IE && sideBar.pixelLeft<0){
		clearTimeout(moving);
		moving = setTimeout('moveOut()', slideSpeed);
		slideSideBar(10);
	}else {
		clearTimeout(moving);
		moving=setTimeout('null',1);
	}
};
function moveBack() {
	clearTimeout(moving);
	moving = setTimeout('moveBack1()', waitTime);
}
function moveBack1() {
	if ((NS6) && parseInt(sideBar.left)>(-sideBarWidth) || IE && sideBar.pixelLeft>(-sideBarWidth)) {
		clearTimeout(moving);
		moving = setTimeout('moveBack1()', slideSpeed);
		slideSideBar(-10);
	} else {
		clearTimeout(moving);
		moving=setTimeout('null',1);
	}
}

function slideSideBar(num){
	if (IE) {
		sideBar.pixelLeft += num;
	}
	if (NS6) {
		sideBar.left = parseInt(sideBar.left)+num+"px";
	}
}

function scrollSideBar() {
	var smooth = 0;
	var windowY = getScrollXY().y;

	if (windowY!=lastWindowY&&windowY>YOffset) {
		smooth = .2 * (windowY - lastWindowY - YOffset);
	}else if (YOffset+lastWindowY>YOffset) {
		smooth = .2 * (windowY - lastWindowY - (YOffset-(YOffset-windowY)));
	} else {
		smooth=0;
	}
	if(smooth > 0){
		 smooth = Math.ceil(smooth);
	}else {
		smooth = Math.floor(smooth);
	}	
	if (IE){
		sideBar.top=parseInt(sideBar.top)+smooth+"px";
	} 
	if (NS6){
		sideBar.top=parseInt(sideBar.top)+smooth+"px";	
	} 
	lastWindowY = lastWindowY+smooth;
	setTimeout('scrollSideBar()', 1)
}

function initSideBar() {
	if (NS6){
		sideBar=document.getElementById("ColdBoxSideBar").style;
		sideBarContainer=document.getElementById("ColdBoxSideBarContainer").style;
		sideBarContainer.clip="rect(0 "+(document.getElementById("ColdBoxSideBar").offsetWidth)+" "+document.getElementById("ColdBoxSideBar").offsetHeight+" 0)";
		sideBar.visibility="visible";
	}
	else if (IE) {
		sideBar=document.all("ColdBoxSideBar").style;
		sideBarContainer=document.all("ColdBoxSideBarContainer").style;
		sideBarContainer.clip="rect(0 "+ColdBoxSideBar.offsetWidth+" "+ColdBoxSideBar.offsetHeight+" 0)";
		sideBarContainer.visibility = "visible";
	}
	if(isScrollSideBar){
		scrollSideBar();
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