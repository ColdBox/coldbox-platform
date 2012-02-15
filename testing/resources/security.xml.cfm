<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Declare as many rule elements as you want, order is important 
Remember that the securelist can contain a list of regular
expression if you want

ex: All events in the user handler
 user\..*
ex: All events
 .*
ex: All events that start with admin
 ^admin

If you are not using regular expression, just write the text that can be found in an event.

The <match> element determines if it should match an event pattern string or the incoming routed URL.
- event : Matches the secure and white lists against the incoming event syntax string
- url   : Matches the secure and white lists agains the incoming routed URL minus the SES Base URL
-->
<rules>
    <rule>
        <whitelist>user\.login,user\.logout,^main.*</whitelist>
        <securelist>^user\..*, ^admin</securelist>
		<match>event</match>
        <roles>admin</roles>
		<permissions></permissions>
        <redirect>user.login</redirect>
		<useSSL>false</useSSL>
    </rule>
</rules>