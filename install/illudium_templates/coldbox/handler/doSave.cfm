	<%cffunction name="doSave" access="public" returntype="void" output="false"%>
		<%cfargument name="event" type="coldbox.system.beans.requestContext" required="yes"%>
		<%cfscript%>
		//References
		var rc = event.getCollection();
		var oService = getPlugin("ioc").getBean("#root.bean.xmlAttributes.name#Service");
		var o#root.bean.xmlAttributes.name#Bean = "";
		
		//get a new #root.bean.xmlAttributes.name# bean
		o#root.bean.xmlAttributes.name#Bean = oService.get#root.bean.xmlAttributes.name#(0);
		
		//Populate the bean
		getPlugin("beanFactory").populateBean(o#root.bean.xmlAttributes.name#Bean);
				
		//Send to service for saving
		oService.save#root.bean.xmlAttributes.name#(o#root.bean.xmlAttributes.name#Bean);
		
		//Set redirect
		setNextEvent("#root.bean.xmlAttributes.name#.list");
		<%/cfscript%>		
	<%/cffunction%>