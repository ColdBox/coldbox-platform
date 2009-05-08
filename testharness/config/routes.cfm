<cfset setEnabled(true)>
<cfset setDebugMode(true)>
<cfset setUniqueURLs(false)>

<cfset setBaseURL("http://#cgi.http_host#/#getSetting('AppMapping')#/index.cfm")>

<!--- CUSTOM COURSES GO HERE (they will be checked in order) --->
<cfset addRoute(pattern="/test/:id-numeric{2}/:num-numeric/:name/:month{3}?",handler="ehGeneral",action="dspHello")>
<cfset addRoute(pattern="test/:id/:name{4}?",handler="ehGeneral",action="dspHello")>

<!--- Views No Events --->
<cfset addRoute(pattern="contactus",view="simpleView")>
<cfset addRoute(pattern="contactus2",view="simpleView",viewnoLayout=true)>

<!--- STANDARD COLDBOX COURSES, DO NOT MODIFY UNLESS YOU DON'T LIKE THEM --->
<cfset addRoute(pattern=":handler/:action?/:id-numeric?",matchVariables="isFound=true,testDate=#now()#")>
<!--- <cfset addRoute(":handler/:action?/:id?")> --->

