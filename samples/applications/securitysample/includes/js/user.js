/****** ONLOAD: START ******/ 
// Prepare Service Jobfamily.list()
var dsJobfamilyList = new Spry.Data.JSONDataSet(null, {path:"data", pathIsObjectOfArrays :true,useCache: false}); 
/****** ONLOAD: END ******/ 
 
/****** FUNCTIONS: START ******/ 
// Service Call Jobfamily.list()
function jobfamilyList(arguments) { 
	// Service URL
	var url = ajaxGateway + "/jobfamily.cfc?method=listJobfamilyGroup"
	 + "&jfg_id=" + arguments.jfg_id; 
	dsJobfamilyList.setURL(url); 
	// Call Service
	dsJobfamilyList.loadData(); 
} 
/****** FUNCTIONS: END ******/