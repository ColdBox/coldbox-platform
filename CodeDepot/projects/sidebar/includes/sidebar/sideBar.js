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
		clearTimeout(moving);moving=setTimeout('null',1);
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
	if (IE) {sideBar.pixelLeft += num;}
	if (NS6) {sideBar.left = parseInt(sideBar.left)+num+"px";}
}

function initSideBar() {
	if (NS6){
		sideBar=document.getElementById("SideBar").style;
		sideBarContainer=document.getElementById("SideBarContainer").style;
		sideBarContainer.clip="rect(0 "+(document.getElementById("SideBar").offsetWidth)+" "+document.getElementById("SideBar").offsetHeight+" 0)";
		sideBar.visibility="visible";
	}
	else if (IE) {
		sideBar=document.all("SideBar").style;
		sideBarContainer=document.all("SideBarContainer").style;
		sideBarContainer.clip="rect(0 "+SideBar.offsetWidth+" "+SideBar.offsetHeight+" 0)";
		sideBarContainer.visibility = "visible";
	}
}
