<cfoutput>
<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i"><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.primaryKey eq "Yes"><cfset primaryKey = root.bean.dbTable.xmlChildren[i].xmlAttributes.name></cfif></cfloop>
<%cfcomponent name="#root.bean.xmlAttributes.name#" extends="coldbox.system.eventhandler" output="false"%>
	
	<%cffunction name="init" access="public" returntype="#root.bean.xmlAttributes.name#" output="false"%>
		<%cfargument name="controller" type="any" required="true"%>
		<%cfset super.init(arguments.controller)%>
		<!--- Any constructor code here --->
		
		<%cfreturn this%>
	<%/cffunction%>

	<%cffunction name="dspList" access="public" returntype="void" output="false"%>
		<%cfargument name="event" type="coldbox.system.beans.requestContext" required="yes"%>
		<%cfscript%>
		//Get references
		var rc = event.getCollection();
		var oService = getPlugin("ioc").getBean("#root.bean.xmlAttributes.name#Service");
		
		//set The exit handlers
		rc.xehEditor = "#root.bean.xmlAttributes.name#.dspEditor";
		rc.xehDelete = "#root.bean.xmlAttributes.name#.doDelete";
		
		//Get the listing
		rc.q#root.bean.xmlAttributes.name# = oService.get#root.bean.xmlAttributes.name#s() ;
		
		//Sorting Logic.
		if ( event.getValue("sortOrder","") neq ""){
			if (rc.sortOrder eq "asc")
				rc.sortOrder = "desc";
			else
				rc.sortOrder = "asc";
		}
		else{
			rc.sortOrder = "asc";
		}
		if ( event.getValue("sortBy","") neq "" ){
			//Sort via Query Helper.
			rc.q#root.bean.xmlAttributes.name# = getPlugin("queryHelper").sortQuery(rc.q#root.bean.xmlAttributes.name#,rc.sortBy, rc.sortOrder);
		}
		else{
			rc.sortBy = "";
		}
		
		//Set the view to render
		event.setView("#root.bean.xmlAttributes.name#List");
		<%/cfscript%>
	<%/cffunction%>
	
	<%cffunction name="dspEditor" access="public" returntype="void" output="false"%>
		<%cfargument name="event" type="coldbox.system.beans.requestContext" required="yes"%>
		<%cfscript%>
		//References
		var rc = event.getCollection();
		var oService = getPlugin("ioc").getBean("#root.bean.xmlAttributes.name#Service");
		
		//set the exit handlers
		rc.xehSave = "#root.bean.xmlAttributes.name#.doSave";
		rc.xehList = "#root.bean.xmlAttributes.name#.dspList";
		
		//Get #root.bean.xmlAttributes.name# bean with/without ID.
		rc.o#root.bean.xmlAttributes.name#Bean = oService.get#root.bean.xmlAttributes.name#(event.getValue("#primaryKey#","0"));
		
		//Set view to render
		event.setView("#root.bean.xmlAttributes.name#Editor");
		<%/cfscript%>		
	<%/cffunction%>
	
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
		setNextEvent("#root.bean.xmlAttributes.name#.dspList");
		<%/cfscript%>		
	<%/cffunction%>
	
	<%cffunction name="doDelete" access="public" returntype="void" output="false"%>
		<%cfargument name="event" type="coldbox.system.beans.requestContext" required="yes"%>
		<%cfscript%>
		//References
		var rc = event.getCollection();
		var oService = getPlugin("ioc").getBean("#root.bean.xmlAttributes.name#Service");
		
		//Remove via the incoming id
		oService.delete#root.bean.xmlAttributes.name#(rc.#primaryKey#);
		
		//Redirect with message box
		getPlugin("messagebox").setMessage("info","The record was sucessfully deleted");
		setNextEvent("#root.bean.xmlAttributes.name#.dspList");
		<%/cfscript%>		
	<%/cffunction%>	
	
<%/cfcomponent%>
</cfoutput>