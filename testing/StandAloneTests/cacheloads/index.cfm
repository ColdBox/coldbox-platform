<cfscript>
	stime = getTickCount();
	if( structKeyExistS(url,"reinit") or NOT structKeyExists(application,"cachemanager") ){
		mockBox = createObject("component","coldbox.system.testing.MockBox").init();
		mockController = mockBox.createMock(classname="coldbox.system.web.Controller",clearMethods=true);
		mockService = mockBox.createMock(classname="coldbox.system.web.services.InterceptorService",clearMethods=true);
		mockController.$("getInterceptorService",mockService);
		mockService.$("processState");
		
		//create cache
		application.cacheManager = createObject("component","coldbox.system.cache.CacheManager").init(mockController);
		
		//Configure cache
		config = createObject("component","coldbox.system.cache.config.CacheConfig").init("10","10","1","100",0,true,"LRU");
		
		application.cacheManager.configure(config);
	}
	
	cm = application.cachemanager;
	
	//size
	writeOutput("Initial Size: #cm.getSize()# <br>");
	//reap
	cm.reap();
	writeOutput("Reaped Size: #cm.getSize()# <br><br />");
	
	obj = createObject("component","coldbox.testing.testmodel.formBean").init();
		
	//Enter objects
	for(x=1; x lte 150; x=x+1){
		cm.set("obj#x#",obj);
		writeOutput("inserted object: #x# <br/>");
	}
</cfscript>
<cfoutput>
	Size: #cm.getSize()#<br />
	<br /><br />
	Time: #getTickCount()-stime# ms
</cfoutput>
