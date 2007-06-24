/* 
*************************************************************************************************************************************
	30 december : 
		added global js var rememberMe (array)
		added functions updateRememberMe() and checkRememberMe()
		added onclick events to categories/entries boxes
	08 january :
		created init() function and added resetRelatedEntries() function in order to be able to re-call script on 'reset' click
*************************************************************************************************************************************
*/

var field1 = document.editForm.cboRelatedEntriesCats;
var field2 = document.editForm.cboRelatedEntries;

var preselected = 0;

function init() {

	field1.options.length 	= 0;
	field2.options.length 	= 0;
	
	// populate the categories on initial page load
	for (var i=0; i<categoryArray.length; i++) {
		field1.options[field1.options.length] = new Option(categoryArray[i], categoryArray[i]);
	}
	
	// pre-select categories for this post if it already has related entries stored
	for (var i=0; i<rememberCats.length; i++) {
		for (var j=0; j<field1.options.length; j++) {
			if (rememberCats[i] == field1.options[j].value) {
				field1.options[j].selected = true;
				preselected++;
				break;
			}
		}
	}

	if (preselected > 0) {
		doPopulateEntries(0);
		checkRememberEntries();
	}
}

init();

// -------------------------------------------------------------------------------------------- //

function updateRememberEntries() {
	rememberEntries.length = 0;
	for (var i=0; i<field2.options.length; i++) {
		if (field2.options[i].selected == true) {
			rememberEntries[rememberEntries.length] = field2.options[i].value;
		}
	}
}

function checkRememberEntries() {
	// loop over the rememberEntries array
	for (var i=0; i<rememberEntries.length; i++) {
		// loop over the options in the Entries box
		for (var j=0; j<field2.options.length; j++) {
			if (rememberEntries[i] == field2.options[j].value) {
				field2.options[j].selected = true;
				break;
			}
		}
	}
}

function doPopulateEntries(sortBy) {
	// populates the entries with the applicable options based on the selected categories
	
	if (field1.selectedIndex == -1) {
		field2.options.length = 0;	// added on 08 january 2005 to remove all entry options if no categories are selected - cjg
		return false;
	}

	if (sortBy == 0) {
		if (document.getElementById('sortLinkDate').style.color == "rgb(128, 128, 128)") {
			sortBy = "sortByTitle";
		} else {
			sortBy = "sortByDate";
		}
	}
	
	if (sortBy == "sortByTitle") {
		document.getElementById('sortLinkDate').style.color = "rgb(128, 128, 128)";
		document.getElementById('sortLinkTitle').style.color = "rgb(0, 0, 255)";
	} else {
		document.getElementById('sortLinkTitle').style.color = "rgb(128, 128, 128)";
		document.getElementById('sortLinkDate').style.color = "rgb(0, 0, 255)";
	}
	
	var entryArray = new Array();	// to populate the options
	field2.options.length = null;	// clear out the options
	
	for (var i=0; i<field1.options.length; i++) {
		if (field1.options[i].selected) {
			for (var j=0; j<categoryArray[field1.options[i].text].length; j++) {
				apos = entryArray.length;
				entryArray[apos] = new Array(categoryArray[field1.options[i].text][j].ID, categoryArray[field1.options[i].text][j].title + ' (' + categoryArray[field1.options[i].text][j].posted + ')', categoryArray[field1.options[i].text][j].posted);
			}
		}
	}

	// dedupe
	entryArrayDeDuped = new Array();
	
	// seed the deduped array with the first element from the entryArray
	entryArrayDeDuped[0] 	= new Array();
	entryArrayDeDuped[0][0] = entryArray[0][0];		// id
	entryArrayDeDuped[0][1] = entryArray[0][1];		// title
	entryArrayDeDuped[0][2] = entryArray[0][2];		// date
	
	for (var i=1; i<entryArray.length; i++) {
		
		found = 0;
		for (var j=0; j<entryArrayDeDuped.length; j++) {
			if (entryArray[i][0] == entryArrayDeDuped[j][0]) {
				found = 1;
				break;
			}
		}
		
		if (found == 0) {
			thispos = entryArrayDeDuped.length;
			entryArrayDeDuped[thispos] = new Array();
			entryArrayDeDuped[thispos][0] = entryArray[i][0];
			entryArrayDeDuped[thispos][1] = entryArray[i][1];
			
			entryArrayDeDuped[thispos][2] = entryArray[i][2];
		}
	}
	
	// sort the deduped array (w00t!)
	function sortByDate(a,b) {
		if (a[2]>b[2]) {
			return 1;
		} else if (a[2]<b[2]) {
			return -1;
		} else {
			return 0;
		}
	}
	
	function sortByTitle(a,b) {
		if (a[1]>b[1]) {
			return 1;
		} else if (a[1]<b[1]) {
			return -1;
		} else {
			return 0;
		}
	}
	if (sortBy == "sortByTitle") {
		entryArrayDeDuped = entryArrayDeDuped.sort(sortByTitle);
	} else {
		entryArrayDeDuped = entryArrayDeDuped.sort(sortByDate);
	}
		
	for (var i=0; i<entryArrayDeDuped.length; i++) {
		field2.options[field2.options.length] = new Option(entryArrayDeDuped[i][1], entryArrayDeDuped[i][0])
	}
	
	checkRememberEntries();
}

function resetRelatedEntries() {
	init();
	
	rememberEntries.length	= 0;	// added 12 january to clear checked entries and allow a true reset - cjg
	field2.selectedIndex 	= -1;	// added 12 january to clear checked entries and allow a true reset - cjg
	
	// loop over the original entries array
	for (var i=0; i<originalEntries.length; i++) {
		// loop over the options in the Entries box
		for (var j=0; j<field2.options.length; j++) {
			if (originalEntries[i] == field2.options[j].value) {
				field2.options[j].selected = true;
				// break;
			} else {
				field2.options[j].selected = false;
			}
		}
	}
	updateRememberEntries();		// added 12 january to clear checked entries and allow a true reset - cjg
}