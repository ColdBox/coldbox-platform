<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Sana Ullah
Date        :	March 05 2008
Description :
	This proxy is an inherited coldbox remote proxy used for enabling
	coldbox as a model framework.
----------------------------------------------------------------------->

<script type="text/javascript">
    function doLogin() {
        // Create the ajax proxy instance.
        // this will automatically introspect of coldboxproxy.cfc,
        var auth = new coldboxproxy();
        // setForm() implicitly passes the form fields to the CFC function.
        auth.setForm("loginForm");
        //Call the CFC validateCredentials function.
        // auth -> knows list of available functions in coldboxproxy.cfc; so no worries 
        if (auth.validateCredentials()) {
            ColdFusion.Window.hide("loginWindow");
        } else {
            var msg = document.getElementById("loginWindow_title");
            msg.innerHTML = "Incorrect username/password. Please try again!";
        }
    }
</script>

<cfajaxproxy cfc="#rc.locColdBoxProxy#" />

<cfif structKeyExists(URL,"logout") and URL.logout>
    <cflogout />
</cfif>

<cflogin>
    <cfwindow name="loginWindow" center="true" closable="false"
                draggable="false" modal="true" 
                title="Please login to use this system"
                initshow="true" width="400" height="250">
        <!--- Notice that the form does not have a submit button.
            Submission is done by the doLogin function. --->
        <cfform name="loginForm" format="xml">
            <cfinput type="text" name="username" label="username" /><br />
            <cfinput type="password" name="password" label="password" />
            <cfinput type="button" name="login" value="Login!" onclick="doLogin();" />
        </cfform>
		<div id="info-d">
			Try some wrong username for testing<br>
			Correct login info:<br />
			<strong>Username: guest</strong><br/>
			<strong>Password: guest</strong><br />
		</div>
		<div id="LoadingInfo"></div>
    </cfwindow>
</cflogin>