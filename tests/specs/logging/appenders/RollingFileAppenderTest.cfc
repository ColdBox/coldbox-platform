<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		props = {filePath=expandPath("/coldbox/testing/cases/logging/tmp"),autoExpand=false,
				 fileMaxArchives=1,fileMaxSize=3};
		//debug(props);
		fileappender = getMockBox().createMock(className="coldbox.system.logging.appenders.RollingFileAppender");
		
		// mock LogBox
		logBox = getMockBox().createMock(classname="coldbox.system.logging.LogBox",clearMethod=true);
		fileAppender.logBox = logBox;
		
		fileappender.init('MyFileAppender',props);
		
		loge = getMockBox().createMock(className="coldbox.system.logging.LogEvent");
		loge.init("Unit Test Sample",0,"","UnitTest");
	}
	function testOnRegistration(){
		fileAppender.onRegistration();	
	}
	function testLogMessage(){
		for(x=0; x lte 50; x++){
			loge.setSeverity(x);
			loge.setCategory("coldbox.system.testing");
			fileappender.logMessage(loge);
		}
		files = dirlist(props.filePath);
		assertTrue( files.recordcount gt 1 );
	}	
</cfscript>

<!--- dirlist --->
<cffunction name="dirlist" output="false" access="private" returntype="query" hint="">
	<cfargument name="dir" type="string" required="true" default="" hint=""/>
	<cfset var qList = "">
	<cfdirectory action="list" directory="#arguments.dir#" name="qList">
	<cfreturn qlist>
</cffunction>
</cfcomponent>