<!-----------------------------------------------------------------------Author 	 :	Your NameDate     :	September 25, 2005Description :	coldboxSamples.system.eventhandler-----------------------------------------------------------------------><cfcomponent name="ehGeneral" extends="coldboxSamples.system.eventhandler">	<!---		Constructor Goes Here if Needed		Sample below is a udf library, to be available to all methods.	--->	<!--- ************************************************************* --->	<!---		Remember that the returntype needs to be the same as the cfc name		This method should not be altered, unless you want code to be executed		when this handler is instantiated.	--->	<cffunction name="init" access="public" returntype="Any">		<cfargument name="controller" required="yes" hint="The reference to the framework controller">		<cfset super.init(arguments.controller)>		<cfreturn this>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="onRequestStart" access="public" returntype="void">	<!--- On Request Start Code Here --->	<!---	Security Check	You need to check for the doLogin method, beacuse, if not, the doLogin method	will never get a chance to be called.	So check if the session.loggedin flag exists or not true, and if we	are not logging in.	--->	<cfif (not isDefined("session.loggedin") or not session.loggedin) and not findnocase("doLogin",getValue("event"))>		<!---		Override the current event if not logged in, to go to the login display event		--->		<cfset setValue("event","ehGeneral.dspLogin")>	</cfif>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="onRequestEnd" access="public" returntype="void">	<!--- ON Request End Here --->	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="dspLogin" access="public" returntype="void">	<cfscript>		//Set the page's title		setValue("title", "ColdBox - Sample Login App: Login page");		//Set the view to display		setView("vwLogin");	</cfscript>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="doLogin" access="public" returntype="void">	<cfscript>		//Do Login Procedure.		//Error checks, does the form variables username & password exist		//in the request collection? if they do, are they blank?		if( not valueExists("username") or not valueExists("password") ){			//Set a message to display			getPlugin("messagebox").setMessage("error","No username or password defined.");			//Redirect to next event, you can also add extra parameters to the URL			setNextEvent("ehGeneral.dspLogin","username=#getValue("username")#");		}		else{			//Check the login. Do your own login procedures here.			if ( getvalue("username") eq "admin" and getValue("password") eq "admin" ){				//Login Correct.				//set my session var				session.loggedin = true;				setNextEvent("ehGeneral.dspHome");			}			else{				//Set a message to display				getPlugin("messagebox").setMessage("error","Invalid Logon Information. Please try again");				//Redirect to next event, you can also add extra parameters to the URL				setNextEvent("ehGeneral.dspLogin","username=#getValue("username")#");			}		}	</cfscript>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="dspHome" access="public" returntype="void">	<cfscript>		//Set the page's title		setValue("title", "Sample Login App: Welcome Back");		//Set the view to display		setView("vwHome");	</cfscript>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="doLogout" access="public" returntype="void">	<cfscript>		//Delete login INformation		structdelete(session, "loggedin");		//Set the next event to display		setNextEvent("ehGeneral.dspLogin");	</cfscript>	</cffunction>	<!--- ************************************************************* ---></cfcomponent>